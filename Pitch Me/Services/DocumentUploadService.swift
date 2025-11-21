//
//  DocumentUploadService.swift
//  Pitch Me
//
//  Document upload and analysis service
//

import Foundation
import SwiftUI
import Combine
import UniformTypeIdentifiers

@MainActor
final class DocumentUploadService: ObservableObject {
    static let shared = DocumentUploadService()
    
    @Published var uploads: [DocumentUpload] = []
    @Published var isUploading = false
    @Published var uploadProgress: Double = 0.0
    
    private init() {}
    
    // MARK: - Upload Document
    
    func uploadDocument(url: URL) async throws -> DocumentUpload {
        isUploading = true
        uploadProgress = 0.0
        
        // Get file info
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
        let fileSize = fileAttributes[.size] as? Int64 ?? 0
        let fileName = url.lastPathComponent
        
        // Create upload record
        let upload = DocumentUpload(
            id: UUID().uuidString,
            userId: "current-user", // Replace with real user ID
            fileName: fileName,
            fileSize: fileSize,
            mimeType: url.pathExtension,
            uploadedAt: Date(),
            status: .uploading
        )
        
        uploads.append(upload)
        
        // Simulate upload progress
        for i in 1...10 {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
            uploadProgress = Double(i) / 10.0
        }
        
        // Update status to processing
        if let index = uploads.firstIndex(where: { $0.id == upload.id }) {
            uploads[index].status = .processing
        }
        
        // Extract text and analyze
        let extractedText = try await extractText(from: url)
        let analysis = try await analyzeDocument(text: extractedText)
        
        // Update with results
        if let index = uploads.firstIndex(where: { $0.id == upload.id }) {
            uploads[index].status = .completed
            uploads[index].extractedText = extractedText
            uploads[index].analysisResult = analysis
        }
        
        isUploading = false
        uploadProgress = 0.0
        
        return uploads.first(where: { $0.id == upload.id })!
    }
    
    // MARK: - Text Extraction
    
    private func extractText(from url: URL) async throws -> String {
        // Simulate text extraction
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In production, use PDFKit for PDFs, or other libraries for other formats
        // For now, return mock text
        return """
        Acme Inc. - AI-Powered Financial Intelligence
        
        Problem: Small business owners struggle with cash flow management and financial planning.
        
        Solution: We provide real-time financial insights powered by AI, making CFO-level analysis accessible to all businesses.
        
        Market: $180B global fintech market, targeting 25M SMBs in the US.
        
        Traction: $2.4M ARR, 1,200 active users, 340% YoY growth.
        
        Team: Jane Doe (CEO, ex-Stripe), John Smith (CTO, ex-Google), Sarah Johnson (Head of Growth, ex-Plaid).
        """
    }
    
    // MARK: - Document Analysis
    
    private func analyzeDocument(text: String) async throws -> DocumentAnalysis {
        // Simulate AI analysis
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        // In production, send to GPT-4/5 for structured extraction
        // Prompt: "Extract key information from this document for a pitch deck..."
        
        return DocumentAnalysis(
            companyName: "Acme Inc.",
            industry: "Fintech",
            problem: "Small business owners struggle with cash flow management and financial planning",
            solution: "Real-time financial insights powered by AI, making CFO-level analysis accessible",
            targetMarket: "25M SMBs in the US",
            competitors: ["Plaid", "Stripe", "QuickBooks"],
            keyMetrics: [
                "ARR": "$2.4M",
                "Users": "1,200",
                "Growth": "340% YoY"
            ],
            teamMembers: [
                "Jane Doe - CEO (ex-Stripe)",
                "John Smith - CTO (ex-Google)",
                "Sarah Johnson - Head of Growth (ex-Plaid)"
            ],
            fundingStage: "Seed",
            fundingAmount: "$3M",
            extractedData: [
                "market_size": "$180B",
                "target_segment": "SMBs"
            ]
        )
    }
    
    // MARK: - Generate Deck from Document
    
    func generateDeckFromDocument(_ upload: DocumentUpload) -> WizardState {
        guard let analysis = upload.analysisResult else {
            return WizardState()
        }
        
        var state = WizardState()
        
        // Populate wizard state from analysis
        state.startupName = analysis.companyName ?? ""
        state.oneLiner = analysis.solution ?? ""
        state.targetUser = analysis.targetMarket ?? ""
        state.problem = analysis.problem ?? ""
        state.solution = analysis.solution ?? ""
        state.marketSize = analysis.extractedData["market_size"] ?? ""
        state.traction = analysis.keyMetrics?.map { "\($0.key): \($0.value)" }.joined(separator: "\n") ?? ""
        state.team = analysis.teamMembers?.joined(separator: "\n") ?? ""
        
        return state
    }
    
    // MARK: - Delete Upload
    
    func deleteUpload(_ upload: DocumentUpload) {
        uploads.removeAll { $0.id == upload.id }
    }
}

