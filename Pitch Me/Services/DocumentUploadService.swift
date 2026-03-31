//
//  DocumentUploadService.swift
//  Pitch Me
//
//  🔥 Document upload and AI analysis service powered by Claude Opus 4.5 🔥
//  Extracts text from PDFs, Word docs, and analyzes with elite AI
//

import Foundation
import SwiftUI
import Combine
import UniformTypeIdentifiers
import PDFKit  // 🔥 Real PDF extraction
import FirebaseAuth

@MainActor
final class DocumentUploadService: ObservableObject {
    static let shared = DocumentUploadService()
    
    @Published var uploads: [DocumentUpload] = []
    @Published var isUploading = false
    @Published var uploadProgress: Double = 0.0
    @Published var usedAIProvider: AIProvider = .none
    
    private let config = APIConfig.shared
    
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
            userId: Auth.auth().currentUser?.uid ?? "anonymous",
            fileName: fileName,
            fileSize: fileSize,
            mimeType: url.pathExtension,
            uploadedAt: Date(),
            status: .uploading
        )
        
        uploads.append(upload)
        
        // Smooth progress animation
        for i in 1...10 {
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05s
            uploadProgress = Double(i) / 20.0  // 0-50%
        }
        
        // Update status to processing
        if let index = uploads.firstIndex(where: { $0.id == upload.id }) {
            uploads[index].status = .processing
        }
        
        // Extract text and analyze
        uploadProgress = 0.5
        let extractedText = try await extractText(from: url)
        
        // 🔥 Start AI analysis with animated progress
        uploadProgress = 0.6
        
        // Create a task to animate progress while AI processes
        let progressTask = Task { @MainActor in
            var progress = 0.6
            while !Task.isCancelled && progress < 0.95 {
                try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s
                progress += 0.05
                self.uploadProgress = min(progress, 0.95)
            }
        }
        
        let analysis: DocumentAnalysis
        do {
            analysis = try await analyzeDocument(text: extractedText)
            progressTask.cancel()
        } catch {
            progressTask.cancel()
            throw error
        }
        
        // Update with results
        if let index = uploads.firstIndex(where: { $0.id == upload.id }) {
            uploads[index].status = .completed
            uploads[index].extractedText = extractedText
            uploads[index].analysisResult = analysis
        }
        
        uploadProgress = 1.0
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s for UX
        
        isUploading = false
        uploadProgress = 0.0
        
        return uploads.first(where: { $0.id == upload.id })!
    }
    
    // MARK: - Text Extraction (REAL PDFKit Implementation)
    
    private func extractText(from url: URL) async throws -> String {
        print("📄 Extracting text from: \(url.lastPathComponent)")
        
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "txt", "md", "markdown":
            // Text/Markdown files - read directly
            do {
                let text = try String(contentsOf: url, encoding: .utf8)
                print("✅ Extracted \(text.count) characters from text file")
                return text
            } catch {
                print("❌ Failed to read text file: \(error)")
                throw DocumentAnalysisError.extractionFailed("Failed to read text file")
            }
            
        case "pdf":
            // 🔥 REAL PDF EXTRACTION with PDFKit
            print("📑 Extracting PDF with PDFKit...")
            return try await extractPDFText(from: url)
            
        case "doc", "docx":
            // Word files - attempt to extract using AttributedString
            print("📝 Attempting Word extraction...")
            return try await extractWordText(from: url)
            
        case "ppt", "pptx", "key":
            // PowerPoint/Keynote - provide guidance
            print("⚠️ Presentation file - extracting what we can...")
            return try await extractPresentationInfo(from: url)
            
        case "rtf":
            // RTF files
            return try await extractRTFText(from: url)
            
        default:
            // Try to read as plain text
            do {
                let text = try String(contentsOf: url, encoding: .utf8)
                print("✅ Extracted \(text.count) characters from file")
                return text
            } catch {
                throw DocumentAnalysisError.unsupportedFileType
            }
        }
    }
    
    // MARK: - PDF Text Extraction (PDFKit)
    
    private func extractPDFText(from url: URL) async throws -> String {
        guard let pdfDocument = PDFDocument(url: url) else {
            throw DocumentAnalysisError.extractionFailed("Could not open PDF file")
        }
        
        var extractedText = ""
        let pageCount = pdfDocument.pageCount
        
        print("📄 PDF has \(pageCount) pages")
        
        for pageIndex in 0..<min(pageCount, 50) {  // Limit to 50 pages
            if let page = pdfDocument.page(at: pageIndex) {
                if let pageText = page.string {
                    extractedText += pageText + "\n\n"
                }
            }
        }
        
        if extractedText.isEmpty {
            // PDF might be scanned/image-based
            extractedText = "[This PDF appears to contain scanned images rather than text. Please provide a text-based document or manually enter your information.]"
        }
        
        print("✅ Extracted \(extractedText.count) characters from PDF")
        return extractedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Word Document Extraction
    
    private func extractWordText(from url: URL) async throws -> String {
        // Try to read DOCX as attributed string
        do {
            let attributedString = try NSAttributedString(
                url: url,
                options: [.documentType: NSAttributedString.DocumentType.rtfd],
                documentAttributes: nil
            )
            let text = attributedString.string
            print("✅ Extracted \(text.count) characters from Word document")
            return text
        } catch {
            // Fallback: try to extract from the DOCX ZIP structure
            do {
                let data = try Data(contentsOf: url)
                // DOCX is a ZIP file, try to read document.xml
                if let text = extractTextFromDocxData(data) {
                    print("✅ Extracted \(text.count) characters from DOCX")
                    return text
                }
            } catch {
                print("⚠️ Could not extract Word document: \(error)")
            }
            
            return "[Word document extraction limited. For best results, copy and paste your text directly or save as PDF/TXT.]"
        }
    }
    
    // MARK: - DOCX Internal Extraction
    
    private func extractTextFromDocxData(_ data: Data) -> String? {
        // DOCX files are ZIP archives containing XML
        // This is a simplified extraction - a full implementation would use ZipArchive
        let searchPattern = Data("<w:t>".utf8)
        let endPattern = Data("</w:t>".utf8)
        
        var extractedText = ""
        var searchStart = data.startIndex
        
        while let startRange = data.range(of: searchPattern, in: searchStart..<data.endIndex) {
            let contentStart = startRange.upperBound
            if let endRange = data.range(of: endPattern, in: contentStart..<data.endIndex) {
                if let text = String(data: data[contentStart..<endRange.lowerBound], encoding: .utf8) {
                    extractedText += text
                }
                searchStart = endRange.upperBound
            } else {
                break
            }
        }
        
        return extractedText.isEmpty ? nil : extractedText
    }
    
    // MARK: - RTF Extraction
    
    private func extractRTFText(from url: URL) async throws -> String {
        do {
            let attributedString = try NSAttributedString(
                url: url,
                options: [.documentType: NSAttributedString.DocumentType.rtf],
                documentAttributes: nil
            )
            return attributedString.string
        } catch {
            throw DocumentAnalysisError.extractionFailed("Could not read RTF file")
        }
    }
    
    // MARK: - Presentation Info
    
    private func extractPresentationInfo(from url: URL) async throws -> String {
        // For presentations, provide helpful guidance
        let fileName = url.lastPathComponent
        return """
        [Presentation file detected: \(fileName)]
        
        For best results with presentation files:
        1. Export your presentation as PDF
        2. Or copy/paste the text content directly
        3. Or use the manual input wizard
        
        We're working on full PowerPoint/Keynote support!
        """
    }
    
    // MARK: - Document Analysis (Gemini 2.0 Flash → GPT-4o → Claude Fallback)
    
    private func analyzeDocument(text: String) async throws -> DocumentAnalysis {
        print("🤖 Starting AI analysis...")
        print("📝 Text length: \(text.count) characters")
        
        // ELITE document analysis prompt
        let systemPrompt = EliteDocumentAnalyzer.eliteExtractionPrompt
        
        // Limit text to avoid token limits
        let limitedText = String(text.prefix(15000))
        
        let userPrompt = """
        DOCUMENT TEXT:
        
        \(limitedText)
        
        Extract all relevant information for creating a pitch deck.
        Return ONLY valid JSON matching this structure:
        {
            "companyName": "string or null",
            "industry": "string or null",
            "problem": "string or null",
            "solution": "string or null",
            "targetMarket": "string or null",
            "competitors": ["string array or null"],
            "keyMetrics": {"key": "value pairs or null"},
            "teamMembers": ["string array or null"],
            "fundingStage": "string or null",
            "fundingAmount": "string or null",
            "extractedData": {"additional": "data"}
        }
        """
        
        // 🔥 Try Gemini FIRST - it's FAST AF 🔥
        if config.hasGeminiKey {
            print("⚡ Using Gemini 2.0 Flash for SPEED...")
            usedAIProvider = .gemini
            
            do {
                let analysis: DocumentAnalysis = try await GeminiService.shared.generateStructuredJSON(
                    prompt: userPrompt,
                    systemPrompt: systemPrompt,
                    model: .gemini20Flash  // 🔥 FASTEST
                )
                
                print("✅ Gemini analysis complete! BLAZING FAST 🔥")
                print("   Company: \(analysis.companyName ?? "N/A")")
                return analysis
            } catch {
                print("⚠️ Gemini failed, trying OpenAI: \(error)")
            }
        }
        
        // Try OpenAI GPT-4o as fallback
        if config.hasOpenAIKey {
            print("🤖 Using GPT-4o for document analysis...")
            usedAIProvider = .openAI
            
            do {
                let analysis: DocumentAnalysis = try await OpenAIService.shared.generateStructuredJSON(
                    prompt: userPrompt,
                    systemPrompt: systemPrompt,
                    model: .gpt4o
                )
                
                print("✅ GPT-4o analysis complete!")
                return analysis
            } catch {
                print("⚠️ GPT-4o failed: \(error)")
            }
        }
        
        // Try Claude as last resort
        if config.hasAnthropicKey {
            print("🔥 Using Claude Opus 4.5 for document analysis...")
            usedAIProvider = .anthropic
            
            do {
                let analysis: DocumentAnalysis = try await AnthropicService.shared.generateStructuredJSON(
                    prompt: userPrompt,
                    systemPrompt: systemPrompt,
                    model: .claudeOpus45
                )
                
                print("✅ Claude analysis complete!")
                return analysis
            } catch {
                print("❌ Claude analysis failed: \(error)")
                throw DocumentAnalysisError.analysisFailedAI(error.localizedDescription)
            }
        }
        
        // No AI available
        throw DocumentAnalysisError.analysisFailedAI("No AI service configured. Add GEMINI_API_KEY, OPENAI_API_KEY, or ANTHROPIC_API_KEY to Secrets.plist")
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

// MARK: - Errors

enum DocumentAnalysisError: Error, LocalizedError {
    case extractionFailed(String)
    case analysisFailedAI(String)  // Fixed typo
    case unsupportedFileType
    case fileTooLarge
    case noAIConfigured
    
    var errorDescription: String? {
        switch self {
        case .extractionFailed(let message):
            return "Failed to extract text: \(message)"
        case .analysisFailedAI(let message):
            return "AI analysis failed: \(message)"
        case .unsupportedFileType:
            return "Unsupported file type. Please use PDF, Word, Text, or Markdown files."
        case .fileTooLarge:
            return "File is too large. Maximum size is 50MB."
        case .noAIConfigured:
            return "No AI service configured. Add API keys to Secrets.plist"
        }
    }
}

