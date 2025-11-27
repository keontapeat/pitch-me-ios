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
    
    // Custom decoder to handle AI returning nested objects instead of flat strings
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        companyName = try container.decodeIfPresent(String.self, forKey: .companyName)
        industry = try container.decodeIfPresent(String.self, forKey: .industry)
        problem = try container.decodeIfPresent(String.self, forKey: .problem)
        solution = try container.decodeIfPresent(String.self, forKey: .solution)
        targetMarket = try container.decodeIfPresent(String.self, forKey: .targetMarket)
        competitors = try container.decodeIfPresent([String].self, forKey: .competitors)
        teamMembers = try container.decodeIfPresent([String].self, forKey: .teamMembers)
        fundingStage = try container.decodeIfPresent(String.self, forKey: .fundingStage)
        fundingAmount = try container.decodeIfPresent(String.self, forKey: .fundingAmount)
        
        // Handle keyMetrics - AI might return nested objects, so flatten them
        if let metricsDict = try? container.decodeIfPresent([String: String].self, forKey: .keyMetrics) {
            keyMetrics = metricsDict
        } else if let flexibleMetrics = try? container.decodeIfPresent([String: FlexibleValue].self, forKey: .keyMetrics) {
            keyMetrics = flexibleMetrics.mapValues { $0.stringValue }
        } else {
            keyMetrics = nil
        }
        
        // Handle extractedData - AI might return nested objects, so flatten them
        if let dataDict = try? container.decodeIfPresent([String: String].self, forKey: .extractedData) {
            extractedData = dataDict
        } else if let flexibleData = try? container.decodeIfPresent([String: FlexibleValue].self, forKey: .extractedData) {
            extractedData = flexibleData.mapValues { $0.stringValue }
        } else {
            extractedData = [:]
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case companyName, industry, problem, solution, targetMarket
        case competitors, keyMetrics, teamMembers, fundingStage, fundingAmount, extractedData
    }
}

// MARK: - Flexible Value (handles AI returning mixed types)

enum FlexibleValue: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([FlexibleValue])
    case dictionary([String: FlexibleValue])
    case null
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
            return
        }
        
        if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let array = try? container.decode([FlexibleValue].self) {
            self = .array(array)
        } else if let dict = try? container.decode([String: FlexibleValue].self) {
            self = .dictionary(dict)
        } else {
            self = .null
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value): try container.encode(value)
        case .int(let value): try container.encode(value)
        case .double(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        case .array(let value): try container.encode(value)
        case .dictionary(let value): try container.encode(value)
        case .null: try container.encodeNil()
        }
    }
    
    /// Convert any value to a string representation
    var stringValue: String {
        switch self {
        case .string(let value): return value
        case .int(let value): return String(value)
        case .double(let value): return String(value)
        case .bool(let value): return value ? "Yes" : "No"
        case .array(let values): return values.map { $0.stringValue }.joined(separator: ", ")
        case .dictionary(let dict):
            return dict.map { "\($0.key): \($0.value.stringValue)" }.joined(separator: "; ")
        case .null: return ""
        }
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

