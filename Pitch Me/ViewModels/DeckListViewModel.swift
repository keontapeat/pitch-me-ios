//
//  DeckListViewModel.swift
//  PitchMe
//
//  View model for managing the deck list
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class DeckListViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var decks: [Deck] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchQuery: String = ""
    
    // MARK: - Computed Properties
    
    var filteredDecks: [Deck] {
        if searchQuery.isEmpty {
            return decks.sorted { $0.updatedAt > $1.updatedAt }
        }
        return decks
            .filter { $0.title.localizedCaseInsensitiveContains(searchQuery) }
            .sorted { $0.updatedAt > $1.updatedAt }
    }
    
    var hasDecks: Bool {
        !decks.isEmpty
    }
    
    // MARK: - Initialization
    
    init() {
        // Load mock data for now
        loadMockDecks()
    }
    
    // MARK: - Public Methods
    
    /// Load decks from backend (mocked for now)
    func loadDecks() async {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // For now, load mock data
        loadMockDecks()
        
        isLoading = false
    }
    
    /// Create a new deck (placeholder)
    func createNewDeck() {
        // This will be connected to the wizard flow
        // For now, just a placeholder
    }
    
    /// Delete a deck
    func deleteDeck(_ deck: Deck) {
        decks.removeAll { $0.id == deck.id }
    }
    
    /// Duplicate a deck
    func duplicateDeck(_ deck: Deck) {
        let newDeckId = UUID().uuidString
        let now = Date()
        
        // Create new slides with new IDs
        let newSlides = deck.slides.map { slide in
            Slide(
                id: UUID().uuidString,
                deckId: newDeckId,
                index: slide.index,
                layoutType: slide.layoutType,
                title: slide.title,
                bullets: slide.bullets,
                speakerNotes: slide.speakerNotes,
                createdAt: now,
                updatedAt: now
            )
        }
        
        // Create new deck
        let duplicatedDeck = Deck(
            id: newDeckId,
            userId: deck.userId,
            title: "\(deck.title) (Copy)",
            useCase: deck.useCase,
            themeId: deck.themeId,
            storyScore: deck.storyScore,
            slides: newSlides,
            createdAt: now,
            updatedAt: now
        )
        
        decks.insert(duplicatedDeck, at: 0)
    }
    
    // MARK: - Private Methods
    
    private func loadMockDecks() {
        decks = Deck.sampleDecks
    }
}

