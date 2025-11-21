//
//  DeckListView.swift
//  PitchMe
//
//  Main view displaying list of pitch decks
//

import SwiftUI

struct DeckListView: View {
    @StateObject private var viewModel = DeckListViewModel()
    @StateObject private var subscriptionService = SubscriptionService.shared
    @State private var showingNewDeckWizard = false
    @State private var showingPaywall = false
    @State private var showingLimitReached = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.pitchBackgroundAdaptive.ignoresSafeArea()
                
                if viewModel.hasDecks {
                    deckListContent
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("My Decks")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        checkLimitAndShowWizard()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.pitchLime)
                    }
                }
                
                ToolbarItem(placement: .navigation) {
                    if subscriptionService.currentTier == .free {
                        Button {
                            showingPaywall = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .font(.caption)
                                Text("Pro")
                                    .font(Typography.labelSmall)
                            }
                            .foregroundColor(.pitchCharcoal)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, 4)
                            .background(Color.pitchLime)
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .searchable(text: $viewModel.searchQuery, prompt: "Search decks")
            .refreshable {
                await viewModel.loadDecks()
            }
            .sheet(isPresented: $showingNewDeckWizard) {
                WizardContainerView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .alert("Limit Reached", isPresented: $showingLimitReached) {
                Button("Upgrade to Pro") {
                    showingPaywall = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You've used your free deck! Upgrade to Pro for unlimited decks starting at just $9.99/month.")
            }
        }
    }
    
    // MARK: - Helpers
    
    private func checkLimitAndShowWizard() {
        if subscriptionService.canAccessFeature(.createDeck) {
            showingNewDeckWizard = true
        } else {
            showingLimitReached = true
        }
    }
    
    // MARK: - Deck List Content
    
    private var deckListContent: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.base) {
                ForEach(viewModel.filteredDecks) { deck in
                    NavigationLink(destination: DeckDetailView(deck: deck)) {
                        DeckCardView(deck: deck)
                            .contextMenu {
                                Button {
                                    viewModel.duplicateDeck(deck)
                                } label: {
                                    Label("Duplicate", systemImage: "doc.on.doc")
                                }
                                
                                Button(role: .destructive) {
                                    withAnimation {
                                        viewModel.deleteDeck(deck)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, Spacing.screenMarginHorizontal)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 72))
                .foregroundColor(.pitchLime)
            
            VStack(spacing: Spacing.sm) {
                Text("No Decks Yet")
                    .font(Typography.displaySmall)
                    .foregroundColor(.pitchTextAdaptive)
                
                Text("Create your first pitch deck and\nstart impressing investors")
                    .font(Typography.bodyLarge)
                    .foregroundColor(.pitchTextSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                showingNewDeckWizard = true
            } label: {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "plus.circle.fill")
                    Text("Start a Pitch")
                }
                .font(Typography.labelLarge)
                .foregroundColor(.pitchCharcoal)
                .frame(height: Spacing.buttonHeight)
                .padding(.horizontal, Spacing.xxl)
                .background(Color.pitchLime)
                .cornerRadius(Spacing.buttonCornerRadius)
            }
            .padding(.top, Spacing.base)
            
            Spacer()
        }
        .padding(.horizontal, Spacing.screenMarginHorizontal)
    }
}

// MARK: - Deck Card View

struct DeckCardView: View {
    let deck: Deck
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header with use case badge
            HStack {
                Label {
                    Text(deck.useCase.displayName)
                        .font(Typography.labelSmall)
                        .foregroundColor(.pitchTextSecondary)
                } icon: {
                    Image(systemName: deck.useCase.icon)
                        .font(.caption)
                        .foregroundColor(.pitchTextSecondary)
                }
                
                Spacer()
                
                if let score = deck.storyScore {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(scoreColor(for: score))
                        Text("\(score)")
                            .font(Typography.labelSmall)
                            .foregroundColor(.pitchTextSecondary)
                    }
                }
            }
            
            // Deck title
            Text(deck.title)
                .font(Typography.titleMedium)
                .foregroundColor(.pitchTextAdaptive)
                .lineLimit(2)
            
            // Theme preview stripe
            HStack(spacing: 4) {
                Rectangle()
                    .fill(deck.theme.primaryColor)
                    .frame(width: 32, height: 4)
                    .cornerRadius(2)
                
                Text(deck.theme.displayName)
                    .font(Typography.labelSmall)
                    .foregroundColor(.pitchTextTertiary)
                
                Spacer()
            }
            
            Divider()
                .padding(.vertical, Spacing.xs)
            
            // Footer with metadata
            HStack {
                Label {
                    Text("\(deck.slideCount) slides")
                        .font(Typography.labelSmall)
                        .foregroundColor(.pitchTextSecondary)
                } icon: {
                    Image(systemName: "rectangle.stack")
                        .font(.caption)
                        .foregroundColor(.pitchTextTertiary)
                }
                
                Spacer()
                
                Text(deck.relativeLastEdited)
                    .font(Typography.labelSmall)
                    .foregroundColor(.pitchTextTertiary)
            }
        }
        .padding(Spacing.base)
        .background(Color.pitchCardBackgroundAdaptive)
        .cornerRadius(Spacing.cardCornerRadius)
        .cardShadow()
    }
    
    private func scoreColor(for score: Int) -> Color {
        switch score {
        case 90...100: return .pitchSuccess
        case 70..<90: return .pitchLime
        case 50..<70: return .pitchWarning
        default: return .pitchError
        }
    }
}

// MARK: - Previews

#Preview("Deck List with Decks") {
    DeckListView()
}

#Preview("Deck Card") {
    ZStack {
        Color.pitchBackgroundAdaptive.ignoresSafeArea()
        
        VStack(spacing: Spacing.base) {
            DeckCardView(deck: .sampleInvestorDeck)
            DeckCardView(deck: .sampleSalesDeck)
            DeckCardView(deck: .sampleAcceleratorDeck)
        }
        .padding()
    }
}

#Preview("Empty State") {
    DeckListView()
        .onAppear {
            // Force empty state by clearing decks
        }
}

