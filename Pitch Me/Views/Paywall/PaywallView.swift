//
//  PaywallView.swift
//  Pitch Me
//
//  Premium subscription paywall
//

import SwiftUI

struct PaywallView: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: SubscriptionTier = .pro
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.pitchCharcoal, Color.pitchCharcoalWarm],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.xxxl) {
                    // Header
                    VStack(spacing: Spacing.base) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 56))
                            .foregroundColor(.pitchLime)
                        
                        Text("Upgrade to Pro")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Unlock unlimited decks, document uploads, and advanced AI")
                            .font(Typography.bodyLarge)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, Spacing.xxxl)
                    
                    // Plan cards
                    VStack(spacing: Spacing.base) {
                        PlanCard(
                            tier: .pro,
                            isSelected: selectedPlan == .pro,
                            onSelect: { selectedPlan = .pro }
                        )
                        
                        // Free tier for comparison
                        ComparisonCard(tier: .free)
                    }
                    .padding(.horizontal, Spacing.screenMarginHorizontal)
                    
                    // Features list
                    VStack(alignment: .leading, spacing: Spacing.base) {
                        Text("What's Included")
                            .font(Typography.titleMedium)
                            .foregroundColor(.white)
                        
                        ForEach(SubscriptionTier.pro.features, id: \.self) { feature in
                            PaywallFeatureRow(feature: feature)
                        }
                    }
                    .padding(.horizontal, Spacing.screenMarginHorizontal)
                    
                    // CTA
                    VStack(spacing: Spacing.base) {
                        PrimaryButton(
                            "Start Free 7-Day Trial",
                            icon: "sparkles",
                            isLoading: subscriptionService.isLoading
                        ) {
                            Task {
                                try? await subscriptionService.upgradeToPro()
                                dismiss()
                            }
                        }
                        
                        Button("Restore Purchases") {
                            Task {
                                try? await subscriptionService.restorePurchases()
                            }
                        }
                        .font(Typography.labelMedium)
                        .foregroundColor(.white.opacity(0.7))
                        
                        Text("Cancel anytime. $29/month after trial.")
                            .font(Typography.labelSmall)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.horizontal, Spacing.screenMarginHorizontal)
                    .padding(.bottom, Spacing.xxxl)
                }
            }
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(Spacing.base)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding()
                Spacer()
            }
        }
    }
}

// MARK: - Plan Card

struct PlanCard: View {
    let tier: SubscriptionTier
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: Spacing.base) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(tier.displayName)
                            .font(Typography.titleLarge)
                            .foregroundColor(.white)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(tier.monthlyPrice)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.pitchLime)
                            
                            Text("/month")
                                .font(Typography.bodyMedium)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        if let yearly = tier.yearlyPrice {
                            Text("or \(yearly)/year (save $99)")
                                .font(Typography.labelSmall)
                                .foregroundColor(.pitchLime)
                        }
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.pitchLime)
                    }
                }
                
                // Badge
                Text("🔥 Most Popular")
                    .font(Typography.labelSmall)
                    .foregroundColor(.pitchCharcoal)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, 4)
                    .background(Color.pitchLime)
                    .cornerRadius(12)
            }
            .padding(Spacing.lg)
            .background(
                isSelected ?
                LinearGradient(
                    colors: [Color.pitchLime.opacity(0.2), Color.pitchLime.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(Spacing.cardCornerRadiusLarge)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.cardCornerRadiusLarge)
                    .stroke(isSelected ? Color.pitchLime : Color.white.opacity(0.2), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Comparison Card

struct ComparisonCard: View {
    let tier: SubscriptionTier
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text(tier.displayName)
                    .font(Typography.titleMedium)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text(tier.monthlyPrice)
                    .font(Typography.titleMedium)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Text("\(tier.maxDecksPerMonth) decks/month • Basic features")
                .font(Typography.bodySmall)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(Spacing.base)
        .background(Color.white.opacity(0.05))
        .cornerRadius(Spacing.cardCornerRadius)
    }
}

// MARK: - Feature Row (Paywall)

struct PaywallFeatureRow: View {
    let feature: String
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.pitchLime)
            
            Text(feature)
                .font(Typography.bodyMedium)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    PaywallView()
}

