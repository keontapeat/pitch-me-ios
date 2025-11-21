//
//  StartupBasicsStepView.swift
//  Pitch Me
//
//  Wizard step 1: Startup basics
//

import SwiftUI

struct StartupBasicsStepView: View {
    @ObservedObject var viewModel: WizardViewModel
    
    var body: some View {
        WizardStepContainer(
            step: .basics,
            viewModel: viewModel
        ) {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                InputField(
                    label: "Startup Name",
                    placeholder: "e.g., Acme Inc",
                    text: $viewModel.state.startupName,
                    icon: "building.2.fill"
                )
                
                TextEditorField(
                    label: "One-line Description",
                    placeholder: "Describe your startup in one compelling sentence...",
                    text: $viewModel.state.oneLiner,
                    minHeight: 80,
                    icon: "text.quote"
                )
                
                // Stage picker
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.caption)
                            .foregroundColor(.pitchLime)
                        
                        Text("Current Stage")
                            .font(Typography.labelMedium)
                            .foregroundColor(.pitchTextSecondary)
                        
                        Text("*")
                            .font(Typography.labelMedium)
                            .foregroundColor(.pitchError)
                    }
                    
                    VStack(spacing: Spacing.sm) {
                        ForEach(StartupStage.allCases, id: \.self) { stage in
                            Button {
                                viewModel.state.stage = stage
                            } label: {
                                HStack {
                                    Image(systemName: stage.icon)
                                        .font(.title3)
                                        .foregroundColor(viewModel.state.stage == stage ? .pitchLime : .pitchTextSecondary)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(stage.rawValue)
                                            .font(Typography.labelLarge)
                                            .foregroundColor(viewModel.state.stage == stage ? .pitchTextAdaptive : .pitchTextSecondary)
                                        
                                        Text(stage.description)
                                            .font(Typography.bodySmall)
                                            .foregroundColor(.pitchTextTertiary)
                                    }
                                    
                                    Spacer()
                                    
                                    if viewModel.state.stage == stage {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.pitchLime)
                                    }
                                }
                                .padding(Spacing.md)
                                .background(
                                    viewModel.state.stage == stage ?
                                    Color.pitchLime.opacity(0.1) :
                                    Color.pitchCardBackgroundAdaptive
                                )
                                .cornerRadius(Spacing.cardCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Spacing.cardCornerRadius)
                                        .stroke(
                                            viewModel.state.stage == stage ? Color.pitchLime : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    StartupBasicsStepView(viewModel: WizardViewModel())
        .background(Color.pitchBackgroundAdaptive)
}

