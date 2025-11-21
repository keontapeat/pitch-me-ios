//
//  TeamStepView.swift
//  Pitch Me
//
//  Wizard step 6: Team
//

import SwiftUI

struct TeamStepView: View {
    @ObservedObject var viewModel: WizardViewModel
    
    var body: some View {
        WizardStepContainer(
            step: .team,
            viewModel: viewModel
        ) {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                TextEditorField(
                    label: "Who's on the team?",
                    placeholder: "List your founders and key team members.\n\nInclude:\n• Names & roles\n• Relevant experience\n• Why you're the right team\n\ne.g., Jane Doe - CEO (ex-Stripe, Stanford CS, built 2 successful startups)",
                    text: $viewModel.state.team,
                    minHeight: 150,
                    icon: "person.3.fill"
                )
                
                TextEditorField(
                    label: "Advisors & Investors (optional)",
                    placeholder: "Notable advisors, angels, or early investors?\n\ne.g., John Smith (ex-Google VP), Seed round led by XYZ Ventures",
                    text: $viewModel.state.advisors,
                    isRequired: false,
                    minHeight: 100,
                    icon: "star.fill"
                )
                
                // Tip box
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.pitchLime)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Why this matters")
                            .font(Typography.labelMedium)
                            .foregroundColor(.pitchTextAdaptive)
                        
                        Text("Investors bet on teams as much as ideas. Show why YOU can execute")
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
    TeamStepView(viewModel: WizardViewModel())
        .background(Color.pitchBackgroundAdaptive)
}

