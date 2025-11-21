//
//  EliteDocumentAnalyzer.swift
//  Pitch Me
//
//  ELITE AI document analysis for accelerator-grade pitch decks
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class EliteDocumentAnalyzer: ObservableObject {
    static let shared = EliteDocumentAnalyzer()
    
    @Published var isAnalyzing = false
    @Published var analysisProgress: Double = 0.0
    
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
    
    // MARK: - Raw Data Extraction
    
    private func extractRawData(from text: String) async throws -> DocumentAnalysis {
        // Simulate GPT-4 extraction
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In production, this calls GPT-4/5 with elite extraction prompt
        return DocumentAnalysis(
            companyName: "TechCorp AI",
            industry: "Enterprise AI/ML",
            problem: "Enterprise data teams waste 60% of their time on data cleaning and preparation instead of analysis",
            solution: "Automated AI-powered data pipeline that cleans, validates, and enriches data in real-time using LLMs",
            targetMarket: "50,000 enterprise data teams in Fortune 5000 companies",
            competitors: ["Databricks", "Snowflake", "Fivetran"],
            keyMetrics: [
                "MRR": "$120K",
                "Growth": "25% MoM",
                "Customers": "15 enterprise",
                "NRR": "135%",
                "Churn": "3% annual"
            ],
            teamMembers: [
                "Jane Doe - CEO (ex-OpenAI, Stanford PhD in ML)",
                "John Smith - CTO (ex-Google Brain, built data infra at scale)",
                "Sarah Johnson - Head of Sales (ex-Databricks, 10+ years enterprise)"
            ],
            fundingStage: "Seed",
            fundingAmount: "$2M",
            extractedData: [
                "market_size": "$50B TAM, $5B SAM",
                "gpu_usage": "Uses NVIDIA A100s for model training",
                "technical_depth": "Custom transformer models, real-time inference",
                "unique_insight": "LLMs can understand data semantics better than rule-based systems"
            ]
        )
    }
    
    // MARK: - Accelerator Scoring
    
    private func scoreForAccelerator(
        _ analysis: DocumentAnalysis,
        accelerator: AcceleratorTemplate
    ) async throws -> AcceleratorScore {
        // Simulate AI scoring
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        var criteriaScores: [String: Int] = [:]
        var overallScore = 0
        var strengths: [String] = []
        var weaknesses: [String] = []
        
        // Score based on accelerator
        switch accelerator.id {
        case "yc":
            criteriaScores = [
                "Market Size": 85,
                "Team Quality": 95,
                "Traction": 75,
                "10X Better": 80,
                "Clarity": 90,
                "Technical Insight": 85
            ]
            
            strengths = [
                "🔥 Exceptional team with AI expertise from OpenAI and Google",
                "📈 Strong MoM growth (25%) shows product-market fit",
                "💰 Impressive NRR (135%) indicates strong customer value",
                "🎯 Clear problem in massive enterprise market",
                "⚡ Unique technical insight using LLMs for data understanding"
            ]
            
            weaknesses = [
                "⚠️ Need more specific TAM/SAM/SOM breakdown with bottom-up calc",
                "⚠️ Show clearer path to $100M ARR (unit economics)",
                "⚠️ Competitive moat needs more definition vs Databricks",
                "⚠️ Need proof of 10X better (customer testimonials, benchmarks)"
            ]
            
            overallScore = 83
            
        case "nvidia":
            criteriaScores = [
                "AI Technical Depth": 90,
                "GPU Utilization": 85,
                "Scalability": 80,
                "Team Expertise": 95,
                "Market Validation": 75,
                "Technical Differentiation": 85
            ]
            
            strengths = [
                "🚀 Deep AI expertise with PhDs from Stanford and Google Brain",
                "💻 Clear GPU utilization (A100s for training)",
                "🧠 Advanced ML architecture with custom transformers",
                "📊 Enterprise-ready with 15 customers",
                "⚡ Real-time inference at scale"
            ]
            
            weaknesses = [
                "⚠️ Need more specific GPU scaling roadmap",
                "⚠️ Show model performance benchmarks (accuracy, speed)",
                "⚠️ Explain why GPUs are essential (vs CPU-based solutions)",
                "⚠️ Demonstrate technical moat (model architecture details)"
            ]
            
            overallScore = 85
            
        default:
            overallScore = 80
        }
        
        let likelihood: AcceleratorScore.AcceptanceLikelihood
        if overallScore >= 85 {
            likelihood = .veryHigh
        } else if overallScore >= 75 {
            likelihood = .high
        } else if overallScore >= 60 {
            likelihood = .medium
        } else if overallScore >= 40 {
            likelihood = .low
        } else {
            likelihood = .veryLow
        }
        
        return AcceleratorScore(
            acceleratorId: accelerator.id,
            overallScore: overallScore,
            criteriaScores: criteriaScores,
            strengths: strengths,
            weaknesses: weaknesses,
            recommendations: [],  // Generated in next step
            likelihood: likelihood
        )
    }
    
    // MARK: - Generate Recommendations
    
    private func generateAcceleratorRecommendations(
        _ score: AcceleratorScore,
        for accelerator: AcceleratorTemplate
    ) async throws -> AcceleratorScore {
        // Simulate GPT-4 recommendations
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        var recommendations: [String] = []
        
        // Generate specific, actionable recommendations
        switch accelerator.id {
        case "yc":
            recommendations = [
                "📊 Add bottom-up market sizing: Calculate # of data teams × ACV to show path to $100M",
                "🎯 Include 2-3 customer quotes showing 10X improvement (time saved, accuracy gained)",
                "💪 Show competitive moat: Explain why your LLM approach is defensible vs incumbents",
                "📈 Add financial projection: Show path from $120K MRR to $10M ARR in 24 months",
                "🔥 Lead with your strongest metric: 25% MoM growth + 135% NRR = world-class retention",
                "👥 Emphasize founder-market fit: Why Jane from OpenAI is uniquely positioned to win"
            ]
            
        case "nvidia":
            recommendations = [
                "🖥️ Create GPU utilization slide: Show current A100 usage → future H100 scaling plan",
                "⚡ Add performance benchmarks: Compare your solution vs CPU-based alternatives (speed, accuracy)",
                "🏗️ Diagram your AI architecture: Show how you use GPUs for training + inference at scale",
                "📊 Quantify GPU economics: Show cost per inference, how it improves with scale",
                "🎯 Highlight NVIDIA ecosystem: Mention CUDA, TensorRT, any NVIDIA partnerships",
                "🚀 Show scaling roadmap: Map customers → GPU needs (10 customers = X GPUs, 100 = Y)"
            ]
            
        default:
            recommendations = [
                "Strengthen your value proposition",
                "Add more traction metrics",
                "Improve team slide",
                "Show clearer market opportunity"
            ]
        }
        
        return AcceleratorScore(
            acceleratorId: score.acceleratorId,
            overallScore: score.overallScore,
            criteriaScores: score.criteriaScores,
            strengths: score.strengths,
            weaknesses: score.weaknesses,
            recommendations: recommendations,
            likelihood: score.likelihood
        )
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

