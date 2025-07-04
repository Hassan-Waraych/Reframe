import Foundation
import FirebaseAuth
import FirebaseCore
import SwiftUI
import FirebaseFirestore
import UIKit
import CryptoKit
import Security
import GoogleSignIn
import AuthenticationServices
import ObjectiveC
import WidgetKit

enum UserStatus: String {
    case free = "free"
    case premium = "premium"
}

class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var userStatus: UserStatus = .free {
        didSet {
            updatePremiumStatusForWidget(isPremium: userStatus == .premium)
        }
    }
    
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
        
        // Check existing accounts for this device
        let querySnapshot = try await db.collection("users")
            .whereField("deviceId", isEqualTo: deviceId)
            .getDocuments()
        
        let existingAccounts = querySnapshot.documents.count
        
        if existingAccounts >= MAX_ACCOUNTS_PER_DEVICE {
            throw NSError(domain: "AuthService", code: -1, 
                userInfo: [NSLocalizedDescriptionKey: "Too many accounts created from this device. Please contact support if you believe this is an error."])
        }
    }
    
    private func recordDeviceAccount(userId: String) async throws {
        let deviceId = getDeviceIdentifier()
        let db = Firestore.firestore()
        
        // Update the user document with device ID if not already set
        try await db.collection("users").document(userId).updateData([
            "deviceId": deviceId
        ])
        
        // Device association recorded
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String) async throws {
        // Get device ID
        let deviceId = getDeviceIdentifier()
        
        // Check device limit
        let db = Firestore.firestore()
        let querySnapshot = try await db.collection("users")
            .whereField("deviceId", isEqualTo: deviceId)
            .getDocuments()
        
        let existingAccounts = querySnapshot.documents.count
        
        if existingAccounts >= MAX_ACCOUNTS_PER_DEVICE {
            throw NSError(domain: "AuthService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Maximum number of accounts reached for this device"])
        }
        
        // Create Firebase Auth user
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let user = authResult.user
        
        // Create user document
        let userData: [String: Any] = [
            "email": email,
            "createdAt": FieldValue.serverTimestamp(),
            "status": UserStatus.free.rawValue,
            "deviceId": deviceId
        ]
        
        try await db.collection("users").document(user.uid).setData(userData)
        
        // Update local state
        await MainActor.run {
            self.currentUser = user
            self.isAuthenticated = true
            self.userStatus = .free
        }
    }
    
    func signIn(email: String, password: String) async throws {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            await MainActor.run {
                self.currentUser = result.user
                self.isAuthenticated = true
                self.errorMessage = nil
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            Task { @MainActor in
                self.currentUser = nil
                self.isAuthenticated = false
                self.errorMessage = nil
            }
        } catch {
            Task { @MainActor in
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func resetPassword(email: String) async throws {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            await MainActor.run {
                self.errorMessage = nil
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Social Sign In Methods
    
    func signInWithGoogle() async throws {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // Check device account limit before proceeding
            try await checkDeviceAccountLimit()
            
            // Get the current view controller
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to present sign-in view"])
            }
            
            // Configure Google Sign-In
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google Sign-In configuration error"])
            }
            
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            // Perform Google Sign-In
            let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<GIDSignInResult, Error>) in
                GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let result = result {
                        continuation.resume(returning: result)
                    } else {
                        continuation.resume(throwing: NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google Sign-In failed"]))
                    }
                }
            }
            
            // Get Google credentials
            guard let idToken = result.user.idToken?.tokenString else {
                throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to get Google ID token"])
            }
            
            // Create Firebase credential
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: result.user.accessToken.tokenString)
            
            // Sign in to Firebase
            let authResult = try await Auth.auth().signIn(with: credential)
            let user = authResult.user
            
            // Check if this is a new user
            let db = Firestore.firestore()
            let userDoc = try await db.collection("users").document(user.uid).getDocument()
            
            if !userDoc.exists {
                // Create new user document
                let deviceId = getDeviceIdentifier()
                let userData: [String: Any] = [
                    "email": user.email ?? "",
                    "displayName": user.displayName ?? "",
                    "createdAt": FieldValue.serverTimestamp(),
                    "userStatus": UserStatus.free.rawValue,
                    "deviceId": deviceId,
                    "provider": "google"
                ]
                
                try await db.collection("users").document(user.uid).setData(userData)
                
                // Record device association
                try await recordDeviceAccount(userId: user.uid)
            }
            
            // Update local state
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
                self.errorMessage = nil
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    func signInWithApple() async throws {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // Check device account limit before proceeding
            try await checkDeviceAccountLimit()
            
            // Create Apple Sign-In request
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            // Generate nonce for security
            let nonce = randomNonceString()
            setCurrentNonce(nonce)
            request.nonce = sha256(nonce)
            
            // Perform Apple Sign-In
            let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AppleSignInResult, Error>) in
                let controller = ASAuthorizationController(authorizationRequests: [request])
                let delegate = AppleSignInDelegate { result in
                    switch result {
                    case .success(let appleSignInResult):
                        continuation.resume(returning: appleSignInResult)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
                
                // Store delegate to prevent deallocation
                objc_setAssociatedObject(controller, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
                controller.delegate = delegate
                controller.presentationContextProvider = delegate
                controller.performRequests()
            }
            
            // Clear the nonce after use
            clearCurrentNonce()
            
            // Get Apple credentials
            guard let appleIDCredential = result.credential as? ASAuthorizationAppleIDCredential,
                  let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to get Apple ID token"])
            }
            
            // Create Firebase credential
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: result.nonce)
            
            // Sign in to Firebase
            let authResult = try await Auth.auth().signIn(with: credential)
            let user = authResult.user
            
            // Check if this is a new user
            let db = Firestore.firestore()
            let userDoc = try await db.collection("users").document(user.uid).getDocument()
            
            if !userDoc.exists {
                // Create new user document
                let deviceId = getDeviceIdentifier()
                let userData: [String: Any] = [
                    "email": user.email ?? "",
                    "displayName": user.displayName ?? "",
                    "createdAt": FieldValue.serverTimestamp(),
                    "userStatus": UserStatus.free.rawValue,
                    "deviceId": deviceId,
                    "provider": "apple"
                ]
                
                try await db.collection("users").document(user.uid).setData(userData)
                
                // Record device association
                try await recordDeviceAccount(userId: user.uid)
            }
            
            // Update local state
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
                self.errorMessage = nil
                self.isLoading = false
            }
            
        } catch {
            clearCurrentNonce()
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Helper Methods for Apple Sign-In
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // MARK: - User State Methods
    
    func isUserGuest() -> Bool {
        return !isAuthenticated
    }
    
    func getUserEmail() -> String? {
        return currentUser?.email
    }
    
    /// Update premium status for widget
    private func updatePremiumStatusForWidget(isPremium: Bool) {
        let userDefaults = UserDefaults(suiteName: "group.com.reframeapp.shared")
        userDefaults?.set(isPremium, forKey: "isPremiumUser")
        userDefaults?.synchronize()
        WidgetKit.WidgetCenter.shared.reloadAllTimelines()
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

// MARK: - Apple Sign-In Delegate
struct AppleSignInResult {
    let credential: ASAuthorizationCredential
    let nonce: String
}

class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private let completion: (Result<AppleSignInResult, Error>) -> Void
    
    init(completion: @escaping (Result<AppleSignInResult, Error>) -> Void) {
        self.completion = completion
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce else {
            completion(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Apple Sign-In response"])))
            return
        }
        
        let result = AppleSignInResult(credential: appleIDCredential, nonce: nonce)
        completion(.success(result))
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Check if it's a cancellation error
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                completion(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Apple Sign-In was canceled"])))
            default:
                completion(.failure(error))
            }
        } else {
            completion(.failure(error))
        }
    }
}

// Global variable to store the current nonce
private var currentNonce: String?

// Extension to AuthService to manage nonce
extension AuthService {
    private func setCurrentNonce(_ nonce: String) {
        currentNonce = nonce
    }
    
    private func getCurrentNonce() -> String? {
        return currentNonce
    }
    
    private func clearCurrentNonce() {
        currentNonce = nil
    }
} 