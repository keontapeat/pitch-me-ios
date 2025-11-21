//
//  Spacing.swift
//  PitchMe
//
//  Design System: Spacing Tokens
//

import SwiftUI

// MARK: - Spacing System

struct Spacing {
    /// 4pt - Minimal spacing
    static let xs: CGFloat = 4
    
    /// 8pt - Extra small spacing
    static let sm: CGFloat = 8
    
    /// 12pt - Small spacing
    static let md: CGFloat = 12
    
    /// 16pt - Base spacing unit
    static let base: CGFloat = 16
    
    /// 20pt - Medium spacing
    static let lg: CGFloat = 20
    
    /// 24pt - Large spacing
    static let xl: CGFloat = 24
    
    /// 32pt - Extra large spacing
    static let xxl: CGFloat = 32
    
    /// 40pt - Huge spacing
    static let xxxl: CGFloat = 40
    
    /// 48pt - Section spacing
    static let section: CGFloat = 48
    
    // MARK: - Component-Specific Spacing
    
    /// Standard card padding (16pt)
    static let cardPadding: CGFloat = base
    
    /// Card corner radius (12pt)
    static let cardCornerRadius: CGFloat = 12
    
    /// Large card corner radius (20pt)
    static let cardCornerRadiusLarge: CGFloat = 20
    
    /// Button height (50pt)
    static let buttonHeight: CGFloat = 50
    
    /// Button corner radius (12pt)
    static let buttonCornerRadius: CGFloat = 12
    
    /// Input field height (48pt)
    static let inputHeight: CGFloat = 48
    
    /// Standard horizontal screen margin (20pt)
    static let screenMarginHorizontal: CGFloat = lg
    
    /// Standard vertical screen margin (24pt)
    static let screenMarginVertical: CGFloat = xl
    
    /// Minimum tap target size (44pt - Apple HIG)
    static let minTapTarget: CGFloat = 44
}

// MARK: - Border Widths

struct BorderWidth {
    /// Hairline border (0.5pt)
    static let hairline: CGFloat = 0.5
    
    /// Thin border (1pt)
    static let thin: CGFloat = 1
    
    /// Medium border (2pt)
    static let medium: CGFloat = 2
    
    /// Thick border (3pt)
    static let thick: CGFloat = 3
}

// MARK: - Shadow Styles

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    /// Subtle card shadow
    static let card = ShadowStyle(
        color: Color.black.opacity(0.08),
        radius: 8,
        x: 0,
        y: 2
    )
    
    /// Medium elevation shadow
    static let elevated = ShadowStyle(
        color: Color.black.opacity(0.12),
        radius: 16,
        x: 0,
        y: 4
    )
    
    /// Strong depth shadow
    static let deep = ShadowStyle(
        color: Color.black.opacity(0.16),
        radius: 24,
        x: 0,
        y: 8
    )
}

// MARK: - View Extension for Easy Shadow Application

extension View {
    /// Apply card shadow style
    func cardShadow() -> some View {
        self.shadow(
            color: ShadowStyle.card.color,
            radius: ShadowStyle.card.radius,
            x: ShadowStyle.card.x,
            y: ShadowStyle.card.y
        )
    }
    
    /// Apply elevated shadow style
    func elevatedShadow() -> some View {
        self.shadow(
            color: ShadowStyle.elevated.color,
            radius: ShadowStyle.elevated.radius,
            x: ShadowStyle.elevated.x,
            y: ShadowStyle.elevated.y
        )
    }
    
    /// Apply deep shadow style
    func deepShadow() -> some View {
        self.shadow(
            color: ShadowStyle.deep.color,
            radius: ShadowStyle.deep.radius,
            x: ShadowStyle.deep.x,
            y: ShadowStyle.deep.y
        )
    }
}

// MARK: - Convenience Extensions

extension View {
    /// Standard screen padding (horizontal: 20pt, vertical: 24pt)
    func screenPadding() -> some View {
        self.padding(.horizontal, Spacing.screenMarginHorizontal)
            .padding(.vertical, Spacing.screenMarginVertical)
    }
    
    /// Card style with padding, background, and shadow
    func cardStyle() -> some View {
        self
            .padding(Spacing.cardPadding)
            .background(Color.pitchCardBackgroundAdaptive)
            .cornerRadius(Spacing.cardCornerRadius)
            .cardShadow()
    }
}

