import Foundation
import FirebaseAuth
import FirebaseCore
import SwiftUI
import FirebaseFirestore
import UIKit
import CryptoKit
import Security

enum UserStatus: String {
    case free = "free"
    case premium = "premium"
}

class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var userStatus: UserStatus = .free
    
    static let shared = AuthService()
    private let MAX_ACCOUNTS_PER_DEVICE = 3
    private let DEVICE_ID_KEY = "com.reframe.deviceId"
    
    private init() {
        // Ensure Firebase is initialized
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isAuthenticated = user != nil
                if let user = user {
                    self?.fetchUserStatus(userId: user.uid)
                } else {
                    self?.userStatus = .free
                }
            }
        }
    }
    
    private func fetchUserStatus(userId: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let data = snapshot?.data(),
                   let statusString = data["userStatus"] as? String,
                   let status = UserStatus(rawValue: statusString) {
                    self?.userStatus = status
                } else {
                    // Default to free if no status is set
                    self?.userStatus = .free
                }
            }
        }
    }
    
    func isPremiumUser() -> Bool {
        return userStatus == .premium
    }
    
    // MARK: - Device Identification
    
    private func getDeviceIdentifier() -> String {
        // Try to get existing device ID from Keychain
        if let existingId = getKeychainDeviceId() {
            print("📱 Using existing device ID: \(existingId.prefix(8))...")
            return existingId
        }
        
        // Generate new device ID
        let device = UIDevice.current
        let systemInfo = device.systemName + device.systemVersion + device.model
        let identifier = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let randomString = UUID().uuidString
        
        // Combine with other device-specific data
        let deviceInfo = systemInfo + identifier + randomString
        
        // Hash the combined string for privacy
        let hashedId = deviceInfo.sha256()
        
        // Store in Keychain
        saveKeychainDeviceId(hashedId)
        
        print("📱 Generated new device ID: \(hashedId.prefix(8))...")
        return hashedId
    }
    
    private func getKeychainDeviceId() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: DEVICE_ID_KEY,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let id = String(data: data, encoding: .utf8) {
            return id
        }
        
        return nil
    }
    
    private func saveKeychainDeviceId(_ id: String) {
        guard let data = id.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: DEVICE_ID_KEY,
            kSecValueData as String: data
        ]
        
        // First try to update
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        if status == errSecItemNotFound {
            // If item doesn't exist, add it
            SecItemAdd(query as CFDictionary, nil)
        }
    }
    
    private func checkDeviceAccountLimit() async throws {
        let deviceId = getDeviceIdentifier()
        let db = Firestore.firestore()
        
        // Create a temporary document to check device limit
        let tempDoc = db.collection("device_checks").document()
        try await tempDoc.setData([
            "deviceId": deviceId,
            "timestamp": FieldValue.serverTimestamp()
        ])
        
        // Wait for the cloud function to process and update the document
        let snapshot = try await tempDoc.getDocument()
        guard let data = snapshot.data(),
              let canCreate = data["canCreate"] as? Bool else {
            throw NSError(domain: "AuthService", code: -1, 
                userInfo: [NSLocalizedDescriptionKey: "Unable to verify device limit. Please try again."])
        }
        
        if !canCreate {
            throw NSError(domain: "AuthService", code: -1, 
                userInfo: [NSLocalizedDescriptionKey: "Too many accounts created from this device. Please contact support if you believe this is an error."])
        }
        
        // Clean up the temporary document
        try await tempDoc.delete()
    }
    
    private func recordDeviceAccount(userId: String) async throws {
        let deviceId = getDeviceIdentifier()
        let db = Firestore.firestore()
        
        // Create a temporary document to record the device-account association
        let tempDoc = db.collection("device_records").document()
        try await tempDoc.setData([
            "deviceId": deviceId,
            "userId": userId,
            "timestamp": FieldValue.serverTimestamp()
        ])
        
        // Wait for the cloud function to process and update the document
        let snapshot = try await tempDoc.getDocument()
        guard let data = snapshot.data(),
              let success = data["success"] as? Bool else {
            throw NSError(domain: "AuthService", code: -1, 
                userInfo: [NSLocalizedDescriptionKey: "Unable to record device association. Please try again."])
        }
        
        if !success {
            throw NSError(domain: "AuthService", code: -1, 
                userInfo: [NSLocalizedDescriptionKey: "Failed to record device association. Please try again."])
        }
        
        // Clean up the temporary document
        try await tempDoc.delete()
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String) async throws {
        print("🚀 Starting sign up process for: \(email)")
        
        // Get device ID
        let deviceId = getDeviceIdentifier()
        print("📱 Checking device ID: \(deviceId.prefix(8))...")
        
        // Check device limit
        let db = Firestore.firestore()
        let querySnapshot = try await db.collection("users")
            .whereField("deviceId", isEqualTo: deviceId)
            .getDocuments()
        
        let existingAccounts = querySnapshot.documents.count
        print("📊 Found \(existingAccounts) existing accounts for this device")
        
        if existingAccounts >= MAX_ACCOUNTS_PER_DEVICE {
            print("❌ Device limit reached: \(existingAccounts) accounts")
            throw NSError(domain: "AuthService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Maximum number of accounts reached for this device"])
        }
        
        // Create Firebase Auth user
        print("👤 Creating Firebase Auth user...")
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let user = authResult.user
        
        // Create user document
        print("📝 Creating user document...")
        let userData: [String: Any] = [
            "email": email,
            "createdAt": FieldValue.serverTimestamp(),
            "status": UserStatus.free.rawValue,
            "deviceId": deviceId
        ]
        
        try await db.collection("users").document(user.uid).setData(userData)
        print("✅ User document created successfully")
        
        // Update local state
        await MainActor.run {
            self.currentUser = user
            self.isAuthenticated = true
            self.userStatus = .free
        }
    }
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            DispatchQueue.main.async {
                self.currentUser = result.user
                self.isAuthenticated = true
                self.errorMessage = nil
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
                self.isAuthenticated = false
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func resetPassword(email: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            DispatchQueue.main.async {
                self.errorMessage = nil
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Social Sign In Methods
    
    func signInWithGoogle() async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            // Check device account limit before proceeding
            try await checkDeviceAccountLimit()
            
            // TODO: Implement Google Sign In
            // For now, show a message that it's coming soon
            DispatchQueue.main.async {
                self.errorMessage = "Google Sign In is coming soon!"
                self.isLoading = false
            }
            throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google Sign In is coming soon!"])
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    func signInWithApple() async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            // Check device account limit before proceeding
            try await checkDeviceAccountLimit()
            
            // TODO: Implement Apple Sign In
            // For now, show a message that it's coming soon
            DispatchQueue.main.async {
                self.errorMessage = "Apple Sign In is coming soon!"
                self.isLoading = false
            }
            throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Apple Sign In is coming soon!"])
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - User State Methods
    
    func isUserGuest() -> Bool {
        return !isAuthenticated
    }
    
    func getUserEmail() -> String? {
        return currentUser?.email
    }
}

// MARK: - String Extension for SHA256
extension String {
    func sha256() -> String {
        let data = Data(self.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
} 