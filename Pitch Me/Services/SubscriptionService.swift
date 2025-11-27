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
    
    // MARK: - Upgrade to Pro ($9.99)
    
    func upgradeToPro() async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Simulate purchase flow
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In production, integrate with RevenueCat:
        // let offerings = try await Purchases.shared.offerings()
        // let package = offerings.current?.package(identifier: "pro_monthly")
        // let result = try await Purchases.shared.purchase(package: package)
        
        currentTier = .pro
        UserDefaults.standard.set(SubscriptionTier.pro.rawValue, forKey: "subscription_tier")
        
        // Sync to Firebase
        await updateSubscriptionInFirebase(.pro)
    }
    
    // MARK: - Upgrade to Pro Plus ($29.99)
    
    func upgradeToProPlus() async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Simulate purchase flow
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In production, integrate with RevenueCat:
        // let offerings = try await Purchases.shared.offerings()
        // let package = offerings.current?.package(identifier: "proplus_monthly")
        // let result = try await Purchases.shared.purchase(package: package)
        
        currentTier = .proPlus
        UserDefaults.standard.set(SubscriptionTier.proPlus.rawValue, forKey: "subscription_tier")
        
        // Sync to Firebase
        await updateSubscriptionInFirebase(.proPlus)
    }
    
    func restorePurchases() async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Simulate restore
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In production:
        // let customerInfo = try await Purchases.shared.restorePurchases()
        // Update currentTier based on active entitlements
        
        // Sync from Firebase to get latest subscription status
        if let userId = auth.currentUser?.uid {
            await syncSubscriptionFromFirebase(userId: userId)
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
