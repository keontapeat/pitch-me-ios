//
//  EliteAIEnsemble.swift
//  Pitch Me
//
//  🔥🔥🔥 ELITE MULTI-AI ENSEMBLE 🔥🔥🔥
//  Combines Claude Opus 4.5 + GPT-4 + Gemini 1.5 Pro
//  For the most intelligent pitch decks in the world
//

import Foundation
import Combine

// MARK: - Ensemble Strategy

enum EnsembleStrategy {
    case bestOfThree      // Run all 3, pick best result
    case claudePrimary    // Claude first, others as fallback
    case consensus        // All 3 must agree on key points
    case specialized      // Different AI for different tasks
    case fastest          // First to respond wins
}

// MARK: - AI Task Type

enum AITaskType {
    case deckGeneration
    case documentAnalysis
    case pitchScoring
    case questionGeneration
    case competitiveAnalysis
    case marketResearch
    case teamAssessment
    case financialProjection
    
    /// Best AI for this task type
    var preferredProvider: AIProvider {
        switch self {
        case .deckGeneration, .pitchScoring:
            return .anthropic  // Claude excels at creative + analytical
        case .documentAnalysis:
            return .gemini     // Gemini has 1M token context
        case .questionGeneration, .teamAssessment:
            return .anthropic  // Claude is best at nuanced analysis
        case .competitiveAnalysis, .marketResearch:
            return .openAI     // GPT-4 has great web knowledge
        case .financialProjection:
            return .openAI     // GPT-4 is good with numbers
        }
    }
}

// MARK: - Ensemble Result

struct EnsembleResult<T> {
    let result: T
    let provider: AIProvider
    let confidence: Double  // 0.0 - 1.0
    let alternatives: [(provider: AIProvider, result: T)]?
    let processingTime: TimeInterval
}

// MARK: - Elite AI Ensemble Service

@MainActor
final class EliteAIEnsemble: ObservableObject {
    static let shared = EliteAIEnsemble()
    
    @Published var isProcessing = false
    @Published var currentProvider: AIProvider = .none
    @Published var progress: Double = 0.0
    @Published var statusMessage: String = ""
    
    private let claude = AnthropicService.shared
    private let gpt = OpenAIService.shared
    private let gemini = GeminiService.shared
    private let config = APIConfig.shared
    
    private init() {}
    
    // MARK: - Generate with Best AI
    
    /// Automatically selects the best AI for the task
    func generateWithBestAI<T: Decodable>(
        prompt: String,
        systemPrompt: String,
        taskType: AITaskType
    ) async throws -> EnsembleResult<T> {
        isProcessing = true
        progress = 0.1
        
        let startTime = Date()
        let preferredProvider = taskType.preferredProvider
        
        statusMessage = "Using \(preferredProvider.displayName)..."
        currentProvider = preferredProvider
        
        do {
            let result: T
            
            switch preferredProvider {
            case .anthropic where config.hasAnthropicKey:
                progress = 0.3
                result = try await claude.generateStructuredJSON(
                    prompt: prompt,
                    systemPrompt: systemPrompt,
                    model: .claudeOpus45
                )
                
            case .gemini where config.hasGeminiKey:
                progress = 0.3
                result = try await gemini.generateStructuredJSON(
                    prompt: prompt,
                    systemPrompt: systemPrompt,
                    model: .gemini15Pro
                )
                
            case .openAI where config.hasOpenAIKey:
                progress = 0.3
                result = try await gpt.generateStructuredJSON(
                    prompt: prompt,
                    systemPrompt: systemPrompt,
                    model: .gpt4o
                )
                
            default:
                // Fallback chain
                result = try await fallbackGenerate(prompt: prompt, systemPrompt: systemPrompt)
            }
            
            progress = 1.0
            isProcessing = false
            
            let processingTime = Date().timeIntervalSince(startTime)
            
            return EnsembleResult(
                result: result,
                provider: currentProvider,
                confidence: 0.95,
                alternatives: nil,
                processingTime: processingTime
            )
            
        } catch {
            // Try fallback
            do {
                let result: T = try await fallbackGenerate(prompt: prompt, systemPrompt: systemPrompt)
                let processingTime = Date().timeIntervalSince(startTime)
                
                isProcessing = false
                return EnsembleResult(
                    result: result,
                    provider: currentProvider,
                    confidence: 0.85,
                    alternatives: nil,
                    processingTime: processingTime
                )
            } catch {
                isProcessing = false
                throw error
            }
        }
    }
    
    // MARK: - Best of Three (Premium Feature)
    
    /// Runs all 3 AIs and picks the best result based on scoring
    func bestOfThree<T: Decodable>(
        prompt: String,
        systemPrompt: String,
        scorer: @escaping (T) -> Double
    ) async throws -> EnsembleResult<T> {
        isProcessing = true
        progress = 0.0
        statusMessage = "Running Elite AI Ensemble..."
        
        let startTime = Date()
        var results: [(provider: AIProvider, result: T, score: Double)] = []
        
        // Run all available AIs in parallel
        await withTaskGroup(of: (AIProvider, T?, Double).self) { group in
            // Claude
            if config.hasAnthropicKey {
                group.addTask { [self] in
                    do {
                        let result: T = try await claude.generateStructuredJSON(
                            prompt: prompt,
                            systemPrompt: systemPrompt,
                            model: .claudeOpus45
                        )
                        let score = scorer(result)
                        return (.anthropic, result, score)
                    } catch {
                        return (.anthropic, nil, 0)
                    }
                }
            }
            
            // GPT-4
            if config.hasOpenAIKey {
                group.addTask { [self] in
                    do {
                        let result: T = try await gpt.generateStructuredJSON(
                            prompt: prompt,
                            systemPrompt: systemPrompt,
                            model: .gpt4o
                        )
                        let score = scorer(result)
                        return (.openAI, result, score)
                    } catch {
                        return (.openAI, nil, 0)
                    }
                }
            }
            
            // Gemini
            if config.hasGeminiKey {
                group.addTask { [self] in
                    do {
                        let result: T = try await gemini.generateStructuredJSON(
                            prompt: prompt,
                            systemPrompt: systemPrompt,
                            model: .gemini15Pro
                        )
                        let score = scorer(result)
                        return (.gemini, result, score)
                    } catch {
                        return (.gemini, nil, 0)
                    }
                }
            }
            
            for await (provider, result, score) in group {
                if let result = result {
                    results.append((provider, result, score))
                }
                progress = Double(results.count) / 3.0
            }
        }
        
        guard !results.isEmpty else {
            isProcessing = false
            throw EnsembleError.allProvidersFailed
        }
        
        // Sort by score and pick best
        results.sort { $0.score > $1.score }
        let best = results[0]
        let alternatives = results.dropFirst().map { ($0.provider, $0.result) }
        
        let processingTime = Date().timeIntervalSince(startTime)
        
        isProcessing = false
        currentProvider = best.provider
        statusMessage = "Best result from \(best.provider.displayName)"
        
        return EnsembleResult(
            result: best.result,
            provider: best.provider,
            confidence: min(best.score, 1.0),
            alternatives: alternatives.isEmpty ? nil : alternatives,
            processingTime: processingTime
        )
    }
    
    // MARK: - Fallback Chain
    
    private func fallbackGenerate<T: Decodable>(
        prompt: String,
        systemPrompt: String
    ) async throws -> T {
        // Try in order: Claude -> GPT-4 -> Gemini
        
        if config.hasAnthropicKey {
            statusMessage = "Trying Claude Opus 4.5..."
            currentProvider = .anthropic
            do {
                return try await claude.generateStructuredJSON(
                    prompt: prompt,
                    systemPrompt: systemPrompt,
                    model: .claudeOpus45
                )
            } catch {
                print("⚠️ Claude failed: \(error)")
            }
        }
        
        if config.hasOpenAIKey {
            statusMessage = "Trying GPT-4..."
            currentProvider = .openAI
            do {
                return try await gpt.generateStructuredJSON(
                    prompt: prompt,
                    systemPrompt: systemPrompt,
                    model: .gpt4o
                )
            } catch {
                print("⚠️ GPT-4 failed: \(error)")
            }
        }
        
        if config.hasGeminiKey {
            statusMessage = "Trying Gemini..."
            currentProvider = .gemini
            do {
                return try await gemini.generateStructuredJSON(
                    prompt: prompt,
                    systemPrompt: systemPrompt,
                    model: .gemini15Pro
                )
            } catch {
                print("⚠️ Gemini failed: \(error)")
            }
        }
        
        throw EnsembleError.allProvidersFailed
    }
    
    // MARK: - Specialized Tasks
    
    /// Analyze a document with Gemini's 1M token context
    func analyzeDocument(content: String, instructions: String) async throws -> String {
        guard config.hasGeminiKey else {
            // Fallback to Claude for shorter docs
            if config.hasAnthropicKey {
                return try await claude.generateCompletion(
                    messages: [
                        ClaudeMessage(role: .user, content: "Document:\n\(content)\n\nInstructions:\n\(instructions)")
                    ],
                    system: "You are an expert document analyst.",
                    model: .claudeOpus45
                )
            }
            throw EnsembleError.noProvidersAvailable
        }
        
        return try await gemini.analyzeDocument(
            content: content,
            analysisPrompt: instructions,
            model: .gemini15Pro
        )
    }
    
    /// Score a pitch deck with Claude's analytical capabilities
    func scorePitch(deck: Deck, accelerator: AcceleratorTemplate) async throws -> AcceleratorScore {
        let prompt = buildPitchScoringPrompt(deck: deck, accelerator: accelerator)
        
        let result: EnsembleResult<AcceleratorScore> = try await generateWithBestAI(
            prompt: prompt,
            systemPrompt: pitchScoringSystemPrompt,
            taskType: .pitchScoring
        )
        
        return result.result
    }
    
    // MARK: - Prompts
    
    private func buildPitchScoringPrompt(deck: Deck, accelerator: AcceleratorTemplate) -> String {
        let slideSummary = deck.slides.map { "- \($0.title): \($0.bullets.joined(separator: "; "))" }.joined(separator: "\n")
        
        return """
        Score this pitch deck for \(accelerator.name) acceptance:
        
        DECK TITLE: \(deck.title)
        USE CASE: \(deck.useCase.displayName)
        
        SLIDES:
        \(slideSummary)
        
        ACCELERATOR CRITERIA:
        \(accelerator.criteria.joined(separator: "\n"))
        
        KEY QUESTIONS THEY ASK:
        \(accelerator.keyQuestions.joined(separator: "\n"))
        
        REVIEWER FOCUS:
        \(accelerator.reviewerFocus.joined(separator: "\n"))
        
        Score each criterion 0-100 and provide overall assessment.
        Return JSON with: acceleratorId, overallScore, criteriaScores (dict), strengths (array), weaknesses (array), recommendations (array), likelihood (enum: veryHigh/high/medium/low/veryLow)
        """
    }
    
    private var pitchScoringSystemPrompt: String {
        """
        You are an ELITE pitch deck evaluator who has reviewed 10,000+ applications for Y Combinator, NVIDIA Inception, Techstars, and other top accelerators.
        
        Your scoring is BRUTALLY HONEST but constructive. You know exactly what makes a deck get accepted vs rejected.
        
        SCORING GUIDELINES:
        - 90-100: Exceptional. Would definitely get interviews.
        - 80-89: Strong. High likelihood of advancing.
        - 70-79: Good. Competitive but needs work.
        - 60-69: Average. Significant improvements needed.
        - 50-59: Below average. Major gaps.
        - Below 50: Needs complete rework.
        
        Be specific in your feedback. Reference actual content from the deck.
        Return ONLY valid JSON.
        """
    }
}

// MARK: - Errors

enum EnsembleError: Error, LocalizedError {
    case allProvidersFailed
    case noProvidersAvailable
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .allProvidersFailed:
            return "All AI providers failed. Please try again."
        case .noProvidersAvailable:
            return "No AI providers configured. Please add API keys."
        case .invalidResponse:
            return "Invalid response from AI ensemble."
        }
    }
}

