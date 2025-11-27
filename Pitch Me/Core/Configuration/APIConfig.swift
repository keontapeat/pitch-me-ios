//
//  APIConfig.swift
//  Pitch Me
//
//  Secure API configuration management
//  🔥 Supports OpenAI, Anthropic (Claude Opus 4.5), and Gemini
//

import Foundation

// MARK: - API Configuration

final class APIConfig {
    static let shared = APIConfig()
    
    // MARK: - API Keys (loaded from secure storage)
    
    private(set) var openAIKey: String?
    private(set) var anthropicKey: String?  // 🔥 Claude Opus 4.5
    private(set) var geminiKey: String?
    
    // MARK: - API Endpoints
    
    enum Endpoint {
        case openAI
        case anthropic  // 🔥 Claude/Anthropic
        case gemini
        
        var baseURL: String {
            switch self {
            case .openAI:
                return "https://api.openai.com/v1"
            case .anthropic:
                return "https://api.anthropic.com/v1"
            case .gemini:
                return "https://generativelanguage.googleapis.com/v1beta"
            }
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        loadAPIKeys()
    }
    
    // MARK: - Load API Keys
    
    private func loadAPIKeys() {
        // Try to load from Secrets.plist first (local development)
        if let plistKeys = loadFromPlist() {
            self.openAIKey = plistKeys.openAI
            self.anthropicKey = plistKeys.anthropic
            self.geminiKey = plistKeys.gemini
            print("✅ API keys loaded from Secrets.plist")
            if plistKeys.anthropic != nil {
                print("🔥 Claude Opus 4.5 key detected!")
            }
            return
        }
        
        // Try environment variables (for CI/CD)
        if let envKeys = loadFromEnvironment() {
            self.openAIKey = envKeys.openAI
            self.anthropicKey = envKeys.anthropic
            self.geminiKey = envKeys.gemini
            print("✅ API keys loaded from environment")
            return
        }
        
        // Warning if no keys found
        print("⚠️ No API keys found. Add Secrets.plist or set environment variables.")
    }
    
    // MARK: - Load from Plist
    
    private func loadFromPlist() -> (openAI: String?, anthropic: String?, gemini: String?)? {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: String] else {
            return nil
        }
        
        return (
            openAI: dict["OPENAI_API_KEY"],
            anthropic: dict["ANTHROPIC_API_KEY"],  // 🔥 Claude key
            gemini: dict["GEMINI_API_KEY"]
        )
    }
    
    // MARK: - Load from Environment
    
    private func loadFromEnvironment() -> (openAI: String?, anthropic: String?, gemini: String?)? {
        let openAI = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
        let anthropic = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"]
        let gemini = ProcessInfo.processInfo.environment["GEMINI_API_KEY"]
        
        guard openAI != nil || anthropic != nil || gemini != nil else {
            return nil
        }
        
        return (openAI: openAI, anthropic: anthropic, gemini: gemini)
    }
    
    // MARK: - Validation
    
    var hasOpenAIKey: Bool {
        guard let key = openAIKey else { return false }
        return !key.isEmpty && key.hasPrefix("sk-")
    }
    
    var hasAnthropicKey: Bool {
        guard let key = anthropicKey else { return false }
        return !key.isEmpty && key.hasPrefix("sk-ant-")
    }
    
    var hasGeminiKey: Bool {
        guard let key = geminiKey else { return false }
        return !key.isEmpty
    }
    
    /// Returns true if we have any AI service configured
    var hasAnyAIKey: Bool {
        hasAnthropicKey || hasOpenAIKey || hasGeminiKey
    }
    
    /// Returns the best available AI provider (prefers Gemini for SPEED 🔥)
    var preferredAIProvider: AIProvider {
        if hasGeminiKey { return .gemini }     // 🔥 FASTEST - Use first!
        if hasOpenAIKey { return .openAI }     // Good fallback
        if hasAnthropicKey { return .anthropic } // Claude as backup
        return .none
    }
    
    // MARK: - Public API
    
    func getOpenAIKey() throws -> String {
        guard let key = openAIKey, !key.isEmpty else {
            throw APIConfigError.missingKey("OpenAI API key not configured")
        }
        return key
    }
    
    func getAnthropicKey() throws -> String {
        guard let key = anthropicKey, !key.isEmpty else {
            throw APIConfigError.missingKey("Anthropic API key not configured. Add ANTHROPIC_API_KEY to Secrets.plist")
        }
        return key
    }
    
    func getGeminiKey() throws -> String {
        guard let key = geminiKey, !key.isEmpty else {
            throw APIConfigError.missingKey("Gemini API key not configured")
        }
        return key
    }
}

// MARK: - AI Provider

enum AIProvider: String {
    case anthropic = "Claude Opus 4.5"  // 🔥 ELITE
    case openAI = "OpenAI GPT-4"
    case gemini = "Google Gemini"
    case none = "None"
    
    var displayName: String { rawValue }
    
    var icon: String {
        switch self {
        case .anthropic: return "brain.head.profile"
        case .openAI: return "cpu"
        case .gemini: return "sparkles"
        case .none: return "exclamationmark.triangle"
        }
    }
}

// MARK: - Errors

enum APIConfigError: Error, LocalizedError {
    case missingKey(String)
    case invalidKey(String)
    
    var errorDescription: String? {
        switch self {
        case .missingKey(let message):
            return message
        case .invalidKey(let message):
            return message
        }
    }
}

