//
//  EliteDocumentAnalyzer.swift
//  Pitch Me
//
//  🔥 ELITE AI document analysis powered by Claude Opus 4.5 🔥
//  Creates accelerator-grade pitch decks with YC-level insights
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class EliteDocumentAnalyzer: ObservableObject {
    static let shared = EliteDocumentAnalyzer()
    
    @Published var isAnalyzing = false
    @Published var analysisProgress: Double = 0.0
    @Published var usedProvider: AIProvider = .none
    
    private let config = APIConfig.shared
    
    private init() {}
    
    // MARK: - Elite Document Analysis
    
    func analyzeForAccelerator(
        text: String,
        accelerator: AcceleratorTemplate
    ) async throws -> (analysis: DocumentAnalysis, score: AcceleratorScore) {
        isAnalyzing = true
        analysisProgress = 0.0
        
        // Step 1: Extract raw data (30%)
        analysisProgress = 0.3
        let baseAnalysis = try await extractRawData(from: text)
        
        // Step 2: Accelerator-specific scoring (60%)
        analysisProgress = 0.6
        let score = try await scoreForAccelerator(baseAnalysis, accelerator: accelerator)
        
        // Step 3: Generate recommendations (90%)
        analysisProgress = 0.9
        let enhancedScore = try await generateAcceleratorRecommendations(score, for: accelerator)
        
        // Step 4: Complete (100%)
        analysisProgress = 1.0
        isAnalyzing = false
        
        return (baseAnalysis, enhancedScore)
    }
    
    // MARK: - Raw Data Extraction (Claude Opus 4.5 or GPT-4)
    
    private func extractRawData(from text: String) async throws -> DocumentAnalysis {
        let systemPrompt = EliteDocumentAnalyzer.eliteExtractionPrompt
        
        let userPrompt = """
        DOCUMENT TEXT:
        
        \(text)
        
        Extract all information with extreme precision. Return ONLY valid JSON.
        """
        
        // 🔥 Try Claude Opus 4.5 first
        if config.hasAnthropicKey {
            do {
                usedProvider = .anthropic
                let analysis: DocumentAnalysis = try await AnthropicService.shared.generateStructuredJSON(
                    prompt: userPrompt,
                    systemPrompt: systemPrompt,
                    model: .claudeOpus45
                )
                print("✅ Claude Opus 4.5 extraction successful!")
                return analysis
            } catch {
                print("⚠️ Claude extraction failed, trying GPT-4: \(error)")
            }
        }
        
        // Fallback to GPT-4
        if config.hasOpenAIKey {
            usedProvider = .openAI
            let analysis: DocumentAnalysis = try await OpenAIService.shared.generateStructuredJSON(
                prompt: userPrompt,
                systemPrompt: systemPrompt,
                model: .gpt4o
            )
            return analysis
        }
        
        throw AnthropicError.missingAPIKey
    }
    
    // MARK: - Accelerator Scoring (Claude Opus 4.5)
    
    private func scoreForAccelerator(
        _ analysis: DocumentAnalysis,
        accelerator: AcceleratorTemplate
    ) async throws -> AcceleratorScore {
        let systemPrompt = EliteDocumentAnalyzer.scoringPrompt(for: accelerator)
        
        let userPrompt = """
        EXTRACTED DATA:
        
        Company: \(analysis.companyName ?? "Unknown")
        Industry: \(analysis.industry ?? "Unknown")
        Problem: \(analysis.problem ?? "Unknown")
        Solution: \(analysis.solution ?? "Unknown")
        Target Market: \(analysis.targetMarket ?? "Unknown")
        Competitors: \(analysis.competitors?.joined(separator: ", ") ?? "Unknown")
        Team: \(analysis.teamMembers?.joined(separator: ", ") ?? "Unknown")
        Funding Stage: \(analysis.fundingStage ?? "Unknown")
        Key Metrics: \(analysis.keyMetrics?.map { "\($0.key): \($0.value)" }.joined(separator: ", ") ?? "None")
        
        Score this startup for \(accelerator.name) acceptance.
        Return ONLY valid JSON with: criteriaScores (dict), overallScore (int), strengths (array), weaknesses (array), likelihood (string).
        """
        
        struct ScoringResponse: Codable {
            let criteriaScores: [String: Int]
            let overallScore: Int
            let strengths: [String]
            let weaknesses: [String]
            let likelihood: String
        }
        
        let response: ScoringResponse
        
        // 🔥 Use Claude Opus 4.5 for scoring
        if config.hasAnthropicKey {
            do {
                response = try await AnthropicService.shared.generateStructuredJSON(
                    prompt: userPrompt,
                    systemPrompt: systemPrompt,
                    model: .claudeOpus45
                )
            } catch {
                // Fallback to GPT-4
                guard config.hasOpenAIKey else { throw error }
                response = try await OpenAIService.shared.generateStructuredJSON(
                    prompt: userPrompt,
                    systemPrompt: systemPrompt,
                    model: .gpt4o
                )
            }
        } else if config.hasOpenAIKey {
            response = try await OpenAIService.shared.generateStructuredJSON(
                prompt: userPrompt,
                systemPrompt: systemPrompt,
                model: .gpt4o
            )
        } else {
            throw AnthropicError.missingAPIKey
        }
        
        let likelihood = parseLikelihood(response.likelihood)
        
        return AcceleratorScore(
            acceleratorId: accelerator.id,
            overallScore: response.overallScore,
            criteriaScores: response.criteriaScores,
            strengths: response.strengths,
            weaknesses: response.weaknesses,
            recommendations: [],  // Generated in next step
            likelihood: likelihood
        )
    }
    
    // MARK: - Helper
    
    private func parseLikelihood(_ string: String) -> AcceleratorScore.AcceptanceLikelihood {
        switch string.lowercased() {
        case "very high", "veryhigh":
            return .veryHigh
        case "high":
            return .high
        case "medium", "moderate":
            return .medium
        case "low":
            return .low
        default:
            return .veryLow
        }
    }
    
    // MARK: - Generate Recommendations (Claude Opus 4.5)
    
    private func generateAcceleratorRecommendations(
        _ score: AcceleratorScore,
        for accelerator: AcceleratorTemplate
    ) async throws -> AcceleratorScore {
        let systemPrompt = EliteDocumentAnalyzer.recommendationsPrompt(
            for: accelerator,
            score: score.overallScore
        )
        
        let userPrompt = """
        Current analysis:
        - Overall Score: \(score.overallScore)/100
        - Strengths: \(score.strengths.joined(separator: ", "))
        - Weaknesses: \(score.weaknesses.joined(separator: ", "))
        
        Generate 6-10 specific, actionable recommendations to improve their \(accelerator.name) application.
        Return ONLY valid JSON: {"recommendations": ["string", "string", ...]}
        """
        
        struct RecommendationsResponse: Codable {
            let recommendations: [String]
        }
        
        do {
            let response: RecommendationsResponse
            
            // 🔥 Use Claude Opus 4.5 for recommendations
            if config.hasAnthropicKey {
                response = try await AnthropicService.shared.generateStructuredJSON(
                    prompt: userPrompt,
                    systemPrompt: systemPrompt,
                    model: .claudeOpus45
                )
            } else if config.hasOpenAIKey {
                response = try await OpenAIService.shared.generateStructuredJSON(
                    prompt: userPrompt,
                    systemPrompt: systemPrompt,
                    model: .gpt4o
                )
            } else {
                return score  // Return without recommendations
            }
            
            return AcceleratorScore(
                acceleratorId: score.acceleratorId,
                overallScore: score.overallScore,
                criteriaScores: score.criteriaScores,
                strengths: score.strengths,
                weaknesses: score.weaknesses,
                recommendations: response.recommendations,
                likelihood: score.likelihood
            )
            
        } catch {
            print("⚠️ Recommendations generation failed: \(error)")
            // Return score without enhanced recommendations
            return score
        }
    }
}

// MARK: - Elite Prompts (for production GPT-4/5 integration)

extension EliteDocumentAnalyzer {
    /// The ULTIMATE document extraction prompt
    static let eliteExtractionPrompt = """
    You are an elite startup advisor who has reviewed 10,000+ pitch decks for Y Combinator, NVIDIA Inception, and top VCs.
    
    Your task: Extract EVERY piece of valuable information from this startup document with EXTREME precision.
    
    EXTRACT:
    1. Company Basics
       - Name, industry, one-liner
       - Stage (idea, MVP, growth, scale)
    
    2. Problem (CRITICAL)
       - WHO specifically has this problem?
       - HOW painful is it? (quantify if possible)
       - CURRENT workarounds and why they fail
       - Market timing (why now?)
    
    3. Solution
       - WHAT you built (be specific)
       - HOW it works (technical approach)
       - WHY it's 10X better
       - Unique insight or unfair advantage
    
    4. Market Opportunity
       - TAM, SAM, SOM (with calculations)
       - Market growth rate
       - Go-to-market strategy
    
    5. Traction & Metrics (CRITICAL)
       - Revenue (MRR, ARR, growth rate)
       - Users/customers (total, active, growth)
       - Key metrics (NRR, churn, CAC, LTV)
       - Milestones achieved
    
    6. Competition
       - Direct competitors
       - Your differentiation
       - Why you'll win
    
    7. Team (CRITICAL)
       - Founders (names, roles, credentials)
       - Relevant experience
       - Why this team can execute
       - Advisors/investors
    
    8. Financial
       - Funding raised
       - Current burn rate
       - Runway
       - Unit economics
    
    9. Technical (for AI/ML companies)
       - AI/ML approach
       - Model architecture
       - GPU/compute needs
       - Technical moat
    
    10. Ask
        - How much raising
        - Use of funds
        - Milestones to hit
    
    Return as structured JSON. Be SPECIFIC - extract numbers, names, metrics. Don't make things up.
    """
    
    /// Accelerator-specific scoring prompt
    static func scoringPrompt(for accelerator: AcceleratorTemplate) -> String {
        return """
        You are a \(accelerator.name) reviewer evaluating this startup for acceptance.
        
        \(accelerator.name) acceptance criteria:
        \(accelerator.criteria.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
        
        Key focus areas:
        \(accelerator.reviewerFocus.enumerated().map { "- \($0.element)" }.joined(separator: "\n"))
        
        \(accelerator.uniqueFocus)
        
        Based on the extracted data, provide:
        1. Score (0-100) for each criterion
        2. Overall acceptance score (0-100)
        3. Top 5 strengths (with emojis)
        4. Top 4 weaknesses (with specific gaps)
        5. Acceptance likelihood (Very High, High, Medium, Low, Very Low)
        
        Be BRUTALLY honest like a real \(accelerator.name) reviewer. Don't hold back.
        
        Return as JSON.
        """
    }
    
    /// Actionable recommendations prompt
    static func recommendationsPrompt(for accelerator: AcceleratorTemplate, score: Int) -> String {
        return """
        You are an advisor helping this startup get accepted into \(accelerator.name).
        
        Their current score: \(score)/100
        
        Generate 6-10 SPECIFIC, ACTIONABLE recommendations to improve their application.
        
        Each recommendation should:
        - Start with an emoji
        - Be specific (not generic advice)
        - Include exact actions to take
        - Reference \(accelerator.name)'s criteria
        - Use numbers/metrics when possible
        
        Examples of GOOD recommendations:
        ✅ "📊 Add bottom-up market sizing: Calculate # of target customers (50K) × ACV ($10K) = $500M SAM"
        ✅ "🎯 Include 2-3 customer quotes showing 10X improvement in specific metrics"
        
        Examples of BAD recommendations:
        ❌ "Improve your pitch deck"
        ❌ "Work on traction"
        
        Return as JSON array of strings.
        """
    }
}

