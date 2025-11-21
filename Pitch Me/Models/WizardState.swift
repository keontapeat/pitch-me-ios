//
//  WizardState.swift
//  Pitch Me
//
//  Wizard flow state management
//

import Foundation

// MARK: - Wizard State

struct WizardState: Codable {
    // Step 1: Startup Basics
    var startupName: String = ""
    var oneLiner: String = ""
    var stage: StartupStage = .idea
    
    // Step 2: Target & Problem
    var targetUser: String = ""
    var problem: String = ""
    
    // Step 3: Solution
    var solution: String = ""
    var whyNow: String = ""
    var uniqueValue: String = ""
    
    // Step 4: Market & Business Model
    var marketSize: String = ""
    var businessModel: String = ""
    var pricing: String = ""
    
    // Step 5: Traction & Metrics
    var traction: String = ""
    var keyMetrics: String = ""
    
    // Step 6: Team
    var team: String = ""
    var advisors: String = ""
    
    // Step 7: Use Case & Theme
    var useCase: DeckUseCase = .investor
    var preferredTheme: String = Theme.default.id
    
    // Progress tracking
    var currentStep: Int = 0
    var completedSteps: Set<Int> = []
    
    // Validation
    var isComplete: Bool {
        completedSteps.count >= 7
    }
    
    mutating func markStepComplete(_ step: Int) {
        completedSteps.insert(step)
    }
    
    func isStepComplete(_ step: Int) -> Bool {
        completedSteps.contains(step)
    }
}

// MARK: - Startup Stage

enum StartupStage: String, Codable, CaseIterable {
    case idea = "Idea Stage"
    case mvp = "MVP Built"
    case revenue = "Generating Revenue"
    case growth = "Growth Stage"
    case scale = "Scaling"
    
    var icon: String {
        switch self {
        case .idea: return "lightbulb.fill"
        case .mvp: return "hammer.fill"
        case .revenue: return "dollarsign.circle.fill"
        case .growth: return "chart.line.uptrend.xyaxis"
        case .scale: return "arrow.up.right.circle.fill"
        }
    }
    
    var description: String {
        switch self {
        case .idea: return "Just getting started with the concept"
        case .mvp: return "Have a working prototype or MVP"
        case .revenue: return "Generating revenue from customers"
        case .growth: return "Scaling customer acquisition"
        case .scale: return "Rapid growth and expansion"
        }
    }
}

// MARK: - Wizard Step

enum WizardStep: Int, CaseIterable {
    case intro = 0
    case basics = 1
    case problem = 2
    case solution = 3
    case market = 4
    case traction = 5
    case team = 6
    case summary = 7
    
    var title: String {
        switch self {
        case .intro: return "Welcome"
        case .basics: return "The Basics"
        case .problem: return "The Problem"
        case .solution: return "Your Solution"
        case .market: return "Market & Model"
        case .traction: return "Traction"
        case .team: return "Your Team"
        case .summary: return "Review & Generate"
        }
    }
    
    var subtitle: String {
        switch self {
        case .intro: return "Let's build your pitch deck"
        case .basics: return "Tell us about your startup"
        case .problem: return "What problem are you solving?"
        case .solution: return "How do you solve it?"
        case .market: return "Size the opportunity"
        case .traction: return "Show your progress"
        case .team: return "Who's building this?"
        case .summary: return "Ready to generate"
        }
    }
    
    var icon: String {
        switch self {
        case .intro: return "hand.wave.fill"
        case .basics: return "building.2.fill"
        case .problem: return "exclamationmark.triangle.fill"
        case .solution: return "lightbulb.fill"
        case .market: return "chart.bar.fill"
        case .traction: return "arrow.up.right.circle.fill"
        case .team: return "person.3.fill"
        case .summary: return "checkmark.circle.fill"
        }
    }
}

