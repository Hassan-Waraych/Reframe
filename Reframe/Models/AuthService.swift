import Foundation
import FirebaseAuth
import FirebaseCore
import SwiftUI
import FirebaseFirestore
import CoreData
import Reframe

enum UserStatus: String {
    case free = "free"
    case premium = "premium"
}

enum AuthError: Error {
    case emailAlreadyInUse
    case tooManyAccounts
    case deviceLimitReached
    case invalidGuestData
    case conversionFailed
}

class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var userStatus: UserStatus = .free
    @Published var isGuestMode = false
    
    static let shared = AuthService()
    private let localStorage = LocalStorageService.shared
    
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
                    self?.isGuestMode = false
                } else {
                    self?.userStatus = .free
                    // Check for guest profile
                    if let _ = self?.localStorage.getGuestProfile() {
                        self?.isGuestMode = true
                    }
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
            let userId = result.user.uid
            
            // Create user document with default free status
            let db = Firestore.firestore()
            try await db.collection("users").document(userId).setData([
                "userStatus": UserStatus.free.rawValue,
                "createdAt": FieldValue.serverTimestamp()
            ])
            
            // Migrate guest data if it exists
            print("Checking for guest data to migrate")
            if localStorage.getGuestProfile() != nil {
                print("Found guest profile, starting migration")
                try await migrateGuestData(to: userId)
            } else {
                print("No guest profile found, skipping migration")
            }
            
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
    
    // MARK: - Guest Mode
    
    func startGuestMode() {
        if localStorage.getGuestProfile() == nil {
            _ = localStorage.createGuestProfile()
        }
        isGuestMode = true
    }
    
    func convertGuestToRegistered(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            // Check if email is already registered
            let methods = try await Auth.auth().fetchSignInMethods(forEmail: email)
            if !methods.isEmpty {
                throw AuthError.emailAlreadyInUse
            }
            
            // Create new user
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Create user document with default free status
            let db = Firestore.firestore()
            try await db.collection("users").document(result.user.uid).setData([
                "userStatus": UserStatus.free.rawValue,
                "createdAt": FieldValue.serverTimestamp(),
                "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? ""
            ])
            
            // Migrate guest data
            try await migrateGuestData(to: result.user.uid)
            
            // Clear guest data
            localStorage.clearGuestData()
            
            DispatchQueue.main.async {
                self.currentUser = result.user
                self.isAuthenticated = true
                self.isGuestMode = false
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
    
    private func migrateGuestData(to userId: String) async throws {
        print("Starting guest data migration to user ID: \(userId)")
        
        // Get all local data
        let reframes = localStorage.getReframes()
        let journalEntries = localStorage.getJournalEntries()
        let coachMessages = localStorage.getCoachMessages()
        
        print("Found data to migrate:")
        print("- Reframes: \(reframes.count)")
        print("- Journal entries: \(journalEntries.count)")
        print("- Coach messages: \(coachMessages.count)")
        
        let db = Firestore.firestore()
        
        // Migrate reframes
        print("Migrating reframes...")
        for reframe in reframes {
            let reframeData: [String: Any] = [
                "userId": userId,
                "content": reframe.content ?? "",
                "category": reframe.category ?? "",
                "createdAt": reframe.createdAt ?? Date(),
                "helped": reframe.helped
            ]
            print("Saving reframe: \(reframe.id ?? "unknown")")
            try await db.collection("reframes").document(reframe.id ?? UUID().uuidString).setData(reframeData)
        }
        print("Reframes migration complete")
        
        // Migrate journal entries
        print("Migrating journal entries...")
        for entry in journalEntries {
            let entryData: [String: Any] = [
                "userId": userId,
                "content": entry.content ?? "",
                "category": entry.category ?? "",
                "reframeId": entry.reframeId ?? "",
                "createdAt": entry.createdAt ?? Date(),
                "isFavorite": entry.isFavorite
            ]
            print("Saving journal entry: \(entry.id ?? "unknown")")
            try await db.collection("journal_entries").document(entry.id ?? UUID().uuidString).setData(entryData)
        }
        print("Journal entries migration complete")
        
        // Migrate coach messages
        print("Migrating coach messages...")
        for message in coachMessages {
            let messageData: [String: Any] = [
                "userId": userId,
                "content": message.content ?? "",
                "createdAt": message.createdAt ?? Date(),
                "isRead": message.isRead,
                "isFromUser": message.isFromUser
            ]
            print("Saving coach message: \(message.id ?? "unknown")")
            try await db.collection("coach_messages").document(message.id ?? UUID().uuidString).setData(messageData)
        }
        print("Coach messages migration complete")
        
        // Clear local data after successful migration
        print("Clearing local data...")
        localStorage.clearAllReframes()
        localStorage.clearAllJournalEntries()
        localStorage.clearAllCoachMessages()
        localStorage.deleteGuestProfile()
        print("Local data cleared")
        print("Migration complete!")
    }
    
    func createAccount(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let userId = result.user.uid
            
            // Create user document
            let db = Firestore.firestore()
            try await db.collection("users").document(userId).setData([
                "email": email,
                "createdAt": Date(),
                "userStatus": UserStatus.free.rawValue
            ])
            
            // Migrate guest data if it exists
            print("Checking for guest data to migrate")
            if localStorage.getGuestProfile() != nil {
                print("Found guest profile, starting migration")
                try await migrateGuestData(to: userId)
            } else {
                print("No guest profile found, skipping migration")
            }
            
            // Update user status
            userStatus = .free
            
        } catch {
            throw error
        }
    }
} 