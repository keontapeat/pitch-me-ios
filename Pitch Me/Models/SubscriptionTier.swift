//
//  SubscriptionTier.swift
//  Pitch Me
//
//  AGGRESSIVE PRICING - Make them pay! 💰
//

import Foundation

// MARK: - Subscription Tier

enum SubscriptionTier: String, Codable {
    case free = "free"
    case pro = "pro"
    case proPlus = "proPlus"
    case enterprise = "enterprise"
    
    var displayName: String {
        switch self {
        case .free: return "Free"
        case .pro: return "Pro"
        case .proPlus: return "Pro Plus"
        case .enterprise: return "Enterprise"
        }
    }
    
    var monthlyPrice: String {
        switch self {
        case .free: return "$0"
        case .pro: return "$9.99"
        case .proPlus: return "$29.99"
        case .enterprise: return "Custom"
        }
    }
    
    var yearlyPrice: String {
        switch self {
        case .free: return "$0"
        case .pro: return "$79"
        case .proPlus: return "$249"
        case .enterprise: return "Custom"
        }
    }
    
    // AGGRESSIVE LIMITS
    var maxDecksTotal: Int {
        switch self {
        case .free: return 1  // Only 1 deck EVER (forces upgrade immediately)
        case .pro: return .max
        case .proPlus: return .max
        case .enterprise: return .max
        }
    }
    
    var maxSlidesPerDeck: Int {
        switch self {
        case .free: return 8  // Too small for real pitch
        case .pro: return 20
        case .proPlus: return 30
        case .enterprise: return .max
        }
    }
    
    var canUploadDocuments: Bool {
        switch self {
        case .free: return false  // Free users must use manual input
        case .pro: return true    // 🔥 Pro gets document upload!
        case .proPlus: return true
        case .enterprise: return true
        }
    }
    
    var canUseAdvancedAI: Bool {
        switch self {
        case .free: return false  // Basic AI only
        case .pro: return true  // Better AI
        case .proPlus: return true  // Elite AI
        case .enterprise: return true
        }
    }
    
    var usesEliteAI: Bool {
        switch self {
        case .free: return false
        case .pro: return false
        case .proPlus: return true  // GPT-4/5 + Gemini 2.0
        case .enterprise: return true
        }
    }
    
    var canExportToPowerPoint: Bool {
        switch self {
        case .free: return false  // PDF only with watermark
        case .pro: return true
        case .proPlus: return true
        case .enterprise: return true
        }
    }
    
    var canExportToGoogleSlides: Bool {
        switch self {
        case .free: return false
        case .pro: return false
        case .proPlus: return true  // Only Pro Plus
        case .enterprise: return true
        }
    }
    
    var canExportToPDF: Bool {
        true  // All tiers
    }
    
    var hasWatermark: Bool {
        switch self {
        case .free: return true  // BIG WATERMARK
        case .pro: return false
        case .proPlus: return false
        case .enterprise: return false
        }
    }
    
    var hasAIFeedback: Bool {
        switch self {
        case .free: return false
        case .pro: return false
        case .proPlus: return true  // Accelerator scoring
        case .enterprise: return true
        }
    }
    
    var canAccessAcceleratorTemplates: Bool {
        switch self {
        case .free: return false
        case .pro: return false
        case .proPlus: return true  // YC, NVIDIA templates
        case .enterprise: return true
        }
    }
    
    var hasPrioritySupport: Bool {
        switch self {
        case .free: return false
        case .pro: return true
        case .proPlus: return true
        case .enterprise: return true
        }
    }
    
    var hasCustomBranding: Bool {
        switch self {
        case .free, .pro, .proPlus: return false
        case .enterprise: return true
        }
    }
    
    var features: [String] {
        switch self {
        case .free:
            return [
                "1 deck total (trial)",
                "Up to 8 slides per deck",
                "PDF export with watermark",
                "1 theme",
                "Basic AI generation",
                "Manual input only"
            ]
        case .pro:
            return [
                "✨ Unlimited decks",
                "📄 Document upload & analysis",
                "Up to 20 slides per deck",
                "🤖 GPT-4o AI generation",
                "Export to PDF + PowerPoint",
                "10 premium themes",
                "No watermarks",
                "Email support"
            ]
        case .proPlus:
            return [
                "Everything in Pro",
                "🔥 Claude Opus 4.5 (ELITE AI)",
                "Up to 30 slides per deck",
                "Export to Google Slides",
                "All 20+ premium themes",
                "🎯 AI story feedback & scoring",
                "🚀 Accelerator templates (YC, NVIDIA)",
                "Priority support (24h response)"
            ]
        case .enterprise:
            return [
                "Everything in Pro Plus",
                "Team collaboration",
                "API access",
                "White-label option",
                "Dedicated account manager",
                "SLA guarantee"
            ]
        }
    }
}

// MARK: - Product IDs (for RevenueCat / StoreKit)

enum ProductID: String {
    case proMonthly = "com.pitchme.pro.monthly"
    case proYearly = "com.pitchme.pro.yearly"
    case proPlusMonthly = "com.pitchme.proplus.monthly"
    case proPlusYearly = "com.pitchme.proplus.yearly"
    case enterpriseCustom = "com.pitchme.enterprise"
    
    var displayName: String {
        switch self {
        case .proMonthly: return "Pro Monthly"
        case .proYearly: return "Pro Yearly"
        case .proPlusMonthly: return "Pro Plus Monthly"
        case .proPlusYearly: return "Pro Plus Yearly"
        case .enterpriseCustom: return "Enterprise"
        }
    }
    
    var price: String {
        switch self {
        case .proMonthly: return "$9.99/month"
        case .proYearly: return "$79/year"
        case .proPlusMonthly: return "$29.99/month"
        case .proPlusYearly: return "$249/year"
        case .enterpriseCustom: return "Contact sales"
        }
    }
    
    var savingsText: String? {
        switch self {
        case .proYearly: return "Save $40/year"
        case .proPlusYearly: return "Save $110/year"
        default: return nil
        }
    }
}
