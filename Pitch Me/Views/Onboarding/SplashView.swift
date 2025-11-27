//
//  SplashView.swift
//  Pitch Me
//
//  Professional animated splash screen with official logo
//

import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var glowOpacity: Double = 0
    @State private var glowScale: CGFloat = 0.8
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 30
    @State private var pulseAnimation = false
    @State private var shimmerOffset: CGFloat = -200
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // MARK: - Background
            backgroundGradient
            
            VStack(spacing: 0) {
                Spacer()
                
                // MARK: - Logo Section
                logoSection
                
                Spacer()
                    .frame(height: Spacing.xxxl)
                
                // MARK: - Text Section
                textSection
                
                Spacer()
                
                // MARK: - Loading Section
                loadingSection
                    .padding(.bottom, Spacing.xxxl * 1.5)
            }
        }
        .onAppear {
            startAnimationSequence()
        }
    }
    
    // MARK: - Background Gradient
    
    private var backgroundGradient: some View {
        ZStack {
            // Base color
            Color.pitchCharcoal
                .ignoresSafeArea()
            
            // Subtle radial gradient for depth
            RadialGradient(
                colors: [
                    Color.pitchCharcoal.opacity(0.9),
                    Color.black
                ],
                center: .center,
                startRadius: 100,
                endRadius: 500
            )
            .ignoresSafeArea()
            
            // Top ambient glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.pitchLime.opacity(0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 300
                    )
                )
                .frame(width: 600, height: 600)
                .offset(y: -200)
                .blur(radius: 60)
        }
    }
    
    // MARK: - Logo Section
    
    private var logoSection: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.pitchLime.opacity(0.4),
                            Color.pitchLime.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 60,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .scaleEffect(glowScale)
                .opacity(glowOpacity)
                .blur(radius: 30)
            
            // Inner glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.pitchLime.opacity(0.6),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 40,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .opacity(glowOpacity)
                .blur(radius: 20)
            
            // Shadow under logo
            RoundedRectangle(cornerRadius: 50)
                .fill(Color.black.opacity(0.3))
                .frame(width: 180, height: 180)
                .blur(radius: 30)
                .offset(y: 20)
                .opacity(logoOpacity)
            
            // Official Logo
            Image("SplashLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 40))
                .shadow(color: Color.pitchLime.opacity(0.5), radius: 40, x: 0, y: 10)
                .shadow(color: Color.pitchLime.opacity(0.3), radius: 20, x: 0, y: 5)
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                .scaleEffect(pulseAnimation ? 1.02 : 1.0)
                .animation(
                    pulseAnimation ? .easeInOut(duration: 1.5).repeatForever(autoreverses: true) : .default,
                    value: pulseAnimation
                )
            
            // Shimmer overlay
            RoundedRectangle(cornerRadius: 40)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.2),
                            Color.white.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 180, height: 180)
                .offset(x: shimmerOffset)
                .mask(
                    RoundedRectangle(cornerRadius: 40)
                        .frame(width: 180, height: 180)
                )
                .opacity(logoOpacity)
        }
    }
    
    // MARK: - Text Section
    
    private var textSection: some View {
        VStack(spacing: Spacing.sm) {
            // App Name
            Text("Pitch Me")
                .font(.system(size: 44, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.9)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
            
            // Tagline
            Text("AI Pitch Decks")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .tracking(2)
        }
        .opacity(textOpacity)
        .offset(y: textOffset)
    }
    
    // MARK: - Loading Section
    
    private var loadingSection: some View {
        VStack(spacing: Spacing.base) {
            // Custom loading indicator
            LoadingDotsView()
            
            Text("Loading your creative workspace...")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
        }
        .opacity(textOpacity)
    }
    
    // MARK: - Animation Sequence
    
    private func startAnimationSequence() {
        // Phase 1: Logo entrance (0ms)
        withAnimation(.spring(response: 0.8, dampingFraction: 0.65)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Phase 2: Glow appears (200ms)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.6)) {
                glowOpacity = 1.0
                glowScale = 1.0
            }
        }
        
        // Phase 3: Text appears (400ms)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                textOpacity = 1.0
                textOffset = 0
            }
        }
        
        // Phase 4: Shimmer effect (600ms)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.8)) {
                shimmerOffset = 200
            }
        }
        
        // Phase 5: Start pulse animation (1000ms)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            pulseAnimation = true
        }
        
        // Phase 6: Complete splash (2.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                onComplete()
            }
        }
    }
}

// MARK: - Loading Dots View

struct LoadingDotsView: View {
    @State private var animatingDots = [false, false, false]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.pitchLime)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animatingDots[index] ? 1.0 : 0.5)
                    .opacity(animatingDots[index] ? 1.0 : 0.3)
            }
        }
        .onAppear {
            // Staggered animation for each dot
            for index in 0..<3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15) {
                    withAnimation(
                        .easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true)
                    ) {
                        animatingDots[index] = true
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SplashView(onComplete: {})
}
