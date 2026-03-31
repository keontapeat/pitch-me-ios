//
//  StoreKitService.swift
//  Pitch Me
//
//  🔥 REAL StoreKit 2 In-App Purchase Engine 🔥
//  Handles all subscription purchases, renewals, and restores
//

import Foundation
import StoreKit
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

// MARK: - StoreKit Service

@MainActor
final class StoreKitService: ObservableObject {
    static let shared = StoreKitService()

    // MARK: - Published State

    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Product IDs (must match App Store Connect exactly)

    enum ProductID: String, CaseIterable {
        case proMonthly     = "com.pitchme.pro.monthly"
        case proYearly      = "com.pitchme.pro.yearly"
        case proPlusMonthly = "com.pitchme.proplus.monthly"
        case proPlusYearly  = "com.pitchme.proplus.yearly"

        var tier: SubscriptionTier {
            switch self {
            case .proMonthly, .proYearly:         return .pro
            case .proPlusMonthly, .proPlusYearly: return .proPlus
            }
        }
    }

    private var transactionUpdatesTask: Task<Void, Never>?
    private let db = Firestore.firestore()

    // MARK: - Init

    private init() {
        transactionUpdatesTask = Task {
            await listenForTransactionUpdates()
        }
    }

    deinit {
        transactionUpdatesTask?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            let ids = ProductID.allCases.map { $0.rawValue }
            let storeProducts = try await Product.products(for: ids)
            products = storeProducts.sorted { $0.price < $1.price }
            print("✅ Loaded \(products.count) StoreKit products")
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            print("❌ StoreKit product load error: \(error)")
        }

        isLoading = false
        await refreshPurchasedProducts()
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> Bool {
        isLoading = true
        defer { isLoading = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await handleSuccessfulTransaction(transaction)
            await transaction.finish()
            return true

        case .userCancelled:
            return false

        case .pending:
            print("⏳ Purchase pending (Ask to Buy or payment issue)")
            return false

        @unknown default:
            return false
        }
    }

    // MARK: - Purchase by Product ID

    func purchaseProduct(id: ProductID) async throws -> Bool {
        guard let product = products.first(where: { $0.id == id.rawValue }) else {
            throw StoreKitError.productNotFound(id.rawValue)
        }
        return try await purchase(product)
    }

    // MARK: - Restore Purchases

    func restorePurchases() async throws {
        isLoading = true
        defer { isLoading = false }

        // StoreKit 2: sync with App Store
        try await AppStore.sync()
        await refreshPurchasedProducts()
        print("✅ Purchases restored")
    }

    // MARK: - Refresh Purchased Products

    func refreshPurchasedProducts() async {
        var newPurchasedIDs: Set<String> = []

        for await result in StoreKit.Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                if transaction.revocationDate == nil {
                    newPurchasedIDs.insert(transaction.productID)
                }
            }
        }

        purchasedProductIDs = newPurchasedIDs
        await syncTierFromPurchases(newPurchasedIDs)
    }

    // MARK: - Current Subscription Tier

    var currentTier: SubscriptionTier {
        // Admin accounts always get Pro Plus
        if AppConfig.currentUserIsAdmin { return .proPlus }
        // Check Pro Plus first (higher tier)
        if purchasedProductIDs.contains(ProductID.proPlusMonthly.rawValue) ||
           purchasedProductIDs.contains(ProductID.proPlusYearly.rawValue) {
            return .proPlus
        }
        // Check Pro
        if purchasedProductIDs.contains(ProductID.proMonthly.rawValue) ||
           purchasedProductIDs.contains(ProductID.proYearly.rawValue) {
            return .pro
        }
        return .free
    }

    // MARK: - Get Product for Display

    func product(for id: ProductID) -> Product? {
        products.first { $0.id == id.rawValue }
    }

    func displayPrice(for id: ProductID) -> String {
        guard let product = product(for: id) else {
            // Fallback to hardcoded prices while products load
            switch id {
            case .proMonthly:     return "$9.99/mo"
            case .proYearly:      return "$79/yr"
            case .proPlusMonthly: return "$29.99/mo"
            case .proPlusYearly:  return "$249/yr"
            }
        }
        return product.displayPrice
    }

    // MARK: - Transaction Listener

    private func listenForTransactionUpdates() async {
        for await result in StoreKit.Transaction.updates {
            if let transaction = try? checkVerified(result) {
                await handleSuccessfulTransaction(transaction)
                await transaction.finish()
            }
        }
    }

    // MARK: - Handle Successful Transaction

    private func handleSuccessfulTransaction(_ transaction: StoreKit.Transaction) async {
        purchasedProductIDs.insert(transaction.productID)

        // Determine tier from product ID
        let tier: SubscriptionTier
        if transaction.productID == ProductID.proPlusMonthly.rawValue ||
           transaction.productID == ProductID.proPlusYearly.rawValue {
            tier = .proPlus
        } else if transaction.productID == ProductID.proMonthly.rawValue ||
                  transaction.productID == ProductID.proYearly.rawValue {
            tier = .pro
        } else {
            tier = .free
        }

        // Sync with SubscriptionService
        SubscriptionService.shared.currentTier = tier
        UserDefaults.standard.set(tier.rawValue, forKey: "subscription_tier")

        // Sync to Firebase
        await syncTierToFirebase(tier)

        print("✅ Transaction processed: \(transaction.productID) → \(tier.displayName)")
    }

    // MARK: - Firebase Sync

    private func syncTierFromPurchases(_ productIDs: Set<String>) async {
        // Never downgrade an admin account
        if AppConfig.currentUserIsAdmin {
            SubscriptionService.shared.currentTier = .proPlus
            return
        }
        let tier = currentTier
        SubscriptionService.shared.currentTier = tier
        UserDefaults.standard.set(tier.rawValue, forKey: "subscription_tier")
        await syncTierToFirebase(tier)
    }

    private func syncTierToFirebase(_ tier: SubscriptionTier) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        do {
            try await db.collection("users").document(userId).updateData([
                "subscriptionTier": tier.rawValue,
                "subscriptionUpdatedAt": FieldValue.serverTimestamp()
            ])
        } catch {
            print("⚠️ Firebase tier sync failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Verification

    private func checkVerified<T>(_ result: StoreKit.VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - StoreKit Errors

enum StoreKitError: LocalizedError {
    case productNotFound(String)
    case purchaseFailed(String)
    case verificationFailed

    var errorDescription: String? {
        switch self {
        case .productNotFound(let id):
            return "Product not found: \(id). Check App Store Connect setup."
        case .purchaseFailed(let message):
            return "Purchase failed: \(message)"
        case .verificationFailed:
            return "Purchase verification failed. Please contact support."
        }
    }
}
