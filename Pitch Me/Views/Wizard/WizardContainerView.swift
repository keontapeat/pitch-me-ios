//
//  WizardContainerView.swift
//  Pitch Me
//
//  Main wizard container with navigation
//

import SwiftUI

struct WizardContainerView: View {
    @StateObject private var viewModel = WizardViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showExitConfirmation = false
    
    var body: some View {
        ZStack {
            Color.pitchBackgroundAdaptive.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar
                if viewModel.currentStep != .intro {
                    VStack(spacing: Spacing.sm) {
                        // Progress indicator
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background
                                Rectangle()
                                    .fill(Color.pitchDivider.opacity(0.3))
                                    .frame(height: 4)
                                
                                // Progress
                                Rectangle()
                                    .fill(Color.pitchLime)
                                    .frame(width: geometry.size.width * viewModel.progress, height: 4)
                                    .animation(.spring(response: 0.4), value: viewModel.progress)
                            }
                        }
                        .frame(height: 4)
                        
                        // Step indicator
                        HStack {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: viewModel.currentStep.icon)
                                    .font(.caption)
                                Text("Step \(viewModel.currentStep.rawValue) of \(viewModel.totalSteps - 1)")
                                    .font(Typography.labelSmall)
                            }
                            .foregroundColor(.pitchTextSecondary)
                            
                            Spacer()
                            
                            Button {
                                showExitConfirmation = true
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.caption)
                                    .foregroundColor(.pitchTextSecondary)
                                    .padding(8)
                            }
                        }
                        .padding(.horizontal, Spacing.screenMarginHorizontal)
                    }
                    .padding(.top, Spacing.sm)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Step content
                Group {
                    switch viewModel.currentStep {
                    case .intro:
                        PitchIntroView(viewModel: viewModel)
                    case .basics:
                        // Check if user wants to upload documents
                        DocumentUploadStepView(viewModel: viewModel)
                    case .problem:
                        ProblemStepView(viewModel: viewModel)
                    case .solution:
                        SolutionStepView(viewModel: viewModel)
                    case .market:
                        MarketStepView(viewModel: viewModel)
                    case .traction:
                        TractionStepView(viewModel: viewModel)
                    case .team:
                        TeamStepView(viewModel: viewModel)
                    case .summary:
                        SummaryStepView(viewModel: viewModel)
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
            
            // Generation loading overlay
            if viewModel.isGenerating {
                generationLoadingView
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.currentStep)
        .confirmationDialog(
            "Exit Wizard?",
            isPresented: $showExitConfirmation,
            titleVisibility: .visible
        ) {
            Button("Exit and Discard", role: .destructive) {
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your progress will be lost if you exit now.")
        }
        .fullScreenCover(item: $viewModel.generatedDeck) { deck in
            DeckPreviewContainer(initialDeck: deck, onSaveAndExit: {
                // Dismiss wizard
                dismiss()
            })
        }
        .onAppear {
            // Load subscription status
            SubscriptionService.shared.loadSubscriptionTier()
        }
    }
    
    // MARK: - Generation Loading View
    
    private var generationLoadingView: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.xl) {
                // Animated icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.pitchLime.opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 30,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                    
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 56))
                        .foregroundColor(.pitchLime)
                        .symbolEffect(.pulse)
                }
                
                VStack(spacing: Spacing.sm) {
                    Text("Generating your deck...")
                        .font(Typography.titleLarge)
                        .foregroundColor(.white)
                    
                    Text(loadingMessage)
                        .font(Typography.bodyMedium)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                // Progress bar
                VStack(spacing: Spacing.sm) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 4)
                            
                            Rectangle()
                                .fill(Color.pitchLime)
                                .frame(width: geometry.size.width * viewModel.generationProgress, height: 4)
                                .animation(.easeInOut, value: viewModel.generationProgress)
                        }
                    }
                    .frame(height: 4)
                    .cornerRadius(2)
                    
                    Text("\(Int(viewModel.generationProgress * 100))% complete")
                        .font(Typography.labelSmall)
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: 200)
            }
            .padding(Spacing.xxxl)
        }
    }
    
    private var loadingMessage: String {
        let progress = viewModel.generationProgress
        switch progress {
        case 0..<0.2:
            return "Analyzing your startup..."
        case 0.2..<0.4:
            return "Crafting your story..."
        case 0.4..<0.6:
            return "Generating slides..."
        case 0.6..<0.8:
            return "Applying theme..."
        default:
            return "Finalizing your deck..."
        }
    }
}

// MARK: - Deck Preview Container

/// Container that manages deck state and ensures proper saving
struct DeckPreviewContainer: View {
    let initialDeck: Deck
    let onSaveAndExit: () -> Void
    
    @StateObject private var viewModel: DeckDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(initialDeck: Deck, onSaveAndExit: @escaping () -> Void) {
        self.initialDeck = initialDeck
        self.onSaveAndExit = onSaveAndExit
        _viewModel = StateObject(wrappedValue: DeckDetailViewModel(deck: initialDeck))
    }
    
    var body: some View {
        NavigationStack {
            DeckDetailViewContent(viewModel: viewModel)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Save & Exit") {
                            saveAndExit()
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.pitchLime)
                    }
                    
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
                .navigationTitle(viewModel.deck.title)
                .navigationBarTitleDisplayMode(.inline)
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
    
    private func saveAndExit() {
        // 🔥 Save the EDITED deck from viewModel, not the initial deck!
        let editedDeck = viewModel.deck
        
        print("💾 Saving deck: \(editedDeck.title) with \(editedDeck.slides.count) slides")
        
        // Save to deck list
        DeckListViewModel.shared.addDeck(editedDeck)
        
        // Increment deck count for subscription tracking
        SubscriptionService.shared.incrementDeckCount()
        
        // Dismiss the full screen cover first
        dismiss()
        
        // Then trigger the wizard dismissal
        onSaveAndExit()
    }
}

// MARK: - Preview

#Preview {
    WizardContainerView()
}

