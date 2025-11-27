//
//  User.swift
//  Pitch Me
//
//  User model for authenticated users
//

import Foundation

struct User: Identifiable, Codable {
    let id: String  // Firebase UID
    let email: String
    var displayName: String?
    var subscriptionTier: SubscriptionTier
    var createdAt: Date
    var decksCreated: Int
    
    var initials: String {
        if let displayName = displayName, !displayName.isEmpty {
            let components = displayName.components(separatedBy: " ")
            if components.count >= 2 {
                let firstInitial = components[0].prefix(1)
                let lastInitial = components[1].prefix(1)
                return "\(firstInitial)\(lastInitial)".uppercased()
            } else {
                return String(displayName.prefix(2)).uppercased()
            }
        } else {
            return String(email.prefix(2)).uppercased()
        }
    }
    
    var hasProAccess: Bool {
        subscriptionTier == .pro || subscriptionTier == .proPlus || subscriptionTier == .enterprise
    }
    
    var hasProPlusAccess: Bool {
        subscriptionTier == .proPlus || subscriptionTier == .enterprise
    }
}

