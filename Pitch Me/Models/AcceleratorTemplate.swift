//
//  AcceleratorTemplate.swift
//  Pitch Me
//
//  Elite accelerator-specific templates and criteria
//

import Foundation

// MARK: - Accelerator Template

struct AcceleratorTemplate: Identifiable, Codable {
    let id: String
    let name: String
    let shortName: String
    let description: String
    let logoName: String
    let criteria: [String]
    let slideStructure: [AcceleratorSlide]
    let keyQuestions: [String]
    let successMetrics: [String]
    let reviewerFocus: [String]
    
    // What makes this accelerator unique
    var uniqueFocus: String
    var idealCompanyProfile: String
    var acceptanceRate: String
}

// MARK: - Accelerator Slide

struct AcceleratorSlide: Codable {
    let title: String
    let layoutType: String
    let requiredContent: [String]
    let tips: [String]
    let examples: [String]?
}

// MARK: - Predefined Accelerators

extension AcceleratorTemplate {
    /// Y Combinator - The world's most prestigious startup accelerator
    static let yCombinator = AcceleratorTemplate(
        id: "yc",
        name: "Y Combinator",
        shortName: "YC",
        description: "The world's most prestigious startup accelerator. 3% acceptance rate.",
        logoName: "yc_logo",
        criteria: [
            "10X better than existing solutions",
            "Huge market opportunity ($1B+)",
            "Strong founding team",
            "Clear path to product-market fit",
            "Evidence of growth/traction",
            "Technical advantage or insight"
        ],
        slideStructure: [
            AcceleratorSlide(
                title: "One-liner",
                layoutType: "title_only",
                requiredContent: ["Company name", "What you do in one sentence"],
                tips: ["Be crystal clear", "No buzzwords", "Make it memorable"],
                examples: ["Airbnb: Book rooms with locals, rather than hotels", "Dropbox: It's like your hard drive, but in the cloud"]
            ),
            AcceleratorSlide(
                title: "Problem",
                layoutType: "title_bullets",
                requiredContent: ["Who has this problem?", "How painful is it?", "What's the impact?"],
                tips: ["Quantify the pain", "Show you deeply understand it", "Make it relatable"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Solution",
                layoutType: "title_bullets",
                requiredContent: ["How you solve it", "Why now?", "Your unique insight"],
                tips: ["Show the 'aha' moment", "Explain your unfair advantage", "Demo if possible"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Market Size",
                layoutType: "metric",
                requiredContent: ["TAM", "SAM", "SOM", "Growth rate"],
                tips: ["Be realistic", "Bottom-up is better than top-down", "Show why it's big AND growing"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Traction",
                layoutType: "metric",
                requiredContent: ["Key metrics", "Growth rate", "What's working"],
                tips: ["Show momentum", "Month-over-month growth", "Quality > Quantity"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Team",
                layoutType: "team",
                requiredContent: ["Founders", "Relevant experience", "Why you?"],
                tips: ["Show you can execute", "Highlight domain expertise", "Chemistry matters"],
                examples: nil
            )
        ],
        keyQuestions: [
            "What do you make?",
            "Why now?",
            "What's your unfair advantage?",
            "How do you grow?",
            "Who are your users?",
            "How do you make money?",
            "Why you?"
        ],
        successMetrics: [
            "Clear problem/solution fit",
            "Massive market ($1B+ TAM)",
            "10X better than alternatives",
            "Strong unit economics",
            "Compound growth",
            "Founder-market fit"
        ],
        reviewerFocus: [
            "Founder quality",
            "Market size",
            "Traction/growth",
            "Technical insight",
            "Clarity of vision"
        ],
        uniqueFocus: "YC looks for EXTREME growth potential. They want companies that can be $1B+ unicorns.",
        idealCompanyProfile: "Technical founders building 10X better solutions for huge markets",
        acceptanceRate: "~3% (most competitive in the world)"
    )
    
    /// NVIDIA Inception - For AI/ML startups leveraging NVIDIA tech
    static let nvidiaInception = AcceleratorTemplate(
        id: "nvidia",
        name: "NVIDIA Inception",
        shortName: "NVIDIA",
        description: "Premier accelerator for AI startups leveraging NVIDIA technology",
        logoName: "nvidia_logo",
        criteria: [
            "AI/ML/Deep Learning focus",
            "Uses or plans to use NVIDIA GPUs",
            "Technical depth in AI",
            "Scalable AI solution",
            "Clear path to GPU utilization",
            "Strong technical team"
        ],
        slideStructure: [
            AcceleratorSlide(
                title: "AI Solution Overview",
                layoutType: "title_bullets",
                requiredContent: ["What AI problem you solve", "Your approach", "Why AI is essential"],
                tips: ["Show technical depth", "Explain your AI architecture", "Prove you need GPUs"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Technical Architecture",
                layoutType: "title_two_column",
                requiredContent: ["AI models used", "Infrastructure needs", "NVIDIA GPU usage"],
                tips: ["Be specific about GPU requirements", "Show you understand the tech", "Highlight performance gains"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Market & Use Case",
                layoutType: "title_bullets",
                requiredContent: ["Target industry", "Specific use case", "Market size"],
                tips: ["Show AI is the right solution", "Prove the need for speed/scale", "Enterprise focus is good"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Competitive Advantage",
                layoutType: "title_bullets",
                requiredContent: ["Your AI moat", "Technical differentiation", "Performance metrics"],
                tips: ["Quantify your advantage", "Show benchmarks", "Explain why it's defensible"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Traction & Metrics",
                layoutType: "metric",
                requiredContent: ["Model performance", "Customer metrics", "GPU utilization"],
                tips: ["Show AI is working", "Prove scalability", "Share accuracy/speed gains"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Team & Expertise",
                layoutType: "team",
                requiredContent: ["AI expertise", "Domain knowledge", "Technical background"],
                tips: ["Highlight AI credentials", "Show you can execute", "PhDs/publications are a plus"],
                examples: nil
            )
        ],
        keyQuestions: [
            "What AI problem are you solving?",
            "Why do you need GPUs?",
            "What's your AI architecture?",
            "How do you scale?",
            "What's your competitive moat?",
            "Who are your customers?"
        ],
        successMetrics: [
            "Strong AI/ML foundation",
            "Clear GPU utilization path",
            "Technical differentiation",
            "Scalable architecture",
            "Enterprise readiness",
            "Team expertise in AI"
        ],
        reviewerFocus: [
            "AI technical depth",
            "GPU/compute needs",
            "Scalability",
            "Team credentials",
            "Market validation"
        ],
        uniqueFocus: "NVIDIA wants AI-first companies that will grow their GPU usage as they scale",
        idealCompanyProfile: "Technical teams building enterprise-grade AI solutions with clear GPU needs",
        acceptanceRate: "~15% (selective but more accessible than YC)"
    )
    
    /// Techstars - Global network, mentor-driven
    static let techstars = AcceleratorTemplate(
        id: "techstars",
        name: "Techstars",
        shortName: "Techstars",
        description: "Global mentor-driven accelerator with strong corporate partnerships",
        logoName: "techstars_logo",
        criteria: [
            "Coachable founders",
            "Clear market opportunity",
            "Strong team dynamics",
            "Mentor-driven growth mindset",
            "Scalable business model",
            "Open to feedback"
        ],
        slideStructure: [],
        keyQuestions: [
            "Why this problem?",
            "Why you?",
            "Why now?",
            "What do you need help with?",
            "How will mentors accelerate you?"
        ],
        successMetrics: [
            "Founder coachability",
            "Team chemistry",
            "Clear problem/solution",
            "Willingness to pivot",
            "Network leverage potential"
        ],
        reviewerFocus: [
            "Founder quality",
            "Coachability",
            "Team dynamics",
            "Market opportunity",
            "Execution speed"
        ],
        uniqueFocus: "Techstars is all about mentorship. They want coachable founders who can move fast.",
        idealCompanyProfile: "Strong teams open to feedback, building scalable businesses",
        acceptanceRate: "~1-2% (very competitive)"
    )
    
    static let allTemplates: [AcceleratorTemplate] = [
        .yCombinator,
        .nvidiaInception,
        .techstars
    ]
}

// MARK: - Accelerator Score

struct AcceleratorScore: Codable {
    let acceleratorId: String
    let overallScore: Int  // 0-100
    let criteriaScores: [String: Int]
    let strengths: [String]
    let weaknesses: [String]
    let recommendations: [String]
    let likelihood: AcceptanceLikelihood
    
    enum AcceptanceLikelihood: String, Codable {
        case veryHigh = "Very High (90%+)"
        case high = "High (70-90%)"
        case medium = "Medium (40-70%)"
        case low = "Low (20-40%)"
        case veryLow = "Very Low (<20%)"
        
        var color: String {
            switch self {
            case .veryHigh: return "success"
            case .high: return "lime"
            case .medium: return "warning"
            case .low: return "error"
            case .veryLow: return "error"
            }
        }
    }
}

