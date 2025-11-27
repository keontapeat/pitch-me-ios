//
//  OpenAIService.swift
//  Pitch Me
//
//  OpenAI GPT-4/5 integration for ELITE deck generation
//

import Foundation

// MARK: - OpenAI Service

final class OpenAIService {
    static let shared = OpenAIService()
    
    private let config = APIConfig.shared
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 120
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Chat Completion (GPT-4/5)
    
    func generateChatCompletion(
        messages: [ChatMessage],
        model: GPTModel = .gpt4Turbo,
        temperature: Double = 0.7,
        maxTokens: Int = 4096
    ) async throws -> String {
        let apiKey = try config.getOpenAIKey()
        
        let endpoint = "\(APIConfig.Endpoint.openAI.baseURL)/chat/completions"
        guard let url = URL(string: endpoint) else {
            throw OpenAIError.invalidURL
        }
        
        // Prepare request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Request body
        let requestBody: [String: Any] = [
            "model": model.rawValue,
            "messages": messages.map { $0.toDictionary() },
            "temperature": temperature,
            "max_tokens": maxTokens
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Make request
        let (data, response) = try await session.data(for: request)
        
        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data) {
                throw OpenAIError.apiError(errorResponse.error.message)
            }
            throw OpenAIError.httpError(httpResponse.statusCode)
        }
        
        // Parse response
        let completion = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        
        guard let content = completion.choices.first?.message.content else {
            throw OpenAIError.emptyResponse
        }
        
        return content
    }
    
    // MARK: - Structured JSON Generation
    
    func generateStructuredJSON<T: Decodable>(
        prompt: String,
        systemPrompt: String? = nil,
        model: GPTModel = .gpt4Turbo
    ) async throws -> T {
        var messages: [ChatMessage] = []
        
        if let systemPrompt = systemPrompt {
            messages.append(ChatMessage(role: .system, content: systemPrompt))
        }
        
        messages.append(ChatMessage(role: .user, content: prompt))
        
        let response = try await generateChatCompletion(
            messages: messages,
            model: model,
            temperature: 0.7,
            maxTokens: 4096
        )
        
        // Extract JSON if wrapped in markdown
        let jsonString = extractJSON(from: response)
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw OpenAIError.invalidJSON
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: jsonData)
        } catch {
            print("❌ JSON Decode Error: \(error)")
            print("📄 Response: \(jsonString)")
            throw OpenAIError.jsonDecodingFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Helpers
    
    private func extractJSON(from text: String) -> String {
        // Remove markdown code blocks if present
        if text.contains("```json") {
            let components = text.components(separatedBy: "```json")
            if components.count > 1 {
                let jsonPart = components[1].components(separatedBy: "```")[0]
                return jsonPart.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        if text.contains("```") {
            let components = text.components(separatedBy: "```")
            if components.count > 1 {
                return components[1].trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Models

enum GPTModel: String {
    // GPT-3.5 (Fast, cheap - for Free tier)
    case gpt35Turbo = "gpt-3.5-turbo"
    
    // GPT-4 (High quality - for Pro tier)
    case gpt4 = "gpt-4"
    case gpt4Turbo = "gpt-4-turbo-preview"
    case gpt4o = "gpt-4o"              // ← RECOMMENDED (best balance)
    case gpt4oMini = "gpt-4o-mini"     // Smaller, faster GPT-4o
    
    // GPT-5 (Elite quality - for Pro Plus tier)
    case gpt5 = "gpt-5"                // When OpenAI releases it
    case gpt5Turbo = "gpt-5-turbo"     // Future: Fast GPT-5 variant
    case gpt5o = "gpt-5o"              // Future: Optimized GPT-5
    
    var displayName: String {
        switch self {
        case .gpt35Turbo:
            return "GPT-3.5 Turbo (Fast)"
        case .gpt4:
            return "GPT-4 (High Quality)"
        case .gpt4Turbo:
            return "GPT-4 Turbo"
        case .gpt4o:
            return "GPT-4o (Recommended)"
        case .gpt4oMini:
            return "GPT-4o Mini (Fast)"
        case .gpt5, .gpt5Turbo, .gpt5o:
            return "GPT-5 (Elite) 🔥"
        }
    }
    
    var tier: SubscriptionTier {
        switch self {
        case .gpt35Turbo:
            return .free
        case .gpt4, .gpt4Turbo, .gpt4o, .gpt4oMini:
            return .pro
        case .gpt5, .gpt5Turbo, .gpt5o:
            return .proPlus
        }
    }
}

struct ChatMessage {
    enum Role: String {
        case system
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

struct ChatCompletionResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage
    
    struct Choice: Codable {
        let index: Int
        let message: Message
        let finishReason: String?
        
        enum CodingKeys: String, CodingKey {
            case index
            case message
            case finishReason = "finish_reason"
        }
    }
    
    struct Message: Codable {
        let role: String
        let content: String
    }
    
    struct Usage: Codable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int
        
        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
}

struct OpenAIErrorResponse: Codable {
    let error: ErrorDetail
    
    struct ErrorDetail: Codable {
        let message: String
        let type: String
        let code: String?
    }
}

// MARK: - Errors

enum OpenAIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case apiError(String)
    case emptyResponse
    case invalidJSON
    case jsonDecodingFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from OpenAI"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .apiError(let message):
            return "OpenAI API error: \(message)"
        case .emptyResponse:
            return "Empty response from OpenAI"
        case .invalidJSON:
            return "Invalid JSON response"
        case .jsonDecodingFailed(let error):
            return "JSON decoding failed: \(error)"
        }
    }
}

