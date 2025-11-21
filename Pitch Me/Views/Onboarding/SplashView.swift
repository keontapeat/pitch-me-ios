//
//  SplashView.swift
//  Pitch Me
//
//  Beautiful animated splash screen
//

import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var showGlow = false
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            Color.pitchCharcoal
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.xxxl) {
                Spacer()
                
                // Logo with animation
                ZStack {
                    // Glow effect
                    if showGlow {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.pitchLime.opacity(0.3),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 50,
                                    endRadius: 150
                                )
                            )
                            .frame(width: 300, height: 300)
                            .blur(radius: 20)
                    }
                    
                    // Speech bubble "P" (using SF Symbol as placeholder)
                    ZStack {
                        // Background bubble
                        RoundedRectangle(cornerRadius: 40)
                            .fill(Color.pitchLime)
                            .frame(width: 120, height: 120)
                            .shadow(color: Color.pitchLime.opacity(0.5), radius: 30, x: 0, y: 10)
                        
                        // "P" letter
                        Text("P")
                            .font(.system(size: 72, weight: .black, design: .rounded))
                            .foregroundColor(.pitchCharcoal)
                    }
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1.0 : 0.0)
                }
                
                // App name
                VStack(spacing: Spacing.sm) {
                    Text("Pitch Me")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(isAnimating ? 1.0 : 0.0)
                    
                    Text("AI Pitch Decks")
                        .font(Typography.titleMedium)
                        .foregroundColor(.pitchLime)
                        .opacity(isAnimating ? 1.0 : 0.0)
                }
                .offset(y: isAnimating ? 0 : 20)
                
                Spacer()
                
                // Loading indicator
                VStack(spacing: Spacing.base) {
                    ProgressView()
                        .tint(.pitchLime)
                    
                    Text("Loading your creative workspace...")
                        .font(Typography.bodyMedium)
                        .foregroundColor(.white.opacity(0.7))
                }
                .opacity(isAnimating ? 1.0 : 0.0)
                .padding(.bottom, Spacing.xxxl)
            }
        }
        .onAppear {
            // Animate logo entrance
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                isAnimating = true
            }
            
            // Show glow after slight delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showGlow = true
                }
            }
            
            // Complete splash after 2.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    onComplete()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SplashView(onComplete: {})
}

