//
//  StoreManager.swift
//  Controlla
//
//  Handles StoreKit 2 subscriptions and Pro status
//

import Foundation
import StoreKit

@MainActor
class StoreManager: ObservableObject {

    // MARK: - Published Properties
    @Published var isPro: Bool = false
    @Published var isLoading: Bool = false
    @Published var products: [Product] = []
    @Published var purchasedSubscriptions: [Product] = []

    // MARK: - Product IDs
    // NOTE: These must match your App Store Connect configuration
    private let monthlySubscriptionID = "com.controlla.pro.monthly"

    // MARK: - Transaction Updates
    private var updateListenerTask: Task<Void, Error>? = nil

    // MARK: - Initialization
    init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()

        Task {
            await loadProducts()
            await updateProStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Product Loading
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Load products from App Store
            let productIDs = [monthlySubscriptionID]
            let loadedProducts = try await Product.products(for: productIDs)

            DispatchQueue.main.async {
                self.products = loadedProducts
                print("✅ Loaded \(loadedProducts.count) products")
            }
        } catch {
            print("❌ Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase
    func purchase(_ product: Product) async throws -> Bool {
        isLoading = true
        defer { isLoading = false }

        // Start purchase
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            // Verify the transaction
            let transaction = try StoreManager.checkVerified(verification)

            // Update Pro status
            await updateProStatus()

            // Finish the transaction
            await transaction.finish()

            print("✅ Purchase successful")
            return true

        case .userCancelled:
            print("ℹ️ User cancelled purchase")
            return false

        case .pending:
            print("⏳ Purchase pending")
            return false

        @unknown default:
            print("⚠️ Unknown purchase result")
            return false
        }
    }

    // MARK: - Restore Purchases
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Sync with App Store
            try await AppStore.sync()

            // Update Pro status
            await updateProStatus()

            print("✅ Purchases restored")
        } catch {
            print("❌ Failed to restore purchases: \(error)")
        }
    }

    // MARK: - Pro Status
    func updateProStatus() async {
        var isProUser = false

        // Check for active subscriptions
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try StoreManager.checkVerified(result)

                // Check if this is our Pro subscription
                if transaction.productID == monthlySubscriptionID {
                    isProUser = true
                    break
                }
            } catch {
                print("❌ Transaction verification failed: \(error)")
            }
        }

        DispatchQueue.main.async {
            self.isPro = isProUser
            print(self.isPro ? "✅ User is Pro" : "ℹ️ User is Free")
        }
    }

    // MARK: - Transaction Listener
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Listen for transaction updates
            for await result in Transaction.updates {
                do {
                    let transaction = try StoreManager.checkVerified(result)

                    // Update Pro status when transactions change
                    Task { @MainActor in
                        await self.updateProStatus()
                    }

                    // Finish the transaction
                    await transaction.finish()
                } catch {
                    print("❌ Transaction verification failed: \(error)")
                }
            }
        }
    }

    // MARK: - Transaction Verification
    nonisolated static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Store Errors
enum StoreError: Error {
    case failedVerification
}
