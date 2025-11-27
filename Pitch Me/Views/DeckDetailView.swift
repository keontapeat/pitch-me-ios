//
//  DeckDetailView.swift
//  PitchMe
//
//  Main view for viewing and editing a pitch deck
//

import SwiftUI

struct DeckDetailView: View {
    @StateObject private var viewModel: DeckDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(deck: Deck) {
        _viewModel = StateObject(wrappedValue: DeckDetailViewModel(deck: deck))
    }
    
    var body: some View {
        ZStack {
            Color.pitchBackgroundAdaptive.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Slide carousel
                SlidePreviewCarouselView(
                    deck: viewModel.deck,
                    selectedIndex: $viewModel.selectedSlideIndex
                )
                .padding(.top, Spacing.md)
                
                // Current slide editor
                if let currentSlide = viewModel.currentSlide {
                    slideEditorView(for: currentSlide)
                } else {
                    emptyDeckView
                }
            }
        }
        .navigationTitle(viewModel.deck.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Menu {
                    Button {
                        viewModel.isShowingThemePicker = true
                    } label: {
                        Label("Change Theme", systemImage: "paintbrush.fill")
                    }
                    
                    Button {
                        viewModel.isShowingExportOptions = true
                    } label: {
                        Label("Export Deck", systemImage: "square.and.arrow.up")
                    }
                    
                    Divider()
                    
                    Button {
                        viewModel.addSlide()
                    } label: {
                        Label("Add Slide", systemImage: "plus.rectangle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.pitchLime)
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingThemePicker) {
            ThemePickerView(
                selectedTheme: viewModel.deck.theme,
                onThemeSelected: { theme in
                    viewModel.changeTheme(to: theme)
                }
            )
        }
        .sheet(isPresented: $viewModel.isShowingExportOptions) {
            ExportOptionsView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            if let fileURL = viewModel.exportedFileURL {
                ShareSheet(items: [fileURL])
            }
        }
        .alert("Export Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
    
    // MARK: - Slide Editor View
    
    private func slideEditorView(for slide: Slide) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                // Slide title editor
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Label("Title", systemImage: "textformat.size")
                        .font(Typography.labelMedium)
                        .foregroundColor(.pitchTextSecondary)
                    
                    TextField("Slide title", text: binding(for: slide, keyPath: \.title))
                        .font(Typography.titleLarge)
                        .foregroundColor(.pitchTextAdaptive)
                        .padding(Spacing.md)
                        .background(Color.pitchCardBackgroundAdaptive)
                        .cornerRadius(Spacing.cardCornerRadius)
                }
                
                // Bullets editor
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Label("Content", systemImage: "list.bullet")
                            .font(Typography.labelMedium)
                            .foregroundColor(.pitchTextSecondary)
                        
                        Spacer()
                        
                        Button {
                            viewModel.addBulletToSlide(at: viewModel.selectedSlideIndex)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.pitchLime)
                        }
                    }
                    
                    ForEach(Array(slide.bullets.enumerated()), id: \.offset) { index, bullet in
                        HStack(alignment: .top, spacing: Spacing.sm) {
                            Circle()
                                .fill(Color.pitchLime)
                                .frame(width: 8, height: 8)
                                .padding(.top, 12)
                            
                            TextField("Bullet point", text: bulletBinding(slideIndex: viewModel.selectedSlideIndex, bulletIndex: index))
                                .font(Typography.bodyLarge)
                                .foregroundColor(.pitchTextAdaptive)
                                .padding(Spacing.md)
                                .background(Color.pitchCardBackgroundAdaptive)
                                .cornerRadius(Spacing.cardCornerRadius)
                            
                            Button {
                                viewModel.removeBulletFromSlide(
                                    slideIndex: viewModel.selectedSlideIndex,
                                    bulletIndex: index
                                )
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.pitchError)
                            }
                            .padding(.top, 12)
                        }
                    }
                    
                    if slide.bullets.isEmpty {
                        Text("No content yet. Tap + to add bullet points.")
                            .font(Typography.bodyMedium)
                            .foregroundColor(.pitchTextTertiary)
                            .padding(Spacing.lg)
                            .frame(maxWidth: .infinity)
                            .background(Color.pitchCardBackgroundAdaptive)
                            .cornerRadius(Spacing.cardCornerRadius)
                    }
                }
                
                // AI regenerate button
                Button {
                    Task {
                        await viewModel.regenerateSlide(at: viewModel.selectedSlideIndex)
                    }
                } label: {
                    HStack {
                        if viewModel.isRegeneratingSlide {
                            ProgressView()
                                .tint(.pitchCharcoal)
                        } else {
                            Image(systemName: "sparkles")
                        }
                        Text(viewModel.isRegeneratingSlide ? "Improving..." : "Ask AI to improve this slide")
                    }
                    .font(Typography.labelLarge)
                    .foregroundColor(.pitchCharcoal)
                    .frame(height: Spacing.buttonHeight)
                    .frame(maxWidth: .infinity)
                    .background(Color.pitchLime)
                    .cornerRadius(Spacing.buttonCornerRadius)
                }
                .disabled(viewModel.isRegeneratingSlide)
                
                // Speaker notes
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Label("Speaker Notes", systemImage: "note.text")
                        .font(Typography.labelMedium)
                        .foregroundColor(.pitchTextSecondary)
                    
                    TextEditor(text: speakerNotesBinding(for: slide))
                        .font(Typography.bodyMedium)
                        .foregroundColor(.pitchTextAdaptive)
                        .frame(minHeight: 100)
                        .padding(Spacing.sm)
                        .background(Color.pitchCardBackgroundAdaptive)
                        .cornerRadius(Spacing.cardCornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: Spacing.cardCornerRadius)
                                .stroke(Color.pitchDivider, lineWidth: BorderWidth.hairline)
                        )
                }
                
                // Slide actions
                HStack(spacing: Spacing.base) {
                    Button(role: .destructive) {
                        viewModel.deleteSlide(at: viewModel.selectedSlideIndex)
                    } label: {
                        Label("Delete Slide", systemImage: "trash")
                            .font(Typography.labelLarge)
                            .foregroundColor(.white)
                            .frame(height: Spacing.buttonHeight)
                            .frame(maxWidth: .infinity)
                            .background(Color.pitchError)
                            .cornerRadius(Spacing.buttonCornerRadius)
                    }
                }
            }
            .padding(Spacing.screenMarginHorizontal)
            .padding(.bottom, Spacing.xxxl)
        }
    }
    
    // MARK: - Empty Deck View
    
    private var emptyDeckView: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 56))
                .foregroundColor(.pitchLime)
            
            Text("No slides yet")
                .font(Typography.titleLarge)
                .foregroundColor(.pitchTextAdaptive)
            
            Button {
                viewModel.addSlide()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add First Slide")
                }
                .font(Typography.labelLarge)
                .foregroundColor(.pitchCharcoal)
                .frame(height: Spacing.buttonHeight)
                .padding(.horizontal, Spacing.xxl)
                .background(Color.pitchLime)
                .cornerRadius(Spacing.buttonCornerRadius)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Bindings
    
    private func binding(for slide: Slide, keyPath: WritableKeyPath<Slide, String>) -> Binding<String> {
        Binding(
            get: { viewModel.deck.slides[viewModel.selectedSlideIndex][keyPath: keyPath] },
            set: { newValue in
                viewModel.updateSlideTitle(at: viewModel.selectedSlideIndex, newTitle: newValue)
            }
        )
    }
    
    private func bulletBinding(slideIndex: Int, bulletIndex: Int) -> Binding<String> {
        Binding(
            get: { 
                guard slideIndex < viewModel.deck.slides.count,
                      bulletIndex < viewModel.deck.slides[slideIndex].bullets.count else {
                    return ""
                }
                return viewModel.deck.slides[slideIndex].bullets[bulletIndex]
            },
            set: { newValue in
                viewModel.updateSlideBullet(slideIndex: slideIndex, bulletIndex: bulletIndex, newText: newValue)
            }
        )
    }
    
    private func speakerNotesBinding(for slide: Slide) -> Binding<String> {
        Binding(
            get: { slide.speakerNotes ?? "" },
            set: { newValue in
                viewModel.updateSpeakerNotes(
                    at: viewModel.selectedSlideIndex,
                    notes: newValue.isEmpty ? nil : newValue
                )
            }
        )
    }
}

// MARK: - Theme Picker View

struct ThemePickerView: View {
    let selectedTheme: Theme
    let onThemeSelected: (Theme) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.pitchBackgroundAdaptive.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.base) {
                        ForEach(Theme.allThemes) { theme in
                            ThemeCard(
                                theme: theme,
                                isSelected: theme.id == selectedTheme.id
                            )
                            .onTapGesture {
                                onThemeSelected(theme)
                                dismiss()
                            }
                        }
                    }
                    .padding(Spacing.screenMarginHorizontal)
                }
            }
            .navigationTitle("Choose Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ThemeCard: View {
    let theme: Theme
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(theme.displayName)
                        .font(Typography.titleMedium)
                        .foregroundColor(.pitchTextAdaptive)
                    
                    Text(theme.description)
                        .font(Typography.bodyMedium)
                        .foregroundColor(.pitchTextSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.pitchLime)
                }
            }
            
            // Theme preview
            HStack(spacing: Spacing.xs) {
                Rectangle()
                    .fill(theme.backgroundColor)
                    .frame(height: 60)
                    .overlay(
                        VStack {
                            Rectangle()
                                .fill(theme.primaryColor)
                                .frame(height: 8)
                            Spacer()
                        }
                    )
                
                Rectangle()
                    .fill(theme.cardBackgroundColor)
                    .frame(height: 60)
                    .overlay(
                        VStack(alignment: .leading, spacing: 4) {
                            Rectangle()
                                .fill(theme.textColor)
                                .frame(width: 40, height: 4)
                            Rectangle()
                                .fill(theme.textColor.opacity(0.5))
                                .frame(width: 30, height: 3)
                        }
                        .padding(6)
                    )
                
                if let gradient = theme.gradient {
                    Rectangle()
                        .fill(gradient)
                        .frame(height: 60)
                }
            }
            .cornerRadius(8)
        }
        .padding(Spacing.base)
        .background(Color.pitchCardBackgroundAdaptive)
        .cornerRadius(Spacing.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.cardCornerRadius)
                .stroke(isSelected ? Color.pitchLime : Color.clear, lineWidth: 2)
        )
        .cardShadow()
    }
}

// MARK: - Export Options View

struct ExportOptionsView: View {
    @ObservedObject var viewModel: DeckDetailViewModel
    @ObservedObject private var subscriptionService = SubscriptionService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showUpgradeAlert = false
    @State private var selectedFormat: ExportFormat?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.pitchBackgroundAdaptive.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Header
                        VStack(spacing: Spacing.sm) {
                            Image(systemName: "square.and.arrow.up.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.pitchLime)
                            
                            Text("Export Your Deck")
                                .font(Typography.titleLarge)
                                .foregroundColor(.pitchTextAdaptive)
                            
                            Text("Choose your preferred format")
                                .font(Typography.bodyMedium)
                                .foregroundColor(.pitchTextSecondary)
                        }
                        .padding(.top, Spacing.lg)
                        
                        // Export format cards
                        VStack(spacing: Spacing.md) {
                            ForEach(ExportFormat.allCases) { format in
                                ExportFormatCard(
                                    format: format,
                                    currentTier: subscriptionService.currentTier
                                ) {
                                    handleExport(format)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(Spacing.screenMarginHorizontal)
                }
                
                // Export progress overlay
                if viewModel.isExporting {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                    
                    VStack(spacing: Spacing.lg) {
                        // Progress circle
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 8)
                                .frame(width: 100, height: 100)
                            
                            Circle()
                                .trim(from: 0, to: viewModel.exportProgress)
                                .stroke(Color.pitchLime, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .frame(width: 100, height: 100)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut, value: viewModel.exportProgress)
                            
                            Text("\(Int(viewModel.exportProgress * 100))%")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: Spacing.sm) {
                            Text(viewModel.exportStep)
                                .font(Typography.titleMedium)
                                .foregroundColor(.white)
                            
                            if let format = selectedFormat {
                                Text("Exporting as \(format.displayName)")
                                    .font(Typography.bodyMedium)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                    .padding(Spacing.xxxl)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.pitchCharcoal)
                            .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 10)
                    )
                    .padding(Spacing.xl)
                }
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(viewModel.isExporting)
                }
            }
        }
    }
    
    private func handleExport(_ format: ExportFormat) {
        // Check if user has permission
        let canExport: Bool
        switch format {
        case .pdf:
            canExport = subscriptionService.canAccessFeature(.exportPDF)
        case .powerpoint:
            canExport = subscriptionService.canAccessFeature(.exportPowerPoint)
        case .googleSlides:
            canExport = subscriptionService.canAccessFeature(.exportGoogleSlides)
        }
        
        if canExport {
            selectedFormat = format
            Task {
                await viewModel.exportDeck(as: format)
            }
        } else {
            // Show upgrade requirement
            showUpgradeAlert = true
        }
    }
}

// MARK: - Export Format Card

struct ExportFormatCard: View {
    let format: ExportFormat
    let currentTier: SubscriptionTier
    let onTap: () -> Void
    
    private var isLocked: Bool {
        currentTier.rawValue < format.requiredTier.rawValue
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.base) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isLocked ? Color.gray.opacity(0.2) : Color.pitchLime.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: format.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(isLocked ? .gray : .pitchLime)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(format.displayName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(isLocked ? .pitchTextTertiary : .pitchTextAdaptive)
                        
                        if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(.pitchTextTertiary)
                        }
                    }
                    
                    Text(format.tierRequirementMessage)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.pitchTextSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: isLocked ? "arrow.up.right.square.fill" : "chevron.right")
                    .font(.title3)
                    .foregroundColor(isLocked ? .pitchLime : .pitchTextTertiary)
            }
            .padding(Spacing.base)
            .background(Color.pitchCardBackgroundAdaptive)
            .cornerRadius(Spacing.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.cardCornerRadius)
                    .stroke(isLocked ? Color.clear : Color.pitchLime.opacity(0.2), lineWidth: 1)
            )
            .cardShadow()
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Previews

#Preview("Deck Detail") {
    NavigationStack {
        DeckDetailView(deck: .sampleInvestorDeck)
    }
}

#Preview("Theme Picker") {
    ThemePickerView(
        selectedTheme: .cleanLight,
        onThemeSelected: { _ in }
    )
}

#Preview("Export Options") {
    ExportOptionsView(
        viewModel: DeckDetailViewModel(deck: .sampleInvestorDeck)
    )
}

