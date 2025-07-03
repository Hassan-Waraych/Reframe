import Foundation
import StoreKit
import FirebaseFirestore
import FirebaseAuth

@MainActor
class StoreKitService: ObservableObject {
    static let shared = StoreKitService()
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs = Set<String>()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let productIDs = [
        "com.reframe.premium.monthly",
        "com.reframe.premium.yearly"
    ]
    
    private var updateListenerTask: Task<Void, Error>?
    
    private init() {
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Purchase Methods
    
    func purchase(_ product: Product) async throws {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Check whether the transaction is verified
                switch verification {
                case .verified(let transaction):
                    // Deliver content to the user
                    await updatePurchasedProducts()
                    await syncPurchaseWithFirebase(transaction: transaction)
                    await transaction.finish()
                case .unverified(_, let error):
                    throw error
                }
            case .userCancelled:
                throw StoreKitError.userCancelled
            case .pending:
                throw StoreKitError.pending
            @unknown default:
                throw StoreKitError.unknown
            }
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func restorePurchases() async throws {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Subscription Management
    
    func manageSubscriptions() {
        Task {
            do {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    try await AppStore.showManageSubscriptions(in: windowScene)
                }
            } catch {
                errorMessage = "Failed to open subscription management: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func updatePurchasedProducts() async {
        var purchasedProductIDs = Set<String>()
        
        for await result in StoreKit.Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                purchasedProductIDs.insert(transaction.productID)
            case .unverified:
                break
            }
        }
        
        self.purchasedProductIDs = purchasedProductIDs
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in StoreKit.Transaction.updates {
                switch result {
                case .verified(let transaction):
                    // Deliver content to the user
                    await self.updatePurchasedProducts()
                    await self.syncPurchaseWithFirebase(transaction: transaction)
                    await transaction.finish()
                case .unverified(_, let error):
                    // Handle unverified transaction
                    print("Transaction failed verification: \(error)")
                }
            }
        }
    }
    
    private func syncPurchaseWithFirebase(transaction: StoreKit.Transaction) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        let purchaseData: [String: Any] = [
            "userId": userId,
            "productId": transaction.productID,
            "transactionId": transaction.id,
            "purchaseDate": transaction.purchaseDate,
            "originalTransactionId": transaction.originalID,
            "isUpgraded": transaction.isUpgraded,
            "expirationDate": transaction.expirationDate,
            "revocationDate": transaction.revocationDate,
            "syncDate": FieldValue.serverTimestamp()
        ]
        
        do {
            // Update user status to premium
            try await db.collection("users").document(userId).updateData([
                "userStatus": "premium",
                "premiumPurchaseDate": transaction.purchaseDate,
                "premiumProductId": transaction.productID
            ])
            
            // Log the purchase
            try await db.collection("purchases").addDocument(data: purchaseData)
            
            // Update local auth service
            await MainActor.run {
                AuthService.shared.userStatus = .premium
            }
        } catch {
            print("Failed to sync purchase with Firebase: \(error)")
        }
    }
    
    // MARK: - Public Methods
    
    func isPremium() -> Bool {
        return !purchasedProductIDs.isEmpty
    }
    
    func getMonthlyProduct() -> Product? {
        return products.first { $0.id == "com.reframe.premium.monthly" }
    }
    
    func getYearlyProduct() -> Product? {
        return products.first { $0.id == "com.reframe.premium.yearly" }
    }
}

// MARK: - StoreKit Errors

enum StoreKitError: LocalizedError {
    case userCancelled
    case pending
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .userCancelled:
            return "Purchase was cancelled"
        case .pending:
            return "Purchase is pending approval"
        case .unknown:
            return "An unknown error occurred"
        }
    }
} 