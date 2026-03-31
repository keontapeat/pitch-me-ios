//
//  AppState.swift
//  Pitch Me
//
//  App state management and UserDefaults
//

import Foundation
import Combine
import SwiftUI

final class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding)
        }
    }
    
    @Published var isAuthenticated: Bool = false
    
    // MARK: - Appearance
    
    @Published var colorSchemePreference: ColorSchemePreference {
        didSet {
            UserDefaults.standard.set(colorSchemePreference.rawValue, forKey: Keys.colorSchemePreference)
        }
    }
    
    var preferredColorScheme: ColorScheme? {
        colorSchemePreference.colorScheme
    }
    
    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let colorSchemePreference  = "colorSchemePreference"
    }
    
    private init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding)
        let raw = UserDefaults.standard.string(forKey: Keys.colorSchemePreference) ?? ""
        self.colorSchemePreference = ColorSchemePreference(rawValue: raw) ?? .system
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
    }
}

// MARK: - Color Scheme Preference

enum ColorSchemePreference: String, CaseIterable, Identifiable {
    case system = "system"
    case light  = "light"
    case dark   = "dark"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }
    
    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max.fill"
        case .dark:   return "moon.fill"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

