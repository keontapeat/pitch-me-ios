//
//  SubscriptionService.swift
//  Pitch Me
//
//  AGGRESSIVE subscription management - Force them to pay! 💰
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()
    
    @Published var currentTier: SubscriptionTier = .free
    @Published var isLoading = false
    
    private init() {
        loadSubscriptionTier()
    }
    
    // MARK: - Subscription Status
    
    func loadSubscriptionTier() {
        // Load from UserDefaults for now
        // In production, this would sync with RevenueCat/StoreKit
        if let savedTier = UserDefaults.standard.string(forKey: "subscription_tier"),
           let tier = SubscriptionTier(rawValue: savedTier) {
            currentTier = tier
        }
    }
    
    // MARK: - Feature Gating (AGGRESSIVE)
    
    func canAccessFeature(_ feature: Feature) -> Bool {
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
        
        // Simulate purchase flow
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In production, integrate with RevenueCat:
        // let offerings = try await Purchases.shared.offerings()
        // let package = offerings.current?.package(identifier: "pro_monthly")
        // let result = try await Purchases.shared.purchase(package: package)
        
        currentTier = .pro
        UserDefaults.standard.set(SubscriptionTier.pro.rawValue, forKey: "subscription_tier")
        
        isLoading = false
    }
    
    // MARK: - Upgrade to Pro Plus ($29.99)
    
    func upgradeToProPlus() async throws {
        isLoading = true
        
        // Simulate purchase flow
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In production, integrate with RevenueCat:
        // let offerings = try await Purchases.shared.offerings()
        // let package = offerings.current?.package(identifier: "proplus_monthly")
        // let result = try await Purchases.shared.purchase(package: package)
        
        currentTier = .proPlus
        UserDefaults.standard.set(SubscriptionTier.proPlus.rawValue, forKey: "subscription_tier")
        
        isLoading = false
    }
    
    func restorePurchases() async throws {
        isLoading = true
        
        // Simulate restore
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In production:
        // let customerInfo = try await Purchases.shared.restorePurchases()
        // Update currentTier based on active entitlements
        
        isLoading = false
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
