//
//  SlideRegenerationService.swift
//  Pitch Me
//
//  🔥 Real AI-powered slide improvement using Claude Opus 4.5 / GPT-4 🔥
//

import Foundation

// MARK: - Slide Regeneration Response

private struct SlideImprovementResponse: Codable {
    let title: String
    let bullets: [String]
    let speakerNotes: String?
}

// MARK: - Slide Regeneration Service

final class SlideRegenerationService {
    static let shared = SlideRegenerationService()
    
    private let anthropic = AnthropicService.shared
    private let openAI = OpenAIService.shared
    private let config = APIConfig.shared
    
    private init() {}
    
    // MARK: - Improve a Single Slide
    
    func improveSlide(_ slide: Slide, deckContext: Deck) async throws -> Slide {
        let systemPrompt = """
        You are an elite pitch deck consultant and storytelling expert. \
        Your job is to improve a single slide in an investor pitch deck. \
        Make the content more compelling, specific, and investor-ready. \
        Keep bullets concise (under 12 words each) and punchy. \
        Return ONLY valid JSON — no markdown, no code blocks.
        """
        
        let prompt = """
        Improve this slide from the "\(deckContext.title)" pitch deck (\(deckContext.useCase.displayName)):
        
        CURRENT SLIDE:
        Title: \(slide.title)
        Bullets:
        \(slide.bullets.enumerated().map { "  \($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
        \(slide.speakerNotes.map { "\nSpeaker Notes: \($0)" } ?? "")
        
        Improve this slide to be more compelling and investor-ready. Keep the same topic but make it stronger.
        
        Return JSON in this exact format:
        {
          "title": "improved slide title",
          "bullets": ["bullet 1", "bullet 2", "bullet 3"],
          "speakerNotes": "improved speaker notes or null"
        }
        """
        
        // Try Claude first (Pro Plus), then OpenAI
        if config.hasAnthropicKey {
            let tier = SubscriptionService.shared.currentTier
            let model: AnthropicService.ClaudeModel = (tier == .proPlus || tier == .enterprise)
                ? .claudeOpus45
                : .claude35Sonnet
            
            let response: SlideImprovementResponse = try await anthropic.generateStructuredJSON(
                prompt: prompt,
                systemPrompt: systemPrompt,
                model: model
            )
            return applyImprovements(response, to: slide)
        }
        
        if config.hasOpenAIKey {
            let response: SlideImprovementResponse = try await openAI.generateStructuredJSON(
                prompt: prompt,
                systemPrompt: systemPrompt,
                model: .gpt4o
            )
            return applyImprovements(response, to: slide)
        }
        
        throw SlideRegenerationError.noAIConfigured
    }
    
    // MARK: - Apply improvements to slide copy
    
    private func applyImprovements(_ response: SlideImprovementResponse, to slide: Slide) -> Slide {
        var improved = slide
        improved.title = response.title
        improved.bullets = response.bullets
        if let notes = response.speakerNotes, !notes.isEmpty {
            improved.speakerNotes = notes
        }
        return improved
    }
}

// MARK: - Errors

enum SlideRegenerationError: LocalizedError {
    case noAIConfigured
    case generationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .noAIConfigured:
            return "No AI service configured. Add ANTHROPIC_API_KEY or OPENAI_API_KEY to Secrets.plist."
        case .generationFailed(let msg):
            return "Slide improvement failed: \(msg)"
        }
    }
}
