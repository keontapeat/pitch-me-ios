//
//  PaywallView.swift
//  Pitch Me
//
//  Premium subscription paywall
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    @StateObject private var storeKit = StoreKitService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: SubscriptionTier = .pro
    @State private var isYearly: Bool = false
    @State private var purchaseError: String?
    @State private var showError = false
    
    var body: some View {
        ZStack {
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
                        
                        Text("Choose Your Plan")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Start creating unlimited decks today")
                            .font(Typography.bodyLarge)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, Spacing.xxxl)
                    
                    // Billing toggle
                    BillingToggle(isYearly: $isYearly)
                        .padding(.horizontal, Spacing.screenMarginHorizontal)
                    
                    // Plan cards
                    VStack(spacing: Spacing.base) {
                        PlanCard(
                            tier: .pro,
                            isSelected: selectedPlan == .pro,
                            isYearly: isYearly,
                            monthlyPrice: storeKit.displayPrice(for: .proMonthly),
                            yearlyPrice: storeKit.displayPrice(for: .proYearly),
                            onSelect: { selectedPlan = .pro },
                            badge: "🔥 Most Popular"
                        )
                        
                        PlanCard(
                            tier: .proPlus,
                            isSelected: selectedPlan == .proPlus,
                            isYearly: isYearly,
                            monthlyPrice: storeKit.displayPrice(for: .proPlusMonthly),
                            yearlyPrice: storeKit.displayPrice(for: .proPlusYearly),
                            onSelect: { selectedPlan = .proPlus },
                            badge: "🚀 Power Users"
                        )
                    }
                    .padding(.horizontal, Spacing.screenMarginHorizontal)
                    
                    // Features list
                    VStack(alignment: .leading, spacing: Spacing.base) {
                        Text("What's Included")
                            .font(Typography.titleMedium)
                            .foregroundColor(.white)
                        
                        ForEach(selectedPlan.features, id: \.self) { feature in
                            PaywallFeatureRow(feature: feature)
                        }
                    }
                    .padding(.horizontal, Spacing.screenMarginHorizontal)
                    
                    // CTA
                    VStack(spacing: Spacing.base) {
                        PrimaryButton(
                            "Start Free 7-Day Trial",
                            icon: "sparkles",
                            isLoading: subscriptionService.isLoading || storeKit.isLoading
                        ) {
                            Task {
                                await handlePurchase()
                            }
                        }
                        
                        Button("Restore Purchases") {
                            Task {
                                do {
                                    try await subscriptionService.restorePurchases()
                                    dismiss()
                                } catch {
                                    purchaseError = error.localizedDescription
                                    showError = true
                                }
                            }
                        }
                        .font(Typography.labelMedium)
                        .foregroundColor(.white.opacity(0.7))
                        
                        Text("Cancel anytime. Auto-renews at \(priceAfterTrial).")
                            .font(Typography.labelSmall)
                            .foregroundColor(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                        
                        // Required legal links for App Store
                        HStack(spacing: Spacing.lg) {
                            Link("Terms of Use", destination: AppConfig.termsOfServiceURL)
                            Text("•").foregroundColor(.white.opacity(0.4))
                            Link("Privacy Policy", destination: AppConfig.privacyPolicyURL)
                        }
                        .font(Typography.labelSmall)
                        .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.horizontal, Spacing.screenMarginHorizontal)
                    .padding(.bottom, Spacing.xxxl)
                }
            }
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
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
        .alert("Purchase Failed", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(purchaseError ?? "An unknown error occurred. Please try again.")
        }
        .onAppear {
            if storeKit.products.isEmpty {
                Task { await storeKit.loadProducts() }
            }
        }
    }
    
    // MARK: - Helpers
    
    private var priceAfterTrial: String {
        switch selectedPlan {
        case .pro:     return isYearly ? storeKit.displayPrice(for: .proYearly) + "/yr" : storeKit.displayPrice(for: .proMonthly) + "/mo"
        case .proPlus: return isYearly ? storeKit.displayPrice(for: .proPlusYearly) + "/yr" : storeKit.displayPrice(for: .proPlusMonthly) + "/mo"
        default:       return ""
        }
    }
    
    private func handlePurchase() async {
        do {
            if selectedPlan == .pro {
                try await subscriptionService.upgradeToPro(yearly: isYearly)
            } else if selectedPlan == .proPlus {
                try await subscriptionService.upgradeToProPlus(yearly: isYearly)
            }
            // Only dismiss on confirmed purchase (not user cancel)
            if subscriptionService.currentTier != .free {
                dismiss()
            }
        } catch {
            purchaseError = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - Billing Toggle

struct BillingToggle: View {
    @Binding var isYearly: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            toggleOption(title: "Monthly", selected: !isYearly) {
                withAnimation(.spring(response: 0.3)) { isYearly = false }
            }
            toggleOption(title: "Yearly", badge: "Save 34%", selected: isYearly) {
                withAnimation(.spring(response: 0.3)) { isYearly = true }
            }
        }
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func toggleOption(title: String, badge: String? = nil, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(Typography.labelMedium)
                    .foregroundColor(selected ? .pitchCharcoal : .white.opacity(0.6))
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(selected ? .pitchCharcoal : .pitchLime)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(selected ? Color.pitchCharcoal.opacity(0.15) : Color.pitchLime.opacity(0.2))
                        .cornerRadius(6)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
            .background(selected ? Color.pitchLime : Color.clear)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Plan Card

struct PlanCard: View {
    let tier: SubscriptionTier
    let isSelected: Bool
    let isYearly: Bool
    let monthlyPrice: String
    let yearlyPrice: String
    let onSelect: () -> Void
    let badge: String?
    
    init(
        tier: SubscriptionTier,
        isSelected: Bool,
        isYearly: Bool = false,
        monthlyPrice: String,
        yearlyPrice: String,
        onSelect: @escaping () -> Void,
        badge: String? = nil
    ) {
        self.tier = tier
        self.isSelected = isSelected
        self.isYearly = isYearly
        self.monthlyPrice = monthlyPrice
        self.yearlyPrice = yearlyPrice
        self.onSelect = onSelect
        self.badge = badge
    }
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: Spacing.base) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(tier.displayName)
                            .font(Typography.titleLarge)
                            .foregroundColor(.white)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(isYearly ? yearlyPrice : monthlyPrice)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.pitchLime)
                            
                            Text(isYearly ? "/year" : "/month")
                                .font(Typography.bodyMedium)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        if isYearly {
                            Text("Billed annually — best value")
                                .font(Typography.labelSmall)
                                .foregroundColor(.pitchLime)
                        } else {
                            Text("or \(yearlyPrice)/year — save 34%")
                                .font(Typography.labelSmall)
                                .foregroundColor(.pitchLime.opacity(0.8))
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
                if let badge = badge {
                    Text(badge)
                        .font(Typography.labelSmall)
                        .foregroundColor(.pitchCharcoal)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, 4)
                        .background(Color.pitchLime)
                        .cornerRadius(12)
                }
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
            
            Text("1 deck total • Basic features")
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

