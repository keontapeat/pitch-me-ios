//
//  Colors.swift
//  PitchMe
//
//  Design System: Color Tokens
//

import SwiftUI

extension Color {
    // MARK: - Brand Colors
    
    /// Neon lime accent - primary brand color
    static let pitchLime = Color(red: 0.75, green: 1.0, blue: 0.0)
    
    /// Dark charcoal - primary dark color
    static let pitchCharcoal = Color(red: 0.14, green: 0.14, blue: 0.14)
    
    /// Charcoal with slight warmth for backgrounds
    static let pitchCharcoalWarm = Color(red: 0.16, green: 0.15, blue: 0.15)
    
    // MARK: - Semantic Colors (Light Mode)
    
    /// Primary background color
    static let pitchBackground = Color(red: 0.98, green: 0.98, blue: 0.98)
    
    /// Card background color
    static let pitchCardBackground = Color.white
    
    /// Primary text color
    static let pitchTextPrimary = Color(red: 0.11, green: 0.11, blue: 0.12)
    
    /// Secondary text color
    static let pitchTextSecondary = Color(red: 0.42, green: 0.42, blue: 0.45)
    
    /// Tertiary text color (subtle labels)
    static let pitchTextTertiary = Color(red: 0.62, green: 0.62, blue: 0.65)
    
    // MARK: - Semantic Colors (Dark Mode)
    
    /// Primary background color (dark mode)
    static let pitchBackgroundDark = Color(red: 0.11, green: 0.11, blue: 0.12)
    
    /// Card background color (dark mode)
    static let pitchCardBackgroundDark = Color(red: 0.17, green: 0.17, blue: 0.18)
    
    /// Primary text color (dark mode)
    static let pitchTextPrimaryDark = Color(red: 0.98, green: 0.98, blue: 0.98)
    
    // MARK: - Adaptive Colors
    
    /// Adaptive background that responds to light/dark mode
    static var pitchBackgroundAdaptive: Color {
        Color(light: .pitchBackground, dark: .pitchBackgroundDark)
    }
    
    /// Adaptive card background
    static var pitchCardBackgroundAdaptive: Color {
        Color(light: .pitchCardBackground, dark: .pitchCardBackgroundDark)
    }
    
    /// Adaptive primary text
    static var pitchTextAdaptive: Color {
        Color(light: .pitchTextPrimary, dark: .pitchTextPrimaryDark)
    }
    
    // MARK: - Utility Colors
    
    /// Success green
    static let pitchSuccess = Color(red: 0.20, green: 0.78, blue: 0.35)
    
    /// Warning orange
    static let pitchWarning = Color(red: 1.0, green: 0.58, blue: 0.0)
    
    /// Error red
    static let pitchError = Color(red: 1.0, green: 0.23, blue: 0.19)
    
    /// Divider/border color
    static let pitchDivider = Color(red: 0.85, green: 0.85, blue: 0.87)
    
    // MARK: - Theme-Specific Colors
    
    /// Bold theme gradient start
    static let pitchBoldGradientStart = Color(red: 0.4, green: 0.2, blue: 0.9)
    
    /// Bold theme gradient end
    static let pitchBoldGradientEnd = Color(red: 0.9, green: 0.3, blue: 0.5)
}

// MARK: - Color Initialization Helpers

extension Color {
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor(light: UIColor(light), dark: UIColor(dark)))
    }
}

extension UIColor {
    convenience init(light: UIColor, dark: UIColor) {
        self.init { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return dark
            default:
                return light
            }
        }
    }
}

