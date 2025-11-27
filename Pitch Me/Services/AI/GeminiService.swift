//
//  GeminiService.swift
//  Pitch Me
//
//  🔥 Google Vertex AI / Gemini Integration 🔥
//  Enterprise-grade AI for world-class pitch decks
//

import Foundation
import Combine

// MARK: - Gemini Model

enum GeminiModel: String, CaseIterable {
    case gemini15Pro = "gemini-1.5-pro"
    case gemini15Flash = "gemini-1.5-flash"
    case gemini20Flash = "gemini-2.0-flash"        // 🔥 FASTEST - Use this!
    case gemini20FlashExp = "gemini-2.0-flash-exp" // Experimental
    case geminiPro = "gemini-pro"
    
    var displayName: String {
        switch self {
        case .gemini15Pro: return "Gemini 1.5 Pro"
        case .gemini15Flash: return "Gemini 1.5 Flash"
        case .gemini20Flash: return "Gemini 2.0 Flash ⚡"
        case .gemini20FlashExp: return "Gemini 2.0 Flash (Exp)"
        case .geminiPro: return "Gemini Pro"
        }
    }
    
    var maxTokens: Int {
        switch self {
        case .gemini15Pro, .gemini20Flash, .gemini20FlashExp: return 8192
        case .gemini15Flash: return 8192
        case .geminiPro: return 4096
        }
    }
    
    var contextWindow: Int {
        switch self {
        case .gemini15Pro: return 1_000_000  // 1M tokens!
        case .gemini15Flash: return 1_000_000
        case .gemini20Flash, .gemini20FlashExp: return 1_000_000
        case .geminiPro: return 32_000
        }
    }
}

// MARK: - Gemini Service

@MainActor
final class GeminiService: ObservableObject {
    static let shared = GeminiService()
    
    private let config = APIConfig.shared
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta"
    private let session: URLSession
    
    private init() {
        // 🔥 Optimized session config for SPEED
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 45  // Fast timeout
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Generate Content
    
    func generateContent(
        prompt: String,
        systemPrompt: String? = nil,
        model: GeminiModel = .gemini15Pro
    ) async throws -> String {
        let apiKey = try config.getGeminiKey()
        
        let url = URL(string: "\(baseURL)/models/\(model.rawValue):generateContent?key=\(apiKey)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Build request body
        var contents: [[String: Any]] = []
        
        // Add system instruction if provided
        if let systemPrompt = systemPrompt {
            contents.append([
                "role": "user",
                "parts": [["text": "System instruction: \(systemPrompt)"]]
            ])
            contents.append([
                "role": "model",
                "parts": [["text": "Understood. I will follow these instructions."]]
            ])
        }
        
        // Add user prompt
        contents.append([
            "role": "user",
            "parts": [["text": prompt]]
        ])
        
        let body: [String: Any] = [
            "contents": contents,
            "generationConfig": [
                "temperature": 0.7,
                "topP": 0.95,
                "topK": 40,
                "maxOutputTokens": model.maxTokens,
                "responseMimeType": "text/plain"
            ],
            "safetySettings": [
                ["category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"],
                ["category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_NONE"],
                ["category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_NONE"],
                ["category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_NONE"]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw GeminiError.apiError(httpResponse.statusCode, errorBody)
        }
        
        // Parse response
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw GeminiError.invalidResponse
        }
        
        return text
    }
    
    // MARK: - Generate Structured JSON
    
    func generateStructuredJSON<T: Decodable>(
        prompt: String,
        systemPrompt: String? = nil,
        model: GeminiModel = .gemini15Pro
    ) async throws -> T {
        let jsonSystemPrompt = """
        \(systemPrompt ?? "")
        
        CRITICAL: You MUST respond with ONLY valid JSON. No markdown, no code blocks, no explanations.
        Start your response with { and end with }
        """
        
        let response = try await generateContent(
            prompt: prompt,
            systemPrompt: jsonSystemPrompt,
            model: model
        )
        
        // Clean the response
        var cleanedResponse = response
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove markdown code blocks if present
        if cleanedResponse.hasPrefix("```json") {
            cleanedResponse = String(cleanedResponse.dropFirst(7))
        }
        if cleanedResponse.hasPrefix("```") {
            cleanedResponse = String(cleanedResponse.dropFirst(3))
        }
        if cleanedResponse.hasSuffix("```") {
            cleanedResponse = String(cleanedResponse.dropLast(3))
        }
        cleanedResponse = cleanedResponse.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Parse JSON
        guard let jsonData = cleanedResponse.data(using: .utf8) else {
            throw GeminiError.invalidJSON
        }
        
        do {
            let decoded = try JSONDecoder().decode(T.self, from: jsonData)
            return decoded
        } catch {
            print("❌ Gemini JSON parsing error: \(error)")
            print("Response was: \(cleanedResponse.prefix(500))")
            throw GeminiError.invalidJSON
        }
    }
    
    // MARK: - Analyze Document (Long Context)
    
    func analyzeDocument(
        content: String,
        analysisPrompt: String,
        model: GeminiModel = .gemini15Pro
    ) async throws -> String {
        // Gemini 1.5 Pro has 1M token context - perfect for long documents
        let prompt = """
        DOCUMENT CONTENT:
        ---
        \(content)
        ---
        
        ANALYSIS REQUEST:
        \(analysisPrompt)
        """
        
        return try await generateContent(
            prompt: prompt,
            systemPrompt: "You are an expert document analyst. Analyze the provided document thoroughly and accurately.",
            model: model
        )
    }
}

// MARK: - Errors

enum GeminiError: Error, LocalizedError {
    case invalidResponse
    case invalidJSON
    case apiError(Int, String)
    case missingKey
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from Gemini API"
        case .invalidJSON:
            return "Failed to parse JSON response from Gemini"
        case .apiError(let code, let message):
            return "Gemini API error (\(code)): \(message)"
        case .missingKey:
            return "Gemini API key not configured"
        }
    }
}

