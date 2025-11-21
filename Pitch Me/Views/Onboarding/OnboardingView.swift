//
//  OnboardingView.swift
//  Pitch Me
//
//  Premium onboarding experience
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var appState = AppState.shared
    @State private var currentPage = 0
    @State private var isAnimating = false
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "sparkles",
            title: "AI-Powered Pitch Decks",
            description: "Transform your startup idea into a professional, investor-ready pitch deck in minutes",
            accentColor: .pitchLime
        ),
        OnboardingPage(
            icon: "wand.and.stars",
            title: "Smart Generation",
            description: "Answer a few questions and watch as AI crafts a compelling story tailored to your audience",
            accentColor: Color(red: 0.4, green: 0.2, blue: 0.9)
        ),
        OnboardingPage(
            icon: "paintbrush.fill",
            title: "Beautiful Themes",
            description: "Choose from stunning themes that make your deck stand out. From clean & minimal to bold & impactful",
            accentColor: Color(red: 0.9, green: 0.3, blue: 0.5)
        ),
        OnboardingPage(
            icon: "square.and.arrow.up.fill",
            title: "Export Anywhere",
            description: "Export to Google Slides, PowerPoint, or PDF. Your pitch, your way",
            accentColor: .pitchLime
        )
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.pitchCharcoal,
                    Color.pitchCharcoalWarm
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button {
                        withAnimation {
                            appState.completeOnboarding()
                        }
                    } label: {
                        Text("Skip")
                            .font(Typography.labelLarge)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, Spacing.lg)
                            .padding(.vertical, Spacing.sm)
                    }
                }
                .padding(.top, Spacing.lg)
                .padding(.horizontal, Spacing.base)
                .opacity(currentPage < pages.count - 1 ? 1.0 : 0.0)
                
                // Pages
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Page indicators
                HStack(spacing: Spacing.sm) {
                    ForEach(pages.indices, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.pitchLime : Color.white.opacity(0.3))
                            .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, Spacing.base)
                
                // Action button
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentPage += 1
                        }
                    } else {
                        withAnimation {
                            appState.completeOnboarding()
                        }
                    }
                } label: {
                    HStack(spacing: Spacing.sm) {
                        Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                            .font(Typography.labelLarge)
                            .fontWeight(.bold)
                        
                        if currentPage < pages.count - 1 {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        } else {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .foregroundColor(.pitchCharcoal)
                    .frame(maxWidth: .infinity)
                    .frame(height: Spacing.buttonHeight)
                    .background(Color.pitchLime)
                    .cornerRadius(Spacing.buttonCornerRadius)
                    .shadow(color: Color.pitchLime.opacity(0.3), radius: 20, x: 0, y: 10)
                }
                .padding(.horizontal, Spacing.screenMarginHorizontal)
                .padding(.bottom, Spacing.xxxl)
            }
        }
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let accentColor: Color
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: Spacing.xxxl) {
            Spacer()
            
            // Icon with glow effect
            ZStack {
                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                page.accentColor.opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 50,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .blur(radius: 20)
                    .opacity(isAnimating ? 1.0 : 0.0)
                
                // Icon background
                Circle()
                    .fill(page.accentColor.opacity(0.2))
                    .frame(width: 140, height: 140)
                
                // Icon
                Image(systemName: page.icon)
                    .font(.system(size: 64, weight: .medium))
                    .foregroundColor(page.accentColor)
            }
            .scaleEffect(isAnimating ? 1.0 : 0.8)
            .opacity(isAnimating ? 1.0 : 0.0)
            
            // Content
            VStack(spacing: Spacing.lg) {
                Text(page.title)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                
                Text(page.description)
                    .font(Typography.bodyLarge)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }
            .padding(.horizontal, Spacing.xxxl)
            .offset(y: isAnimating ? 0 : 30)
            .opacity(isAnimating ? 1.0 : 0.0)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                isAnimating = true
            }
        }
        .onDisappear {
            isAnimating = false
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
}

