//
//  Deck.swift
//  PitchMe
//
//  Model representing a complete pitch deck
//

import Foundation

// MARK: - Deck

struct Deck: Identifiable, Codable, Hashable {
    let id: String
    let userId: String
    var title: String
    var useCase: DeckUseCase
    var themeId: String
    var storyScore: Int?
    var slides: [Slide]
    let createdAt: Date
    var updatedAt: Date
    
    // MARK: - Initialization
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        title: String,
        useCase: DeckUseCase,
        themeId: String = Theme.default.id,
        storyScore: Int? = nil,
        slides: [Slide] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.useCase = useCase
        self.themeId = themeId
        self.storyScore = storyScore
        self.slides = slides
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - DeckUseCase

enum DeckUseCase: String, Codable, CaseIterable {
    case investor = "investor"
    case sales = "sales"
    case accelerator = "accelerator"
    case yCombinator = "y_combinator"
    case nvidiaInception = "nvidia_inception"
    case demoDay = "demo_day"
    
    var displayName: String {
        switch self {
        case .investor: return "Investor Pitch"
        case .sales: return "Sales Deck"
        case .accelerator: return "Accelerator"
        case .yCombinator: return "Y Combinator"
        case .nvidiaInception: return "NVIDIA Inception"
        case .demoDay: return "Demo Day"
        }
    }
    
    var description: String {
        switch self {
        case .investor:
            return "Raise seed, Series A, or growth capital from VCs and angels"
        case .sales:
            return "Win enterprise customers and close B2B deals"
        case .accelerator:
            return "Apply to Techstars, 500 Global, and other top programs"
        case .yCombinator:
            return "Stand out in YC's competitive application process"
        case .nvidiaInception:
            return "Join NVIDIA's free program for AI/ML startups"
        case .demoDay:
            return "Deliver a compelling 3-minute pitch on stage"
        }
    }
    
    var icon: String {
        switch self {
        case .investor: return "chart.line.uptrend.xyaxis"
        case .sales: return "cart.fill"
        case .accelerator: return "bolt.fill"
        case .yCombinator: return "y.circle.fill"
        case .nvidiaInception: return "cpu.fill"
        case .demoDay: return "mic.fill"
        }
    }
    
    /// Detailed explanation of what this deck type is optimized for
    var detailedDescription: String {
        switch self {
        case .investor:
            return "Optimized for venture capital and angel investor meetings. Includes problem, solution, market size (TAM/SAM/SOM), traction, business model, team, and funding ask slides."
        case .sales:
            return "Designed to convert prospects into customers. Focuses on pain points, ROI, case studies, pricing, and clear call-to-action."
        case .accelerator:
            return "Tailored for accelerator applications like Techstars, 500 Global, and Plug and Play. Emphasizes team, traction, and coachability."
        case .yCombinator:
            return "Follows YC's minimalist philosophy: clear problem, unique insight, market opportunity, traction, and exceptional team. Keep it simple and focused."
        case .nvidiaInception:
            return "Highlights your AI/ML technology, GPU utilization, technical architecture, and scalability. Perfect for joining NVIDIA's startup ecosystem with access to hardware, cloud credits, and VC network."
        case .demoDay:
            return "Condensed, high-impact deck for 2-5 minute presentations. Bold visuals, minimal text, and a memorable hook to capture investor attention."
        }
    }
    
    /// Recommended number of slides for this deck type
    var recommendedSlideCount: ClosedRange<Int> {
        switch self {
        case .investor: return 10...15
        case .sales: return 8...12
        case .accelerator: return 10...12
        case .yCombinator: return 8...10
        case .nvidiaInception: return 10...12
        case .demoDay: return 6...10
        }
    }
}

// MARK: - Deck Extensions

extension Deck {
    /// Get the theme for this deck
    var theme: Theme {
        Theme.allThemes.first(where: { $0.id == themeId }) ?? .default
    }
    
    /// Get slide count
    var slideCount: Int {
        slides.count
    }
    
    /// Check if deck has content
    var hasContent: Bool {
        !slides.isEmpty
    }
    
    /// Get formatted creation date
    var formattedCreatedDate: String {
        createdAt.formatted(date: .abbreviated, time: .omitted)
    }
    
    /// Get relative last edited time
    var relativeLastEdited: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: updatedAt, relativeTo: Date())
    }
    
    /// Update the deck's timestamp
    mutating func touch() {
        updatedAt = Date()
    }
    
    /// Add a slide to the deck
    mutating func addSlide(_ slide: Slide) {
        var newSlide = slide
        newSlide.index = slides.count
        slides.append(newSlide)
        touch()
    }
    
    /// Remove a slide from the deck
    mutating func removeSlide(at index: Int) {
        guard index < slides.count else { return }
        slides.remove(at: index)
        // Reindex remaining slides
        for i in index..<slides.count {
            slides[i].index = i
        }
        touch()
    }
    
    /// Move a slide within the deck
    mutating func moveSlide(from source: Int, to destination: Int) {
        guard source < slides.count && destination < slides.count else { return }
        let slide = slides.remove(at: source)
        slides.insert(slide, at: destination)
        // Reindex all slides
        for i in 0..<slides.count {
            slides[i].index = i
        }
        touch()
    }
}

// MARK: - Sample Decks for Previews

extension Deck {
    static func sample(
        title: String = "Sample Deck",
        useCase: DeckUseCase = .investor,
        slideCount: Int = 3
    ) -> Deck {
        let deckId = UUID().uuidString
        let slides = (0..<slideCount).map { index in
            Slide.sample(index: index, deckId: deckId)
        }
        return Deck(
            userId: "sample-user",
            title: title,
            useCase: useCase,
            slides: slides
        )
    }
    
    static let sampleInvestorDeck = Deck(
        id: "deck-1",
        userId: "user-1",
        title: "Fintech SaaS Seed Round",
        useCase: .investor,
        themeId: Theme.cleanLight.id,
        storyScore: 87,
        slides: [
            Slide.sampleTitleSlide,
            Slide.sampleProblemSlide,
            Slide.sampleSolutionSlide,
            Slide.sampleMetricSlide,
            Slide(
                deckId: "deck-1",
                index: 4,
                layoutType: .titleBullets,
                title: "Market Opportunity",
                bullets: [
                    "$180B global fintech market",
                    "25M SMBs in US alone",
                    "Growing 18% annually"
                ]
            ),
            Slide(
                deckId: "deck-1",
                index: 5,
                layoutType: .titleBullets,
                title: "Business Model",
                bullets: [
                    "$99/mo per user subscription",
                    "Premium features at $299/mo",
                    "Enterprise custom pricing"
                ]
            ),
            Slide(
                deckId: "deck-1",
                index: 6,
                layoutType: .team,
                title: "The Team",
                bullets: [
                    "Jane Doe - CEO (ex-Stripe, Stanford CS)",
                    "John Smith - CTO (ex-Google, MIT)",
                    "Sarah Johnson - Head of Growth (ex-Plaid)"
                ]
            ),
            Slide(
                deckId: "deck-1",
                index: 7,
                layoutType: .titleBullets,
                title: "The Ask",
                bullets: [
                    "Raising $3M seed round",
                    "18 months runway to $10M ARR",
                    "Join us in revolutionizing fintech"
                ]
            )
        ],
        createdAt: Date().addingTimeInterval(-86400 * 3),
        updatedAt: Date().addingTimeInterval(-3600)
    )
    
    static let sampleSalesDeck = Deck(
        id: "deck-2",
        userId: "user-1",
        title: "Enterprise Sales Deck Q1 2025",
        useCase: .sales,
        themeId: Theme.darkTech.id,
        storyScore: nil,
        slides: [
            Slide(
                deckId: "deck-2",
                index: 0,
                layoutType: .titleOnly,
                title: "Transform Your Finance Operations",
                bullets: ["Real-time insights. Real growth."]
            ),
            Slide(
                deckId: "deck-2",
                index: 1,
                layoutType: .titleBullets,
                title: "Why Companies Choose Us",
                bullets: [
                    "Setup in minutes, not months",
                    "ROI within first quarter",
                    "Enterprise-grade security"
                ]
            )
        ],
        createdAt: Date().addingTimeInterval(-86400 * 7),
        updatedAt: Date().addingTimeInterval(-86400)
    )
    
    static let sampleAcceleratorDeck = Deck(
        id: "deck-3",
        userId: "user-1",
        title: "Y Combinator W25 Application",
        useCase: .accelerator,
        themeId: Theme.boldColor.id,
        storyScore: 92,
        slides: [
            Slide(
                deckId: "deck-3",
                index: 0,
                layoutType: .titleOnly,
                title: "AI-Powered Financial Intelligence",
                bullets: ["Built for founders, by founders"]
            )
        ],
        createdAt: Date().addingTimeInterval(-86400 * 2),
        updatedAt: Date().addingTimeInterval(-1800)
    )
    
    static let sampleDecks: [Deck] = [
        sampleInvestorDeck,
        sampleSalesDeck,
        sampleAcceleratorDeck
    ]
}

