//
//  AuthService.swift
//  Pitch Me
//
//  Elite Firebase Authentication Service
//  Handles all auth operations with security and elegance
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import LocalAuthentication
import Combine

// MARK: - Auth Error

enum AuthError: Error, LocalizedError {
    case notAuthenticated
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case userNotFound
    case wrongPassword
    case networkError
    case biometricNotAvailable
    case biometricFailed
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be logged in to perform this action"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .weakPassword:
            return "Password must be at least 8 characters with uppercase, lowercase, and numbers"
        case .emailAlreadyInUse:
            return "This email is already registered. Try logging in instead."
        case .userNotFound:
            return "No account found with this email"
        case .wrongPassword:
            return "Incorrect password. Please try again."
        case .networkError:
            return "Network error. Check your connection and try again."
        case .biometricNotAvailable:
            return "Face ID/Touch ID is not available on this device"
        case .biometricFailed:
            return "Biometric authentication failed"
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - Auth Service

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published private(set) var currentUser: User?
    @Published private(set) var isAuthenticated = false
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    private init() {
        setupAuthStateListener()
    }
    
    // MARK: - Auth State Management
    
    private func setupAuthStateListener() {
        authStateHandle = auth.addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { @MainActor in
                if let firebaseUser = firebaseUser {
                    await self?.loadUserData(uid: firebaseUser.uid)
                } else {
                    self?.currentUser = nil
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
    private func loadUserData(uid: String) async {
        do {
            let document = try await db.collection("users").document(uid).getDocument()
            
            guard document.exists, let data = document.data() else {
                // User document doesn't exist yet (might be just created)
                return
            }
            
            self.currentUser = User(
                id: uid,
                email: data["email"] as? String ?? "",
                displayName: data["displayName"] as? String,
                subscriptionTier: SubscriptionTier(rawValue: data["subscriptionTier"] as? String ?? "free") ?? .free,
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                decksCreated: data["decksCreated"] as? Int ?? 0
            )
            self.isAuthenticated = true
            
        } catch {
            print("⚠️ Error loading user data: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Sign Up
    
    func signUp(email: String, password: String, displayName: String?) async throws {
        // Validate input
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }
        
        guard isStrongPassword(password) else {
            throw AuthError.weakPassword
        }
        
        do {
            // Create user
            let result = try await auth.createUser(withEmail: email, password: password)
            
            // Create user document in Firestore
            let userData: [String: Any] = [
                "email": email,
                "displayName": displayName ?? "",
                "subscriptionTier": SubscriptionTier.free.rawValue,
                "createdAt": FieldValue.serverTimestamp(),
                "decksCreated": 0,
                "onboardingCompleted": false
            ]
            
            try await db.collection("users").document(result.user.uid).setData(userData)
            
            // Update profile if display name provided
            if let displayName = displayName {
                let changeRequest = result.user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                try await changeRequest.commitChanges()
            }
            
            // User data will be loaded automatically via auth state listener
            
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }
    
    // MARK: - Sign In
    
    func signIn(email: String, password: String) async throws {
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }
        
        do {
            try await auth.signIn(withEmail: email, password: password)
            // User data will be loaded automatically via auth state listener
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() throws {
        do {
            try auth.signOut()
            currentUser = nil
            isAuthenticated = false
        } catch {
            throw AuthError.unknown("Failed to sign out")
        }
    }
    
    // MARK: - Password Reset
    
    func resetPassword(email: String) async throws {
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }
        
        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }
    
    // MARK: - Biometric Authentication
    
    func canUseBiometrics() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func authenticateWithBiometrics() async throws {
        let context = LAContext()
        context.localizedCancelTitle = "Use Password"
        
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw AuthError.biometricNotAvailable
        }
        
        let reason = "Authenticate to access Pitch Me"
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            
            if !success {
                throw AuthError.biometricFailed
            }
        } catch {
            throw AuthError.biometricFailed
        }
    }
    
    // MARK: - Validation Helpers
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func isStrongPassword(_ password: String) -> Bool {
        // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
        guard password.count >= 8 else { return false }
        
        let uppercaseRegex = ".*[A-Z]+.*"
        let lowercaseRegex = ".*[a-z]+.*"
        let numberRegex = ".*[0-9]+.*"
        
        let uppercasePredicate = NSPredicate(format: "SELF MATCHES %@", uppercaseRegex)
        let lowercasePredicate = NSPredicate(format: "SELF MATCHES %@", lowercaseRegex)
        let numberPredicate = NSPredicate(format: "SELF MATCHES %@", numberRegex)
        
        return uppercasePredicate.evaluate(with: password) &&
               lowercasePredicate.evaluate(with: password) &&
               numberPredicate.evaluate(with: password)
    }
    
    func getPasswordStrength(_ password: String) -> PasswordStrength {
        if password.isEmpty {
            return .none
        } else if password.count < 6 {
            return .weak
        } else if password.count < 8 || !isStrongPassword(password) {
            return .medium
        } else {
            return .strong
        }
    }
    
    // MARK: - Error Mapping
    
    private func mapAuthError(_ error: NSError) -> AuthError {
        guard let errorCode = AuthErrorCode(rawValue: error.code) else {
            return .unknown(error.localizedDescription)
        }
        
        switch errorCode {
        case .invalidEmail:
            return .invalidEmail
        case .weakPassword:
            return .weakPassword
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .userNotFound:
            return .userNotFound
        case .wrongPassword:
            return .wrongPassword
        case .networkError:
            return .networkError
        default:
            return .unknown(error.localizedDescription)
        }
    }
    
    deinit {
        if let handle = authStateHandle {
            auth.removeStateDidChangeListener(handle)
        }
    }
}

// MARK: - Password Strength

enum PasswordStrength {
    case none
    case weak
    case medium
    case strong
    
    var color: String {
        switch self {
        case .none: return "gray"
        case .weak: return "red"
        case .medium: return "orange"
        case .strong: return "green"
        }
    }
    
    var text: String {
        switch self {
        case .none: return ""
        case .weak: return "Weak"
        case .medium: return "Medium"
        case .strong: return "Strong"
        }
    }
}

