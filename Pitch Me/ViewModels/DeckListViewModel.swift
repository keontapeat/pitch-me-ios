//
//  DeckListViewModel.swift
//  PitchMe
//
//  View model for managing the deck list
//  Supports both local storage (offline) and Firebase sync (online)
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class DeckListViewModel: ObservableObject {
    // MARK: - Singleton for deck persistence
    static let shared = DeckListViewModel()
    
    // MARK: - Published Properties
    
    @Published var decks: [Deck] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchQuery: String = ""
    @Published var isSyncing: Bool = false
    
    // MARK: - Private Properties
    private let decksStorageKey = "saved_decks"
    private let firestoreService = FirestoreService.shared
    private var firestoreListener: ListenerRegistration?
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
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
    
    var isAuthenticated: Bool {
        Auth.auth().currentUser != nil
    }
    
    // MARK: - Initialization
    
    init() {
        loadSavedDecks()
        setupAuthListener()
    }
    
    // MARK: - Auth State Listener
    
    private func setupAuthListener() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                if user != nil {
                    // User logged in - start syncing with Firebase
                    self?.startFirestoreListener()
                } else {
                    // User logged out - stop syncing, use local only
                    self?.stopFirestoreListener()
                    self?.loadSavedDecks()
                }
            }
        }
    }
    
    // MARK: - Firestore Real-time Sync
    
    private func startFirestoreListener() {
        firestoreListener = firestoreService.listenToDecks { [weak self] firebaseDecks in
            Task { @MainActor in
                self?.mergeDecks(firebaseDecks)
            }
        }
        print("🔥 Started Firestore real-time sync")
    }
    
    private func stopFirestoreListener() {
        firestoreListener?.remove()
        firestoreListener = nil
        print("🔥 Stopped Firestore sync")
    }
    
    /// Merge Firebase decks with local decks (Firebase wins for conflicts)
    private func mergeDecks(_ firebaseDecks: [Deck]) {
        // For now, Firebase is source of truth when authenticated
        self.decks = firebaseDecks
        saveDecksLocally() // Cache locally for offline access
        print("🔄 Synced \(firebaseDecks.count) decks from Firebase")
    }
    
    // MARK: - Public Methods
    
    /// Load decks from storage (local or Firebase)
    func loadDecks() async {
        isLoading = true
        errorMessage = nil
        
        if isAuthenticated {
            // Load from Firebase
            do {
                let firebaseDecks = try await firestoreService.fetchDecks()
                self.decks = firebaseDecks
                saveDecksLocally() // Cache locally
                print("☁️ Loaded \(firebaseDecks.count) decks from Firebase")
            } catch {
                print("⚠️ Firebase fetch failed, using local: \(error.localizedDescription)")
                loadSavedDecks()
            }
        } else {
            // Load from local storage
            loadSavedDecks()
        }
        
        isLoading = false
    }
    
    /// Add a new deck (called after generation)
    func addDeck(_ deck: Deck) {
        // Check if deck already exists
        if !decks.contains(where: { $0.id == deck.id }) {
            decks.insert(deck, at: 0)
            saveDecksLocally()
            print("✅ Deck saved locally: \(deck.title)")
            
            // Sync to Firebase if authenticated
            if isAuthenticated {
                Task {
                    await saveDeckToFirebase(deck)
                }
            }
        } else {
            // Update existing deck
            updateDeck(deck)
        }
    }
    
    /// Update an existing deck
    func updateDeck(_ deck: Deck) {
        if let index = decks.firstIndex(where: { $0.id == deck.id }) {
            decks[index] = deck
            saveDecksLocally()
            
            // Sync to Firebase if authenticated
            if isAuthenticated {
                Task {
                    await updateDeckInFirebase(deck)
                }
            }
        }
    }
    
    /// Delete a deck
    func deleteDeck(_ deck: Deck) {
        decks.removeAll { $0.id == deck.id }
        saveDecksLocally()
        
        // Delete from Firebase if authenticated
        if isAuthenticated {
            Task {
                await deleteDeckFromFirebase(deck.id)
            }
        }
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
        
        addDeck(duplicatedDeck)
    }
    
    // MARK: - Firebase Operations
    
    private func saveDeckToFirebase(_ deck: Deck) async {
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            let newId = try await firestoreService.saveDeckWithSlides(deck, slides: deck.slides)
            print("☁️ Deck saved to Firebase: \(newId)")
        } catch {
            print("⚠️ Failed to save deck to Firebase: \(error.localizedDescription)")
            errorMessage = "Failed to sync deck to cloud"
        }
    }
    
    private func updateDeckInFirebase(_ deck: Deck) async {
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            try await firestoreService.updateDeck(deck)
            print("☁️ Deck updated in Firebase: \(deck.id)")
        } catch {
            print("⚠️ Failed to update deck in Firebase: \(error.localizedDescription)")
        }
    }
    
    private func deleteDeckFromFirebase(_ deckId: String) async {
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            try await firestoreService.deleteDeck(deckId)
            print("☁️ Deck deleted from Firebase: \(deckId)")
        } catch {
            print("⚠️ Failed to delete deck from Firebase: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Local Storage
    
    /// Save decks to UserDefaults (local cache)
    private func saveDecksLocally() {
        do {
            let data = try JSONEncoder().encode(decks)
            UserDefaults.standard.set(data, forKey: decksStorageKey)
            print("💾 Saved \(decks.count) decks locally")
        } catch {
            print("❌ Failed to save decks locally: \(error)")
        }
    }
    
    /// Load decks from UserDefaults
    private func loadSavedDecks() {
        guard let data = UserDefaults.standard.data(forKey: decksStorageKey) else {
            // No saved decks, start fresh
            decks = []
            print("📂 No saved decks found")
            return
        }
        
        do {
            decks = try JSONDecoder().decode([Deck].self, from: data)
            print("📂 Loaded \(decks.count) decks from local storage")
        } catch {
            print("❌ Failed to load decks: \(error)")
            decks = []
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        firestoreListener?.remove()
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

