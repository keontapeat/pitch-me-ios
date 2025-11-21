//
//  RootView.swift
//  Pitch Me
//
//  Root coordinator managing app flow
//

import SwiftUI

struct RootView: View {
    @StateObject private var appState = AppState.shared
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                // Splash screen
                SplashView {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showSplash = false
                    }
                }
                .transition(.opacity)
            } else if !appState.hasCompletedOnboarding {
                // Onboarding flow
                OnboardingView()
                    .transition(.opacity)
            } else {
                // Main app
                DeckListView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showSplash)
        .animation(.easeInOut(duration: 0.4), value: appState.hasCompletedOnboarding)
    }
}

// MARK: - Preview

#Preview("With Onboarding") {
    RootView()
        .onAppear {
            AppState.shared.resetOnboarding()
        }
}

#Preview("Skip to App") {
    RootView()
        .onAppear {
            AppState.shared.completeOnboarding()
        }
}

