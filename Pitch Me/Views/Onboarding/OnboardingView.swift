//
//  OnboardingView.swift
//  Pitch Me
//
//  Premium onboarding experience - Apple & ChatGPT quality
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var appState = AppState.shared
    @State private var currentPage = 0
    @State private var isAnimating = false
    let onGetStarted: (() -> Void)?
    
    init(onGetStarted: (() -> Void)? = nil) {
        self.onGetStarted = onGetStarted
    }
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "sparkles",
            title: "AI-Powered Pitch Decks",
            description: "Transform your startup idea into a professional, investor-ready pitch deck in minutes",
            accentColor: Color(red: 0.5, green: 0.5, blue: 0.55)
        ),
        OnboardingPage(
            icon: "wand.and.stars",
            title: "Smart Generation",
            description: "Answer a few questions and watch as AI crafts a compelling story tailored to your audience",
            accentColor: Color(red: 0.45, green: 0.5, blue: 0.6)
        ),
        OnboardingPage(
            icon: "paintbrush.fill",
            title: "Beautiful Themes",
            description: "Choose from stunning themes that make your deck stand out. From clean & minimal to bold & impactful",
            accentColor: Color(red: 0.55, green: 0.5, blue: 0.5)
        ),
        OnboardingPage(
            icon: "square.and.arrow.up.fill",
            title: "Export Anywhere",
            description: "Export to Google Slides, PowerPoint, or PDF. Your pitch, your way",
            accentColor: Color(red: 0.5, green: 0.55, blue: 0.5)
        )
    ]
    
    var body: some View {
        ZStack {
            // Clean dark background
            Color(red: 0.08, green: 0.08, blue: 0.09)
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
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
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
                
                // Page indicators - subtle dots
                HStack(spacing: Spacing.sm) {
                    ForEach(pages.indices, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.2))
                            .frame(width: index == currentPage ? 8 : 6, height: index == currentPage ? 8 : 6)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, Spacing.base)
                
                // Action button - professional style
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentPage += 1
                        }
                    } else {
                        withAnimation {
                            appState.completeOnboarding()
                        }
                        onGetStarted?()
                    }
                } label: {
                    HStack(spacing: 10) {
                        if currentPage >= pages.count - 1 {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        
                        Text(currentPage < pages.count - 1 ? "Continue" : "Start Pitching")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(red: 0.15, green: 0.15, blue: 0.17))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 24)
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
        VStack(spacing: 0) {
            Spacer()
            
            // Icon - clean and minimal
            ZStack {
                // Subtle background
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 120, height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                
                // Icon
                Image(systemName: page.icon)
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(.white.opacity(0.9))
            }
            .scaleEffect(isAnimating ? 1.0 : 0.9)
            .opacity(isAnimating ? 1.0 : 0.0)
            .padding(.bottom, 48)
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                
                Text(page.description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)
            }
            .padding(.horizontal, 32)
            .offset(y: isAnimating ? 0 : 20)
            .opacity(isAnimating ? 1.0 : 0.0)
            
            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
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

