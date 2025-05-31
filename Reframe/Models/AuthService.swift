import Foundation
import FirebaseAuth
import FirebaseCore
import SwiftUI

class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    static let shared = AuthService()
    
    private init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        print("Debug: Setting up auth state listener")
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            print("Debug: Auth state changed - User: \(user?.uid ?? "nil")")
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isAuthenticated = user != nil
                print("Debug: Authentication state updated - isAuthenticated: \(self?.isAuthenticated ?? false)")
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String) async throws {
        print("Debug: Attempting to sign up user: \(email)")
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("Debug: User signed up successfully")
            DispatchQueue.main.async {
                self.currentUser = result.user
                self.isAuthenticated = true
                self.errorMessage = nil
                self.isLoading = false
            }
        } catch {
            print("Debug: Sign up error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws {
        print("Debug: Attempting to sign in user: \(email)")
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("Debug: User signed in successfully")
            DispatchQueue.main.async {
                self.currentUser = result.user
                self.isAuthenticated = true
                self.errorMessage = nil
                self.isLoading = false
            }
        } catch {
            print("Debug: Sign in error: \(error.localizedDescription)")
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