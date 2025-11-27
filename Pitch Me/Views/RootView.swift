//
//  RootView.swift
//  Pitch Me
//
//  Root coordinator managing app flow
//

import SwiftUI

struct RootView: View {
    @StateObject private var appState = AppState.shared
    @StateObject private var authService = AuthService.shared
    @State private var showSplash = true
    @State private var showLogin = false
    
    var body: some View {
        ZStack {
            if showSplash {
                // Video splash screen
                VideoSplashView {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showSplash = false
                    }
                }
                .transition(.opacity)
            } else if !appState.hasCompletedOnboarding {
                // Onboarding flow
                OnboardingView(onGetStarted: {
                    showLogin = true
                })
                .transition(.opacity)
            } else if !authService.isAuthenticated {
                // Auth required - show login
                LoginView()
                    .transition(.opacity)
            } else {
                // Main app - authenticated
                DeckListView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showSplash)
        .animation(.easeInOut(duration: 0.4), value: appState.hasCompletedOnboarding)
        .animation(.easeInOut(duration: 0.4), value: authService.isAuthenticated)
        .fullScreenCover(isPresented: $showLogin) {
            LoginView()
        }
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

