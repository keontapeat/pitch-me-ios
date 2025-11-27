//
//  SignUpView.swift
//  Pitch Me
//
//  🔥 NUCLEAR Sign Up View - Beautiful onboarding experience
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    
    enum Field {
        case displayName, email, password, confirmPassword
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.pitchBackgroundAdaptive
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Header
                        header
                        
                        // Form
                        VStack(spacing: Spacing.lg) {
                            // Display name
                            InputField(
                                text: $viewModel.displayName,
                                placeholder: "Full Name (Optional)",
                                icon: "person.fill",
                                textContentType: .name
                            )
                            .focused($focusedField, equals: .displayName)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .email
                            }
                            
                            // Email field
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                InputField(
                                    text: $viewModel.email,
                                    placeholder: "Email",
                                    icon: "envelope.fill",
                                    keyboardType: .emailAddress,
                                    textContentType: .emailAddress,
                                    autocapitalization: .never
                                )
                                .focused($focusedField, equals: .email)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .password
                                }
                                .onChange(of: viewModel.email) {
                                    viewModel.validateEmailField()
                                }
                                
                                if let emailError = viewModel.emailError {
                                    Text(emailError)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.leading, Spacing.base)
                                        .transition(.opacity)
                                }
                            }
                            .animation(.easeInOut(duration: 0.2), value: viewModel.emailError)
                            
                            // Password field
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                InputField(
                                    text: $viewModel.password,
                                    placeholder: "Password",
                                    icon: "lock.fill",
                                    isSecure: true,
                                    textContentType: .newPassword
                                )
                                .focused($focusedField, equals: .password)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .confirmPassword
                                }
                                .onChange(of: viewModel.password) {
                                    viewModel.validatePasswordField()
                                }
                                
                                // Password strength indicator
                                if !viewModel.password.isEmpty {
                                    HStack(spacing: Spacing.xs) {
                                        ForEach(0..<3) { index in
                                            Rectangle()
                                                .fill(passwordStrengthColor(for: index))
                                                .frame(height: 3)
                                                .cornerRadius(1.5)
                                        }
                                        
                                        Text(viewModel.passwordStrength.text)
                                            .font(.caption)
                                            .foregroundColor(passwordStrengthTextColor)
                                    }
                                    .padding(.horizontal, Spacing.base)
                                    .transition(.opacity)
                                }
                                
                                if let passwordError = viewModel.passwordError {
                                    Text(passwordError)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.leading, Spacing.base)
                                        .transition(.opacity)
                                }
                            }
                            .animation(.easeInOut(duration: 0.2), value: viewModel.password)
                            .animation(.easeInOut(duration: 0.2), value: viewModel.passwordError)
                            
                            // Confirm password field
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                InputField(
                                    text: $viewModel.confirmPassword,
                                    placeholder: "Confirm Password",
                                    icon: "lock.fill",
                                    isSecure: true,
                                    textContentType: .newPassword
                                )
                                .focused($focusedField, equals: .confirmPassword)
                                .submitLabel(.done)
                                .onSubmit {
                                    focusedField = nil
                                    if viewModel.canSignUp {
                                        Task {
                                            await viewModel.signUp()
                                        }
                                    }
                                }
                                
                                if !viewModel.confirmPassword.isEmpty && viewModel.password != viewModel.confirmPassword {
                                    Text("Passwords don't match")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.leading, Spacing.base)
                                        .transition(.opacity)
                                }
                            }
                            .animation(.easeInOut(duration: 0.2), value: viewModel.confirmPassword)
                            
                            // Password requirements
                            passwordRequirements
                            
                            // Sign up button
                            Button {
                                focusedField = nil
                                Task {
                                    await viewModel.signUp()
                                }
                            } label: {
                                HStack {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Create Account")
                                            .font(.system(size: 17, weight: .semibold))
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(viewModel.canSignUp ? Color.pitchTextAdaptive : Color.pitchTextAdaptive.opacity(0.2))
                                )
                            }
                            .disabled(!viewModel.canSignUp || viewModel.isLoading)
                            .padding(.top, Spacing.base)
                            
                            // Terms
                            Text("By signing up, you agree to our Terms of Service and Privacy Policy")
                                .font(.caption)
                                .foregroundColor(.pitchTextAdaptive.opacity(0.5))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Spacing.base)
                            
                            // Divider
                            HStack {
                                Rectangle()
                                    .fill(Color.pitchTextAdaptive.opacity(0.2))
                                    .frame(height: 1)
                                
                                Text("OR")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.pitchTextAdaptive.opacity(0.5))
                                
                                Rectangle()
                                    .fill(Color.pitchTextAdaptive.opacity(0.2))
                                    .frame(height: 1)
                            }
                            .padding(.vertical, Spacing.base)
                            
                            // Sign in link
                            Button {
                                dismiss()
                            } label: {
                                HStack(spacing: 4) {
                                    Text("Already have an account?")
                                        .foregroundColor(.pitchTextAdaptive.opacity(0.5))
                                    Text("Sign In")
                                        .foregroundColor(.pitchTextAdaptive)
                                        .fontWeight(.semibold)
                                }
                                .font(.system(size: 15))
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                    }
                    .padding(.top, Spacing.xxxl)
                    .padding(.bottom, Spacing.xxxl)
                }
                
                // Error toast
                if viewModel.showError, let errorMessage = viewModel.errorMessage {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text(errorMessage)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.2, green: 0.2, blue: 0.22))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, Spacing.xxxl)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.pitchTextAdaptive)
                    }
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: Spacing.lg) {
            VStack(spacing: Spacing.xs) {
                Text("Create Account")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(.pitchTextAdaptive)
                
                Text("Get started in seconds")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.pitchTextAdaptive.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.bottom, Spacing.base)
    }
    
    // MARK: - Password Requirements
    
    private var passwordRequirements: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            requirementRow(
                text: "At least 8 characters",
                isMet: viewModel.password.count >= 8
            )
            requirementRow(
                text: "One uppercase letter",
                isMet: viewModel.password.range(of: "[A-Z]", options: .regularExpression) != nil
            )
            requirementRow(
                text: "One lowercase letter",
                isMet: viewModel.password.range(of: "[a-z]", options: .regularExpression) != nil
            )
            requirementRow(
                text: "One number",
                isMet: viewModel.password.range(of: "[0-9]", options: .regularExpression) != nil
            )
        }
        .padding(.horizontal, Spacing.base)
        .padding(.vertical, Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.pitchTextAdaptive.opacity(0.05))
        )
    }
    
    private func requirementRow(text: String, isMet: Bool) -> some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 12))
                .foregroundColor(isMet ? .green : .pitchTextAdaptive.opacity(0.3))
            
            Text(text)
                .font(.caption)
                .foregroundColor(.pitchTextAdaptive.opacity(isMet ? 0.7 : 0.5))
        }
    }
    
    // MARK: - Helpers
    
    private func passwordStrengthColor(for index: Int) -> Color {
        let strength = viewModel.passwordStrength
        
        switch strength {
        case .none:
            return Color.gray.opacity(0.2)
        case .weak:
            if index == 0 {
                return .red
            }
            return Color.gray.opacity(0.2)
        case .medium:
            if index <= 1 {
                return .orange
            }
            return Color.gray.opacity(0.2)
        case .strong:
            return .green
        }
    }
    
    private var passwordStrengthTextColor: Color {
        switch viewModel.passwordStrength {
        case .none:
            return .gray
        case .weak:
            return .red
        case .medium:
            return .orange
        case .strong:
            return .green
        }
    }
}

// MARK: - Preview

#Preview {
    SignUpView()
}

