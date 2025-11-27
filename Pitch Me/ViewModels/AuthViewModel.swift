//
//  AuthViewModel.swift
//  Pitch Me
//
//  Authentication ViewModel - Handle all auth UI logic
//

import SwiftUI
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var displayName = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    @Published var emailError: String?
    @Published var passwordError: String?
    
    // MARK: - Dependencies
    
    private let authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var isValidEmail: Bool {
        authService.isValidEmail(email)
    }
    
    var passwordStrength: PasswordStrength {
        authService.getPasswordStrength(password)
    }
    
    var canSignUp: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        password == confirmPassword &&
        isValidEmail &&
        passwordStrength == .strong
    }
    
    var canSignIn: Bool {
        !email.isEmpty && !password.isEmpty && isValidEmail
    }
    
    var canUseBiometrics: Bool {
        authService.canUseBiometrics()
    }
    
    // MARK: - Actions
    
    func signUp() async {
        guard canSignUp else {
            showError(message: "Please fill in all fields correctly")
            return
        }
        
        isLoading = true
        errorMessage = nil
        emailError = nil
        passwordError = nil
        
        do {
            try await authService.signUp(
                email: email.trimmingCharacters(in: .whitespaces),
                password: password,
                displayName: displayName.isEmpty ? nil : displayName.trimmingCharacters(in: .whitespaces)
            )
            
            // Success - auth state listener will handle navigation
            resetForm()
            
        } catch let error as AuthError {
            handleAuthError(error)
        } catch {
            showError(message: "An unexpected error occurred")
        }
        
        isLoading = false
    }
    
    func signIn() async {
        guard canSignIn else {
            showError(message: "Please enter a valid email and password")
            return
        }
        
        isLoading = true
        errorMessage = nil
        emailError = nil
        passwordError = nil
        
        do {
            try await authService.signIn(
                email: email.trimmingCharacters(in: .whitespaces),
                password: password
            )
            
            // Success - auth state listener will handle navigation
            resetForm()
            
        } catch let error as AuthError {
            handleAuthError(error)
        } catch {
            showError(message: "An unexpected error occurred")
        }
        
        isLoading = false
    }
    
    func signInWithBiometrics() async {
        guard canUseBiometrics else {
            showError(message: "Biometric authentication is not available")
            return
        }
        
        isLoading = true
        
        do {
            try await authService.authenticateWithBiometrics()
            // If biometric auth succeeds, proceed with stored credentials
            // (In production, you'd retrieve stored credentials from Keychain)
            
        } catch let error as AuthError {
            handleAuthError(error)
        } catch {
            showError(message: "Biometric authentication failed")
        }
        
        isLoading = false
    }
    
    func resetPassword() async {
        guard isValidEmail else {
            showError(message: "Please enter a valid email address")
            return
        }
        
        isLoading = true
        
        do {
            try await authService.resetPassword(email: email.trimmingCharacters(in: .whitespaces))
            showError(message: "Password reset email sent. Check your inbox.")
        } catch let error as AuthError {
            handleAuthError(error)
        } catch {
            showError(message: "Failed to send reset email")
        }
        
        isLoading = false
    }
    
    func validateEmailField() {
        if email.isEmpty {
            emailError = nil
        } else if !authService.isValidEmail(email) {
            emailError = "Invalid email address"
        } else {
            emailError = nil
        }
    }
    
    func validatePasswordField() {
        if password.isEmpty {
            passwordError = nil
        } else if passwordStrength == .weak {
            passwordError = "Password is too weak"
        } else if !confirmPassword.isEmpty && password != confirmPassword {
            passwordError = "Passwords don't match"
        } else {
            passwordError = nil
        }
    }
    
    // MARK: - Helpers
    
    private func handleAuthError(_ error: AuthError) {
        switch error {
        case .invalidEmail:
            emailError = error.localizedDescription
        case .weakPassword, .wrongPassword:
            passwordError = error.localizedDescription
        default:
            showError(message: error.localizedDescription)
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
        
        // Auto-dismiss after 3 seconds
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            errorMessage = nil
            showError = false
        }
    }
    
    private func resetForm() {
        email = ""
        password = ""
        confirmPassword = ""
        displayName = ""
        emailError = nil
        passwordError = nil
    }
}

