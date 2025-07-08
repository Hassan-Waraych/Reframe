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
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    private init() {
        // Ensure Firebase is initialized
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
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
    
    // Email/password authentication is disabled - only social sign-in is available
    func signUp(email: String, password: String) async throws {
        throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Email/password sign up is not available. Please use Google or Apple Sign-In."])
    }
    
    // Email/password authentication is disabled - only social sign-in is available
    func signIn(email: String, password: String) async throws {
        throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Email/password sign in is not available. Please use Google or Apple Sign-In."])
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
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in"])
        }
        
        do {
            // Just try to delete the user directly - if it fails with 17014, we'll handle it
            try await user.delete()
            print("User deletion successful")
            
            // Update local state
            await MainActor.run {
                self.currentUser = nil
                self.isAuthenticated = false
                self.errorMessage = nil
                self.userStatus = .free
            }
        } catch {
            print("User deletion failed with error: \(error)")
            print("Error details: \(error.localizedDescription)")
            
            // Check if we need to re-authenticate
            if let nsError = error as NSError? {
                print("Error code: \(nsError.code)")
                if nsError.code == 17014 {
                    throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Account deletion requires recent authentication. Please sign out and sign back in, then try again."])
                } else if nsError.code == 17020 {
                    throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Network error. Please check your internet connection and try again."])
                } else if nsError.code == 17011 {
                    throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Authentication was canceled."])
                }
            }
            
            throw error
        }
    }
    

    
    // Email/password authentication is disabled - only social sign-in is available
    func resetPassword(email: String) async throws {
        throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Password reset is not available. Please use Google or Apple Sign-In."])
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
            
            // Get the current view controller and configure Google Sign-In on the main thread
            let rootViewController = await MainActor.run {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first,
                      let rootViewController = window.rootViewController else {
                    fatalError("Unable to present sign-in view")
                }
                guard let clientID = FirebaseApp.app()?.options.clientID else {
                    fatalError("Google Sign-In configuration error")
                }
                let config = GIDConfiguration(clientID: clientID)
                GIDSignIn.sharedInstance.configuration = config
                return rootViewController
            }
            
            // Perform Google Sign-In on the main thread
            let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<GIDSignInResult, Error>) in
                Task { @MainActor in
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
                // Provide more user-friendly error messages for Google Sign-In
                let userFriendlyMessage: String
                if let nsError = error as NSError? {
                    switch nsError.code {
                    case -1:
                        if nsError.localizedDescription.contains("main thread") {
                            userFriendlyMessage = "Unable to start Google Sign-In. Please try again."
                        } else {
                            userFriendlyMessage = "Google Sign-In failed. Please try again."
                        }
                    case 17020:
                        userFriendlyMessage = "Network error. Please check your internet connection and try again."
                    case 17011:
                        userFriendlyMessage = "Google Sign-In was canceled."
                    default:
                        userFriendlyMessage = error.localizedDescription
                    }
                } else {
                    userFriendlyMessage = error.localizedDescription
                }
                self.errorMessage = userFriendlyMessage
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
            
            // Perform Apple Sign-In on the main thread
            let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AppleSignInResult, Error>) in
                Task { @MainActor in
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
            }
            
            // Clear the nonce after use
            clearCurrentNonce()
            
            // Get Apple credentials
            guard let appleIDCredential = result.credential as? ASAuthorizationAppleIDCredential,
                  let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to get Apple ID token"])
            }
            
            // Create Firebase credential (use new method signature)
            let credential = OAuthProvider.credential(providerID: AuthProviderID.apple, idToken: idTokenString, rawNonce: result.nonce)
            
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