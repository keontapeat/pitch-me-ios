//
//  DocumentUploadStepView.swift
//  Pitch Me
//
//  Document upload for Pro users
//

import SwiftUI
import UniformTypeIdentifiers

struct DocumentUploadStepView: View {
    @ObservedObject var viewModel: WizardViewModel
    @StateObject private var uploadService = DocumentUploadService.shared
    @StateObject private var subscriptionService = SubscriptionService.shared
    @State private var showDocumentPicker = false
    @State private var showPaywall = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                // Header
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Quick Upload")
                        .font(Typography.displaySmall)
                        .foregroundColor(.pitchTextAdaptive)
                    
                    Text("Upload company documents and let AI extract the key information")
                        .font(Typography.bodyLarge)
                        .foregroundColor(.pitchTextSecondary)
                }
                
                // Pro feature badge or upgrade prompt
                if !subscriptionService.canAccessFeature(.uploadDocuments) {
                    ProFeatureBanner {
                        showPaywall = true
                    }
                } else {
                    // Upload area
                    uploadArea
                    
                    // Uploaded documents
                    if !uploadService.uploads.isEmpty {
                        uploadedDocumentsList
                    }
                    
                    // Or divider
                    HStack {
                        Rectangle().fill(Color.pitchDivider).frame(height: 1)
                        Text("OR")
                            .font(Typography.labelSmall)
                            .foregroundColor(.pitchTextTertiary)
                        Rectangle().fill(Color.pitchDivider).frame(height: 1)
                    }
                    
                    // Manual entry option
                    Text("Fill out manually")
                        .font(Typography.labelMedium)
                        .foregroundColor(.pitchTextSecondary)
                }
                
                Spacer()
                    .frame(height: Spacing.base)
            }
            .padding(.horizontal, Spacing.screenMarginHorizontal)
            .padding(.top, Spacing.lg)
            .padding(.bottom, 120)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: Spacing.sm) {
                if !uploadService.uploads.isEmpty, let lastUpload = uploadService.uploads.last, lastUpload.status == .completed {
                    PrimaryButton("Use This Document", icon: "checkmark") {
                        applyDocumentData(lastUpload)
                    }
                }
                
                PrimaryButton("Continue Manually", icon: "arrow.right") {
                    viewModel.goToNextStep()
                }
                
                if viewModel.canGoBack {
                    SecondaryButton("Back", icon: "arrow.left") {
                        viewModel.goToPreviousStep()
                    }
                }
            }
            .padding(.horizontal, Spacing.screenMarginHorizontal)
            .padding(.vertical, Spacing.base)
            .background(Color.pitchBackgroundAdaptive)
        }
        .fileImporter(
            isPresented: $showDocumentPicker,
            allowedContentTypes: SupportedFileType.allUTTypes,
            allowsMultipleSelection: false
        ) { result in
            Task {
                await handleFileSelection(result)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
    
    // MARK: - Upload Area
    
    private var uploadArea: some View {
        Button {
            showDocumentPicker = true
        } label: {
            VStack(spacing: Spacing.base) {
                if uploadService.isUploading {
                    // 🔥 Better progress indication
                    ProgressView(value: uploadService.uploadProgress)
                        .tint(.pitchLime)
                        .frame(width: 150)
                    
                    Text(progressLabel)
                        .font(Typography.labelMedium)
                        .foregroundColor(.pitchTextSecondary)
                        .animation(.easeInOut, value: uploadService.uploadProgress)
                    
                    // Show which AI is being used
                    if uploadService.uploadProgress > 0.5 {
                        HStack(spacing: 4) {
                            Image(systemName: uploadService.usedAIProvider.icon)
                                .foregroundColor(.pitchLime)
                            Text(uploadService.usedAIProvider.displayName)
                                .font(Typography.labelSmall)
                                .foregroundColor(.pitchTextTertiary)
                        }
                        .transition(.opacity)
                    }
                } else {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(.pitchLime)
                    
                    VStack(spacing: Spacing.xs) {
                        Text("Upload Document")
                            .font(Typography.titleMedium)
                            .foregroundColor(.pitchTextAdaptive)
                        
                        Text("PDF, Word, PowerPoint, or Pitch Deck")
                            .font(Typography.bodySmall)
                            .foregroundColor(.pitchTextSecondary)
                    }
                    
                    Text("Tap to browse files")
                        .font(Typography.labelSmall)
                        .foregroundColor(.pitchLime)
                        .padding(.horizontal, Spacing.base)
                        .padding(.vertical, Spacing.xs)
                        .background(Color.pitchLime.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.xxxl)
            .background(Color.pitchCardBackgroundAdaptive)
            .cornerRadius(Spacing.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.cardCornerRadius)
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 2, dash: [8])
                    )
                    .foregroundColor(.pitchLime.opacity(0.5))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(uploadService.isUploading)
    }
    
    // MARK: - Progress Label
    
    private var progressLabel: String {
        let progress = uploadService.uploadProgress
        if progress < 0.5 {
            return "Uploading... \(Int(progress * 100))%"
        } else if progress < 0.6 {
            return "Extracting text... 🔍"
        } else if progress < 0.95 {
            return "AI analyzing... \(Int(progress * 100))% 🤖"
        } else {
            return "Finishing up... ✨"
        }
    }
    
    // MARK: - Uploaded Documents List
    
    private var uploadedDocumentsList: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Uploaded Documents")
                .font(Typography.labelMedium)
                .foregroundColor(.pitchTextSecondary)
            
            ForEach(uploadService.uploads) { upload in
                DocumentCard(upload: upload)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func handleFileSelection(_ result: Result<[URL], Error>) async {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // Start accessing security-scoped resource
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let _ = try await uploadService.uploadDocument(url: url)
            } catch {
                print("Upload failed: \(error)")
            }
            
        case .failure(let error):
            print("File selection failed: \(error)")
        }
    }
    
    private func applyDocumentData(_ upload: DocumentUpload) {
        let extractedState = uploadService.generateDeckFromDocument(upload)
        viewModel.state = extractedState
        viewModel.goToStep(.summary)
    }
}

// MARK: - Pro Feature Banner

struct ProFeatureBanner: View {
    let onUpgrade: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.base) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "crown.fill")
                    .foregroundColor(.pitchLime)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pro Feature")
                        .font(Typography.labelLarge)
                        .foregroundColor(.pitchTextAdaptive)
                    
                    Text("Upload documents with Pro")
                        .font(Typography.bodySmall)
                        .foregroundColor(.pitchTextSecondary)
                }
                
                Spacer()
            }
            
            Button {
                onUpgrade()
            } label: {
                Text("Upgrade to Pro")
                    .font(Typography.labelLarge)
                    .fontWeight(.bold)
                    .foregroundColor(.pitchCharcoal)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.pitchLime)
                    .cornerRadius(Spacing.buttonCornerRadius)
            }
        }
        .padding(Spacing.base)
        .background(Color.pitchLime.opacity(0.1))
        .cornerRadius(Spacing.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.cardCornerRadius)
                .stroke(Color.pitchLime, lineWidth: 1)
        )
    }
}

// MARK: - Document Card

struct DocumentCard: View {
    let upload: DocumentUpload
    
    var body: some View {
        HStack(spacing: Spacing.base) {
            // File icon
            Image(systemName: upload.status.icon)
                .font(.title2)
                .foregroundColor(statusColor)
                .frame(width: 40)
            
            // File info
            VStack(alignment: .leading, spacing: 4) {
                Text(upload.fileName)
                    .font(Typography.labelLarge)
                    .foregroundColor(.pitchTextAdaptive)
                    .lineLimit(1)
                
                HStack(spacing: Spacing.xs) {
                    Text(upload.fileSizeFormatted)
                        .font(Typography.bodySmall)
                        .foregroundColor(.pitchTextSecondary)
                    
                    Text("•")
                        .foregroundColor(.pitchTextTertiary)
                    
                    Text(upload.status.displayName)
                        .font(Typography.bodySmall)
                        .foregroundColor(statusColor)
                }
            }
            
            Spacer()
            
            // Progress or checkmark
            if upload.status == .processing {
                ProgressView()
                    .tint(.pitchLime)
            } else if upload.status == .completed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.pitchSuccess)
            }
        }
        .padding(Spacing.md)
        .background(Color.pitchCardBackgroundAdaptive)
        .cornerRadius(Spacing.cardCornerRadius)
    }
    
    private var statusColor: Color {
        switch upload.status {
        case .uploading: return .pitchLime
        case .processing: return .pitchLime
        case .completed: return .pitchSuccess
        case .failed: return .pitchError
        }
    }
}

// MARK: - Preview

#Preview {
    DocumentUploadStepView(viewModel: WizardViewModel())
        .background(Color.pitchBackgroundAdaptive)
}

