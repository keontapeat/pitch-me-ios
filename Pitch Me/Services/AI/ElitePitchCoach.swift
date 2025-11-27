//
//  ElitePitchCoach.swift
//  Pitch Me
//
//  🔥🔥🔥 ELITE AI PITCH COACH 🔥🔥🔥
//  Real-time scoring, feedback, and optimization
//  Get your deck YC-ready, VC-ready, accelerator-ready
//

import Foundation
import SwiftUI
import Combine

// MARK: - Pitch Score

struct PitchScore: Codable, Identifiable {
    let id: String
    let overallScore: Int  // 0-100
    let categoryScores: [String: Int]
    let strengths: [String]
    let weaknesses: [String]
    let criticalIssues: [String]
    let recommendations: [PitchRecommendation]
    let competitivePosition: String
    let investorReadiness: InvestorReadiness
    let timestamp: Date
    
    enum InvestorReadiness: String, Codable {
        case ready = "Ready to Pitch"
        case almostReady = "Almost Ready"
        case needsWork = "Needs Work"
        case notReady = "Not Ready"
        
        var color: String {
            switch self {
            case .ready: return "success"
            case .almostReady: return "lime"
            case .needsWork: return "warning"
            case .notReady: return "error"
            }
        }
        
        var icon: String {
            switch self {
            case .ready: return "checkmark.seal.fill"
            case .almostReady: return "checkmark.circle.fill"
            case .needsWork: return "exclamationmark.triangle.fill"
            case .notReady: return "xmark.circle.fill"
            }
        }
    }
}

// MARK: - Pitch Recommendation

struct PitchRecommendation: Codable, Identifiable {
    let id: String
    let category: RecommendationCategory
    let priority: Priority
    let title: String
    let description: String
    let actionItems: [String]
    let slideIndex: Int?  // Which slide to fix
    let estimatedImpact: String
    
    enum RecommendationCategory: String, Codable, CaseIterable {
        case story = "Story & Narrative"
        case problem = "Problem Definition"
        case solution = "Solution Clarity"
        case market = "Market Size"
        case traction = "Traction & Metrics"
        case team = "Team Presentation"
        case competition = "Competitive Analysis"
        case financials = "Financials"
        case ask = "The Ask"
        case design = "Visual Design"
        
        var icon: String {
            switch self {
            case .story: return "book.fill"
            case .problem: return "exclamationmark.triangle.fill"
            case .solution: return "lightbulb.fill"
            case .market: return "chart.pie.fill"
            case .traction: return "chart.line.uptrend.xyaxis"
            case .team: return "person.3.fill"
            case .competition: return "flag.2.crossed.fill"
            case .financials: return "dollarsign.circle.fill"
            case .ask: return "hand.raised.fill"
            case .design: return "paintbrush.fill"
            }
        }
    }
    
    enum Priority: String, Codable {
        case critical = "Critical"
        case high = "High"
        case medium = "Medium"
        case low = "Low"
        
        var color: String {
            switch self {
            case .critical: return "error"
            case .high: return "warning"
            case .medium: return "lime"
            case .low: return "secondary"
            }
        }
    }
}

// MARK: - Question Bank

struct InterviewQuestion: Codable, Identifiable {
    let id: String
    let question: String
    let category: String
    let difficulty: Difficulty
    let tips: [String]
    let sampleAnswer: String?
    let redFlags: [String]
    let source: String  // Which accelerator/VC asks this
    
    enum Difficulty: String, Codable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        case killer = "Killer Question"
    }
}

// MARK: - Elite Pitch Coach Service

@MainActor
final class ElitePitchCoach: ObservableObject {
    static let shared = ElitePitchCoach()
    
    @Published var isAnalyzing = false
    @Published var progress: Double = 0.0
    @Published var currentStep: String = ""
    @Published var latestScore: PitchScore?
    
    private let ensemble = EliteAIEnsemble.shared
    private let config = APIConfig.shared
    
    private init() {}
    
    // MARK: - Score Deck
    
    func scoreDeck(_ deck: Deck, for target: AcceleratorTemplate? = nil) async throws -> PitchScore {
        isAnalyzing = true
        progress = 0.1
        currentStep = "Analyzing your pitch deck..."
        
        let prompt = buildScoringPrompt(deck: deck, target: target)
        
        progress = 0.3
        currentStep = "Running elite AI analysis..."
        
        let result: EnsembleResult<PitchScoreResponse> = try await ensemble.generateWithBestAI(
            prompt: prompt,
            systemPrompt: eliteScoringSystemPrompt,
            taskType: .pitchScoring
        )
        
        progress = 0.8
        currentStep = "Generating recommendations..."
        
        let score = convertToPitchScore(result.result)
        
        progress = 1.0
        currentStep = "Analysis complete!"
        latestScore = score
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        isAnalyzing = false
        
        return score
    }
    
    // MARK: - Generate Interview Questions
    
    func generateInterviewQuestions(
        for deck: Deck,
        target: AcceleratorTemplate,
        count: Int = 10
    ) async throws -> [InterviewQuestion] {
        let prompt = """
        Generate \(count) interview questions that \(target.name) would ask about this pitch:
        
        DECK: \(deck.title)
        USE CASE: \(deck.useCase.displayName)
        
        SLIDES:
        \(deck.slides.map { "- \($0.title): \($0.bullets.joined(separator: "; "))" }.joined(separator: "\n"))
        
        ACCELERATOR'S KEY QUESTIONS:
        \(target.keyQuestions.joined(separator: "\n"))
        
        WHAT THEY FOCUS ON:
        \(target.reviewerFocus.joined(separator: "\n"))
        
        Generate questions ranging from easy to "killer questions" that could make or break the pitch.
        Include tips for answering and red flags to avoid.
        
        Return JSON array with: id, question, category, difficulty (easy/medium/hard/killer), tips (array), sampleAnswer, redFlags (array), source
        """
        
        let result: EnsembleResult<[InterviewQuestion]> = try await ensemble.generateWithBestAI(
            prompt: prompt,
            systemPrompt: questionGenerationSystemPrompt,
            taskType: .questionGeneration
        )
        
        return result.result
    }
    
    // MARK: - Get Slide-by-Slide Feedback
    
    func getSlideBySlide(for deck: Deck) async throws -> [SlideFeedback] {
        let prompt = """
        Analyze each slide of this pitch deck and provide specific, actionable feedback:
        
        DECK: \(deck.title)
        
        SLIDES:
        \(deck.slides.enumerated().map { "Slide \($0.offset + 1) - \($0.element.title):\n\($0.element.bullets.joined(separator: "\n"))" }.joined(separator: "\n\n"))
        
        For each slide, provide:
        1. Score (0-100)
        2. What's working well
        3. What needs improvement
        4. Specific rewrite suggestions
        5. Design tips
        
        Return JSON array with: slideIndex, score, strengths (array), improvements (array), rewriteSuggestions (array), designTips (array)
        """
        
        let result: EnsembleResult<[SlideFeedback]> = try await ensemble.generateWithBestAI(
            prompt: prompt,
            systemPrompt: slideAnalysisSystemPrompt,
            taskType: .pitchScoring
        )
        
        return result.result
    }
    
    // MARK: - Compare to Successful Decks
    
    func compareToSuccessful(deck: Deck, target: AcceleratorTemplate) async throws -> ComparisonResult {
        let prompt = """
        Compare this pitch deck to successful \(target.name) applications:
        
        DECK: \(deck.title)
        USE CASE: \(deck.useCase.displayName)
        
        SLIDES:
        \(deck.slides.map { "- \($0.title): \($0.bullets.joined(separator: "; "))" }.joined(separator: "\n"))
        
        Compare against the patterns of successful \(target.name) companies like:
        - Airbnb, Dropbox, Stripe (for YC)
        - Successful AI companies (for NVIDIA)
        - Top portfolio companies
        
        Identify:
        1. What successful decks do that this one doesn't
        2. Common patterns this deck is missing
        3. Specific improvements to match successful decks
        
        Return JSON with: similarityScore (0-100), matchingPatterns (array), missingPatterns (array), successfulExamples (array with company names), gapAnalysis (string), improvementPlan (array of specific actions)
        """
        
        let result: EnsembleResult<ComparisonResult> = try await ensemble.generateWithBestAI(
            prompt: prompt,
            systemPrompt: comparisonSystemPrompt,
            taskType: .competitiveAnalysis
        )
        
        return result.result
    }
    
    // MARK: - Prompts
    
    private func buildScoringPrompt(deck: Deck, target: AcceleratorTemplate?) -> String {
        var prompt = """
        Score this pitch deck for investor/accelerator readiness:
        
        DECK TITLE: \(deck.title)
        USE CASE: \(deck.useCase.displayName)
        SLIDE COUNT: \(deck.slides.count)
        
        SLIDES:
        """
        
        for (index, slide) in deck.slides.enumerated() {
            prompt += "\n\nSlide \(index + 1) - \(slide.title):"
            prompt += "\n" + slide.bullets.map { "• \($0)" }.joined(separator: "\n")
        }
        
        if let target = target {
            prompt += """
            
            
            TARGET: \(target.name)
            
            CRITERIA THEY LOOK FOR:
            \(target.criteria.joined(separator: "\n"))
            
            KEY QUESTIONS:
            \(target.keyQuestions.joined(separator: "\n"))
            """
        }
        
        prompt += """
        
        
        Score 0-100 for each category:
        - Story & Narrative Flow
        - Problem Definition
        - Solution Clarity
        - Market Opportunity
        - Traction & Metrics
        - Team Presentation
        - Competitive Positioning
        - Financial Viability
        - Visual Design
        - Overall Pitch Quality
        
        Return JSON with: overallScore, categoryScores (dict), strengths (array), weaknesses (array), criticalIssues (array), recommendations (array with id, category, priority, title, description, actionItems, slideIndex, estimatedImpact), competitivePosition (string), investorReadiness (ready/almostReady/needsWork/notReady)
        """
        
        return prompt
    }
    
    private var eliteScoringSystemPrompt: String {
        """
        You are an ELITE pitch deck evaluator who has:
        - Reviewed 10,000+ pitch decks
        - Worked at Y Combinator, Sequoia, and a16z
        - Helped raise $2B+ in funding
        - 95% accuracy in predicting funding success
        
        Your scoring is BRUTALLY HONEST but constructive. You know exactly what separates a $100M deck from a rejection.
        
        SCORING FRAMEWORK:
        90-100: Exceptional. Would get multiple term sheets.
        80-89: Strong. High likelihood of funding.
        70-79: Good. Competitive but needs polish.
        60-69: Average. Significant gaps to address.
        50-59: Below average. Major rework needed.
        Below 50: Not investor-ready. Fundamental issues.
        
        WHAT MAKES A GREAT DECK:
        1. Clear, compelling narrative arc
        2. Quantified problem with urgency
        3. 10X better solution with proof
        4. Massive, growing market
        5. Strong traction with momentum
        6. World-class team
        7. Defensible competitive position
        8. Clear path to profitability
        9. Specific, reasonable ask
        10. Professional, clean design
        
        Be specific. Reference actual content. Give actionable feedback.
        Return ONLY valid JSON.
        """
    }
    
    private var questionGenerationSystemPrompt: String {
        """
        You are an expert interviewer who has conducted 5,000+ pitch meetings for top accelerators and VCs.
        
        Generate questions that:
        1. Test the founder's depth of understanding
        2. Expose potential weaknesses
        3. Assess team quality and coachability
        4. Evaluate market knowledge
        5. Probe financial acumen
        
        Include "killer questions" that separate great founders from good ones.
        Return ONLY valid JSON array.
        """
    }
    
    private var slideAnalysisSystemPrompt: String {
        """
        You are a pitch deck design expert who has created decks for Airbnb, Stripe, and other unicorns.
        
        Analyze each slide for:
        1. Content quality and clarity
        2. Visual hierarchy
        3. Message effectiveness
        4. Investor impact
        
        Provide specific, actionable rewrites and improvements.
        Return ONLY valid JSON array.
        """
    }
    
    private var comparisonSystemPrompt: String {
        """
        You are a pitch deck analyst with deep knowledge of successful startup decks.
        
        You've studied the original decks of:
        - Airbnb ($600M raised)
        - Uber ($24B raised)
        - Stripe ($2B raised)
        - Dropbox ($1.7B raised)
        - And 500+ other successful companies
        
        Identify patterns, gaps, and specific improvements.
        Return ONLY valid JSON.
        """
    }
    
    // MARK: - Helpers
    
    private func convertToPitchScore(_ response: PitchScoreResponse) -> PitchScore {
        PitchScore(
            id: UUID().uuidString,
            overallScore: response.overallScore,
            categoryScores: response.categoryScores,
            strengths: response.strengths,
            weaknesses: response.weaknesses,
            criticalIssues: response.criticalIssues ?? [],
            recommendations: response.recommendations.map { rec in
                PitchRecommendation(
                    id: rec.id ?? UUID().uuidString,
                    category: PitchRecommendation.RecommendationCategory(rawValue: rec.category) ?? .story,
                    priority: PitchRecommendation.Priority(rawValue: rec.priority) ?? .medium,
                    title: rec.title,
                    description: rec.description,
                    actionItems: rec.actionItems,
                    slideIndex: rec.slideIndex,
                    estimatedImpact: rec.estimatedImpact ?? "Medium"
                )
            },
            competitivePosition: response.competitivePosition,
            investorReadiness: PitchScore.InvestorReadiness(rawValue: response.investorReadiness) ?? .needsWork,
            timestamp: Date()
        )
    }
}

// MARK: - Response Models

struct PitchScoreResponse: Codable {
    let overallScore: Int
    let categoryScores: [String: Int]
    let strengths: [String]
    let weaknesses: [String]
    let criticalIssues: [String]?
    let recommendations: [RecommendationResponse]
    let competitivePosition: String
    let investorReadiness: String
    
    struct RecommendationResponse: Codable {
        let id: String?
        let category: String
        let priority: String
        let title: String
        let description: String
        let actionItems: [String]
        let slideIndex: Int?
        let estimatedImpact: String?
    }
}

struct SlideFeedback: Codable, Identifiable {
    var id: String { "\(slideIndex)" }
    let slideIndex: Int
    let score: Int
    let strengths: [String]
    let improvements: [String]
    let rewriteSuggestions: [String]
    let designTips: [String]
}

struct ComparisonResult: Codable {
    let similarityScore: Int
    let matchingPatterns: [String]
    let missingPatterns: [String]
    let successfulExamples: [String]
    let gapAnalysis: String
    let improvementPlan: [String]
}

