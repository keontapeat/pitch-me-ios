//
//  PitchScoreView.swift
//  Pitch Me
//
//  YC-ready pitch scoring UI — Pro Plus gated
//

import SwiftUI

// MARK: - Pitch Score View

struct PitchScoreView: View {
    let deck: Deck
    @StateObject private var coach = ElitePitchCoach.shared
    @StateObject private var subscriptionService = SubscriptionService.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var score: PitchScore?
    @State private var errorMessage: String?
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pitchBackgroundAdaptive.ignoresSafeArea()

                Group {
                    if !subscriptionService.currentTier.hasAIFeedback {
                        lockedView
                    } else if coach.isAnalyzing {
                        analyzingView
                    } else if let score = score {
                        scoreResultView(score)
                    } else {
                        readyToAnalyzeView
                    }
                }

                if let error = errorMessage {
                    VStack {
                        Spacer()
                        Text(error)
                            .font(Typography.bodyMedium)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.pitchError.cornerRadius(12))
                            .padding(.horizontal, Spacing.xl)
                            .padding(.bottom, Spacing.xxl)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("AI Pitch Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.pitchTextAdaptive)
                }
            }
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    // MARK: - Locked (Free / Pro users)

    private var lockedView: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.pitchLime.opacity(0.12))
                    .frame(width: 120, height: 120)
                Image(systemName: "lock.fill")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundColor(.pitchLime)
            }

            VStack(spacing: Spacing.sm) {
                Text("AI Pitch Scoring")
                    .font(Typography.displaySmall)
                    .foregroundColor(.pitchTextAdaptive)

                Text("Get brutally honest, YC-caliber feedback on every slide.\nUnlock with Pro Plus.")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.pitchTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }

            VStack(spacing: Spacing.md) {
                featurePill("Overall pitch score 0–100")
                featurePill("Category breakdown (story, market, team...)")
                featurePill("Slide-by-slide recommendations")
                featurePill("YC / NVIDIA / investor readiness rating")
            }
            .padding(.horizontal, Spacing.xl)

            Button {
                showPaywall = true
            } label: {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "crown.fill")
                    Text("Upgrade to Pro Plus")
                        .font(Typography.labelLarge)
                }
                .foregroundColor(.pitchCharcoal)
                .frame(maxWidth: .infinity)
                .frame(height: Spacing.buttonHeight)
                .background(Color.pitchLime)
                .cornerRadius(Spacing.buttonCornerRadius)
            }
            .padding(.horizontal, Spacing.xl)

            Spacer()
        }
    }

    // MARK: - Ready To Analyze

    private var readyToAnalyzeView: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.pitchLime.opacity(0.12))
                    .frame(width: 120, height: 120)
                Image(systemName: "waveform.badge.magnifyingglass")
                    .font(.system(size: 44, weight: .light))
                    .foregroundColor(.pitchLime)
            }

            VStack(spacing: Spacing.sm) {
                Text("Score Your Pitch")
                    .font(Typography.displaySmall)
                    .foregroundColor(.pitchTextAdaptive)

                Text("Claude Opus will analyze \(deck.slides.count) slides using the same criteria YC partners use.")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.pitchTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }

            Button {
                Task { await analyzeScore() }
            } label: {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "sparkles")
                    Text("Analyze My Pitch")
                        .font(Typography.labelLarge)
                }
                .foregroundColor(.pitchCharcoal)
                .frame(maxWidth: .infinity)
                .frame(height: Spacing.buttonHeight)
                .background(Color.pitchLime)
                .cornerRadius(Spacing.buttonCornerRadius)
            }
            .padding(.horizontal, Spacing.xl)

            Spacer()
        }
    }

    // MARK: - Analyzing

    private var analyzingView: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.pitchLime.opacity(0.2), lineWidth: 8)
                    .frame(width: 100, height: 100)
                Circle()
                    .trim(from: 0, to: coach.progress)
                    .stroke(Color.pitchLime, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.4), value: coach.progress)
                Text("\(Int(coach.progress * 100))%")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.pitchTextAdaptive)
            }

            VStack(spacing: Spacing.xs) {
                Text("Analyzing your pitch...")
                    .font(Typography.titleMedium)
                    .foregroundColor(.pitchTextAdaptive)
                Text(coach.currentStep)
                    .font(Typography.bodyMedium)
                    .foregroundColor(.pitchTextSecondary)
                    .animation(.easeInOut, value: coach.currentStep)
            }

            Spacer()
        }
    }

    // MARK: - Score Results

    private func scoreResultView(_ score: PitchScore) -> some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {

                // Overall score hero
                overallScoreHero(score)
                    .padding(.top, Spacing.lg)

                // Investor readiness badge
                readinessBadge(score.investorReadiness)

                // Category scores
                if !score.categoryScores.isEmpty {
                    categoryBreakdown(score.categoryScores)
                }

                // Strengths
                if !score.strengths.isEmpty {
                    feedbackSection(
                        title: "What's Working",
                        icon: "checkmark.circle.fill",
                        iconColor: .pitchSuccess,
                        items: score.strengths
                    )
                }

                // Weaknesses
                if !score.weaknesses.isEmpty {
                    feedbackSection(
                        title: "Needs Work",
                        icon: "exclamationmark.triangle.fill",
                        iconColor: .pitchWarning,
                        items: score.weaknesses
                    )
                }

                // Critical issues
                if !score.criticalIssues.isEmpty {
                    feedbackSection(
                        title: "Critical Issues",
                        icon: "xmark.circle.fill",
                        iconColor: .pitchError,
                        items: score.criticalIssues
                    )
                }

                // Top recommendations
                if !score.recommendations.isEmpty {
                    recommendationsSection(score.recommendations)
                }

                // Re-analyze button
                Button {
                    self.score = nil
                } label: {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "arrow.clockwise")
                        Text("Re-Analyze")
                    }
                    .font(Typography.labelLarge)
                    .foregroundColor(.pitchTextAdaptive)
                    .frame(maxWidth: .infinity)
                    .frame(height: Spacing.buttonHeight)
                    .background(Color.pitchCardBackgroundAdaptive)
                    .cornerRadius(Spacing.buttonCornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: Spacing.buttonCornerRadius)
                            .stroke(Color.pitchDivider, lineWidth: 1)
                    )
                }
                .padding(.horizontal, Spacing.screenMarginHorizontal)
                .padding(.bottom, Spacing.xxxl)
            }
        }
    }

    // MARK: - Overall Score Hero

    private func overallScoreHero(_ score: PitchScore) -> some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .stroke(Color.pitchDivider, lineWidth: 12)
                    .frame(width: 140, height: 140)
                Circle()
                    .trim(from: 0, to: Double(score.overallScore) / 100.0)
                    .stroke(
                        scoreColor(score.overallScore),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.0, dampingFraction: 0.8), value: score.overallScore)

                VStack(spacing: 2) {
                    Text("\(score.overallScore)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.pitchTextAdaptive)
                    Text("/ 100")
                        .font(Typography.bodySmall)
                        .foregroundColor(.pitchTextSecondary)
                }
            }

            Text(scoreTier(score.overallScore))
                .font(Typography.titleSmall)
                .foregroundColor(scoreColor(score.overallScore))
        }
        .padding(.horizontal, Spacing.screenMarginHorizontal)
    }

    // MARK: - Readiness Badge

    private func readinessBadge(_ readiness: PitchScore.InvestorReadiness) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: readiness.icon)
            Text(readiness.rawValue)
                .font(Typography.labelMedium)
        }
        .foregroundColor(.white)
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .background(readinessColor(readiness).cornerRadius(20))
    }

    // MARK: - Category Breakdown

    private func categoryBreakdown(_ scores: [String: Int]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Category Breakdown")
                .font(Typography.titleSmall)
                .foregroundColor(.pitchTextAdaptive)
                .padding(.horizontal, Spacing.screenMarginHorizontal)

            VStack(spacing: Spacing.sm) {
                ForEach(scores.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                    HStack(spacing: Spacing.md) {
                        Text(key)
                            .font(Typography.bodyMedium)
                            .foregroundColor(.pitchTextAdaptive)
                            .frame(minWidth: 130, alignment: .leading)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.pitchDivider)
                                    .frame(height: 8)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(scoreColor(value))
                                    .frame(width: geo.size.width * CGFloat(value) / 100, height: 8)
                                    .animation(.spring(response: 0.8), value: value)
                            }
                        }
                        .frame(height: 8)

                        Text("\(value)")
                            .font(Typography.labelSmall)
                            .foregroundColor(.pitchTextSecondary)
                            .frame(width: 28, alignment: .trailing)
                    }
                    .padding(.horizontal, Spacing.screenMarginHorizontal)
                }
            }
        }
        .padding(.vertical, Spacing.md)
        .background(Color.pitchCardBackgroundAdaptive)
    }

    // MARK: - Feedback Section

    private func feedbackSection(title: String, icon: String, iconColor: Color, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                Text(title)
                    .font(Typography.titleSmall)
                    .foregroundColor(.pitchTextAdaptive)
            }

            VStack(alignment: .leading, spacing: Spacing.sm) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: Spacing.sm) {
                        Circle()
                            .fill(iconColor)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)
                        Text(item)
                            .font(Typography.bodyMedium)
                            .foregroundColor(.pitchTextAdaptive)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(Spacing.base)
        .background(Color.pitchCardBackgroundAdaptive)
        .cornerRadius(Spacing.cardCornerRadius)
        .padding(.horizontal, Spacing.screenMarginHorizontal)
    }

    // MARK: - Recommendations

    private func recommendationsSection(_ recs: [PitchRecommendation]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Top Recommendations")
                .font(Typography.titleSmall)
                .foregroundColor(.pitchTextAdaptive)
                .padding(.horizontal, Spacing.screenMarginHorizontal)

            ForEach(recs.prefix(5)) { rec in
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack(spacing: Spacing.sm) {
                        Text(rec.priority.rawValue)
                            .font(Typography.labelSmall)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(priorityColor(rec.priority).cornerRadius(6))

                        Text(rec.category.rawValue)
                            .font(Typography.labelSmall)
                            .foregroundColor(.pitchTextSecondary)
                    }

                    Text(rec.title)
                        .font(Typography.labelLarge)
                        .foregroundColor(.pitchTextAdaptive)

                    Text(rec.description)
                        .font(Typography.bodyMedium)
                        .foregroundColor(.pitchTextSecondary)

                    if !rec.actionItems.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(rec.actionItems, id: \.self) { action in
                                HStack(alignment: .top, spacing: Spacing.xs) {
                                    Image(systemName: "arrow.right")
                                        .font(.caption2)
                                        .foregroundColor(.pitchLime)
                                        .padding(.top, 3)
                                    Text(action)
                                        .font(Typography.bodySmall)
                                        .foregroundColor(.pitchTextAdaptive)
                                }
                            }
                        }
                    }
                }
                .padding(Spacing.base)
                .background(Color.pitchCardBackgroundAdaptive)
                .cornerRadius(Spacing.cardCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.cardCornerRadius)
                        .stroke(Color.pitchLime.opacity(0.15), lineWidth: 1)
                )
                .padding(.horizontal, Spacing.screenMarginHorizontal)
            }
        }
    }

    // MARK: - Feature Pill

    private func featurePill(_ text: String) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.pitchLime)
                .font(.system(size: 14))
            Text(text)
                .font(Typography.bodyMedium)
                .foregroundColor(.pitchTextAdaptive)
            Spacer()
        }
        .padding(.horizontal, Spacing.base)
        .padding(.vertical, Spacing.sm)
        .background(Color.pitchCardBackgroundAdaptive)
        .cornerRadius(Spacing.cardCornerRadius)
    }

    // MARK: - Helpers

    private func analyzeScore() async {
        errorMessage = nil
        do {
            let result = try await coach.scoreDeck(deck)
            withAnimation { self.score = result }
        } catch {
            withAnimation { errorMessage = error.localizedDescription }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation { self.errorMessage = nil }
            }
        }
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 80...100: return .pitchSuccess
        case 60..<80:  return .pitchLime
        case 40..<60:  return .pitchWarning
        default:       return .pitchError
        }
    }

    private func scoreTier(_ score: Int) -> String {
        switch score {
        case 90...100: return "Exceptional — Multiple term sheets"
        case 80..<90:  return "Strong — High funding likelihood"
        case 70..<80:  return "Good — Competitive, needs polish"
        case 60..<70:  return "Average — Significant gaps"
        case 50..<60:  return "Below Average — Major rework needed"
        default:       return "Not Investor-Ready — Start over"
        }
    }

    private func readinessColor(_ r: PitchScore.InvestorReadiness) -> Color {
        switch r {
        case .ready:       return .pitchSuccess
        case .almostReady: return .pitchLime
        case .needsWork:   return .pitchWarning
        case .notReady:    return .pitchError
        }
    }

    private func priorityColor(_ p: PitchRecommendation.Priority) -> Color {
        switch p {
        case .critical: return .pitchError
        case .high:     return .pitchWarning
        case .medium:   return .pitchLime
        case .low:      return .pitchTextSecondary
        }
    }
}

#Preview {
    PitchScoreView(deck: .sampleInvestorDeck)
}
