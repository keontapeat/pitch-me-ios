//
//  VideoSplashView.swift
//  Pitch Me
//
//  Clean logo splash screen with your brand
//

import SwiftUI

// MARK: - Logo Splash View

struct VideoSplashView: View {
    let onComplete: () -> Void
    
    @State private var isAnimating = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Dark background
            Color(red: 0.11, green: 0.12, blue: 0.13)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Your Logo
                ZStack {
                    // Subtle glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.75, green: 1.0, blue: 0.0).opacity(0.15),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 40,
                                endRadius: 140
                            )
                        )
                        .frame(width: 280, height: 280)
                        .blur(radius: 30)
                        .opacity(isAnimating ? 1.0 : 0.0)
                    
                    // Logo container
                    RoundedRectangle(cornerRadius: 42)
                        .fill(Color(red: 0.75, green: 1.0, blue: 0.0))
                        .frame(width: 160, height: 160)
                        .shadow(color: Color(red: 0.75, green: 1.0, blue: 0.0).opacity(0.3), radius: 30, x: 0, y: 10)
                    
                    // "P" letter (speech bubble style)
                    VStack(spacing: 0) {
                        // Top of P
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.11, green: 0.12, blue: 0.13))
                            .frame(width: 70, height: 50)
                        
                        // Stem of P
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.11, green: 0.12, blue: 0.13))
                            .frame(width: 20, height: 40)
                            .offset(x: -25, y: -10)
                    }
                    .offset(y: -5)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                // App name
                VStack(spacing: 12) {
                    Text("Pitch Me")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("AI Pitch Decks")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(1)
                }
                .opacity(logoOpacity)
                
                Spacer()
            }
        }
        .onAppear {
            // Logo bounce animation
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                logoScale = 1.0
                logoOpacity = 1.0
                isAnimating = true
            }
            
            // Auto-complete after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.3)) {
                    logoOpacity = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onComplete()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VideoSplashView(onComplete: {
        print("Splash completed")
    })
}


