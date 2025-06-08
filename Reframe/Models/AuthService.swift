import Foundation
import FirebaseAuth
import FirebaseCore
import SwiftUI
import FirebaseFirestore

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
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Create user document with default free status
            let db = Firestore.firestore()
            try await db.collection("users").document(result.user.uid).setData([
                "userStatus": UserStatus.free.rawValue,
                "createdAt": FieldValue.serverTimestamp()
            ])
            
            DispatchQueue.main.async {
                self.currentUser = result.user
                self.isAuthenticated = true
                self.userStatus = .free
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
        
        // TODO: Implement Google Sign In
        // For now, show a message that it's coming soon
        DispatchQueue.main.async {
            self.errorMessage = "Google Sign In is coming soon!"
            self.isLoading = false
        }
        throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google Sign In is coming soon!"])
    }
    
    func signInWithApple() async throws {
        isLoading = true
        errorMessage = nil
        
        // TODO: Implement Apple Sign In
        // For now, show a message that it's coming soon
        DispatchQueue.main.async {
            self.errorMessage = "Apple Sign In is coming soon!"
            self.isLoading = false
        }
        throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Apple Sign In is coming soon!"])
    }
    
    // MARK: - User State Methods
    
    func isUserGuest() -> Bool {
        return !isAuthenticated
    }
    
    func getUserEmail() -> String? {
        return currentUser?.email
    }
} 