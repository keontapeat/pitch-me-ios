//
//  DocumentUpload.swift
//  Pitch Me
//
//  Document upload models
//

import Foundation
import UniformTypeIdentifiers

// MARK: - Document Upload

struct DocumentUpload: Identifiable, Codable {
    let id: String
    let userId: String
    let fileName: String
    let fileSize: Int64
    let mimeType: String
    let uploadedAt: Date
    var status: UploadStatus
    var extractedText: String?
    var analysisResult: DocumentAnalysis?
    
    var fileSizeFormatted: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
    
    var fileExtension: String {
        (fileName as NSString).pathExtension.uppercased()
    }
}

// MARK: - Upload Status

enum UploadStatus: String, Codable {
    case uploading = "uploading"
    case processing = "processing"
    case completed = "completed"
    case failed = "failed"
    
    var displayName: String {
        switch self {
        case .uploading: return "Uploading..."
        case .processing: return "Analyzing..."
        case .completed: return "Ready"
        case .failed: return "Failed"
        }
    }
    
    var icon: String {
        switch self {
        case .uploading: return "arrow.up.circle"
        case .processing: return "brain"
        case .completed: return "checkmark.circle.fill"
        case .failed: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - Document Analysis

struct DocumentAnalysis: Codable {
    let companyName: String?
    let industry: String?
    let problem: String?
    let solution: String?
    let targetMarket: String?
    let competitors: [String]?
    let keyMetrics: [String: String]?
    let teamMembers: [String]?
    let fundingStage: String?
    let fundingAmount: String?
    let extractedData: [String: String]
    
    var hasUsefulData: Bool {
        companyName != nil || problem != nil || solution != nil
    }
}

// MARK: - Supported File Types

enum SupportedFileType: String, CaseIterable {
    case pdf = "pdf"
    case doc = "doc"
    case docx = "docx"
    case txt = "txt"
    case pitch = "pitch"
    case pptx = "pptx"
    case key = "key"
    
    var displayName: String {
        switch self {
        case .pdf: return "PDF"
        case .doc: return "Word (DOC)"
        case .docx: return "Word (DOCX)"
        case .txt: return "Text"
        case .pitch: return "Pitch Deck"
        case .pptx: return "PowerPoint"
        case .key: return "Keynote"
        }
    }
    
    var icon: String {
        switch self {
        case .pdf: return "doc.fill"
        case .doc, .docx: return "doc.text.fill"
        case .txt: return "doc.plaintext.fill"
        case .pitch, .pptx, .key: return "rectangle.stack.fill"
        }
    }
    
    var utType: UTType? {
        switch self {
        case .pdf: return .pdf
        case .doc: return UTType(filenameExtension: "doc")
        case .docx: return UTType(filenameExtension: "docx")
        case .txt: return .plainText
        case .pitch: return UTType(filenameExtension: "pitch")
        case .pptx: return UTType(filenameExtension: "pptx")
        case .key: return UTType(filenameExtension: "key")
        }
    }
    
    static var allUTTypes: [UTType] {
        allCases.compactMap { $0.utType }
    }
}

