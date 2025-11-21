//
//  PitchIntroView.swift
//  Pitch Me
//
//  Wizard intro screen
//

import SwiftUI

struct PitchIntroView: View {
    @ObservedObject var viewModel: WizardViewModel
    @State private var isAnimating = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xxxl) {
                Spacer()
                    .frame(height: Spacing.xxxl)
                
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.pitchLime.opacity(0.2), Color.clear],
                                center: .center,
                                startRadius: 40,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                    
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 64, weight: .medium))
                        .foregroundColor(.pitchLime)
                }
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .opacity(isAnimating ? 1.0 : 0)
                
                // Content
                VStack(spacing: Spacing.lg) {
                    Text("Pitch me your idea.\nI'll build the deck.")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.pitchTextAdaptive)
                        .multilineTextAlignment(.center)
                    
                    Text("Answer a few questions and I'll generate a professional, investor-ready pitch deck tailored to your startup.")
                        .font(Typography.bodyLarge)
                        .foregroundColor(.pitchTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                }
                .padding(.horizontal, Spacing.xxl)
                .offset(y: isAnimating ? 0 : 20)
                .opacity(isAnimating ? 1.0 : 0)
                
                // Features
                VStack(spacing: Spacing.base) {
                    FeatureRow(icon: "sparkles", title: "AI-Powered", description: "Gemini 2.0 crafts your story")
                    FeatureRow(icon: "bolt.fill", title: "Fast", description: "Generated in under 60 seconds")
                    FeatureRow(icon: "paintbrush.fill", title: "Beautiful", description: "Professional themes included")
                }
                .padding(.horizontal, Spacing.lg)
                .opacity(isAnimating ? 1.0 : 0)
                
                Spacer()
                
                // CTA
                VStack(spacing: Spacing.base) {
                    PrimaryButton("Start Pitching", icon: "arrow.right") {
                        viewModel.goToNextStep()
                    }
                    
                    Text("Takes about 3-5 minutes")
                        .font(Typography.labelSmall)
                        .foregroundColor(.pitchTextTertiary)
                }
                .padding(.horizontal, Spacing.screenMarginHorizontal)
                .padding(.bottom, Spacing.xxl)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: Spacing.base) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.pitchLime)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Typography.labelLarge)
                    .foregroundColor(.pitchTextAdaptive)
                
                Text(description)
                    .font(Typography.bodySmall)
                    .foregroundColor(.pitchTextSecondary)
            }
            
            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.pitchCardBackgroundAdaptive)
        .cornerRadius(Spacing.cardCornerRadius)
    }
}

// MARK: - Preview

#Preview {
    PitchIntroView(viewModel: WizardViewModel())
        .background(Color.pitchBackgroundAdaptive)
}

