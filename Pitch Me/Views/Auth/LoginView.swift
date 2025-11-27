//
//  LoginView.swift
//  Pitch Me
//
//  🔥 NUCLEAR Login View - Beautiful, smooth, powerful
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showSignUp = false
    @State private var showResetPassword = false
    
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
                            
                            // Password field
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                InputField(
                                    text: $viewModel.password,
                                    placeholder: "Password",
                                    icon: "lock.fill",
                                    isSecure: true,
                                    textContentType: .password
                                )
                                
                                if let passwordError = viewModel.passwordError {
                                    Text(passwordError)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.leading, Spacing.base)
                                        .transition(.opacity)
                                }
                            }
                            
                            // Forgot password
                            HStack {
                                Spacer()
                                Button {
                                    showResetPassword = true
                                } label: {
                                    Text("Forgot password?")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.pitchTextAdaptive.opacity(0.6))
                                }
                            }
                            .padding(.horizontal, Spacing.base)
                            
                            // Sign in button
                            Button {
                                Task {
                                    await viewModel.signIn()
                                }
                            } label: {
                                HStack {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Sign In")
                                            .font(.system(size: 17, weight: .semibold))
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(viewModel.canSignIn ? Color.pitchTextAdaptive : Color.pitchTextAdaptive.opacity(0.2))
                                )
                            }
                            .disabled(!viewModel.canSignIn || viewModel.isLoading)
                            .padding(.top, Spacing.base)
                            
                            // Biometric auth (if available)
                            if viewModel.canUseBiometrics {
                                biometricButton
                            }
                            
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
                            
                            // Sign up link
                            Button {
                                showSignUp = true
                            } label: {
                                HStack(spacing: 4) {
                                    Text("Don't have an account?")
                                        .foregroundColor(.pitchTextAdaptive.opacity(0.5))
                                    Text("Sign Up")
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
            .fullScreenCover(isPresented: $showSignUp) {
                SignUpView()
            }
            .sheet(isPresented: $showResetPassword) {
                ResetPasswordView(email: viewModel.email)
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: Spacing.lg) {
            VStack(spacing: Spacing.xs) {
                Text("Welcome Back")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(.pitchTextAdaptive)
                
                Text("Sign in to continue")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.pitchTextAdaptive.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.bottom, Spacing.base)
    }
    
    // MARK: - Biometric Button
    
    private var biometricButton: some View {
        Button {
            Task {
                await viewModel.signInWithBiometrics()
            }
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "faceid")
                    .font(.system(size: 20, weight: .semibold))
                
                Text("Sign in with Face ID")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.pitchTextAdaptive)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.pitchTextAdaptive.opacity(0.2), lineWidth: 1.5)
            )
        }
    }
}

// MARK: - Reset Password View

struct ResetPasswordView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    let email: String
    
    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xl) {
                // Header
                VStack(spacing: Spacing.base) {
                    VStack(spacing: Spacing.xs) {
                        Text("Reset Password")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.pitchTextAdaptive)
                        
                        Text("Enter your email to receive a reset link")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.pitchTextAdaptive.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, Spacing.xxxl)
                
                // Email field
                VStack(spacing: Spacing.base) {
                    InputField(
                        text: $viewModel.email,
                        placeholder: "Email",
                        icon: "envelope.fill",
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress,
                        autocapitalization: .never
                    )
                    
                    Button {
                        Task {
                            await viewModel.resetPassword()
                            dismiss()
                        }
                    } label: {
                        Text("Send Reset Link")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(viewModel.isValidEmail ? Color.pitchTextAdaptive : Color.pitchTextAdaptive.opacity(0.2))
                            )
                    }
                    .disabled(!viewModel.isValidEmail || viewModel.isLoading)
                }
                .padding(.horizontal, Spacing.xl)
                
                Spacer()
            }
            .background(Color.pitchBackgroundAdaptive.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.pitchTextAdaptive)
                }
            }
        }
        .onAppear {
            viewModel.email = email
        }
    }
}

// MARK: - Preview

#Preview {
    LoginView()
}

