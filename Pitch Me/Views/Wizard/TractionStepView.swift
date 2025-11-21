//
//  TractionStepView.swift
//  Pitch Me
//
//  Wizard step 5: Traction & metrics
//

import SwiftUI

struct TractionStepView: View {
    @ObservedObject var viewModel: WizardViewModel
    
    var body: some View {
        WizardStepContainer(
            step: .traction,
            viewModel: viewModel
        ) {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                TextEditorField(
                    label: "What's your traction?",
                    placeholder: "Share your key metrics and achievements.\n\nUsers, revenue, growth rate, partnerships, pilots, LOIs, waitlist...\n\nBe specific with numbers!",
                    text: $viewModel.state.traction,
                    minHeight: 150,
                    icon: "arrow.up.right.circle.fill"
                )
                
                TextEditorField(
                    label: "Key metrics (optional)",
                    placeholder: "Important KPIs you track:\n\n• ARR/MRR\n• Customer acquisition cost (CAC)\n• Lifetime value (LTV)\n• Churn rate\n• Growth rate",
                    text: $viewModel.state.keyMetrics,
                    isRequired: false,
                    minHeight: 120,
                    icon: "chart.xyaxis.line"
                )
                
                // Tip box
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.pitchLime)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("No traction yet?")
                            .font(Typography.labelMedium)
                            .foregroundColor(.pitchTextAdaptive)
                        
                        Text("Share your vision, early customer conversations, or prototype feedback")
                            .font(Typography.bodySmall)
                            .foregroundColor(.pitchTextSecondary)
                    }
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
    TractionStepView(viewModel: WizardViewModel())
        .background(Color.pitchBackgroundAdaptive)
}

