//
//  AppConfig.swift
//  Pitch Me
//
//  🔥 App Store Ready Configuration 🔥
//  Central configuration for URLs, app info, and settings
//

import Foundation

// MARK: - App Configuration

struct AppConfig {
    // MARK: - App Info
    
    static let appName = "Pitch Me"
    static let appTagline = "AI-Powered Pitch Decks That Win"
    static let appDescription = "Create investor-ready pitch decks in minutes with Claude Opus 4.5 AI"
    
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    static var fullVersion: String {
        "\(appVersion) (\(buildNumber))"
    }
    
    // MARK: - URLs (Update before App Store submission!)
    
    /// Privacy Policy URL - REQUIRED for App Store
    static let privacyPolicyURL = URL(string: "https://pitchme.app/privacy")!
    
    /// Terms of Service URL - REQUIRED for App Store
    static let termsOfServiceURL = URL(string: "https://pitchme.app/terms")!
    
    /// Support Email
    static let supportEmail = "support@pitchme.app"
    
    /// Support URL
    static let supportURL = URL(string: "https://pitchme.app/support")!
    
    /// App Store URL (update after first release)
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



