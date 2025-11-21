//
//  Typography.swift
//  PitchMe
//
//  Design System: Typography Tokens
//

import SwiftUI

// MARK: - Typography System

struct Typography {
    // MARK: - Display
    
    /// Large display text (48pt, bold) - Hero headlines
    static let displayLarge = Font.system(size: 48, weight: .bold, design: .rounded)
    
    /// Medium display text (36pt, bold) - Section titles
    static let displayMedium = Font.system(size: 36, weight: .bold, design: .rounded)
    
    /// Small display text (28pt, semibold) - Subsection titles
    static let displaySmall = Font.system(size: 28, weight: .semibold, design: .rounded)
    
    // MARK: - Title
    
    /// Large title (24pt, semibold) - Screen titles
    static let titleLarge = Font.system(size: 24, weight: .semibold, design: .rounded)
    
    /// Medium title (20pt, semibold) - Card titles
    static let titleMedium = Font.system(size: 20, weight: .semibold, design: .rounded)
    
    /// Small title (18pt, semibold) - List section headers
    static let titleSmall = Font.system(size: 18, weight: .semibold, design: .rounded)
    
    // MARK: - Body
    
    /// Large body text (17pt, regular) - Primary content
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)
    
    /// Medium body text (15pt, regular) - Secondary content
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)
    
    /// Small body text (13pt, regular) - Tertiary content
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)
    
    // MARK: - Label
    
    /// Large label (15pt, medium) - Button labels
    static let labelLarge = Font.system(size: 15, weight: .medium, design: .rounded)
    
    /// Medium label (13pt, medium) - Input labels
    static let labelMedium = Font.system(size: 13, weight: .medium, design: .rounded)
    
    /// Small label (11pt, medium) - Captions, metadata
    static let labelSmall = Font.system(size: 11, weight: .medium, design: .rounded)
    
    // MARK: - Slide Content (for deck rendering)
    
    /// Slide title (32pt, bold)
    static let slideTitle = Font.system(size: 32, weight: .bold, design: .rounded)
    
    /// Slide subtitle (24pt, semibold)
    static let slideSubtitle = Font.system(size: 24, weight: .semibold, design: .rounded)
    
    /// Slide body text (18pt, regular)
    static let slideBody = Font.system(size: 18, weight: .regular, design: .default)
    
    /// Slide bullet point (16pt, regular)
    static let slideBullet = Font.system(size: 16, weight: .regular, design: .default)
}

// MARK: - Text Modifiers

extension Text {
    /// Apply display large style
    func displayLarge() -> Text {
        self.font(Typography.displayLarge)
    }
    
    /// Apply display medium style
    func displayMedium() -> Text {
        self.font(Typography.displayMedium)
    }
    
    /// Apply title large style
    func titleLarge() -> Text {
        self.font(Typography.titleLarge)
    }
    
    /// Apply title medium style
    func titleMedium() -> Text {
        self.font(Typography.titleMedium)
    }
    
    /// Apply body large style
    func bodyLarge() -> Text {
        self.font(Typography.bodyLarge)
    }
    
    /// Apply body medium style
    func bodyMedium() -> Text {
        self.font(Typography.bodyMedium)
    }
    
    /// Apply label large style
    func labelLarge() -> Text {
        self.font(Typography.labelLarge)
    }
}

// MARK: - View Modifiers for Typography

struct DisplayLargeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Typography.displayLarge)
            .foregroundColor(.pitchTextAdaptive)
    }
}

struct TitleLargeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Typography.titleLarge)
            .foregroundColor(.pitchTextAdaptive)
    }
}

struct BodyLargeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Typography.bodyLarge)
            .foregroundColor(.pitchTextAdaptive)
    }
}

extension View {
    func displayLargeStyle() -> some View {
        self.modifier(DisplayLargeModifier())
    }
    
    func titleLargeStyle() -> some View {
        self.modifier(TitleLargeModifier())
    }
    
    func bodyLargeStyle() -> some View {
        self.modifier(BodyLargeModifier())
    }
}

