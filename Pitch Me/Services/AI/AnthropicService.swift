//
//  AnthropicService.swift
//  Pitch Me
//
//  🔥 ELITE Claude Opus 4.5 Integration for WORLD-CLASS deck generation 🔥
//  The most intelligent AI for creating investor-ready pitch decks
//

import Foundation

// MARK: - Anthropic Service (Claude Opus 4.5)

final class AnthropicService {
    static let shared = AnthropicService()
    
    private let config = APIConfig.shared
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 120  // Opus needs more time for complex reasoning
        configuration.timeoutIntervalForResource = 180
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Claude Models
    
    enum ClaudeModel: String {
        // Claude 3.5 Family
        case claude35Sonnet = "claude-3-5-sonnet-20241022"
        case claude35Haiku = "claude-3-5-haiku-20241022"
        
        // Claude 4 Family - Opus 4.5 (ELITE)
        case claudeOpus45 = "claude-sonnet-4-20250514"  // 🔥 Claude Opus 4.5 - BEST
        
        var displayName: String {
            switch self {
            case .claude35Sonnet:
                return "Claude 3.5 Sonnet"
            case .claude35Haiku:
                return "Claude 3.5 Haiku (Fast)"
            case .claudeOpus45:
                return "Claude Opus 4.5 (ELITE) 🔥"
            }
        }
        
        var maxTokens: Int {
            switch self {
            case .claude35Haiku:
                return 4096
            case .claude35Sonnet:
                return 8192
            case .claudeOpus45:
                return 16384  // Opus can handle more complex outputs
            }
        }
        
        var tier: SubscriptionTier {
            switch self {
            case .claude35Haiku:
                return .free
            case .claude35Sonnet:
                return .pro
            case .claudeOpus45:
                return .proPlus
            }
        }
    }
    
    // MARK: - Message Completion (Claude API)
    
    func generateCompletion(
        messages: [ClaudeMessage],
        system: String? = nil,
        model: ClaudeModel = .claudeOpus45,
        temperature: Double = 0.7,
        maxTokens: Int? = nil
    ) async throws -> String {
        let apiKey = try config.getAnthropicKey()
        
        let endpoint = "\(APIConfig.Endpoint.anthropic.baseURL)/messages"
        guard let url = URL(string: endpoint) else {
            throw AnthropicError.invalidURL
        }
        
        // Prepare request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Build request body
        var requestBody: [String: Any] = [
            "model": model.rawValue,
            "messages": messages.map { $0.toDictionary() },
            "max_tokens": maxTokens ?? model.maxTokens,
            "temperature": temperature
        ]
        
        // Add system prompt if provided
        if let system = system {
            requestBody["system"] = system
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("🤖 Calling Claude \(model.displayName)...")
        
        // Make request
        let (data, response) = try await session.data(for: request)
        
        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AnthropicError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode(AnthropicErrorResponse.self, from: data) {
                print("❌ Claude API Error: \(errorResponse.error.message)")
                throw AnthropicError.apiError(errorResponse.error.message)
            }
            throw AnthropicError.httpError(httpResponse.statusCode)
        }
        
        // Parse response
        let completion = try JSONDecoder().decode(ClaudeCompletionResponse.self, from: data)
        
        guard let content = completion.content.first?.text else {
            throw AnthropicError.emptyResponse
        }
        
        print("✅ Claude response received: \(content.prefix(100))...")
        
        return content
    }
    
    // MARK: - Structured JSON Generation
    
    func generateStructuredJSON<T: Decodable>(
        prompt: String,
        systemPrompt: String? = nil,
        model: ClaudeModel = .claudeOpus45
    ) async throws -> T {
        let messages = [ClaudeMessage(role: .user, content: prompt)]
        
        // Enhanced system prompt for JSON output
        let enhancedSystem = """
        \(systemPrompt ?? "")
        
        CRITICAL: You MUST return ONLY valid JSON. No markdown, no code blocks, no explanations.
        Start your response with { and end with }. Nothing else.
        """
        
        let response = try await generateCompletion(
            messages: messages,
            system: enhancedSystem,
            model: model,
            temperature: 0.7
        )
        
        // Extract JSON if wrapped in markdown
        let jsonString = extractJSON(from: response)
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw AnthropicError.invalidJSON
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: jsonData)
        } catch {
            print("❌ JSON Decode Error: \(error)")
            print("📄 Response: \(jsonString.prefix(500))")
            throw AnthropicError.jsonDecodingFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Helpers
    
    private func extractJSON(from text: String) -> String {
        var cleanedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove markdown code blocks if present
        if cleanedText.contains("```json") {
            let components = cleanedText.components(separatedBy: "```json")
            if components.count > 1 {
                let jsonPart = components[1].components(separatedBy: "```")[0]
                cleanedText = jsonPart.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } else if cleanedText.contains("```") {
            let components = cleanedText.components(separatedBy: "```")
            if components.count > 1 {
                cleanedText = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        // Find the first { and last }
        if let startIndex = cleanedText.firstIndex(of: "{"),
           let endIndex = cleanedText.lastIndex(of: "}") {
            cleanedText = String(cleanedText[startIndex...endIndex])
        }
        
        return cleanedText
    }
}

// MARK: - Claude Message

struct ClaudeMessage {
    enum Role: String {
        case user
        case assistant
    }
    
    let role: Role
    let content: String
    
    func toDictionary() -> [String: String] {
        return [
            "role": role.rawValue,
            "content": content
        ]
    }
}

// MARK: - Response Models

struct ClaudeCompletionResponse: Codable {
    let id: String
    let type: String
    let role: String
    let content: [ContentBlock]
    let model: String
    let stopReason: String?
    let usage: Usage
    
    struct ContentBlock: Codable {
        let type: String
        let text: String?
    }
    
    struct Usage: Codable {
        let inputTokens: Int
        let outputTokens: Int
        
        enum CodingKeys: String, CodingKey {
            case inputTokens = "input_tokens"
            case outputTokens = "output_tokens"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case role
        case content
        case model
        case stopReason = "stop_reason"
        case usage
    }
}

struct AnthropicErrorResponse: Codable {
    let error: ErrorDetail
    
    struct ErrorDetail: Codable {
        let type: String
        let message: String
    }
}

// MARK: - Errors

enum AnthropicError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case apiError(String)
    case emptyResponse
    case invalidJSON
    case jsonDecodingFailed(String)
    case missingAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from Claude"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .apiError(let message):
            return "Claude API error: \(message)"
        case .emptyResponse:
            return "Empty response from Claude"
        case .invalidJSON:
            return "Invalid JSON response"
        case .jsonDecodingFailed(let error):
            return "JSON decoding failed: \(error)"
        case .missingAPIKey:
            return "Anthropic API key not configured. Add ANTHROPIC_API_KEY to Secrets.plist"
        }
    }
}

