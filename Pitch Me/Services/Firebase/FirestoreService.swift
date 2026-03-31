//
//  FirestoreService.swift
//  Pitch Me
//
//  🔥 Elite Firestore Database Service
//  Handles all database operations for decks, slides, and user data
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

// MARK: - Firestore Error

enum FirestoreError: Error, LocalizedError {
    case notAuthenticated
    case documentNotFound
    case encodingFailed
    case decodingFailed
    case networkError
    case permissionDenied
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be logged in to perform this action"
        case .documentNotFound:
            return "The requested document was not found"
        case .encodingFailed:
            return "Failed to save data"
        case .decodingFailed:
            return "Failed to load data"
        case .networkError:
            return "Network error. Please check your connection."
        case .permissionDenied:
            return "You don't have permission to access this data"
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - Firestore Service

@MainActor
final class FirestoreService: ObservableObject {
    static let shared = FirestoreService()
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    private init() {
        // Firestore settings are configured in AppDelegate before any service accesses Firestore
    }
    
    // MARK: - Current User ID
    
    private var currentUserId: String? {
        auth.currentUser?.uid
    }
    
    private func requireUserId() throws -> String {
        guard let userId = currentUserId else {
            throw FirestoreError.notAuthenticated
        }
        return userId
    }
    
    // MARK: - User Operations
    
    /// Get user document reference
    private func userDocument() throws -> DocumentReference {
        let userId = try requireUserId()
        return db.collection("users").document(userId)
    }
    
    /// Update user data
    func updateUser(_ data: [String: Any]) async throws {
        let userRef = try userDocument()
        try await userRef.updateData(data)
    }
    
    /// Increment deck count
    func incrementDeckCount() async throws {
        let userRef = try userDocument()
        try await userRef.updateData([
            "decksCreated": FieldValue.increment(Int64(1))
        ])
    }
    
    // MARK: - Deck Operations
    
    /// Get decks collection reference
    private func decksCollection() throws -> CollectionReference {
        let userRef = try userDocument()
        return userRef.collection("decks")
    }
    
    /// Save a new deck
    func saveDeck(_ deck: Deck) async throws -> String {
        let decksRef = try decksCollection()
        
        var deckData = try encodeDeck(deck)
        deckData["createdAt"] = FieldValue.serverTimestamp()
        deckData["updatedAt"] = FieldValue.serverTimestamp()
        
        let docRef = try await decksRef.addDocument(data: deckData)
        
        // Increment user's deck count
        try await incrementDeckCount()
        
        print("✅ Deck saved with ID: \(docRef.documentID)")
        return docRef.documentID
    }
    
    /// Update an existing deck (with slides)
    func updateDeck(_ deck: Deck) async throws {
        guard !deck.id.isEmpty else {
            throw FirestoreError.documentNotFound
        }
        
        let decksRef = try decksCollection()
        var deckData = try encodeDeck(deck)
        deckData["updatedAt"] = FieldValue.serverTimestamp()
        
        // Use batch to update deck and slides atomically
        let batch = db.batch()
        
        // Update deck document
        let deckDoc = decksRef.document(deck.id)
        batch.setData(deckData, forDocument: deckDoc, merge: true)
        
        // Update all slides
        let slidesRef = deckDoc.collection("slides")
        for slide in deck.slides {
            let slideData = try encodeSlide(slide)
            let slideDoc = slidesRef.document(slide.id)
            batch.setData(slideData, forDocument: slideDoc)
        }
        
        try await batch.commit()
        print("✅ Deck updated with \(deck.slides.count) slides: \(deck.id)")
    }
    
    /// Delete a deck
    func deleteDeck(_ deckId: String) async throws {
        let decksRef = try decksCollection()
        
        // Delete all slides first
        let slidesRef = decksRef.document(deckId).collection("slides")
        let slides = try await slidesRef.getDocuments()
        
        for slide in slides.documents {
            try await slide.reference.delete()
        }
        
        // Delete the deck
        try await decksRef.document(deckId).delete()
        print("✅ Deck deleted: \(deckId)")
    }
    
    /// Fetch all decks for current user (with slides)
    func fetchDecks() async throws -> [Deck] {
        let decksRef = try decksCollection()
        
        let snapshot = try await decksRef
            .order(by: "updatedAt", descending: true)
            .getDocuments()
        
        var decks: [Deck] = []
        
        for document in snapshot.documents {
            if var deck = try? decodeDeck(from: document) {
                // Fetch slides for this deck
                let slides = try await fetchSlides(forDeck: document.documentID)
                deck.slides = slides
                decks.append(deck)
            }
        }
        
        print("📂 Fetched \(decks.count) decks with slides")
        return decks
    }
    
    /// Fetch a single deck by ID (with slides)
    func fetchDeck(id: String) async throws -> Deck {
        let decksRef = try decksCollection()
        let document = try await decksRef.document(id).getDocument()
        
        guard document.exists else {
            throw FirestoreError.documentNotFound
        }
        
        var deck = try decodeDeck(from: document)
        
        // Fetch slides for this deck
        let slides = try await fetchSlides(forDeck: id)
        deck.slides = slides
        
        return deck
    }
    
    /// Listen to deck changes in real-time
    func listenToDecks(onChange: @escaping ([Deck]) -> Void) -> ListenerRegistration? {
        guard let userId = currentUserId else {
            print("⚠️ Cannot listen to decks: not authenticated")
            return nil
        }
        
        let decksRef = db.collection("users").document(userId).collection("decks")
        
        return decksRef
            .order(by: "updatedAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Firestore listener error: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    onChange([])
                    return
                }
                
                // Fetch decks with their slides
                Task { @MainActor in
                    var decksWithSlides: [Deck] = []
                    
                    for doc in documents {
                        if var deck = try? self.decodeDeck(from: doc) {
                            // Fetch slides for this deck
                            if let slides = try? await self.fetchSlides(forDeck: doc.documentID) {
                                deck.slides = slides
                            }
                            decksWithSlides.append(deck)
                        }
                    }
                    
                    onChange(decksWithSlides)
                }
            }
    }
    
    // MARK: - Slide Operations
    
    /// Save slides for a deck
    func saveSlides(_ slides: [Slide], forDeck deckId: String) async throws {
        let decksRef = try decksCollection()
        let slidesRef = decksRef.document(deckId).collection("slides")
        
        // Use batch write for efficiency
        let batch = db.batch()
        
        for slide in slides {
            let slideData = try encodeSlide(slide)
            let slideDoc = slidesRef.document(slide.id)
            batch.setData(slideData, forDocument: slideDoc)
        }
        
        try await batch.commit()
        print("✅ Saved \(slides.count) slides for deck \(deckId)")
    }
    
    /// Fetch slides for a deck
    func fetchSlides(forDeck deckId: String) async throws -> [Slide] {
        let decksRef = try decksCollection()
        let slidesRef = decksRef.document(deckId).collection("slides")
        
        let snapshot = try await slidesRef
            .order(by: "index")
            .getDocuments()
        
        let slides = snapshot.documents.compactMap { doc -> Slide? in
            try? decodeSlide(from: doc, deckId: deckId)
        }
        
        print("📑 Fetched \(slides.count) slides for deck \(deckId)")
        return slides
    }
    
    // MARK: - Encoding/Decoding
    
    private func encodeDeck(_ deck: Deck) throws -> [String: Any] {
        return [
            "title": deck.title,
            "userId": deck.userId,
            "useCase": deck.useCase.rawValue,
            "themeId": deck.themeId,
            "storyScore": deck.storyScore as Any,
            "slideCount": deck.slides.count
        ]
    }
    
    private func decodeDeck(from document: DocumentSnapshot) throws -> Deck {
        guard let data = document.data() else {
            throw FirestoreError.decodingFailed
        }
        
        let useCase = DeckUseCase(rawValue: data["useCase"] as? String ?? "investor") ?? .investor
        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
        let userId = data["userId"] as? String ?? currentUserId ?? "unknown"
        
        return Deck(
            id: document.documentID,
            userId: userId,
            title: data["title"] as? String ?? "Untitled Deck",
            useCase: useCase,
            themeId: data["themeId"] as? String ?? "clean-light",
            storyScore: data["storyScore"] as? Int,
            slides: [], // Slides loaded separately
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    private func encodeSlide(_ slide: Slide) throws -> [String: Any] {
        return [
            "index": slide.index,
            "deckId": slide.deckId,
            "layoutType": slide.layoutType.rawValue,
            "title": slide.title,
            "bullets": slide.bullets,
            "speakerNotes": slide.speakerNotes as Any
        ]
    }
    
    private func decodeSlide(from document: DocumentSnapshot, deckId: String) throws -> Slide {
        guard let data = document.data() else {
            throw FirestoreError.decodingFailed
        }
        
        let layoutType = SlideLayoutType(rawValue: data["layoutType"] as? String ?? "title_bullets") ?? .titleBullets
        
        return Slide(
            id: document.documentID,
            deckId: data["deckId"] as? String ?? deckId,
            index: data["index"] as? Int ?? 0,
            layoutType: layoutType,
            title: data["title"] as? String ?? "",
            bullets: data["bullets"] as? [String] ?? [],
            speakerNotes: data["speakerNotes"] as? String
        )
    }
    
    // MARK: - Error Mapping
    
    private func mapFirestoreError(_ error: Error) -> FirestoreError {
        let nsError = error as NSError
        
        switch nsError.code {
        case FirestoreErrorCode.notFound.rawValue:
            return .documentNotFound
        case FirestoreErrorCode.permissionDenied.rawValue:
            return .permissionDenied
        case FirestoreErrorCode.unavailable.rawValue:
            return .networkError
        default:
            return .unknown(error.localizedDescription)
        }
    }
}

// MARK: - Batch Operations Extension

extension FirestoreService {
    /// Save deck with all slides in a single batch
    func saveDeckWithSlides(_ deck: Deck, slides: [Slide]) async throws -> String {
        let userId = try requireUserId()
        let deckRef = db.collection("users").document(userId).collection("decks").document()
        
        let batch = db.batch()
        
        // Add deck
        var deckData = try encodeDeck(deck)
        deckData["createdAt"] = FieldValue.serverTimestamp()
        deckData["updatedAt"] = FieldValue.serverTimestamp()
        batch.setData(deckData, forDocument: deckRef)
        
        // Add slides
        for slide in slides {
            let slideRef = deckRef.collection("slides").document(slide.id)
            let slideData = try encodeSlide(slide)
            batch.setData(slideData, forDocument: slideRef)
        }
        
        // Increment deck count
        let userRef = db.collection("users").document(userId)
        batch.updateData(["decksCreated": FieldValue.increment(Int64(1))], forDocument: userRef)
        
        try await batch.commit()
        
        print("✅ Saved deck with \(slides.count) slides: \(deckRef.documentID)")
        return deckRef.documentID
    }
}
