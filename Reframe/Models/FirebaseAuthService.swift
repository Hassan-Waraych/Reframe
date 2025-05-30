import Foundation
import FirebaseAuth
import FirebaseCore

class FirebaseAuthService: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    
    init() {
        setupFirebase()
        setupAuthStateListener()
    }
    
    private func setupFirebase() {
        FirebaseApp.configure()
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            DispatchQueue.main.async {
                self.user = result.user
                self.isAuthenticated = true
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func signUp(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            DispatchQueue.main.async {
                self.user = result.user
                self.isAuthenticated = true
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.user = nil
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
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            DispatchQueue.main.async {
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
} 