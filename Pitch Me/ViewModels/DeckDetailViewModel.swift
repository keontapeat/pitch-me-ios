//
//  DeckDetailViewModel.swift
//  PitchMe
//
//  View model for managing deck detail and editing
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class DeckDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var deck: Deck
    @Published var selectedSlideIndex: Int = 0
    @Published var isEditingTitle: Bool = false
    @Published var isShowingThemePicker: Bool = false
    @Published var isShowingExportOptions: Bool = false
    @Published var isRegeneratingSlide: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Computed Properties
    
    var currentSlide: Slide? {
        guard selectedSlideIndex < deck.slides.count else { return nil }
        return deck.slides[selectedSlideIndex]
    }
    
    var canGoToPreviousSlide: Bool {
        selectedSlideIndex > 0
    }
    
    var canGoToNextSlide: Bool {
        selectedSlideIndex < deck.slides.count - 1
    }
    
    // MARK: - Initialization
    
    init(deck: Deck) {
        self.deck = deck
    }
    
    // MARK: - Navigation Methods
    
    func goToPreviousSlide() {
        guard canGoToPreviousSlide else { return }
        withAnimation {
            selectedSlideIndex -= 1
        }
    }
    
    func goToNextSlide() {
        guard canGoToNextSlide else { return }
        withAnimation {
            selectedSlideIndex += 1
        }
    }
    
    func selectSlide(at index: Int) {
        guard index >= 0 && index < deck.slides.count else { return }
        withAnimation {
            selectedSlideIndex = index
        }
    }
    
    // MARK: - Editing Methods
    
    func updateDeckTitle(_ newTitle: String) {
        deck.title = newTitle
        deck.touch()
    }
    
    func updateSlideTitle(at index: Int, newTitle: String) {
        guard index < deck.slides.count else { return }
        deck.slides[index].title = newTitle
        deck.slides[index].touch()
        deck.touch()
    }
    
    func updateSlideBullet(slideIndex: Int, bulletIndex: Int, newText: String) {
        guard slideIndex < deck.slides.count,
              bulletIndex < deck.slides[slideIndex].bullets.count else { return }
        deck.slides[slideIndex].bullets[bulletIndex] = newText
        deck.slides[slideIndex].touch()
        deck.touch()
    }
    
    func addBulletToSlide(at slideIndex: Int, text: String = "") {
        guard slideIndex < deck.slides.count else { return }
        deck.slides[slideIndex].bullets.append(text)
        deck.slides[slideIndex].touch()
        deck.touch()
    }
    
    func removeBulletFromSlide(slideIndex: Int, bulletIndex: Int) {
        guard slideIndex < deck.slides.count,
              bulletIndex < deck.slides[slideIndex].bullets.count else { return }
        deck.slides[slideIndex].bullets.remove(at: bulletIndex)
        deck.slides[slideIndex].touch()
        deck.touch()
    }
    
    func updateSpeakerNotes(at index: Int, notes: String?) {
        guard index < deck.slides.count else { return }
        deck.slides[index].speakerNotes = notes
        deck.slides[index].touch()
        deck.touch()
    }
    
    // MARK: - Slide Management
    
    func addSlide(layoutType: SlideLayoutType = .titleBullets) {
        let newSlide = Slide(
            deckId: deck.id,
            index: deck.slides.count,
            layoutType: layoutType,
            title: "New Slide",
            bullets: []
        )
        deck.addSlide(newSlide)
    }
    
    func deleteSlide(at index: Int) {
        guard index < deck.slides.count else { return }
        deck.removeSlide(at: index)
        
        // Adjust selected index if needed
        if selectedSlideIndex >= deck.slides.count {
            selectedSlideIndex = max(0, deck.slides.count - 1)
        }
    }
    
    func moveSlide(from source: Int, to destination: Int) {
        deck.moveSlide(from: source, to: destination)
        selectedSlideIndex = destination
    }
    
    // MARK: - Theme Methods
    
    func changeTheme(to theme: Theme) {
        deck.themeId = theme.id
        deck.touch()
        isShowingThemePicker = false
    }
    
    // MARK: - AI Methods
    
    func regenerateSlide(at index: Int) async {
        guard index < deck.slides.count else { return }
        
        isRegeneratingSlide = true
        errorMessage = nil
        
        // Simulate AI regeneration
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Mock improvement
        let currentSlide = deck.slides[index]
        deck.slides[index].bullets = currentSlide.bullets.map { bullet in
            "✨ \(bullet)"
        }
        deck.slides[index].touch()
        deck.touch()
        
        isRegeneratingSlide = false
    }
    
    // MARK: - Export Methods
    
    func exportDeck(as format: ExportFormat) async {
        errorMessage = nil
        
        // Simulate export process
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        // This will be connected to real export service
        isShowingExportOptions = false
    }
}

// MARK: - ExportFormat

enum ExportFormat: String, CaseIterable {
    case googleSlides = "google_slides"
    case powerpoint = "pptx"
    case pdf = "pdf"
    
    var displayName: String {
        switch self {
        case .googleSlides: return "Google Slides"
        case .powerpoint: return "PowerPoint"
        case .pdf: return "PDF"
        }
    }
    
    var icon: String {
        switch self {
        case .googleSlides: return "square.grid.3x3.fill"
        case .powerpoint: return "doc.fill"
        case .pdf: return "doc.richtext.fill"
        }
    }
}

