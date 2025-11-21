//
//  MarketStepView.swift
//  Pitch Me
//
//  Wizard step 4: Market & business model
//

import SwiftUI

struct MarketStepView: View {
    @ObservedObject var viewModel: WizardViewModel
    
    var body: some View {
        WizardStepContainer(
            step: .market,
            viewModel: viewModel
        ) {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                TextEditorField(
                    label: "What's the market size?",
                    placeholder: "How big is the opportunity? Use TAM, SAM, SOM if you have them.\n\ne.g., $180B global fintech market, targeting $25B SMB segment",
                    text: $viewModel.state.marketSize,
                    minHeight: 100,
                    icon: "chart.bar.fill"
                )
                
                TextEditorField(
                    label: "How do you make money?",
                    placeholder: "Describe your business model and revenue streams.\n\ne.g., SaaS subscription at $99/month per user, 20% annual growth",
                    text: $viewModel.state.businessModel,
                    minHeight: 120,
                    icon: "dollarsign.circle.fill"
                )
                
                TextEditorField(
                    label: "What's your pricing strategy?",
                    placeholder: "How do you price your product? Different tiers?\n\ne.g., Freemium model, Pro at $49/mo, Enterprise custom pricing",
                    text: $viewModel.state.pricing,
                    isRequired: false,
                    minHeight: 80,
                    icon: "tag.fill"
                )
                
                // Tip box
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.pitchLime)
                    
                    Text("Tip: Show you understand the economics of your business")
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
    MarketStepView(viewModel: WizardViewModel())
        .background(Color.pitchBackgroundAdaptive)
}

