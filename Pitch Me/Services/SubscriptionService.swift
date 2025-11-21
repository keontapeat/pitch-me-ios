//
//  SubscriptionService.swift
//  Pitch Me
//
//  Subscription management service
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()
    
    @Published var currentTier: SubscriptionTier = .free
    @Published var subscriptionStatus: SubscriptionStatus?
    @Published var isLoading = false
    
    private init() {
        loadSubscriptionStatus()
    }
    
    // MARK: - Subscription Status
    
    func loadSubscriptionStatus() {
        // Load from UserDefaults for now
        // In production, this would sync with RevenueCat/StoreKit
        if let savedTier = UserDefaults.standard.string(forKey: "subscription_tier"),
           let tier = SubscriptionTier(rawValue: savedTier) {
            currentTier = tier
        }
        
        // Create status
        let decksCreated = UserDefaults.standard.integer(forKey: "decks_created_this_month")
        let lastReset = UserDefaults.standard.object(forKey: "last_reset_date") as? Date ?? Date()
        
        subscriptionStatus = SubscriptionStatus(
            tier: currentTier,
            isActive: true,
            expiresAt: nil, // Would come from payment provider
            decksCreatedThisMonth: decksCreated,
            lastResetDate: lastReset
        )
        
        // Check if we need to reset monthly counter
        checkAndResetMonthlyLimits()
    }
    
    private func checkAndResetMonthlyLimits() {
        guard let status = subscriptionStatus else { return }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Reset if it's a new month
        if !calendar.isDate(status.lastResetDate, equalTo: now, toGranularity: .month) {
            UserDefaults.standard.set(0, forKey: "decks_created_this_month")
            UserDefaults.standard.set(now, forKey: "last_reset_date")
            loadSubscriptionStatus()
        }
    }
    
    // MARK: - Feature Gating
    
    func canAccessFeature(_ feature: Feature) -> Bool {
        switch feature {
        case .createDeck:
            return subscriptionStatus?.canCreateDeck ?? false
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
    
    func incrementDeckCount() {
        let current = UserDefaults.standard.integer(forKey: "decks_created_this_month")
        UserDefaults.standard.set(current + 1, forKey: "decks_created_this_month")
        loadSubscriptionStatus()
    }
    
    // MARK: - Upgrade
    
    func upgradeToPro() async throws {
        isLoading = true
        
        // Simulate purchase flow
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In production, integrate with RevenueCat:
        // let result = try await Purchases.shared.purchase(package: proMonthly)
        
        currentTier = .pro
        UserDefaults.standard.set(SubscriptionTier.pro.rawValue, forKey: "subscription_tier")
        
        loadSubscriptionStatus()
        isLoading = false
    }
    
    func restorePurchases() async throws {
        isLoading = true
        
        // Simulate restore
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In production:
        // let customerInfo = try await Purchases.shared.restorePurchases()
        
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

