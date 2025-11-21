//
//  ProblemStepView.swift
//  Pitch Me
//
//  Wizard step 2: Problem & target user
//

import SwiftUI

struct ProblemStepView: View {
    @ObservedObject var viewModel: WizardViewModel
    
    var body: some View {
        WizardStepContainer(
            step: .problem,
            viewModel: viewModel
        ) {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                TextEditorField(
                    label: "Who is your target customer?",
                    placeholder: "e.g., Small business owners managing cash flow, B2B SaaS companies...",
                    text: $viewModel.state.targetUser,
                    minHeight: 100,
                    icon: "person.2.fill"
                )
                
                TextEditorField(
                    label: "What problem are you solving?",
                    placeholder: "Describe the pain point your customers face. What keeps them up at night? How much does this problem cost them?\n\nBe specific and quantify the impact when possible.",
                    text: $viewModel.state.problem,
                    minHeight: 150,
                    icon: "exclamationmark.triangle.fill"
                )
                
                // Tip box
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.pitchLime)
                    
                    Text("Tip: Great problems are urgent, expensive, and affect many people")
                        .font(Typography.bodySmall)
                        .foregroundColor(.pitchTextSecondary)
                }
                .padding(Spacing.md)
                .background(Color.pitchLime.opacity(0.1))
                .cornerRadius(Spacing.cardCornerRadius)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ProblemStepView(viewModel: WizardViewModel())
        .background(Color.pitchBackgroundAdaptive)
}

