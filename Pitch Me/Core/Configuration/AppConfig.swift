//
//  AppConfig.swift
//  Pitch Me
//
//  🔥 App Store Ready Configuration 🔥
//  Central configuration for URLs, app info, and settings
//
//  ⚠️ APP STORE SUBMISSION CHECKLIST:
//  1. ✅ Update privacyPolicyURL to your real privacy policy
//  2. ✅ Update termsOfServiceURL to your real terms
//  3. ✅ Update supportEmail to your real support email
//  4. ✅ Create App Store Connect listing with these URLs
//  5. ✅ Set up RevenueCat/StoreKit with product IDs below
//  6. ✅ Add app screenshots (6.7", 6.5", 5.5" iPhone + iPad)
//  7. ✅ Update appStoreURL after app is live
//

import Foundation
import FirebaseAuth

// MARK: - App Configuration

struct AppConfig {
    // MARK: - App Info
    
    static let appName = "Pitch Me"
    static let appTagline = "AI-Powered Pitch Decks That Win"
    static let appDescription = "Create investor-ready pitch decks in minutes with AI"
    
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    static var fullVersion: String {
        "\(appVersion) (\(buildNumber))"
    }
    
    // MARK: - URLs (⚠️ UPDATE BEFORE APP STORE SUBMISSION!)
    
    /// Privacy Policy URL - REQUIRED for App Store
    /// ⚠️ You MUST host a privacy policy page before submission
    static let privacyPolicyURL = URL(string: "https://pitchme.app/privacy")!
    
    /// Terms of Service URL - REQUIRED for App Store (especially for IAP)
    /// ⚠️ You MUST host a terms of service page before submission
    static let termsOfServiceURL = URL(string: "https://pitchme.app/terms")!
    
    /// Support Email - Required for App Store
    static let supportEmail = "support@pitchme.app"
    
    /// Support URL - Required for App Store
    static let supportURL = URL(string: "https://pitchme.app/support")!
    
    /// App Store URL (update after first release with your app ID)
    static let appStoreURL = URL(string: "https://apps.apple.com/app/pitch-me/id0000000000")!
    
    /// Website URL
    static let websiteURL = URL(string: "https://pitchme.app")!
    
    // MARK: - Social Media
    
    static let twitterHandle = "@pitchmeapp"
    static let twitterURL = URL(string: "https://twitter.com/pitchmeapp")!
    
    // MARK: - Feature Flags
    
    /// Enable AI-powered features
    static let aiEnabled = true
    
    /// Enable accelerator templates (YC, NVIDIA)
    static let acceleratorTemplatesEnabled = true
    
    /// Enable export features
    static let exportEnabled = true
    
    /// Enable analytics (Mixpanel, Amplitude, etc.)
    static let analyticsEnabled = true
    
    /// Enable crash reporting (Sentry, Crashlytics)
    static let crashReportingEnabled = true
    
    // MARK: - Limits
    
    /// Maximum slides per deck for free tier
    static let freeMaxSlides = 8
    
    /// Maximum slides per deck for pro tier
    static let proMaxSlides = 20
    
    /// Maximum slides per deck for pro plus tier
    static let proPlusMaxSlides = 30
    
    /// Maximum file upload size (MB)
    static let maxUploadSizeMB = 50
    
    /// Maximum text extraction characters
    static let maxTextExtractionChars = 50_000
    
    // MARK: - AI Configuration
    
    /// Default AI model for free tier
    static let freeAIModel = "claude-3-5-haiku-20241022"
    
    /// Default AI model for pro tier
    static let proAIModel = "gpt-4o"
    
    /// Default AI model for pro plus tier (ELITE)
    static let proPlusAIModel = "claude-sonnet-4-20250514"  // Claude Opus 4.5
    
    /// AI request timeout (seconds)
    static let aiRequestTimeout: TimeInterval = 120
    
    // MARK: - Cache Configuration
    
    /// How long to cache generated decks (hours)
    static let deckCacheHours = 24
    
    /// Maximum cached decks
    static let maxCachedDecks = 50
    
    // MARK: - Admin / Owner Accounts
    
    /// Owner/admin emails — these accounts always get Pro Plus, no purchase required.
    static let adminEmails: Set<String> = [
        "keontapeat@icloud.com",
        "keontapeat@gmail.com",
        "keonta@pitchme.app",
    ]
    
    /// Returns true if the signed-in Firebase UID belongs to an admin account.
    /// Checks email via FirebaseAuth — works without knowing the UID in advance.
    static func isAdminUID(_ uid: String) -> Bool {
        guard let currentUser = FirebaseAuth.Auth.auth().currentUser,
              currentUser.uid == uid,
              let email = currentUser.email else { return false }
        return adminEmails.contains(email.lowercased())
    }
    
    /// Convenience — check the currently signed-in user.
    static var currentUserIsAdmin: Bool {
        guard let user = FirebaseAuth.Auth.auth().currentUser,
              let email = user.email else { return false }
        return adminEmails.contains(email.lowercased())
    }
    
    // MARK: - Debug
    
    #if DEBUG
    static let isDebug = true
    #else
    static let isDebug = false
    #endif
}

// MARK: - Environment

enum AppEnvironment {
    case development
    case staging
    case production
    
    static var current: AppEnvironment {
        #if DEBUG
        return .development
        #else
        // Could also check for staging builds via configuration
        return .production
        #endif
    }
    
    var baseAPIURL: String {
        switch self {
        case .development:
            return "https://dev-api.pitchme.app"
        case .staging:
            return "https://staging-api.pitchme.app"
        case .production:
            return "https://api.pitchme.app"
        }
    }
}




