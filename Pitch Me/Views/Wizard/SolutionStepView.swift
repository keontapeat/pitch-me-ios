//
//  SolutionStepView.swift
//  Pitch Me
//
//  Wizard step 3: Solution
//

import SwiftUI

struct SolutionStepView: View {
    @ObservedObject var viewModel: WizardViewModel
    
    var body: some View {
        WizardStepContainer(
            step: .solution,
            viewModel: viewModel
        ) {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                TextEditorField(
                    label: "How do you solve this problem?",
                    placeholder: "Describe your product or service. What makes it different? What's your unique insight?\n\nFocus on the 'aha moment' - what makes your solution special?",
                    text: $viewModel.state.solution,
                    minHeight: 150,
                    icon: "lightbulb.fill"
                )
                
                TextEditorField(
                    label: "Why now? Why is this the right time?",
                    placeholder: "What recent changes make your solution possible or necessary?\n\nNew technology? Market shift? Regulatory change?",
                    text: $viewModel.state.whyNow,
                    minHeight: 100,
                    icon: "clock.fill"
                )
                
                TextEditorField(
                    label: "What's your unique value proposition?",
                    placeholder: "What do customers get from you that they can't get anywhere else?",
                    text: $viewModel.state.uniqueValue,
                    isRequired: false,
                    minHeight: 80,
                    icon: "star.fill"
                )
                
                // Tip box
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.pitchLime)
                    
                    Text("Tip: Show, don't tell. Use concrete examples and demos")
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
    SolutionStepView(viewModel: WizardViewModel())
        .background(Color.pitchBackgroundAdaptive)
}

