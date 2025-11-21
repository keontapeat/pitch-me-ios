//
//  WizardStepContainer.swift
//  Pitch Me
//
//  Reusable container for wizard steps
//

import SwiftUI

struct WizardStepContainer<Content: View>: View {
    let step: WizardStep
    @ObservedObject var viewModel: WizardViewModel
    let content: () -> Content
    
    init(
        step: WizardStep,
        viewModel: WizardViewModel,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.step = step
        self.viewModel = viewModel
        self.content = content
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                // Header
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(step.title)
                        .font(Typography.displaySmall)
                        .foregroundColor(.pitchTextAdaptive)
                    
                    Text(step.subtitle)
                        .font(Typography.bodyLarge)
                        .foregroundColor(.pitchTextSecondary)
                }
                
                // Content
                content()
                
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
                    viewModel.isLastStep ? "Review & Generate" : "Continue",
                    icon: viewModel.isLastStep ? nil : "arrow.right",
                    isDisabled: !viewModel.canGoForward
                ) {
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
    }
}

