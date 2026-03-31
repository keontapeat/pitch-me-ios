//
//  WizardViewModel.swift
//  Pitch Me
//
//  Wizard flow business logic
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth

@MainActor
final class WizardViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var state = WizardState()
    @Published var currentStep: WizardStep = .intro
    @Published var isGenerating = false
    @Published var generationProgress: Double = 0.0
    @Published var generatedDeck: Deck?
    @Published var errorMessage: String?
    @Published var showError = false
    
    // MARK: - Constants
    
    let totalSteps = WizardStep.allCases.count
    
    // MARK: - Computed Properties
    
    var progress: Double {
        Double(currentStep.rawValue) / Double(totalSteps - 1)
    }
    
    var canGoBack: Bool {
        currentStep.rawValue > 0
    }
    
    var canGoForward: Bool {
        validateCurrentStep()
    }
    
    var isLastStep: Bool {
        currentStep == .summary
    }
    
    // MARK: - Navigation
    
    func goToNextStep() {
        guard currentStep.rawValue < totalSteps - 1 else { return }
        
        // Mark current step as complete
        state.markStepComplete(currentStep.rawValue)
        
        // Move to next step
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if let nextStep = WizardStep(rawValue: currentStep.rawValue + 1) {
                currentStep = nextStep
                state.currentStep = nextStep.rawValue
            }
        }
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    func goToPreviousStep() {
        guard canGoBack else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if let previousStep = WizardStep(rawValue: currentStep.rawValue - 1) {
                currentStep = previousStep
                state.currentStep = previousStep.rawValue
            }
        }
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    func goToStep(_ step: WizardStep) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentStep = step
            state.currentStep = step.rawValue
        }
    }
    
    // MARK: - Validation
    
    private func validateCurrentStep() -> Bool {
        switch currentStep {
        case .intro:
            return true
        case .basics:
            return !state.startupName.trimmingCharacters(in: .whitespaces).isEmpty &&
                   !state.oneLiner.trimmingCharacters(in: .whitespaces).isEmpty
        case .problem:
            return !state.targetUser.trimmingCharacters(in: .whitespaces).isEmpty &&
                   !state.problem.trimmingCharacters(in: .whitespaces).isEmpty
        case .solution:
            return !state.solution.trimmingCharacters(in: .whitespaces).isEmpty
        case .market:
            return !state.marketSize.trimmingCharacters(in: .whitespaces).isEmpty &&
                   !state.businessModel.trimmingCharacters(in: .whitespaces).isEmpty
        case .traction:
            return !state.traction.trimmingCharacters(in: .whitespaces).isEmpty
        case .team:
            return !state.team.trimmingCharacters(in: .whitespaces).isEmpty
        case .summary:
            return true
        }
    }
    
    // MARK: - Deck Generation
    
    func generateDeck() async {
        guard !isGenerating else { return }
        
        isGenerating = true
        generationProgress = 0.0
        errorMessage = nil
        
        do {
            // 🔥 Use REAL AI generation with Claude Opus 4.5 or GPT-4 🔥
            let deckService = DeckGenerationService.shared
            
            // Pro Plus gets Claude Opus 4.5, others get GPT-4
            let useClaude = shouldUseClaudeOpus()
            
            // Start progress observation
            Task { @MainActor in
                for await _ in Timer.publish(every: 0.1, on: .main, in: .common).autoconnect().values {
                    generationProgress = deckService.generationProgress
                    if !deckService.isGenerating { break }
                }
            }
            
            // Generate deck with best available AI
            let deck = try await deckService.generateDeck(from: state, preferClaude: useClaude)
            
            generatedDeck = deck
            
            // Success haptic
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)
            
        } catch {
            errorMessage = "Failed to generate deck: \(error.localizedDescription)"
            showError = true
            
            // Error haptic
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.error)
        }
        
        isGenerating = false
    }
    
    // MARK: - Model Selection
    
    private func shouldUseClaudeOpus() -> Bool {
        // Pro Plus and Enterprise get Claude Opus 4.5
        let tier = SubscriptionService.shared.currentTier
        return tier == .proPlus || tier == .enterprise
    }
    
    private func determineModelForUser() -> GPTModel {
        let tier = SubscriptionService.shared.currentTier
        
        switch tier {
        case .free:
            return .gpt35Turbo  // Basic AI for free tier
        case .pro:
            return .gpt4o      // GPT-4o for Pro
        case .proPlus, .enterprise:
            return .gpt4o      // Fallback if Claude fails
        }
    }
    
    // MARK: - Fallback Deck Creation (if AI fails)
    
    private func createDeckFromState() -> Deck {
        let deckId = UUID().uuidString
        let now = Date()
        
        // Create slides based on wizard input
        var slides: [Slide] = []
        
        // Title slide
        slides.append(Slide(
            id: UUID().uuidString,
            deckId: deckId,
            index: 0,
            layoutType: .titleOnly,
            title: state.startupName,
            bullets: [state.oneLiner],
            speakerNotes: "Open with confidence. Pause after company name.",
            createdAt: now,
            updatedAt: now
        ))
        
        // Problem slide
        slides.append(Slide(
            id: UUID().uuidString,
            deckId: deckId,
            index: 1,
            layoutType: .titleBullets,
            title: "The Problem",
            bullets: state.problem.components(separatedBy: "\n").filter { !$0.isEmpty },
            speakerNotes: "Make the pain real. Use numbers if you have them.",
            createdAt: now,
            updatedAt: now
        ))
        
        // Solution slide
        slides.append(Slide(
            id: UUID().uuidString,
            deckId: deckId,
            index: 2,
            layoutType: .titleBullets,
            title: "Our Solution",
            bullets: [state.solution, "Why now: \(state.whyNow)"],
            speakerNotes: "Show the magic. This is your 'aha' moment.",
            createdAt: now,
            updatedAt: now
        ))
        
        // Market slide
        slides.append(Slide(
            id: UUID().uuidString,
            deckId: deckId,
            index: 3,
            layoutType: .titleBullets,
            title: "Market Opportunity",
            bullets: ["Market Size: \(state.marketSize)", "Business Model: \(state.businessModel)"],
            speakerNotes: "Show the size of the prize.",
            createdAt: now,
            updatedAt: now
        ))
        
        // Traction slide
        if !state.traction.isEmpty {
            slides.append(Slide(
                id: UUID().uuidString,
                deckId: deckId,
                index: slides.count,
                layoutType: .metric,
                title: "Traction",
                bullets: state.traction.components(separatedBy: "\n").filter { !$0.isEmpty },
                speakerNotes: "Let the numbers speak. Pause for effect.",
                createdAt: now,
                updatedAt: now
            ))
        }
        
        // Team slide
        slides.append(Slide(
            id: UUID().uuidString,
            deckId: deckId,
            index: slides.count,
            layoutType: .team,
            title: "The Team",
            bullets: state.team.components(separatedBy: "\n").filter { !$0.isEmpty },
            speakerNotes: "Show why you're the right team to execute.",
            createdAt: now,
            updatedAt: now
        ))
        
        // Ask slide (for investor decks)
        if state.useCase == .investor {
            slides.append(Slide(
                id: UUID().uuidString,
                deckId: deckId,
                index: slides.count,
                layoutType: .titleBullets,
                title: "The Ask",
                bullets: ["Join us in building the future of \(state.startupName)"],
                speakerNotes: "Be clear and confident about what you need.",
                createdAt: now,
                updatedAt: now
            ))
        }
        
        // Create deck
        return Deck(
            id: deckId,
            userId: Auth.auth().currentUser?.uid ?? "anonymous",
            title: "\(state.startupName) - \(state.useCase.displayName)",
            useCase: state.useCase,
            themeId: state.preferredTheme,
            storyScore: nil,
            slides: slides,
            createdAt: now,
            updatedAt: now
        )
    }
    
    // MARK: - Reset
    
    func reset() {
        state = WizardState()
        currentStep = .intro
        isGenerating = false
        generationProgress = 0.0
        generatedDeck = nil
        errorMessage = nil
        showError = false
    }
}

