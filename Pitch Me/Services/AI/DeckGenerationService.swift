//
//  DeckGenerationService.swift
//  Pitch Me
//
//  🔥 ELITE deck generation using Claude Opus 4.5 + GPT-4 fallback 🔥
//  The world's most intelligent pitch deck generator
//

import Foundation
import SwiftUI
import Combine

// MARK: - Deck Generation Service

@MainActor
final class DeckGenerationService: ObservableObject {
    static let shared = DeckGenerationService()
    
    @Published var isGenerating = false
    @Published var generationProgress: Double = 0.0
    @Published var currentStep: String = ""
    @Published var usedProvider: AIProvider = .none
    
    private let anthropic = AnthropicService.shared  // 🔥 Claude Opus 4.5
    private let openAI = OpenAIService.shared        // GPT-4 fallback
    private let config = APIConfig.shared
    
    private init() {}
    
    // MARK: - Generate Deck (Claude Opus 4.5 Primary)
    
    func generateDeck(from state: WizardState, preferClaude: Bool = true) async throws -> Deck {
        isGenerating = true
        generationProgress = 0.0
        
        do {
            // Step 1: Prepare prompt (10%)
            currentStep = "Analyzing your startup..."
            generationProgress = 0.1
            
            let prompt = buildDeckGenerationPrompt(from: state)
            let systemPrompt = eliteDeckGenerationSystemPrompt
            
            // Step 2: Determine which AI to use
            let provider = config.preferredAIProvider
            currentStep = "Connecting to \(provider.displayName)..."
            generationProgress = 0.2
            
            let response: DeckGenerationResponse
            
            // Step 3: Call AI (30-70%)
            if provider == .anthropic && preferClaude {
                // 🔥 Use Claude Opus 4.5 (ELITE)
                currentStep = "Claude Opus 4.5 is crafting your deck..."
                generationProgress = 0.3
                usedProvider = .anthropic
                
                response = try await anthropic.generateStructuredJSON(
                    prompt: prompt,
                    systemPrompt: systemPrompt,
                    model: .claudeOpus45
                )
                
            } else if provider == .openAI || config.hasOpenAIKey {
                // Use GPT-4 as fallback
                currentStep = "GPT-4 is generating your deck..."
                generationProgress = 0.3
                usedProvider = .openAI
                
                response = try await openAI.generateStructuredJSON(
                    prompt: prompt,
                    systemPrompt: systemPrompt,
                    model: .gpt4o
                )
                
            } else {
                throw DeckGenerationError.missingAPIKey
            }
            
            generationProgress = 0.7
            
            // Step 4: Convert to Deck model (80%)
            currentStep = "Finalizing slides..."
            generationProgress = 0.8
            
            let deck = convertResponseToDeck(response, wizardState: state)
            
            // Step 5: Complete (100%)
            currentStep = "Done! Created with \(usedProvider.displayName)"
            generationProgress = 1.0
            
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s for smooth UX
            
            isGenerating = false
            return deck
            
        } catch {
            isGenerating = false
            generationProgress = 0.0
            currentStep = ""
            throw DeckGenerationError.generationFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Generate Deck (Legacy GPT support)
    
    func generateDeck(from state: WizardState, model: GPTModel) async throws -> Deck {
        // If using GPT model explicitly, use OpenAI
        isGenerating = true
        generationProgress = 0.0
        
        do {
            currentStep = "Analyzing your startup..."
            generationProgress = 0.1
            
            let prompt = buildDeckGenerationPrompt(from: state)
            let systemPrompt = eliteDeckGenerationSystemPrompt
            
            currentStep = "Generating your deck with \(model.displayName)..."
            generationProgress = 0.3
            usedProvider = .openAI
            
            let response: DeckGenerationResponse = try await openAI.generateStructuredJSON(
                prompt: prompt,
                systemPrompt: systemPrompt,
                model: model
            )
            
            currentStep = "Finalizing slides..."
            generationProgress = 0.8
            
            let deck = convertResponseToDeck(response, wizardState: state)
            
            currentStep = "Done!"
            generationProgress = 1.0
            
            try? await Task.sleep(nanoseconds: 300_000_000)
            
            isGenerating = false
            return deck
            
        } catch {
            isGenerating = false
            generationProgress = 0.0
            currentStep = ""
            throw DeckGenerationError.generationFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Build Prompt
    
    private func buildDeckGenerationPrompt(from state: WizardState) -> String {
        var prompt = """
        Generate a professional, investor-ready pitch deck with the following information:
        
        STARTUP BASICS:
        - Company Name: \(state.startupName)
        - One-liner: \(state.oneLiner)
        - Stage: \(state.stage.rawValue)
        """
        
        if !state.targetUser.isEmpty {
            prompt += """
            
            
            TARGET USER:
            \(state.targetUser)
            """
        }
        
        if !state.problem.isEmpty {
            prompt += """
            
            
            PROBLEM:
            \(state.problem)
            """
        }
        
        if !state.solution.isEmpty {
            prompt += """
            
            
            SOLUTION:
            \(state.solution)
            """
            
            if !state.whyNow.isEmpty {
                prompt += "\n\nWHY NOW: \(state.whyNow)"
            }
            
            if !state.uniqueValue.isEmpty {
                prompt += "\n\nUNIQUE VALUE: \(state.uniqueValue)"
            }
        }
        
        if !state.marketSize.isEmpty {
            prompt += """
            
            
            MARKET:
            - Size: \(state.marketSize)
            - Business Model: \(state.businessModel)
            """
            
            if !state.pricing.isEmpty {
                prompt += "\n- Pricing: \(state.pricing)"
            }
        }
        
        if !state.traction.isEmpty {
            prompt += """
            
            
            TRACTION:
            \(state.traction)
            """
            
            if !state.keyMetrics.isEmpty {
                prompt += "\n\nKEY METRICS: \(state.keyMetrics)"
            }
        }
        
        if !state.team.isEmpty {
            prompt += """
            
            
            TEAM:
            \(state.team)
            """
            
            if !state.advisors.isEmpty {
                prompt += "\n\nADVISORS: \(state.advisors)"
            }
        }
        
        prompt += """
        
        
        USE CASE: \(state.useCase.displayName)
        
        Generate a 10-12 slide deck optimized for \(state.useCase.displayName).
        """
        
        return prompt
    }
    
    // MARK: - Convert Response to Deck
    
    private func convertResponseToDeck(_ response: DeckGenerationResponse, wizardState: WizardState) -> Deck {
        let deckId = UUID().uuidString
        let now = Date()
        
        // Convert slides
        var slides: [Slide] = []
        for (index, slideData) in response.slides.enumerated() {
            let slide = Slide(
                id: UUID().uuidString,
                deckId: deckId,
                index: index,
                layoutType: parseLayoutType(slideData.layout),
                title: slideData.title,
                bullets: slideData.bullets ?? [],
                speakerNotes: slideData.speakerNotes,
                createdAt: now,
                updatedAt: now
            )
            slides.append(slide)
        }
        
        // Create deck
        let deck = Deck(
            id: deckId,
            userId: "current-user", // Will be replaced with real user ID when Firebase is integrated
            title: wizardState.startupName,
            useCase: wizardState.useCase,
            themeId: wizardState.preferredTheme,
            storyScore: response.storyScore,
            slides: slides,
            createdAt: now,
            updatedAt: now
        )
        
        return deck
    }
    
    // MARK: - Helpers
    
    private func parseLayoutType(_ layout: String) -> SlideLayoutType {
        switch layout.lowercased() {
        case "title_only", "title":
            return .titleOnly
        case "title_bullets", "bullets":
            return .titleBullets
        case "title_two_column", "two_column":
            return .titleTwoColumn
        case "metric", "metrics":
            return .metric
        case "timeline", "roadmap":
            return .timeline
        case "problem_solution", "problem/solution":
            return .problemSolution
        case "team":
            return .team
        case "quote":
            return .quote
        case "image_caption", "image":
            return .imageCaption
        default:
            return .titleBullets
        }
    }
}

// MARK: - Elite System Prompt

extension DeckGenerationService {
    var eliteDeckGenerationSystemPrompt: String {
        """
        You are an ELITE pitch deck consultant who has helped 1000+ startups raise funding and get into Y Combinator, NVIDIA Inception, Techstars, and other top accelerators.

        Your expertise:
        - Created decks that raised $500M+ in total funding
        - 95% acceptance rate for Y Combinator applications
        - Expert in storytelling, investor psychology, and visual design
        - Deep knowledge of what makes a deck compelling

        CORE PRINCIPLES:
        1. **CLARITY** - Every slide should be instantly understandable
        2. **STORY** - Build narrative tension: problem → solution → opportunity
        3. **NUMBERS** - Quantify everything (market size, traction, impact)
        4. **VISUALS** - Design for visual impact, not text walls
        5. **MOMENTUM** - Show growth, traction, inevitability

        SLIDE STRUCTURE (10-12 slides):
        1. Title - Company name + killer one-liner
        2. Problem - WHO has it, HOW painful, quantify
        3. Solution - WHAT you built, HOW it works, WHY 10X better
        4. Market - TAM/SAM/SOM with bottom-up calculation
        5. Product - Show the product (screenshots, demo, architecture)
        6. Traction - Metrics, growth, momentum (the more specific the better)
        7. Business Model - How you make money, unit economics
        8. Competition - Why you'll win, your moat
        9. Team - Credentials, why THIS team will execute
        10. Roadmap - Next 12-24 months
        11. Financials - Revenue projection, burn, runway
        12. Ask - How much raising, what you'll achieve with it

        FORMATTING RULES:
        - Titles: Short, punchy, action-oriented
        - Bullets: 3-5 max per slide, <15 words each
        - Speaker notes: Include presentation tips, what to emphasize
        - Story score: Rate the narrative quality 0-100

        AUDIENCE-SPECIFIC OPTIMIZATION:
        - **Investor Deck**: Focus on market size, traction, team, ROI potential
        - **Accelerator (YC)**: Focus on 10X better, growth rate, founder-market fit
        - **Customer Pitch**: Focus on problem/solution fit, ROI for customer
        - **Demo Day**: Focus on traction, momentum, vision
        - **Fundraising**: Focus on use of funds, milestones, exit potential
        - **Partnership**: Focus on mutual value, integration, scale potential

        Return ONLY valid JSON in this exact format:
        {
          "slides": [
            {
              "title": "Slide Title",
              "layout": "title_bullets",
              "bullets": ["Bullet 1", "Bullet 2", "Bullet 3"],
              "speakerNotes": "What to say when presenting this slide"
            }
          ],
          "storyScore": 85,
          "recommendations": ["Tip 1", "Tip 2"]
        }

        Make it EXCEPTIONAL. This deck needs to raise millions. 🚀
        """
    }
}

// MARK: - Response Models

struct DeckGenerationResponse: Codable {
    let slides: [SlideData]
    let storyScore: Int?
    let recommendations: [String]?
    
    struct SlideData: Codable {
        let title: String
        let layout: String
        let bullets: [String]?
        let speakerNotes: String?
    }
}

// MARK: - Errors

enum DeckGenerationError: Error, LocalizedError {
    case missingAPIKey
    case generationFailed(String)
    case invalidResponse
    case rateLimitExceeded
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenAI API key not configured. Please add it to Secrets.plist"
        case .generationFailed(let message):
            return "Deck generation failed: \(message)"
        case .invalidResponse:
            return "Invalid response from AI. Please try again."
        case .rateLimitExceeded:
            return "API rate limit exceeded. Please wait a moment and try again."
        }
    }
}

