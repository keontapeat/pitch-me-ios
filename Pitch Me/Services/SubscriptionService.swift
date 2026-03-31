//
//  SubscriptionService.swift
//  Pitch Me
//
//  🔥 PRODUCTION-READY Subscription Management 🔥
//  Handles in-app purchases with RevenueCat integration + Firebase sync
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()
    
    @Published var currentTier: SubscriptionTier = .free
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    // ⚠️ PRODUCTION MODE - Debug features DISABLED for App Store
    // Set to true ONLY during local development/testing
    #if DEBUG
    static let debugUnlockAllFeatures = false  // 🔥 FALSE for App Store submission!
    #else
    static let debugUnlockAllFeatures = false  // Always false in Release builds
    #endif
    
    private init() {
        loadSubscriptionTier()
        setupAuthListener()
    }
    
    // MARK: - Auth State Listener
    
    private func setupAuthListener() {
        authStateHandle = auth.addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                if let user = user {
                    await self?.syncSubscriptionFromFirebase(userId: user.uid)
                } else {
                    self?.currentTier = .free
                }
            }
        }
    }
    
    // MARK: - Firebase Sync
    
    private func syncSubscriptionFromFirebase(userId: String) async {
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            
            if let data = document.data(),
               let tierString = data["subscriptionTier"] as? String,
               let tier = SubscriptionTier(rawValue: tierString) {
                self.currentTier = tier
                UserDefaults.standard.set(tier.rawValue, forKey: "subscription_tier")
                print("✅ Subscription synced from Firebase: \(tier.rawValue)")
            }
        } catch {
            print("⚠️ Could not sync subscription from Firebase: \(error.localizedDescription)")
            // Fall back to local storage
            loadSubscriptionTier()
        }
    }
    
    private func updateSubscriptionInFirebase(_ tier: SubscriptionTier) async {
        guard let userId = auth.currentUser?.uid else { return }
        
        do {
            try await db.collection("users").document(userId).updateData([
                "subscriptionTier": tier.rawValue,
                "subscriptionUpdatedAt": FieldValue.serverTimestamp()
            ])
            print("✅ Subscription updated in Firebase: \(tier.rawValue)")
        } catch {
            print("⚠️ Could not update subscription in Firebase: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Subscription Status
    
    func loadSubscriptionTier() {
        // Load from UserDefaults as fallback/cache
        if let savedTier = UserDefaults.standard.string(forKey: "subscription_tier"),
           let tier = SubscriptionTier(rawValue: savedTier) {
            currentTier = tier
        }
    }
    
    // MARK: - Feature Gating (AGGRESSIVE)
    
    func canAccessFeature(_ feature: Feature) -> Bool {
        // 🔥 DEBUG MODE: Bypass all subscription checks for testing
        #if DEBUG
        if Self.debugUnlockAllFeatures {
            return true  // All features unlocked during development!
        }
        #endif
        
        switch feature {
        case .createDeck:
            // Free users can only create 1 deck TOTAL (not per month)
            let totalDecks = totalDecksCreated
            return totalDecks < currentTier.maxDecksTotal
        case .uploadDocuments:
            return currentTier.canUploadDocuments
        case .advancedAI:
            return currentTier.canUseAdvancedAI
        case .exportPowerPoint:
            return currentTier.canExportToPowerPoint
        case .exportGoogleSlides:
            return currentTier.canExportToGoogleSlides
        case .exportPDF:
            return currentTier.canExportToPDF
        case .aiFeedback:
            return currentTier.hasAIFeedback
        case .prioritySupport:
            return currentTier.hasPrioritySupport
        }
    }
    
    // Total decks created EVER (for free tier limit)
    var totalDecksCreated: Int {
        UserDefaults.standard.integer(forKey: "decks_created_total")
    }
    
    func incrementDeckCount() {
        let current = totalDecksCreated
        UserDefaults.standard.set(current + 1, forKey: "decks_created_total")
    }
    
    // Remaining decks for current tier
    var remainingDecks: Int {
        let total = totalDecksCreated
        let limit = currentTier.maxDecksTotal
        if limit == .max {
            return .max
        }
        return max(0, limit - total)
    }
    
    // MARK: - Upgrade to Pro ($9.99/mo) — Real StoreKit 2
    
    func upgradeToPro(yearly: Bool = false) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let productId: StoreKitService.ProductID = yearly ? .proYearly : .proMonthly
        let purchased = try await StoreKitService.shared.purchaseProduct(id: productId)
        
        if purchased {
            currentTier = .pro
            UserDefaults.standard.set(SubscriptionTier.pro.rawValue, forKey: "subscription_tier")
            await updateSubscriptionInFirebase(.pro)
            print("✅ Pro subscription activated!")
        }
    }
    
    // MARK: - Upgrade to Pro Plus ($29.99/mo) — Real StoreKit 2
    
    func upgradeToProPlus(yearly: Bool = false) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let productId: StoreKitService.ProductID = yearly ? .proPlusYearly : .proPlusMonthly
        let purchased = try await StoreKitService.shared.purchaseProduct(id: productId)
        
        if purchased {
            currentTier = .proPlus
            UserDefaults.standard.set(SubscriptionTier.proPlus.rawValue, forKey: "subscription_tier")
            await updateSubscriptionInFirebase(.proPlus)
            print("✅ Pro Plus subscription activated!")
        }
    }
    
    func restorePurchases() async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Real StoreKit 2 restore
        try await StoreKitService.shared.restorePurchases()
        
        // Pick up refreshed tier from StoreKit
        let restoredTier = StoreKitService.shared.currentTier
        currentTier = restoredTier
        UserDefaults.standard.set(restoredTier.rawValue, forKey: "subscription_tier")
        await updateSubscriptionInFirebase(restoredTier)
        
        print("✅ Purchases restored: \(restoredTier.displayName)")
    }
    
    // MARK: - Initialize StoreKit on launch
    
    func initializeStoreKit() {
        Task {
            await StoreKitService.shared.loadProducts()
            // Override local cache with verified StoreKit entitlements
            let verifiedTier = StoreKitService.shared.currentTier
            if verifiedTier != .free || currentTier == .free {
                currentTier = verifiedTier
                UserDefaults.standard.set(verifiedTier.rawValue, forKey: "subscription_tier")
            }
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        if let handle = authStateHandle {
            auth.removeStateDidChangeListener(handle)
        }
    }
}

// MARK: - Feature Enum

enum Feature {
    case createDeck
    case uploadDocuments
    case advancedAI
    case exportPowerPoint
    case exportGoogleSlides
    case exportPDF
    case aiFeedback
    case prioritySupport
}
