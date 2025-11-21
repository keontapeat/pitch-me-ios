//
//  SummaryStepView.swift
//  Pitch Me
//
//  Wizard step 7: Summary & generation
//

import SwiftUI

struct SummaryStepView: View {
    @ObservedObject var viewModel: WizardViewModel
    @State private var showThemePicker = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                // Header
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(viewModel.currentStep.title)
                        .font(Typography.displaySmall)
                        .foregroundColor(.pitchTextAdaptive)
                    
                    Text(viewModel.currentStep.subtitle)
                        .font(Typography.bodyLarge)
                        .foregroundColor(.pitchTextSecondary)
                }
                
                // Use case selector
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "target")
                            .font(.caption)
                            .foregroundColor(.pitchLime)
                        
                        Text("Deck Purpose")
                            .font(Typography.labelMedium)
                            .foregroundColor(.pitchTextSecondary)
                    }
                    
                    VStack(spacing: Spacing.sm) {
                        ForEach(DeckUseCase.allCases, id: \.self) { useCase in
                            Button {
                                viewModel.state.useCase = useCase
                            } label: {
                                HStack {
                                    Image(systemName: useCase.icon)
                                        .foregroundColor(viewModel.state.useCase == useCase ? .pitchLime : .pitchTextSecondary)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(useCase.displayName)
                                            .font(Typography.labelLarge)
                                            .foregroundColor(viewModel.state.useCase == useCase ? .pitchTextAdaptive : .pitchTextSecondary)
                                        
                                        Text(useCase.description)
                                            .font(Typography.bodySmall)
                                            .foregroundColor(.pitchTextTertiary)
                                    }
                                    
                                    Spacer()
                                    
                                    if viewModel.state.useCase == useCase {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.pitchLime)
                                    }
                                }
                                .padding(Spacing.md)
                                .background(
                                    viewModel.state.useCase == useCase ?
                                    Color.pitchLime.opacity(0.1) :
                                    Color.pitchCardBackgroundAdaptive
                                )
                                .cornerRadius(Spacing.cardCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Spacing.cardCornerRadius)
                                        .stroke(
                                            viewModel.state.useCase == useCase ? Color.pitchLime : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                // Theme selector
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "paintbrush.fill")
                            .font(.caption)
                            .foregroundColor(.pitchLime)
                        
                        Text("Deck Theme")
                            .font(Typography.labelMedium)
                            .foregroundColor(.pitchTextSecondary)
                    }
                    
                    let selectedTheme = Theme.allThemes.first(where: { $0.id == viewModel.state.preferredTheme }) ?? .default
                    
                    Button {
                        showThemePicker = true
                    } label: {
                        HStack {
                            // Theme preview
                            HStack(spacing: 4) {
                                Rectangle()
                                    .fill(selectedTheme.primaryColor)
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(selectedTheme.displayName)
                                        .font(Typography.labelLarge)
                                        .foregroundColor(.pitchTextAdaptive)
                                    
                                    Text(selectedTheme.description)
                                        .font(Typography.bodySmall)
                                        .foregroundColor(.pitchTextSecondary)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.pitchTextTertiary)
                        }
                        .padding(Spacing.md)
                        .background(Color.pitchCardBackgroundAdaptive)
                        .cornerRadius(Spacing.cardCornerRadius)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Ready indicator
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.pitchSuccess)
                    
                    Text("All set! Ready to generate your deck")
                        .font(Typography.bodyMedium)
                        .foregroundColor(.pitchTextAdaptive)
                }
                .padding(Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.pitchSuccess.opacity(0.1))
                .cornerRadius(Spacing.cardCornerRadius)
                
                Spacer()
                    .frame(height: Spacing.base)
            }
            .padding(.horizontal, Spacing.screenMarginHorizontal)
            .padding(.top, Spacing.lg)
            .padding(.bottom, 120) // Space for buttons
        }
        .safeAreaInset(edge: .bottom) {
            // Navigation buttons
            VStack(spacing: Spacing.sm) {
                PrimaryButton(
                    "Generate My Deck",
                    icon: "sparkles",
                    isLoading: viewModel.isGenerating
                ) {
                    Task {
                        await viewModel.generateDeck()
                    }
                }
                
                if viewModel.canGoBack && !viewModel.isGenerating {
                    SecondaryButton("Back", icon: "arrow.left") {
                        viewModel.goToPreviousStep()
                    }
                }
            }
            .padding(.horizontal, Spacing.screenMarginHorizontal)
            .padding(.vertical, Spacing.base)
            .background(Color.pitchBackgroundAdaptive)
        }
        .sheet(isPresented: $showThemePicker) {
            ThemePickerSheet(selectedThemeId: $viewModel.state.preferredTheme)
        }
    }
}

// MARK: - Theme Picker Sheet

struct ThemePickerSheet: View {
    @Binding var selectedThemeId: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.pitchBackgroundAdaptive.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.base) {
                        ForEach(Theme.allThemes) { theme in
                            Button {
                                selectedThemeId = theme.id
                                dismiss()
                            } label: {
                                ThemePreviewCard(
                                    theme: theme,
                                    isSelected: selectedThemeId == theme.id
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(Spacing.screenMarginHorizontal)
                }
            }
            .navigationTitle("Choose Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Theme Preview Card

struct ThemePreviewCard: View {
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

// MARK: - Preview

#Preview {
    SummaryStepView(viewModel: WizardViewModel())
        .background(Color.pitchBackgroundAdaptive)
}

