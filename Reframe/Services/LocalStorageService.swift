import Foundation
import CoreData
import SwiftUI

// Notification names for local storage updates
extension Notification.Name {
    static let localJournalEntryUpdated = Notification.Name("localJournalEntryUpdated")
    static let localReframeUpdated = Notification.Name("localReframeUpdated")
    static let localCoachMessageUpdated = Notification.Name("localCoachMessageUpdated")
}

class LocalStorageService {
    static let shared = LocalStorageService()
    
    private let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "ReframeLocal")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Context Management
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error saving context: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Guest User Management
    
    func createGuestProfile() -> String {
        let guestId = UUID().uuidString
        let context = viewContext
        
        let guestProfile = GuestProfile(context: context)
        guestProfile.id = guestId
        guestProfile.createdAt = Date()
        guestProfile.deviceId = UIDevice.current.identifierForVendor?.uuidString
        
        saveContext()
        return guestId
    }
    
    func getGuestProfile() -> GuestProfile? {
        let context = viewContext
        let request: NSFetchRequest<GuestProfile> = GuestProfile.fetchRequest()
        
        do {
            let profiles = try context.fetch(request)
            return profiles.first
        } catch {
            print("Error fetching guest profile: \(error.localizedDescription)")
            return nil
        }
    }
    
    func clearGuestData() {
        let context = viewContext
        
        // Delete all local data
        let entities = container.managedObjectModel.entities
        entities.forEach { entity in
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            do {
                try context.execute(deleteRequest)
            } catch {
                print("Error deleting \(entity.name ?? ""): \(error.localizedDescription)")
            }
        }
        
        saveContext()
    }
    
    // MARK: - Data Management
    
    func saveReframe(originalThought: String, reframedThought: String, category: String) -> String {
        let reframeId = UUID().uuidString
        let context = viewContext
        
        let reframe = LocalReframe(context: context)
        reframe.id = reframeId
        reframe.content = "Original Thought: \(originalThought)\n\nReframed Thought: \(reframedThought)"
        reframe.category = category
        reframe.createdAt = Date()
        reframe.isSynced = false
        reframe.helped = false
        
        if let guestProfile = getGuestProfile() {
            reframe.userId = guestProfile.id
        }
        
        saveContext()
        return reframeId
    }
    
    func saveJournalEntry(content: String, category: String = "Reflection", reframeId: String? = nil) -> String {
        let entryId = UUID().uuidString
        let entry = LocalJournalEntry(context: viewContext)
        entry.id = entryId
        entry.content = content
        entry.createdAt = Date()
        entry.isSynced = false
        entry.isFavorite = false
        entry.category = category
        entry.reframeId = reframeId
        
        if let guestProfile = getGuestProfile() {
            entry.userId = guestProfile.id
        }
        
        saveContext()
        NotificationCenter.default.post(name: .localJournalEntryUpdated, object: nil)
        return entryId
    }
    
    func saveCoachMessage(content: String, isFromUser: Bool, coachId: String) -> String {
        let messageId = UUID().uuidString
        let context = viewContext
        
        let message = LocalCoachMessage(context: context)
        message.id = messageId
        message.content = content
        message.isFromUser = isFromUser
        message.coachId = coachId
        message.createdAt = Date()
        message.isSynced = false
        
        if let guestProfile = getGuestProfile() {
            message.userId = guestProfile.id
        }
        
        saveContext()
        return messageId
    }
    
    func getLocalReframes() -> [LocalReframe] {
        let context = viewContext
        let request: NSFetchRequest<LocalReframe> = LocalReframe.fetchRequest()
        
        if let guestProfile = getGuestProfile() {
            request.predicate = NSPredicate(format: "userId == %@", guestProfile.id ?? "")
        }
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching local reframes: \(error.localizedDescription)")
            return []
        }
    }
    
    func getLocalJournalEntries() -> [LocalJournalEntry] {
        let context = viewContext
        let request: NSFetchRequest<LocalJournalEntry> = LocalJournalEntry.fetchRequest()
        
        if let guestProfile = getGuestProfile() {
            request.predicate = NSPredicate(format: "userId == %@", guestProfile.id ?? "")
        }
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching local journal entries: \(error.localizedDescription)")
            return []
        }
    }
    
    func getLocalCoachMessages() -> [LocalCoachMessage] {
        let context = viewContext
        let request: NSFetchRequest<LocalCoachMessage> = LocalCoachMessage.fetchRequest()
        
        if let guestProfile = getGuestProfile() {
            request.predicate = NSPredicate(format: "userId == %@", guestProfile.id ?? "")
        }
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching local coach messages: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Reframe Operations
    
    func deleteReframe(id: String) {
        let context = viewContext
        let request: NSFetchRequest<LocalReframe> = LocalReframe.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            if let reframe = try context.fetch(request).first {
                context.delete(reframe)
                saveContext()
            }
        } catch {
            print("Error deleting reframe: \(error.localizedDescription)")
        }
    }
    
    func updateReframe(id: String, helped: Bool) {
        let context = viewContext
        let request: NSFetchRequest<LocalReframe> = LocalReframe.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            if let reframe = try context.fetch(request).first {
                reframe.helped = helped
                saveContext()
            }
        } catch {
            print("Error updating reframe: \(error.localizedDescription)")
        }
    }
    
    func clearAllReframes() {
        let request: NSFetchRequest<LocalReframe> = LocalReframe.fetchRequest()
        
        do {
            let reframes = try viewContext.fetch(request)
            for reframe in reframes {
                viewContext.delete(reframe)
            }
            saveContext()
        } catch {
            print("Error clearing reframes: \(error)")
        }
    }
    
    // MARK: - Journal Entry Operations
    
    func updateJournalEntry(id: String, isFavorite: Bool) {
        let request: NSFetchRequest<LocalJournalEntry> = LocalJournalEntry.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            if let entry = try viewContext.fetch(request).first {
                entry.isFavorite = isFavorite
                entry.isSynced = false
                saveContext()
                NotificationCenter.default.post(name: .localJournalEntryUpdated, object: nil)
            }
        } catch {
            print("Error updating journal entry: \(error)")
        }
    }
    
    func deleteJournalEntry(id: String) {
        let request: NSFetchRequest<LocalJournalEntry> = LocalJournalEntry.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            if let entry = try viewContext.fetch(request).first {
                viewContext.delete(entry)
                saveContext()
                NotificationCenter.default.post(name: .localJournalEntryUpdated, object: nil)
            }
        } catch {
            print("Error deleting journal entry: \(error)")
        }
    }
    
    func clearAllJournalEntries() {
        let request: NSFetchRequest<LocalJournalEntry> = LocalJournalEntry.fetchRequest()
        
        do {
            let entries = try viewContext.fetch(request)
            for entry in entries {
                viewContext.delete(entry)
            }
            saveContext()
            NotificationCenter.default.post(name: .localJournalEntryUpdated, object: nil)
        } catch {
            print("Error clearing journal entries: \(error)")
        }
    }
    
    // MARK: - Data Cleanup
    
    func clearAllCoachMessages() {
        let request: NSFetchRequest<LocalCoachMessage> = LocalCoachMessage.fetchRequest()
        
        do {
            let messages = try viewContext.fetch(request)
            for message in messages {
                viewContext.delete(message)
            }
            saveContext()
        } catch {
            print("Error clearing coach messages: \(error)")
        }
    }
    
    func deleteGuestProfile() {
        let request: NSFetchRequest<GuestProfile> = GuestProfile.fetchRequest()
        
        do {
            if let profile = try viewContext.fetch(request).first {
                viewContext.delete(profile)
                saveContext()
            }
        } catch {
            print("Error deleting guest profile: \(error)")
        }
    }
    
    // MARK: - Data Retrieval Methods
    
    func getReframes() -> [LocalReframe] {
        let request: NSFetchRequest<LocalReframe> = LocalReframe.fetchRequest()
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching reframes: \(error)")
            return []
        }
    }
    
    func getJournalEntries() -> [LocalJournalEntry] {
        let request: NSFetchRequest<LocalJournalEntry> = LocalJournalEntry.fetchRequest()
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching journal entries: \(error)")
            return []
        }
    }
    
    func getCoachMessages() -> [LocalCoachMessage] {
        let request: NSFetchRequest<LocalCoachMessage> = LocalCoachMessage.fetchRequest()
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching coach messages: \(error)")
            return []
        }
    }
} 