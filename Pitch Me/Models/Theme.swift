//
//  Theme.swift
//  PitchMe
//
//  Theme model for deck presentation styling
//

import SwiftUI

// MARK: - Theme

struct Theme: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let displayName: String
    let description: String
    
    // Color configuration (stored as hex strings for Codable)
    let primaryColorHex: String
    let backgroundColorHex: String
    let cardBackgroundColorHex: String
    let textColorHex: String
    let accentColorHex: String
    
    // Typography configuration
    let titleFontWeight: FontWeight
    let bodyFontWeight: FontWeight
    
    // Layout configuration
    let cardCornerRadius: CGFloat
    let usesGradient: Bool
    let gradientStartHex: String?
    let gradientEndHex: String?
    
    // MARK: - Computed Properties
    
    var primaryColor: Color {
        Color(hex: primaryColorHex)
    }
    
    var backgroundColor: Color {
        Color(hex: backgroundColorHex)
    }
    
    var cardBackgroundColor: Color {
        Color(hex: cardBackgroundColorHex)
    }
    
    var textColor: Color {
        Color(hex: textColorHex)
    }
    
    var accentColor: Color {
        Color(hex: accentColorHex)
    }
    
    var gradient: LinearGradient? {
        guard usesGradient,
              let startHex = gradientStartHex,
              let endHex = gradientEndHex else {
            return nil
        }
        return LinearGradient(
            colors: [Color(hex: startHex), Color(hex: endHex)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - FontWeight

enum FontWeight: String, Codable {
    case regular
    case medium
    case semibold
    case bold
    
    var swiftUIWeight: Font.Weight {
        switch self {
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        }
    }
}

// MARK: - Predefined Themes

extension Theme {
    /// Clean Light - White background, dark text, subtle accents
    static let cleanLight = Theme(
        id: "clean-light",
        name: "cleanLight",
        displayName: "Clean Light",
        description: "Professional and minimal with maximum clarity",
        primaryColorHex: "#1C1C1E",
        backgroundColorHex: "#FAFAFA",
        cardBackgroundColorHex: "#FFFFFF",
        textColorHex: "#1C1C1E",
        accentColorHex: "#BFFF00",
        titleFontWeight: .bold,
        bodyFontWeight: .regular,
        cardCornerRadius: 12,
        usesGradient: false,
        gradientStartHex: nil,
        gradientEndHex: nil
    )
    
    /// Dark Tech - Deep charcoal background, light text, neon accents
    static let darkTech = Theme(
        id: "dark-tech",
        name: "darkTech",
        displayName: "Dark Tech",
        description: "Modern and bold for technical products",
        primaryColorHex: "#BFFF00",
        backgroundColorHex: "#1C1C1E",
        cardBackgroundColorHex: "#2C2C2E",
        textColorHex: "#FAFAFA",
        accentColorHex: "#BFFF00",
        titleFontWeight: .bold,
        bodyFontWeight: .regular,
        cardCornerRadius: 16,
        usesGradient: false,
        gradientStartHex: nil,
        gradientEndHex: nil
    )
    
    /// Bold Color - Large colored blocks, gradient accents, impactful
    static let boldColor = Theme(
        id: "bold-color",
        name: "boldColor",
        displayName: "Bold Color",
        description: "Eye-catching and memorable for standout pitches",
        primaryColorHex: "#6633E6",
        backgroundColorHex: "#FAFAFA",
        cardBackgroundColorHex: "#FFFFFF",
        textColorHex: "#1C1C1E",
        accentColorHex: "#E6004D",
        titleFontWeight: .bold,
        bodyFontWeight: .semibold,
        cardCornerRadius: 20,
        usesGradient: true,
        gradientStartHex: "#6633E6",
        gradientEndHex: "#E6004D"
    )
    
    /// All available themes
    static let allThemes: [Theme] = [.cleanLight, .darkTech, .boldColor]
    
    /// Default theme
    static let `default` = cleanLight
}

// MARK: - Color Extension for Hex Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

