//
//  Slide.swift
//  PitchMe
//
//  Model representing a single slide in a pitch deck
//

import Foundation

// MARK: - Slide

struct Slide: Identifiable, Codable, Hashable {
    let id: String
    let deckId: String
    var index: Int
    var layoutType: SlideLayoutType
    var title: String
    var bullets: [String]
    var speakerNotes: String?
    let createdAt: Date
    var updatedAt: Date
    
    // MARK: - Initialization
    
    init(
        id: String = UUID().uuidString,
        deckId: String,
        index: Int,
        layoutType: SlideLayoutType,
        title: String,
        bullets: [String] = [],
        speakerNotes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.deckId = deckId
        self.index = index
        self.layoutType = layoutType
        self.title = title
        self.bullets = bullets
        self.speakerNotes = speakerNotes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - SlideLayoutType

enum SlideLayoutType: String, Codable, CaseIterable {
    /// Title slide with large centered text
    case titleOnly = "title_only"
    
    /// Title with bullet points below
    case titleBullets = "title_bullets"
    
    /// Title with two columns of content
    case titleTwoColumn = "title_two_column"
    
    /// Large metric display (numbers, KPIs)
    case metric = "metric"
    
    /// Timeline or roadmap layout
    case timeline = "timeline"
    
    /// Problem/solution split view
    case problemSolution = "problem_solution"
    
    /// Team members with photos/bios
    case team = "team"
    
    /// Quote or testimonial
    case quote = "quote"
    
    /// Image with caption
    case imageCaption = "image_caption"
    
    var displayName: String {
        switch self {
        case .titleOnly: return "Title Only"
        case .titleBullets: return "Title & Bullets"
        case .titleTwoColumn: return "Two Column"
        case .metric: return "Metrics"
        case .timeline: return "Timeline"
        case .problemSolution: return "Problem/Solution"
        case .team: return "Team"
        case .quote: return "Quote"
        case .imageCaption: return "Image"
        }
    }
    
    var icon: String {
        switch self {
        case .titleOnly: return "textformat.size"
        case .titleBullets: return "list.bullet"
        case .titleTwoColumn: return "rectangle.split.2x1"
        case .metric: return "number.square"
        case .timeline: return "timeline.selection"
        case .problemSolution: return "arrow.left.arrow.right"
        case .team: return "person.3"
        case .quote: return "text.quote"
        case .imageCaption: return "photo"
        }
    }
}

// MARK: - Slide Extensions

extension Slide {
    /// Check if slide has content
    var hasContent: Bool {
        !title.isEmpty || !bullets.isEmpty
    }
    
    /// Check if slide has speaker notes
    var hasSpeakerNotes: Bool {
        speakerNotes != nil && !(speakerNotes?.isEmpty ?? true)
    }
    
    /// Update the slide's timestamp
    mutating func touch() {
        updatedAt = Date()
    }
}

// MARK: - Sample Slides for Previews

extension Slide {
    static func sample(
        index: Int = 0,
        deckId: String = "sample-deck",
        layoutType: SlideLayoutType = .titleBullets,
        title: String = "Sample Slide",
        bullets: [String] = ["Point 1", "Point 2", "Point 3"]
    ) -> Slide {
        Slide(
            deckId: deckId,
            index: index,
            layoutType: layoutType,
            title: title,
            bullets: bullets,
            speakerNotes: nil
        )
    }
    
    static let sampleTitleSlide = Slide(
        deckId: "sample-deck",
        index: 0,
        layoutType: .titleOnly,
        title: "Revolutionizing Fintech",
        bullets: ["The future of embedded payments"],
        speakerNotes: "Open with energy. Pause for effect."
    )
    
    static let sampleProblemSlide = Slide(
        deckId: "sample-deck",
        index: 1,
        layoutType: .titleBullets,
        title: "The Problem",
        bullets: [
            "75% of SMBs struggle with cash flow management",
            "Existing tools are built for accountants, not founders",
            "Real-time insights are inaccessible without expensive CFOs"
        ],
        speakerNotes: "Emphasize the pain point. Make it personal."
    )
    
    static let sampleSolutionSlide = Slide(
        deckId: "sample-deck",
        index: 2,
        layoutType: .titleBullets,
        title: "Our Solution",
        bullets: [
            "AI-powered financial dashboard built for founders",
            "Real-time cash flow forecasting with 95% accuracy",
            "One-click integrations with all major banks & tools"
        ],
        speakerNotes: "Show demo here if possible."
    )
    
    static let sampleMetricSlide = Slide(
        deckId: "sample-deck",
        index: 3,
        layoutType: .metric,
        title: "Traction",
        bullets: [
            "$2.4M ARR",
            "1,200 Active Users",
            "340% YoY Growth"
        ],
        speakerNotes: "Let the numbers speak. Pause."
    )
}

