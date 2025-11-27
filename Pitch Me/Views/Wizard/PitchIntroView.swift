//
//  PitchIntroView.swift
//  Pitch Me
//
//  Wizard intro screen - The opening experience
//

import SwiftUI

struct PitchIntroView: View {
    @ObservedObject var viewModel: WizardViewModel
    @State private var isAnimating = false
    @State private var logoScale: CGFloat = 0.8
    @State private var glowOpacity: Double = 0.3
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // 🔥 BACKGROUND - Deep dark with subtle gradient
            LinearGradient(
                colors: [
                    Color(hex: "0D0D0D"),
                    Color(hex: "141414"),
                    Color(hex: "0D0D0D")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Ambient glow behind logo
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.pitchLime.opacity(0.15),
                            Color.pitchLime.opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(y: -180)
                .blur(radius: 60)
                .opacity(glowOpacity)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.xxl) {
                    Spacer()
                        .frame(height: Spacing.xl)
                    
                    // 🔥 YOUR LOGO - HERO SECTION
                    ZStack {
                        // Outer pulse ring
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.pitchLime.opacity(0.3),
                                        Color.pitchLime.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 160, height: 160)
                            .scaleEffect(pulseScale)
                            .opacity(2 - pulseScale)
                        
                        // Glow circle
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.pitchLime.opacity(0.25),
                                        Color.pitchLime.opacity(0.08),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 30,
                                    endRadius: 90
                                )
                            )
                            .frame(width: 180, height: 180)
                            .blur(radius: 15)
                        
                        // Logo container with glass effect
                        RoundedRectangle(cornerRadius: 32)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.08),
                                        Color.white.opacity(0.02)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.pitchLime.opacity(0.5),
                                                Color.pitchLime.opacity(0.2),
                                                Color.pitchLime.opacity(0.3)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .shadow(color: Color.pitchLime.opacity(0.2), radius: 20, x: 0, y: 10)
                        
                        // YOUR LOGO
                        Image("AppLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 90, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .scaleEffect(logoScale)
                    .opacity(isAnimating ? 1.0 : 0)
                    
                    // Content
                    VStack(spacing: Spacing.lg) {
                        // Main headline with gradient
                        Text("Pitch me your idea.")
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.9)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("I'll build the deck.")
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.pitchLime, Color.pitchLime.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Answer a few questions and I'll generate a professional, investor-ready pitch deck tailored to your startup.")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.white.opacity(0.65))
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .padding(.top, Spacing.xs)
                    }
                    .padding(.horizontal, Spacing.xl)
                    .offset(y: isAnimating ? 0 : 30)
                    .opacity(isAnimating ? 1.0 : 0)
                    
                    // Features with staggered animation
                    VStack(spacing: Spacing.md) {
                        FeatureRow(
                            icon: "sparkles",
                            iconColor: Color.pitchLime,
                            title: "AI-Powered",
                            description: "Gemini 2.0 crafts your story"
                        )
                        .offset(x: isAnimating ? 0 : -50)
                        .opacity(isAnimating ? 1.0 : 0)
                        
                        FeatureRow(
                            icon: "bolt.fill",
                            iconColor: Color(hex: "FFD60A"),
                            title: "Fast",
                            description: "Generated in under 60 seconds"
                        )
                        .offset(x: isAnimating ? 0 : -50)
                        .opacity(isAnimating ? 1.0 : 0)
                        
                        FeatureRow(
                            icon: "paintbrush.fill",
                            iconColor: Color(hex: "FF6B6B"),
                            title: "Beautiful",
                            description: "Professional themes included"
                        )
                        .offset(x: isAnimating ? 0 : -50)
                        .opacity(isAnimating ? 1.0 : 0)
                    }
                    .padding(.horizontal, Spacing.lg)
                    
                    Spacer()
                        .frame(height: Spacing.lg)
                    
                    // CTA Section
                    VStack(spacing: Spacing.md) {
                        // Enhanced button
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            viewModel.goToNextStep()
                        } label: {
                            HStack(spacing: Spacing.sm) {
                                Text("Start Pitching")
                                    .font(.system(size: 18, weight: .bold))
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color.pitchLime,
                                        Color.pitchLime.opacity(0.9)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.pitchLime.opacity(0.4), radius: 20, x: 0, y: 10)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        Text("Takes about 3-5 minutes")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.horizontal, Spacing.screenMarginHorizontal)
                    .padding(.bottom, Spacing.xxxl)
                    .offset(y: isAnimating ? 0 : 40)
                    .opacity(isAnimating ? 1.0 : 0)
                }
            }
        }
        .onAppear {
            // Staggered entrance animations
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                isAnimating = true
                logoScale = 1.0
            }
            
            // Glow animation
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(0.5)) {
                glowOpacity = 0.5
            }
            
            // Pulse ring animation
            withAnimation(.easeOut(duration: 2).repeatForever(autoreverses: false).delay(0.3)) {
                pulseScale = 1.5
            }
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    init(icon: String, iconColor: Color = .pitchLime, title: String, description: String) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.description = description
    }
    
    var body: some View {
        HStack(spacing: Spacing.base) {
            // Icon with colored background
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.55))
            }
            
            Spacer()
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}


// MARK: - Preview

#Preview {
    PitchIntroView(viewModel: WizardViewModel())
}
