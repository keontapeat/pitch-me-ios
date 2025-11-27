//
//  Pitch_MeApp.swift
//  Pitch Me
//
//  Created by Keonta  on 11/21/25.
//

import SwiftUI
import FirebaseCore

// MARK: - App Delegate

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        return true
    }
}

// MARK: - Main App

@main
struct Pitch_MeApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        // Configure app appearance
        configureAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
    
    // MARK: - Configuration
    
    private func configureAppearance() {
        // Configure navigation bar appearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        navigationBarAppearance.backgroundColor = UIColor(Color.pitchBackgroundAdaptive)
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.pitchTextAdaptive),
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.pitchTextAdaptive),
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        
        // Configure tab bar appearance (for future use)
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.pitchCardBackgroundAdaptive)
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Set tint color for navigation and controls
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Color.pitchLime)
    }
}
