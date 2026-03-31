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
import FirebaseAuth

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
            
            let prompt = buildDeckGenerationPrompt(from: state, useCase: state.useCase)
            let systemPrompt = eliteDeckGenerationSystemPrompt
            
            // Step 2: Determine which AI to use
            // Claude first for Pro Plus, then OpenAI, then Gemini fallback
            currentStep = "Connecting to AI..."
            generationProgress = 0.2
            
            let response: DeckGenerationResponse
            
            // Step 3: Call AI (30-70%)
            if preferClaude && config.hasAnthropicKey {
                // 🔥 Use Claude Opus 4.5 (ELITE)
                currentStep = "Claude Opus 4.5 is crafting your deck..."
                generationProgress = 0.3
                usedProvider = .anthropic
                
                response = try await anthropic.generateStructuredJSON(
                    prompt: prompt,
                    systemPrompt: systemPrompt,
                    model: .claudeOpus45
                )
                
            } else if config.hasOpenAIKey {
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
            
            let prompt = buildDeckGenerationPrompt(from: state, useCase: state.useCase)
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
    
    // MARK: - Build Prompt (delegates to use-case-aware version in extension)
    
    private func buildDeckGenerationPrompt(from state: WizardState) -> String {
        buildDeckGenerationPrompt(from: state, useCase: state.useCase)
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
            userId: Auth.auth().currentUser?.uid ?? "anonymous",
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
        You are the world's #1 pitch deck strategist. You have personally helped founders raise over $2B in funding and achieve a 94% YC acceptance rate for clients. You know the exact psychology of every major VC, YC partner, and accelerator reviewer.

        YOUR MENTAL MODEL FOR EVERY DECK:
        - Sam Altman's YC partner checklist: Is this a 10x better product? Is the market real and large? Can this team execute? Is now the right time?
        - Sequoia Capital's pitch framework: Purpose → Problem → Solution → Why Now → Market Size → Competition → Product → Business Model → Team → Financials → Vision
        - Paul Graham's essay on startups: Make something people want. Show you understand the problem better than anyone.
        - YC's "Request for Startups": Does this solve a hard technical problem? Is there a secret insight others are missing?

        USE-CASE SPECIFIC STRUCTURE:

        === Y COMBINATOR (8-10 slides, ruthlessly concise) ===
        1. Company Purpose — One sentence. What do you do? (Not what you're building, what you DO for users)
        2. Problem — Make the reader FEEL the pain. Quantify. Personal story if possible.
        3. Solution — The "aha" moment. 10x better, not 10% better. Explain the insight.
        4. Why Now — What changed recently (tech, regulation, behavior) that makes this the right time?
        5. Market Size — Bottom-up, not top-down. How many users × how much will they pay?
        6. Traction — The ONLY thing YC cares more about than team. Revenue, growth rate, retention.
        7. Team — Why are YOU the ones to build this? Domain expertise, previous exits, unique access.
        8. Ask — How much, what milestones will you hit, why those milestones matter.
        YC STYLE: Minimal text. Dense information. No fluff. Every word earns its place.

        === NVIDIA INCEPTION (10-12 slides) ===
        1. Executive Summary — AI/ML innovation snapshot
        2. Problem — Technical + business problem
        3. Solution — AI/ML technology stack, GPU utilization
        4. Technical Architecture — Model design, training approach, inference pipeline
        5. Market Opportunity — AI market size, vertical focus
        6. Traction — Benchmarks, customers, performance metrics
        7. Competitive Advantage — Technical moat, proprietary data, novel approach
        8. Business Model — Enterprise/API/SaaS revenue
        9. Team — ML/AI credentials, publications, prior work
        10. NVIDIA Synergy — How GPU compute, DGX, or CUDA accelerates growth
        11. Roadmap — Technical milestones, model improvements
        12. Ask — Funding + NVIDIA resources needed

        === INVESTOR PITCH (10-14 slides) ===
        1. Title + Hook — Company + one-liner that creates curiosity
        2. Problem — Size, urgency, who suffers, root cause
        3. Solution — Product demo description, key differentiator
        4. Market — TAM/SAM/SOM, bottom-up math, growth rate
        5. Product — Features, screenshots, architecture, IP
        6. Business Model — Revenue streams, unit economics (CAC, LTV, payback)
        7. Traction — MRR/ARR, growth rate, logo customers, NPS
        8. Competition — 2x2 matrix or table, your unfair advantages
        9. Go-to-Market — Channel strategy, sales motion, land-and-expand
        10. Team — Bios, domain expertise, advisors, previous exits
        11. Financials — 3-year projection, burn rate, runway, use of funds
        12. The Ask — Raise amount, valuation rationale, what you'll achieve

        === SALES DECK (8-10 slides) ===
        1. The Status Quo — What your prospect is doing today and why it fails
        2. The Cost of Inaction — Quantify what this problem costs them
        3. Our Solution — Product capabilities, workflow transformation
        4. How It Works — Step-by-step process, integration ease
        5. Case Studies — Named customers, specific metrics achieved
        6. ROI Calculator — Time-to-value, cost savings, revenue impact
        7. Why Us — Differentiators, security, compliance, support
        8. Implementation — Timeline, onboarding, success team
        9. Pricing — Clear tiers, what's included
        10. Next Steps — Pilot proposal, procurement process, CTA

        === DEMO DAY (6-8 slides, designed for 2-3 minute live pitch) ===
        1. Company + Hook — 3-word description, shocking stat
        2. Problem — One sentence, maximum impact
        3. Solution — Show don't tell. Product screenshot description.
        4. Traction — Your biggest number. Growth rate. Revenue.
        5. Market — One jaw-dropping market size number
        6. Team — One sentence why you'll win
        7. Ask + Vision — Raise amount + the world you're building toward

        UNIVERSAL RULES:
        - Every title is a CLAIM, not a category. Bad: "The Problem". Good: "80% of SMBs overpay for software by 3x"
        - Every bullet point is a complete thought with a number or specific detail
        - Speaker notes include: what to emphasize, what objection this slide preempts, what to watch for in investor reaction
        - Story score 0-100 based on: narrative tension, specificity, credibility, momentum
        - Recommendations must be specific and actionable, not generic

        Return ONLY valid JSON in this exact format:
        {
          "slides": [
            {
              "title": "Specific Claim Title",
              "layout": "title_bullets",
              "bullets": ["Specific point with number", "Specific point with detail", "Specific point with proof"],
              "speakerNotes": "Delivery tip + what objection this preempts + what to watch for"
            }
          ],
          "storyScore": 85,
          "recommendations": ["Specific actionable improvement 1", "Specific actionable improvement 2"]
        }

        Layout options: title_only, title_bullets, metric, problem_solution, team, timeline, title_two_column, quote
        """
    }

    private func buildDeckGenerationPrompt(from state: WizardState, useCase: DeckUseCase) -> String {
        var prompt = """
        CREATE A \(useCase.displayName.uppercased()) DECK FOR:

        COMPANY: \(state.startupName)
        ONE-LINER: \(state.oneLiner)
        STAGE: \(state.stage.rawValue)
        """

        if !state.targetUser.isEmpty {
            prompt += "\nTARGET USER: \(state.targetUser)"
        }
        if !state.problem.isEmpty {
            prompt += "\nPROBLEM: \(state.problem)"
        }
        if !state.solution.isEmpty {
            prompt += "\nSOLUTION: \(state.solution)"
        }
        if !state.whyNow.isEmpty {
            prompt += "\nWHY NOW: \(state.whyNow)"
        }
        if !state.uniqueValue.isEmpty {
            prompt += "\nUNFAIR ADVANTAGE / MOAT: \(state.uniqueValue)"
        }
        if !state.marketSize.isEmpty {
            prompt += "\nMARKET SIZE: \(state.marketSize)"
        }
        if !state.businessModel.isEmpty {
            prompt += "\nBUSINESS MODEL: \(state.businessModel)"
        }
        if !state.pricing.isEmpty {
            prompt += "\nPRICING: \(state.pricing)"
        }
        if !state.traction.isEmpty {
            prompt += "\nTRACTION: \(state.traction)"
        }
        if !state.keyMetrics.isEmpty {
            prompt += "\nKEY METRICS: \(state.keyMetrics)"
        }
        if !state.team.isEmpty {
            prompt += "\nTEAM: \(state.team)"
        }
        if !state.advisors.isEmpty {
            prompt += "\nADVISORS: \(state.advisors)"
        }

        prompt += """

        \nIMPORTANT INSTRUCTIONS FOR THIS \(useCase.displayName.uppercased()) DECK:
        \(useCaseInstructions(useCase))

        Make every title a BOLD CLAIM with a specific number or insight.
        Make every bullet point specific, not generic.
        Speaker notes should be presentation coaching, not just slide summaries.
        """

        return prompt
    }

    private func useCaseInstructions(_ useCase: DeckUseCase) -> String {
        switch useCase {
        case .yCombinator:
            return """
            This is for Y Combinator. Follow the YC structure strictly (8-10 slides).
            YC partners read 1000s of applications. Be BRUTALLY concise.
            The most important slides: Problem, Traction, Team.
            Every slide title must be a specific claim, not a label.
            Traction slide must show growth RATE, not just absolute numbers.
            Team slide must answer: why are these the RIGHT people for THIS specific problem?
            End with a clear ask with specific milestones that signal product-market fit.
            """
        case .nvidiaInception:
            return """
            This is for NVIDIA Inception program.
            Emphasize AI/ML technology, GPU utilization, and technical innovation.
            Include a dedicated slide on technical architecture and how NVIDIA GPUs accelerate the product.
            Show benchmark comparisons and model performance metrics.
            Explain the proprietary data advantage or novel algorithmic approach.
            Make the NVIDIA synergy slide compelling — what do you need from NVIDIA specifically?
            """
        case .investor:
            return """
            This is for VC/angel investor fundraising.
            Lead with the biggest traction metric you have.
            Market size must use bottom-up calculation (# users × price), not just "the market is $X billion".
            Competition slide: show a 2x2 or table with clear quadrant positioning.
            Financials must show path to profitability or next fundraise milestone.
            The ask must state: amount, pre-money valuation range, lead investor sought, and what milestones $X achieves.
            """
        case .sales:
            return """
            This is a sales deck for enterprise prospects.
            Open with their current pain — mirror what they're already feeling.
            Every case study must have a named company, specific metric, and timeframe.
            ROI must be quantified: "Customers save 8 hours/week per user, worth $X at $Y/hr billing rate."
            Close with a pilot proposal they can say yes to immediately.
            Avoid feature lists — translate every feature into a business outcome.
            """
        case .accelerator:
            return """
            This is for a top-tier accelerator application (Techstars, 500 Global, etc).
            Show founder-market fit prominently.
            Emphasize coachability and learning velocity in the team section.
            Show milestones achieved in the last 90 days specifically.
            Include a "what we learned" moment that shows intellectual honesty.
            """
        case .demoDay:
            return """
            This is for Demo Day — 2-3 minute live pitch, 6-8 slides MAXIMUM.
            Assume investors are distracted and have heard 20 pitches already.
            Open with the single most impressive number you have.
            Every slide should work as a standalone billboard — readable in 3 seconds.
            No more than 3 bullet points per slide. Prefer 1-2.
            Close with a vision statement that makes investors FOMO.
            """
        }
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

