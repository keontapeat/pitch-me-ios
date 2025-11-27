//
//  AcceleratorTemplate.swift
//  Pitch Me
//
//  🔥 ELITE accelerator-specific templates and criteria 🔥
//  Optimized for YC, NVIDIA Inception, Google Cloud, Techstars, 500 Global, a16z, Sequoia & more
//

import Foundation

// MARK: - Accelerator Type

enum AcceleratorType: String, Codable, CaseIterable {
    case accelerator = "Accelerator"
    case vcFirm = "VC Firm"
    case corporateProgram = "Corporate Program"
    case grantProgram = "Grant Program"
    
    var icon: String {
        switch self {
        case .accelerator: return "bolt.fill"
        case .vcFirm: return "dollarsign.circle.fill"
        case .corporateProgram: return "building.2.fill"
        case .grantProgram: return "gift.fill"
        }
    }
}

// MARK: - Accelerator Template

struct AcceleratorTemplate: Identifiable, Codable {
    let id: String
    let name: String
    let shortName: String
    let description: String
    let logoName: String
    let type: AcceleratorType
    let criteria: [String]
    let slideStructure: [AcceleratorSlide]
    let keyQuestions: [String]
    let successMetrics: [String]
    let reviewerFocus: [String]
    
    // What makes this accelerator unique
    var uniqueFocus: String
    var idealCompanyProfile: String
    var acceptanceRate: String
    
    // Investment details
    var investmentAmount: String?
    var equityTaken: String?
    var programLength: String?
    var location: String?
    var website: String?
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
        type: .accelerator,
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
        acceptanceRate: "~3% (most competitive in the world)",
        investmentAmount: "$500K",
        equityTaken: "7%",
        programLength: "3 months",
        location: "San Francisco, CA",
        website: "https://www.ycombinator.com"
    )
    
    /// NVIDIA Inception - For AI/ML startups leveraging NVIDIA tech
    static let nvidiaInception = AcceleratorTemplate(
        id: "nvidia",
        name: "NVIDIA Inception",
        shortName: "NVIDIA",
        description: "Premier accelerator for AI startups leveraging NVIDIA technology",
        logoName: "nvidia_logo",
        type: .corporateProgram,
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
        acceptanceRate: "~15% (selective but more accessible than YC)",
        investmentAmount: "Up to $100K in GPU credits",
        equityTaken: "0%",
        programLength: "Ongoing membership",
        location: "Virtual / Global",
        website: "https://www.nvidia.com/inception"
    )
    
    /// Techstars - Global network, mentor-driven
    static let techstars = AcceleratorTemplate(
        id: "techstars",
        name: "Techstars",
        shortName: "Techstars",
        description: "Global mentor-driven accelerator with strong corporate partnerships",
        logoName: "techstars_logo",
        type: .accelerator,
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
        acceptanceRate: "~1-2% (very competitive)",
        investmentAmount: "$120K",
        equityTaken: "6%",
        programLength: "3 months",
        location: "Multiple cities worldwide",
        website: "https://www.techstars.com"
    )
    
    /// 500 Global (formerly 500 Startups)
    static let fiveHundredGlobal = AcceleratorTemplate(
        id: "500global",
        name: "500 Global",
        shortName: "500",
        description: "One of the most active early-stage investors globally",
        logoName: "500_logo",
        type: .accelerator,
        criteria: [
            "Growth-stage ready",
            "International scalability",
            "Strong unit economics",
            "Diverse founding teams welcome",
            "Clear go-to-market strategy",
            "Product-market fit evidence"
        ],
        slideStructure: [],
        keyQuestions: [
            "What's your growth rate?",
            "How do you acquire customers?",
            "What's your CAC/LTV?",
            "Can this scale globally?",
            "What's your moat?"
        ],
        successMetrics: [
            "Revenue growth",
            "Customer acquisition efficiency",
            "International expansion potential",
            "Team diversity",
            "Market timing"
        ],
        reviewerFocus: [
            "Growth metrics",
            "Unit economics",
            "Market size",
            "Team execution",
            "Scalability"
        ],
        uniqueFocus: "500 Global focuses on growth-stage startups with strong metrics and global ambition",
        idealCompanyProfile: "Post-PMF startups with proven traction looking to scale internationally",
        acceptanceRate: "~3% (highly competitive)",
        investmentAmount: "$150K",
        equityTaken: "6%",
        programLength: "4 months",
        location: "San Francisco + Global",
        website: "https://500.co"
    )
    
    /// Google Cloud for Startups
    static let googleCloud = AcceleratorTemplate(
        id: "google_cloud",
        name: "Google Cloud for Startups",
        shortName: "GCP",
        description: "Up to $200K in cloud credits + technical support from Google",
        logoName: "google_cloud_logo",
        type: .corporateProgram,
        criteria: [
            "Tech startup (Seed to Series A)",
            "Uses or plans to use Google Cloud",
            "Scalable technology solution",
            "Backed by approved VC/accelerator",
            "Less than 5 years old",
            "Under $15M in funding"
        ],
        slideStructure: [
            AcceleratorSlide(
                title: "Company Overview",
                layoutType: "title_bullets",
                requiredContent: ["What you do", "Stage/funding", "Team size"],
                tips: ["Be concise", "Highlight tech stack", "Show cloud needs"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Technical Architecture",
                layoutType: "title_two_column",
                requiredContent: ["Current infrastructure", "GCP services needed", "Scale requirements"],
                tips: ["Show you understand GCP", "Highlight specific services", "Quantify compute needs"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Growth & Traction",
                layoutType: "metric",
                requiredContent: ["User metrics", "Growth rate", "Infrastructure scaling needs"],
                tips: ["Show why you need cloud scale", "Quantify growth trajectory", "Project future needs"],
                examples: nil
            )
        ],
        keyQuestions: [
            "What GCP services will you use?",
            "What's your current cloud spend?",
            "How will credits accelerate growth?",
            "What's your scaling roadmap?",
            "Who are your investors?"
        ],
        successMetrics: [
            "Clear GCP usage plan",
            "Scalable architecture",
            "Growth trajectory",
            "VC backing",
            "Technical sophistication"
        ],
        reviewerFocus: [
            "Cloud usage potential",
            "Technical architecture",
            "Growth metrics",
            "Investor quality",
            "Market opportunity"
        ],
        uniqueFocus: "Google wants startups that will become large GCP customers as they scale",
        idealCompanyProfile: "VC-backed startups with cloud-native architecture and high growth",
        acceptanceRate: "~20% (more accessible with VC backing)",
        investmentAmount: "Up to $200K in GCP credits",
        equityTaken: "0%",
        programLength: "2 years",
        location: "Virtual / Global",
        website: "https://cloud.google.com/startup"
    )
    
    /// AWS Activate
    static let awsActivate = AcceleratorTemplate(
        id: "aws_activate",
        name: "AWS Activate",
        shortName: "AWS",
        description: "Up to $100K in AWS credits + technical support",
        logoName: "aws_logo",
        type: .corporateProgram,
        criteria: [
            "Early-stage startup",
            "Uses or plans to use AWS",
            "Funded or in accelerator",
            "Under 10 years old",
            "Less than $100M in funding",
            "Not previously received Activate credits"
        ],
        slideStructure: [],
        keyQuestions: [
            "What AWS services do you use?",
            "What's your monthly cloud spend?",
            "How will credits help you grow?",
            "What's your technical architecture?",
            "Are you part of an accelerator?"
        ],
        successMetrics: [
            "AWS service utilization",
            "Growth potential",
            "Technical architecture",
            "Accelerator/VC affiliation",
            "Scaling needs"
        ],
        reviewerFocus: [
            "AWS usage",
            "Growth trajectory",
            "Technical depth",
            "Accelerator backing"
        ],
        uniqueFocus: "AWS wants to capture startups early and grow with them",
        idealCompanyProfile: "Any early-stage startup building on AWS",
        acceptanceRate: "~40% (most accessible cloud program)",
        investmentAmount: "Up to $100K in AWS credits",
        equityTaken: "0%",
        programLength: "2 years",
        location: "Virtual / Global",
        website: "https://aws.amazon.com/activate"
    )
    
    /// Microsoft for Startups (Founders Hub)
    static let microsoftFoundersHub = AcceleratorTemplate(
        id: "microsoft_founders",
        name: "Microsoft for Startups",
        shortName: "MSFT",
        description: "Up to $150K in Azure credits + GitHub Enterprise + more",
        logoName: "microsoft_logo",
        type: .corporateProgram,
        criteria: [
            "B2B or tech-enabled startup",
            "Building on Azure or Microsoft stack",
            "Less than 7 years old",
            "Under $500M valuation",
            "Working product or MVP",
            "Committed to using Microsoft tech"
        ],
        slideStructure: [],
        keyQuestions: [
            "What Microsoft services will you use?",
            "What's your B2B strategy?",
            "How does Azure fit your architecture?",
            "What's your enterprise sales motion?",
            "How will you leverage the Microsoft ecosystem?"
        ],
        successMetrics: [
            "Azure/Microsoft usage plan",
            "B2B focus",
            "Enterprise readiness",
            "Technical architecture",
            "Growth metrics"
        ],
        reviewerFocus: [
            "Microsoft stack alignment",
            "Enterprise potential",
            "B2B model",
            "Technical depth"
        ],
        uniqueFocus: "Microsoft wants B2B startups that will sell to enterprises using Microsoft",
        idealCompanyProfile: "B2B startups building enterprise solutions on Azure",
        acceptanceRate: "~30% (accessible for B2B companies)",
        investmentAmount: "Up to $150K in Azure credits",
        equityTaken: "0%",
        programLength: "Ongoing",
        location: "Virtual / Global",
        website: "https://www.microsoft.com/startups"
    )
    
    // MARK: - VC Firms
    
    /// Andreessen Horowitz (a16z)
    static let a16z = AcceleratorTemplate(
        id: "a16z",
        name: "Andreessen Horowitz",
        shortName: "a16z",
        description: "Top-tier VC known for bold bets on transformative technology",
        logoName: "a16z_logo",
        type: .vcFirm,
        criteria: [
            "Transformative technology",
            "Exceptional founding team",
            "Massive market opportunity",
            "Technical moat",
            "Network effects potential",
            "Category-defining vision"
        ],
        slideStructure: [
            AcceleratorSlide(
                title: "Vision",
                layoutType: "title_only",
                requiredContent: ["Big, bold vision", "Why this matters", "10-year view"],
                tips: ["Think BIG", "Be contrarian", "Show conviction"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Why Now",
                layoutType: "title_bullets",
                requiredContent: ["Technology shift", "Market timing", "Why this moment"],
                tips: ["Show the inflection point", "Explain what changed", "Be specific"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Product & Traction",
                layoutType: "metric",
                requiredContent: ["Product demo", "Key metrics", "Growth trajectory"],
                tips: ["Show don't tell", "Metrics that matter", "Compound growth"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Market Size",
                layoutType: "metric",
                requiredContent: ["TAM", "Market dynamics", "Expansion potential"],
                tips: ["Think bigger", "Show the wedge", "Explain market creation"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Team",
                layoutType: "team",
                requiredContent: ["Founders", "Why you'll win", "Unfair advantages"],
                tips: ["Show founder-market fit", "Highlight superpowers", "Be authentic"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "The Ask",
                layoutType: "title_bullets",
                requiredContent: ["Raise amount", "Use of funds", "Milestones"],
                tips: ["Be specific", "Show capital efficiency", "Clear milestones"],
                examples: nil
            )
        ],
        keyQuestions: [
            "What's your unique insight?",
            "Why will you win?",
            "What's the 10-year vision?",
            "How big can this be?",
            "What's your moat?",
            "Why you, why now?"
        ],
        successMetrics: [
            "Transformative vision",
            "Technical excellence",
            "Market timing",
            "Team quality",
            "Growth trajectory",
            "Category potential"
        ],
        reviewerFocus: [
            "Founder conviction",
            "Market size",
            "Technical moat",
            "Growth metrics",
            "Vision clarity"
        ],
        uniqueFocus: "a16z bets on founders building the future. They want category-defining companies.",
        idealCompanyProfile: "Technical founders with bold visions and early traction",
        acceptanceRate: "<1% (extremely selective)",
        investmentAmount: "$1M - $100M+",
        equityTaken: "15-25%",
        programLength: "N/A (investment)",
        location: "Menlo Park, CA",
        website: "https://a16z.com"
    )
    
    /// Sequoia Capital
    static let sequoia = AcceleratorTemplate(
        id: "sequoia",
        name: "Sequoia Capital",
        shortName: "Sequoia",
        description: "Legendary VC behind Apple, Google, Airbnb, Stripe, and more",
        logoName: "sequoia_logo",
        type: .vcFirm,
        criteria: [
            "Exceptional founders",
            "Massive market",
            "Clear competitive advantage",
            "Strong unit economics",
            "Proven traction",
            "Long-term vision"
        ],
        slideStructure: [
            AcceleratorSlide(
                title: "Company Purpose",
                layoutType: "title_only",
                requiredContent: ["Mission statement", "Why you exist", "Impact"],
                tips: ["Be memorable", "Show passion", "Make it personal"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Problem",
                layoutType: "title_bullets",
                requiredContent: ["Pain point", "Who suffers", "Cost of status quo"],
                tips: ["Make it visceral", "Quantify the pain", "Show urgency"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Solution",
                layoutType: "title_bullets",
                requiredContent: ["Your answer", "Why 10X better", "Key features"],
                tips: ["Show the magic", "Be specific", "Demo if possible"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Why Now",
                layoutType: "title_bullets",
                requiredContent: ["Market shift", "Technology enabler", "Timing"],
                tips: ["Show the wave", "Explain the catalyst", "Be specific"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Market Size",
                layoutType: "metric",
                requiredContent: ["TAM/SAM/SOM", "Growth rate", "Your wedge"],
                tips: ["Bottom-up preferred", "Show expansion", "Be realistic"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Competition",
                layoutType: "title_two_column",
                requiredContent: ["Landscape", "Your position", "Differentiation"],
                tips: ["Be honest", "Show your moat", "Explain why you win"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Business Model",
                layoutType: "title_bullets",
                requiredContent: ["Revenue model", "Unit economics", "Pricing"],
                tips: ["Show path to profit", "CAC/LTV", "Gross margins"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Team",
                layoutType: "team",
                requiredContent: ["Founders", "Key hires", "Advisors"],
                tips: ["Show credibility", "Highlight wins", "Team chemistry"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Financials",
                layoutType: "metric",
                requiredContent: ["Revenue", "Growth", "Projections"],
                tips: ["Be conservative", "Show efficiency", "Clear path"],
                examples: nil
            ),
            AcceleratorSlide(
                title: "Ask",
                layoutType: "title_bullets",
                requiredContent: ["Raise amount", "Milestones", "Use of funds"],
                tips: ["Be specific", "18-24 month runway", "Clear goals"],
                examples: nil
            )
        ],
        keyQuestions: [
            "Why does this company need to exist?",
            "What's your unfair advantage?",
            "How big can this be?",
            "What are the key risks?",
            "Why will you win?",
            "What do you need to believe?"
        ],
        successMetrics: [
            "Founder quality",
            "Market size",
            "Competitive moat",
            "Unit economics",
            "Growth trajectory",
            "Vision clarity"
        ],
        reviewerFocus: [
            "Founder excellence",
            "Market opportunity",
            "Competitive advantage",
            "Business model",
            "Traction"
        ],
        uniqueFocus: "Sequoia backs legendary founders building enduring companies",
        idealCompanyProfile: "Exceptional founders with proven traction in massive markets",
        acceptanceRate: "<0.5% (most selective VC)",
        investmentAmount: "$500K - $100M+",
        equityTaken: "15-25%",
        programLength: "N/A (investment)",
        location: "Menlo Park, CA",
        website: "https://www.sequoiacap.com"
    )
    
    /// First Round Capital
    static let firstRound = AcceleratorTemplate(
        id: "first_round",
        name: "First Round Capital",
        shortName: "First Round",
        description: "Seed-stage VC known for Uber, Square, Notion, and Roblox",
        logoName: "first_round_logo",
        type: .vcFirm,
        criteria: [
            "Seed-stage company",
            "Strong founding team",
            "Large market opportunity",
            "Early product traction",
            "Unique insight",
            "Coachable founders"
        ],
        slideStructure: [],
        keyQuestions: [
            "What's your unique insight?",
            "Why are you the right team?",
            "What have you learned so far?",
            "What's working/not working?",
            "What do you need help with?"
        ],
        successMetrics: [
            "Founder quality",
            "Market timing",
            "Early traction",
            "Learning velocity",
            "Coachability"
        ],
        reviewerFocus: [
            "Founders",
            "Market",
            "Traction",
            "Insight",
            "Potential"
        ],
        uniqueFocus: "First Round invests at the earliest stages and provides hands-on support",
        idealCompanyProfile: "First-time founders with unique insights and early traction",
        acceptanceRate: "~1% (very selective)",
        investmentAmount: "$500K - $3M",
        equityTaken: "10-20%",
        programLength: "N/A (investment)",
        location: "San Francisco, CA",
        website: "https://firstround.com"
    )
    
    /// Initialized Ventures (AI-focused)
    static let initializedCapital = AcceleratorTemplate(
        id: "initialized",
        name: "Initialized Capital",
        shortName: "Initialized",
        description: "Seed fund from Reddit co-founder, focused on technical founders",
        logoName: "initialized_logo",
        type: .vcFirm,
        criteria: [
            "Technical founding team",
            "Pre-seed to Seed stage",
            "Product-first approach",
            "Clear technical advantage",
            "Large market potential",
            "Authentic founders"
        ],
        slideStructure: [],
        keyQuestions: [
            "What are you building?",
            "Why are you building it?",
            "What's your technical approach?",
            "Who are your users?",
            "What's working?"
        ],
        successMetrics: [
            "Technical depth",
            "Founder authenticity",
            "Product quality",
            "User love",
            "Market potential"
        ],
        reviewerFocus: [
            "Technical founders",
            "Product",
            "Market",
            "Authenticity"
        ],
        uniqueFocus: "Initialized backs technical founders building products they're passionate about",
        idealCompanyProfile: "Technical founders at the earliest stages with working products",
        acceptanceRate: "~2% (selective)",
        investmentAmount: "$250K - $2M",
        equityTaken: "7-15%",
        programLength: "N/A (investment)",
        location: "San Francisco, CA",
        website: "https://initialized.com"
    )
    
    // MARK: - All Templates
    
    static let allTemplates: [AcceleratorTemplate] = [
        // Top Accelerators
        .yCombinator,
        .techstars,
        .fiveHundredGlobal,
        
        // Corporate Programs
        .nvidiaInception,
        .googleCloud,
        .awsActivate,
        .microsoftFoundersHub,
        
        // VC Firms
        .a16z,
        .sequoia,
        .firstRound,
        .initializedCapital
    ]
    
    static var accelerators: [AcceleratorTemplate] {
        allTemplates.filter { $0.type == .accelerator }
    }
    
    static var corporatePrograms: [AcceleratorTemplate] {
        allTemplates.filter { $0.type == .corporateProgram }
    }
    
    static var vcFirms: [AcceleratorTemplate] {
        allTemplates.filter { $0.type == .vcFirm }
    }
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

