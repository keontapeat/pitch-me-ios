//
//  SettingsView.swift
//  Pitch Me
//
//  🔥 Professional settings and account management 🔥
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var authService = AuthService.shared
    @StateObject private var subscriptionService = SubscriptionService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showSignOutAlert = false
    @State private var showDeleteAccountAlert = false
    
    private var aiProvider: AIProvider {
        APIConfig.shared.preferredAIProvider
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Profile section
                if let user = authService.currentUser {
                    Section {
                        HStack(spacing: Spacing.base) {
                            // Avatar
                            Circle()
                                .fill(Color.pitchTextAdaptive.opacity(0.1))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text(user.initials)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.pitchTextAdaptive)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                if let displayName = user.displayName, !displayName.isEmpty {
                                    Text(displayName)
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.pitchTextAdaptive)
                                }
                                
                                Text(user.email)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.pitchTextAdaptive.opacity(0.6))
                                
                                // Subscription badge
                                subscriptionBadge(tier: user.subscriptionTier)
                            }
                        }
                        .padding(.vertical, Spacing.xs)
                    }
                }
                
                // Subscription section
                Section {
                    NavigationLink {
                        PaywallView()
                    } label: {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Subscription")
                                    .foregroundColor(.pitchTextAdaptive)
                                
                                Text(subscriptionService.currentTier.displayName)
                                    .font(.caption)
                                    .foregroundColor(.pitchTextAdaptive.opacity(0.5))
                            }
                        } icon: {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.pitchTextAdaptive.opacity(0.7))
                        }
                    }
                } header: {
                    Text("Plan")
                        .textCase(.uppercase)
                        .font(.caption)
                        .foregroundColor(.pitchTextAdaptive.opacity(0.5))
                }
                
                // 🔥 AI Provider Section
                Section {
                    HStack {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("AI Provider")
                                    .foregroundColor(.pitchTextAdaptive)
                                
                                Text(aiProvider.displayName)
                                    .font(.caption)
                                    .foregroundColor(aiProvider == .anthropic ? .pitchLime : .pitchTextAdaptive.opacity(0.5))
                            }
                        } icon: {
                            Image(systemName: aiProvider.icon)
                                .foregroundColor(aiProvider == .anthropic ? .pitchLime : .pitchTextAdaptive.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        if aiProvider == .anthropic {
                            Text("ELITE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.pitchCharcoal)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.pitchLime)
                                .cornerRadius(4)
                        }
                    }
                } header: {
                    Text("AI Engine")
                        .textCase(.uppercase)
                        .font(.caption)
                        .foregroundColor(.pitchTextAdaptive.opacity(0.5))
                }
                
                // App info
                Section {
                    HStack {
                        Text("Version")
                            .foregroundColor(.pitchTextAdaptive)
                        Spacer()
                        Text(AppConfig.fullVersion)
                            .foregroundColor(.pitchTextAdaptive.opacity(0.5))
                    }
                    
                    Link(destination: AppConfig.privacyPolicyURL) {
                        HStack {
                            Text("Privacy Policy")
                                .foregroundColor(.pitchTextAdaptive)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.pitchTextAdaptive.opacity(0.4))
                        }
                    }
                    
                    Link(destination: AppConfig.termsOfServiceURL) {
                        HStack {
                            Text("Terms of Service")
                                .foregroundColor(.pitchTextAdaptive)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.pitchTextAdaptive.opacity(0.4))
                        }
                    }
                    
                    Link(destination: AppConfig.supportURL) {
                        HStack {
                            Text("Get Support")
                                .foregroundColor(.pitchTextAdaptive)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.pitchTextAdaptive.opacity(0.4))
                        }
                    }
                } header: {
                    Text("About")
                        .textCase(.uppercase)
                        .font(.caption)
                        .foregroundColor(.pitchTextAdaptive.opacity(0.5))
                }
                
                // Account actions
                Section {
                    Button {
                        showSignOutAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.right.square")
                                .foregroundColor(.pitchTextAdaptive.opacity(0.7))
                            Text("Sign Out")
                                .foregroundColor(.pitchTextAdaptive)
                        }
                    }
                    
                    Button(role: .destructive) {
                        showDeleteAccountAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Account")
                        }
                    }
                } header: {
                    Text("Account")
                        .textCase(.uppercase)
                        .font(.caption)
                        .foregroundColor(.pitchTextAdaptive.opacity(0.5))
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.pitchBackgroundAdaptive)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.pitchTextAdaptive)
                    }
                }
            }
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    do {
                        try authService.signOut()
                        dismiss()
                    } catch {
                        print("Error signing out: \(error)")
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    // Handle account deletion
                    // TODO: Implement account deletion
                }
            } message: {
                Text("This action cannot be undone. All your decks and data will be permanently deleted.")
            }
        }
    }
    
    // MARK: - Subscription Badge
    
    private func subscriptionBadge(tier: SubscriptionTier) -> some View {
        HStack(spacing: 4) {
            if tier != .free {
                Image(systemName: "crown.fill")
                    .font(.system(size: 10))
            }
            
            Text(tier.displayName)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(tier == .free ? .pitchTextAdaptive.opacity(0.5) : .pitchTextAdaptive)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(tier == .free ? Color.pitchTextAdaptive.opacity(0.05) : Color.pitchTextAdaptive.opacity(0.1))
        )
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}

