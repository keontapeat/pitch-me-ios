//
//  SlidePreviewCarouselView.swift
//  PitchMe
//
//  Horizontal carousel for slide previews
//

import SwiftUI

struct SlidePreviewCarouselView: View {
    let deck: Deck
    @Binding var selectedIndex: Int
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(Array(deck.slides.enumerated()), id: \.element.id) { index, slide in
                        SlidePreviewCard(
                            slide: slide,
                            theme: deck.theme,
                            isSelected: index == selectedIndex
                        )
                        .id(index)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedIndex = index
                            }
                        }
                    }
                }
                .padding(.horizontal, Spacing.screenMarginHorizontal)
            }
            .onChange(of: selectedIndex) { _, newIndex in
                withAnimation {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
        }
        .frame(height: 240)
    }
}

// MARK: - Slide Preview Card

struct SlidePreviewCard: View {
    let slide: Slide
    let theme: Theme
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Slide index badge
            HStack {
                Text("\(slide.index + 1)")
                    .font(Typography.labelSmall)
                    .foregroundColor(theme.textColor.opacity(0.6))
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, 4)
                    .background(theme.primaryColor.opacity(0.2))
                    .cornerRadius(6)
                
                Spacer()
                
                Image(systemName: slide.layoutType.icon)
                    .font(.caption)
                    .foregroundColor(theme.textColor.opacity(0.4))
            }
            
            // Slide title preview
            Text(slide.title)
                .font(Typography.titleSmall)
                .foregroundColor(theme.textColor)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Bullet points preview
            if !slide.bullets.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(slide.bullets.prefix(3).enumerated()), id: \.offset) { _, bullet in
                        HStack(alignment: .top, spacing: 6) {
                            Circle()
                                .fill(theme.primaryColor)
                                .frame(width: 4, height: 4)
                                .padding(.top, 6)
                            
                            Text(bullet)
                                .font(Typography.bodySmall)
                                .foregroundColor(theme.textColor.opacity(0.8))
                                .lineLimit(1)
                        }
                    }
                    
                    if slide.bullets.count > 3 {
                        Text("+\(slide.bullets.count - 3) more")
                            .font(Typography.labelSmall)
                            .foregroundColor(theme.textColor.opacity(0.5))
                            .padding(.leading, 10)
                    }
                }
            }
            
            Spacer()
        }
        .padding(Spacing.md)
        .frame(width: 180, height: 200)
        .background(theme.cardBackgroundColor)
        .cornerRadius(Spacing.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.cardCornerRadius)
                .stroke(isSelected ? theme.primaryColor : Color.clear, lineWidth: 3)
        )
        .shadow(
            color: isSelected ? theme.primaryColor.opacity(0.3) : Color.black.opacity(0.1),
            radius: isSelected ? 12 : 6,
            x: 0,
            y: isSelected ? 6 : 3
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Previews

#Preview("Slide Carousel") {
    struct PreviewWrapper: View {
        @State private var selectedIndex = 0
        
        var body: some View {
            ZStack {
                Color.pitchBackgroundAdaptive.ignoresSafeArea()
                
                VStack {
                    SlidePreviewCarouselView(
                        deck: .sampleInvestorDeck,
                        selectedIndex: $selectedIndex
                    )
                    
                    Text("Selected: Slide \(selectedIndex + 1)")
                        .font(Typography.bodyLarge)
                        .foregroundColor(.pitchTextAdaptive)
                        .padding()
                }
            }
        }
    }
    
    return PreviewWrapper()
}

#Preview("Slide Preview Cards") {
    ZStack {
        Color.pitchBackgroundAdaptive.ignoresSafeArea()
        
        HStack(spacing: Spacing.base) {
            SlidePreviewCard(
                slide: .sampleTitleSlide,
                theme: .cleanLight,
                isSelected: false
            )
            
            SlidePreviewCard(
                slide: .sampleProblemSlide,
                theme: .cleanLight,
                isSelected: true
            )
            
            SlidePreviewCard(
                slide: .sampleSolutionSlide,
                theme: .darkTech,
                isSelected: false
            )
        }
        .padding()
    }
}

