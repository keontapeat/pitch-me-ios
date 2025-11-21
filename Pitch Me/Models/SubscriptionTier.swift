//
//  SubscriptionTier.swift
//  Pitch Me
//
//  Subscription tier and pricing models
//

import Foundation

// MARK: - Subscription Tier

enum SubscriptionTier: String, Codable {
    case free = "free"
    case pro = "pro"
    case enterprise = "enterprise"
    
    var displayName: String {
        switch self {
        case .free: return "Free"
        case .pro: return "Pro"
        case .enterprise: return "Enterprise"
        }
    }
    
    var monthlyPrice: String {
        switch self {
        case .free: return "$0"
        case .pro: return "$29"
        case .enterprise: return "Custom"
        }
    }
    
    var yearlyPrice: String? {
        switch self {
        case .free: return nil
        case .pro: return "$249"  // Save $99/year
        case .enterprise: return "Custom"
        }
    }
    
    // Feature limits
    var maxDecksPerMonth: Int {
        switch self {
        case .free: return 3
        case .pro: return 100
        case .enterprise: return .max
        }
    }
    
    var maxSlidesPerDeck: Int {
        switch self {
        case .free: return 10
        case .pro: return 30
        case .enterprise: return .max
        }
    }
    
    var canUploadDocuments: Bool {
        switch self {
        case .free: return false
        case .pro, .enterprise: return true
        }
    }
    
    var canUseAdvancedAI: Bool {
        switch self {
        case .free: return false
        case .pro, .enterprise: return true
        }
    }
    
    var canExportToPowerPoint: Bool {
        switch self {
        case .free: return false
        case .pro, .enterprise: return true
        }
    }
    
    var canExportToGoogleSlides: Bool {
        switch self {
        case .free: return false
        case .pro, .enterprise: return true
        }
    }
    
    var canExportToPDF: Bool {
        true // All tiers can export to PDF
    }
    
    var hasAIFeedback: Bool {
        switch self {
        case .free: return false
        case .pro, .enterprise: return true
        }
    }
    
    var hasPrioritySupport: Bool {
        switch self {
        case .free: return false
        case .pro, .enterprise: return true
        }
    }
    
    var hasCustomBranding: Bool {
        switch self {
        case .free, .pro: return false
        case .enterprise: return true
        }
    }
    
    var features: [String] {
        switch self {
        case .free:
            return [
                "\(maxDecksPerMonth) decks per month",
                "Up to \(maxSlidesPerDeck) slides per deck",
                "3 beautiful themes",
                "PDF export",
                "AI-powered generation",
                "Community support"
            ]
        case .pro:
            return [
                "Unlimited decks",
                "Up to \(maxSlidesPerDeck) slides per deck",
                "All premium themes",
                "Upload company documents",
                "Advanced AI (GPT-4/5)",
                "PowerPoint & Google Slides export",
                "AI story feedback",
                "Priority support",
                "No watermarks"
            ]
        case .enterprise:
            return [
                "Everything in Pro",
                "Unlimited slides",
                "Custom branding",
                "Team collaboration",
                "API access",
                "Dedicated account manager",
                "Custom integrations",
                "SLA guarantee"
            ]
        }
    }
}

// MARK: - Subscription Status

struct SubscriptionStatus: Codable {
    let tier: SubscriptionTier
    let isActive: Bool
    let expiresAt: Date?
    let decksCreatedThisMonth: Int
    let lastResetDate: Date
    
    var canCreateDeck: Bool {
        guard isActive else { return false }
        return decksCreatedThisMonth < tier.maxDecksPerMonth
    }
    
    var remainingDecks: Int {
        max(0, tier.maxDecksPerMonth - decksCreatedThisMonth)
    }
    
    var needsRenewal: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }
}

// MARK: - Product IDs (for RevenueCat / StoreKit)

enum ProductID: String {
    case proMonthly = "com.pitchme.pro.monthly"
    case proYearly = "com.pitchme.pro.yearly"
    case enterpriseCustom = "com.pitchme.enterprise"
    
    var displayName: String {
        switch self {
        case .proMonthly: return "Pro Monthly"
        case .proYearly: return "Pro Yearly"
        case .enterpriseCustom: return "Enterprise"
        }
    }
    
    var price: String {
        switch self {
        case .proMonthly: return "$29/month"
        case .proYearly: return "$249/year"
        case .enterpriseCustom: return "Contact sales"
        }
    }
    
    var savingsText: String? {
        switch self {
        case .proYearly: return "Save $99/year"
        default: return nil
        }
    }
}

