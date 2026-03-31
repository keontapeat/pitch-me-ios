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
    
    @Published var deck: Deck {
        didSet {
            // Auto-save when deck changes
            scheduleAutoSave()
        }
    }
    @Published var selectedSlideIndex: Int = 0
    @Published var isEditingTitle: Bool = false
    @Published var isShowingThemePicker: Bool = false
    @Published var isShowingExportOptions: Bool = false
    @Published var isRegeneratingSlide: Bool = false
    @Published var errorMessage: String?
    @Published var exportedFileURL: URL?
    @Published var showShareSheet: Bool = false
    
    // Services
    private let exportService = DeckExportService.shared
    
    // Auto-save debounce
    private var autoSaveTask: Task<Void, Never>?
    
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
    
    // MARK: - Auto-Save
    
    private func scheduleAutoSave() {
        autoSaveTask?.cancel()
        autoSaveTask = Task {
            // Debounce - wait 1 second before saving
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            if !Task.isCancelled {
                saveDeck()
            }
        }
    }
    
    /// Save deck to persistent storage
    func saveDeck() {
        DeckListViewModel.shared.updateDeck(deck)
        print("💾 Auto-saved deck: \(deck.title)")
    }
    
    // MARK: - AI Methods
    
    func regenerateSlide(at index: Int) async {
        guard index < deck.slides.count else { return }
        
        isRegeneratingSlide = true
        errorMessage = nil
        
        let slide = deck.slides[index]
        
        do {
            let improved = try await SlideRegenerationService.shared.improveSlide(
                slide,
                deckContext: deck
            )
            deck.slides[index].title = improved.title
            deck.slides[index].bullets = improved.bullets
            if let notes = improved.speakerNotes {
                deck.slides[index].speakerNotes = notes
            }
            deck.slides[index].touch()
            deck.touch()
        } catch {
            errorMessage = "AI improvement failed: \(error.localizedDescription)"
        }
        
        isRegeneratingSlide = false
        saveDeck()
    }
    
    // MARK: - Export Methods
    
    func exportDeck(as format: ExportFormat) async {
        errorMessage = nil
        exportedFileURL = nil
        
        do {
            // Call the production export service
            let fileURL = try await exportService.exportDeck(deck, format: format)
            
            // Show share sheet
            exportedFileURL = fileURL
            showShareSheet = true
            isShowingExportOptions = false
            
        } catch let error as ExportError {
            errorMessage = error.errorDescription ?? "Export failed"
        } catch {
            errorMessage = "Failed to export deck. Please try again."
        }
    }
    
    /// Get export progress from service
    var exportProgress: Double {
        exportService.exportProgress
    }
    
    var isExporting: Bool {
        exportService.isExporting
    }
    
    var exportStep: String {
        exportService.currentStep
    }
}

