//
//  StorageService.swift
//  Pitch Me
//
//  🔥 Elite Firebase Storage Service
//  Handles file uploads for documents, images, and exports
//

import Foundation
import FirebaseStorage
import FirebaseAuth
import UIKit

// MARK: - Storage Error

enum StorageError: Error, LocalizedError {
    case notAuthenticated
    case uploadFailed(String)
    case downloadFailed(String)
    case deleteFailed(String)
    case invalidFileType
    case fileTooLarge
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be logged in to upload files"
        case .uploadFailed(let message):
            return "Upload failed: \(message)"
        case .downloadFailed(let message):
            return "Download failed: \(message)"
        case .deleteFailed(let message):
            return "Delete failed: \(message)"
        case .invalidFileType:
            return "This file type is not supported"
        case .fileTooLarge:
            return "File is too large. Maximum size is 50MB."
        case .networkError:
            return "Network error. Please check your connection."
        }
    }
}

// MARK: - Upload Progress

struct UploadProgress {
    let bytesTransferred: Int64
    let totalBytes: Int64
    
    var progress: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(bytesTransferred) / Double(totalBytes)
    }
    
    var percentComplete: Int {
        Int(progress * 100)
    }
}

// MARK: - Storage Service

@MainActor
final class StorageService: ObservableObject {
    static let shared = StorageService()
    
    private let storage = Storage.storage()
    private let auth = Auth.auth()
    
    @Published var uploadProgress: Double = 0
    @Published var isUploading = false
    
    // Maximum file size: 50MB
    private let maxFileSize: Int64 = 50 * 1024 * 1024
    
    private init() {}
    
    // MARK: - Current User ID
    
    private var currentUserId: String? {
        auth.currentUser?.uid
    }
    
    private func requireUserId() throws -> String {
        guard let userId = currentUserId else {
            throw StorageError.notAuthenticated
        }
        return userId
    }
    
    // MARK: - Storage References
    
    private func userStorageRef() throws -> StorageReference {
        let userId = try requireUserId()
        return storage.reference().child("users/\(userId)")
    }
    
    // MARK: - Document Upload
    
    /// Upload a document file (PDF, Word, etc.)
    func uploadDocument(
        url: URL,
        fileName: String? = nil,
        progressHandler: ((UploadProgress) -> Void)? = nil
    ) async throws -> String {
        let userId = try requireUserId()
        let finalFileName = fileName ?? url.lastPathComponent
        
        // Validate file size
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
        let fileSize = fileAttributes[.size] as? Int64 ?? 0
        
        guard fileSize <= maxFileSize else {
            throw StorageError.fileTooLarge
        }
        
        // Read file data
        let data = try Data(contentsOf: url)
        
        // Create storage reference
        let documentRef = storage.reference()
            .child("users/\(userId)/documents/\(UUID().uuidString)_\(finalFileName)")
        
        // Create metadata
        let metadata = StorageMetadata()
        metadata.contentType = mimeType(for: url.pathExtension)
        metadata.customMetadata = [
            "originalFileName": finalFileName,
            "uploadedAt": ISO8601DateFormatter().string(from: Date())
        ]
        
        isUploading = true
        uploadProgress = 0
        
        defer {
            isUploading = false
            uploadProgress = 0
        }
        
        // Upload with progress
        let uploadTask = documentRef.putData(data, metadata: metadata)
        
        // Track progress
        uploadTask.observe(.progress) { [weak self] snapshot in
            guard let progress = snapshot.progress else { return }
            let uploadProgress = UploadProgress(
                bytesTransferred: progress.completedUnitCount,
                totalBytes: progress.totalUnitCount
            )
            Task { @MainActor in
                self?.uploadProgress = uploadProgress.progress
            }
            progressHandler?(uploadProgress)
        }
        
        // Wait for completion
        _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<StorageMetadata, Error>) in
            uploadTask.observe(.success) { snapshot in
                if let metadata = snapshot.metadata {
                    continuation.resume(returning: metadata)
                } else {
                    continuation.resume(throwing: StorageError.uploadFailed("No metadata returned"))
                }
            }
            
            uploadTask.observe(.failure) { snapshot in
                let error = snapshot.error ?? StorageError.uploadFailed("Unknown error")
                continuation.resume(throwing: error)
            }
        }
        
        // Get download URL
        let downloadURL = try await documentRef.downloadURL()
        print("✅ Document uploaded: \(downloadURL.absoluteString)")
        
        return downloadURL.absoluteString
    }
    
    // MARK: - Image Upload
    
    /// Upload an image (for slide images, profile photos, etc.)
    func uploadImage(
        _ image: UIImage,
        path: String,
        quality: CGFloat = 0.8,
        progressHandler: ((UploadProgress) -> Void)? = nil
    ) async throws -> String {
        let userId = try requireUserId()
        
        guard let imageData = image.jpegData(compressionQuality: quality) else {
            throw StorageError.uploadFailed("Could not convert image to data")
        }
        
        // Check file size
        guard imageData.count <= maxFileSize else {
            throw StorageError.fileTooLarge
        }
        
        let imageRef = storage.reference()
            .child("users/\(userId)/images/\(path)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        isUploading = true
        uploadProgress = 0
        
        defer {
            isUploading = false
            uploadProgress = 0
        }
        
        let uploadTask = imageRef.putData(imageData, metadata: metadata)
        
        uploadTask.observe(.progress) { [weak self] snapshot in
            guard let progress = snapshot.progress else { return }
            let uploadProgress = UploadProgress(
                bytesTransferred: progress.completedUnitCount,
                totalBytes: progress.totalUnitCount
            )
            Task { @MainActor in
                self?.uploadProgress = uploadProgress.progress
            }
            progressHandler?(uploadProgress)
        }
        
        _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<StorageMetadata, Error>) in
            uploadTask.observe(.success) { snapshot in
                if let metadata = snapshot.metadata {
                    continuation.resume(returning: metadata)
                } else {
                    continuation.resume(throwing: StorageError.uploadFailed("No metadata returned"))
                }
            }
            
            uploadTask.observe(.failure) { snapshot in
                let error = snapshot.error ?? StorageError.uploadFailed("Unknown error")
                continuation.resume(throwing: error)
            }
        }
        
        let downloadURL = try await imageRef.downloadURL()
        print("✅ Image uploaded: \(downloadURL.absoluteString)")
        
        return downloadURL.absoluteString
    }
    
    // MARK: - Export Upload
    
    /// Upload an exported deck file (PDF, PPTX)
    func uploadExport(
        data: Data,
        fileName: String,
        deckId: String,
        format: String,
        progressHandler: ((UploadProgress) -> Void)? = nil
    ) async throws -> String {
        let userId = try requireUserId()
        
        guard data.count <= maxFileSize else {
            throw StorageError.fileTooLarge
        }
        
        let exportRef = storage.reference()
            .child("users/\(userId)/exports/\(deckId)/\(fileName)")
        
        let metadata = StorageMetadata()
        metadata.contentType = mimeType(for: format)
        metadata.customMetadata = [
            "deckId": deckId,
            "format": format,
            "exportedAt": ISO8601DateFormatter().string(from: Date())
        ]
        
        isUploading = true
        uploadProgress = 0
        
        defer {
            isUploading = false
            uploadProgress = 0
        }
        
        let uploadTask = exportRef.putData(data, metadata: metadata)
        
        uploadTask.observe(.progress) { [weak self] snapshot in
            guard let progress = snapshot.progress else { return }
            let uploadProgress = UploadProgress(
                bytesTransferred: progress.completedUnitCount,
                totalBytes: progress.totalUnitCount
            )
            Task { @MainActor in
                self?.uploadProgress = uploadProgress.progress
            }
            progressHandler?(uploadProgress)
        }
        
        _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<StorageMetadata, Error>) in
            uploadTask.observe(.success) { snapshot in
                if let metadata = snapshot.metadata {
                    continuation.resume(returning: metadata)
                } else {
                    continuation.resume(throwing: StorageError.uploadFailed("No metadata returned"))
                }
            }
            
            uploadTask.observe(.failure) { snapshot in
                let error = snapshot.error ?? StorageError.uploadFailed("Unknown error")
                continuation.resume(throwing: error)
            }
        }
        
        let downloadURL = try await exportRef.downloadURL()
        print("✅ Export uploaded: \(downloadURL.absoluteString)")
        
        return downloadURL.absoluteString
    }
    
    // MARK: - Download
    
    /// Download file data from URL
    func downloadData(from urlString: String) async throws -> Data {
        let ref = storage.reference(forURL: urlString)
        
        do {
            let data = try await ref.data(maxSize: maxFileSize)
            print("✅ Downloaded \(data.count) bytes")
            return data
        } catch {
            throw StorageError.downloadFailed(error.localizedDescription)
        }
    }
    
    /// Get download URL for a storage path
    func getDownloadURL(for path: String) async throws -> URL {
        let userId = try requireUserId()
        let ref = storage.reference().child("users/\(userId)/\(path)")
        
        do {
            return try await ref.downloadURL()
        } catch {
            throw StorageError.downloadFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Delete
    
    /// Delete a file from storage
    func deleteFile(at urlString: String) async throws {
        let ref = storage.reference(forURL: urlString)
        
        do {
            try await ref.delete()
            print("✅ File deleted: \(urlString)")
        } catch {
            throw StorageError.deleteFailed(error.localizedDescription)
        }
    }
    
    /// Delete all files for a deck
    func deleteDeckFiles(deckId: String) async throws {
        let userId = try requireUserId()
        let deckRef = storage.reference().child("users/\(userId)/exports/\(deckId)")
        
        do {
            let listResult = try await deckRef.listAll()
            
            for item in listResult.items {
                try await item.delete()
            }
            
            print("✅ Deleted all files for deck: \(deckId)")
        } catch {
            // Ignore if folder doesn't exist
            print("⚠️ Could not delete deck files: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helpers
    
    private func mimeType(for fileExtension: String) -> String {
        switch fileExtension.lowercased() {
        case "pdf":
            return "application/pdf"
        case "doc":
            return "application/msword"
        case "docx":
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "ppt":
            return "application/vnd.ms-powerpoint"
        case "pptx":
            return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case "txt":
            return "text/plain"
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "gif":
            return "image/gif"
        default:
            return "application/octet-stream"
        }
    }
}

// MARK: - Profile Image Extension

extension StorageService {
    /// Upload profile image
    func uploadProfileImage(_ image: UIImage) async throws -> String {
        let userId = try requireUserId()
        let path = "profile/\(userId).jpg"
        
        // Resize image for profile (max 500x500)
        let resizedImage = resizeImage(image, maxSize: 500)
        
        return try await uploadImage(resizedImage, path: path, quality: 0.85)
    }
    
    private func resizeImage(_ image: UIImage, maxSize: CGFloat) -> UIImage {
        let size = image.size
        
        guard size.width > maxSize || size.height > maxSize else {
            return image
        }
        
        let ratio = min(maxSize / size.width, maxSize / size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
}
