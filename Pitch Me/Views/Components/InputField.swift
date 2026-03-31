//
//  InputField.swift
//  Pitch Me
//
//  Reusable input components
//

import SwiftUI

// MARK: - Text Input Field

struct InputField: View {
    @Binding var text: String
    let placeholder: String
    var label: String? = nil
    var icon: String? = nil
    var isRequired: Bool = false
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var autocapitalization: TextInputAutocapitalization = .sentences
    var minLines: Int = 1
    var maxLines: Int = 5
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Optional label with icon
            if let label = label {
                HStack(spacing: Spacing.xs) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.caption)
                            .foregroundColor(.pitchLime)
                    }
                    
                    Text(label)
                        .font(Typography.labelMedium)
                        .foregroundColor(.pitchTextSecondary)
                    
                    if isRequired {
                        Text("*")
                            .font(Typography.labelMedium)
                            .foregroundColor(.pitchError)
                    }
                }
            }
            
            // Text field or secure field
            HStack(spacing: Spacing.sm) {
                if let icon = icon, label == nil {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.pitchTextAdaptive.opacity(0.4))
                        .frame(width: 20)
                }
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(Typography.bodyLarge)
                        .foregroundColor(.pitchTextAdaptive)
                        .textContentType(textContentType)
                        .textInputAutocapitalization(autocapitalization)
                } else {
                    TextField(placeholder, text: $text, axis: .vertical)
                        .font(Typography.bodyLarge)
                        .foregroundColor(.pitchTextAdaptive)
                        .keyboardType(keyboardType)
                        .textContentType(textContentType)
                        .textInputAutocapitalization(autocapitalization)
                        .lineLimit(minLines...maxLines)
                }
            }
            .padding(Spacing.md)
            .background(Color.pitchCardBackgroundAdaptive)
            .cornerRadius(Spacing.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.cardCornerRadius)
                    .stroke(text.isEmpty && isRequired ? Color.pitchError.opacity(0.3) : Color.pitchTextAdaptive.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

// MARK: - Text Editor Field

struct TextEditorField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isRequired: Bool = true
    var minHeight: CGFloat = 120
    var icon: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Label
            HStack(spacing: Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundColor(.pitchLime)
                }
                
                Text(label)
                    .font(Typography.labelMedium)
                    .foregroundColor(.pitchTextSecondary)
                
                if isRequired {
                    Text("*")
                        .font(Typography.labelMedium)
                        .foregroundColor(.pitchError)
                }
            }
            
            // Editor
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(Typography.bodyLarge)
                        .foregroundColor(.pitchTextTertiary)
                        .padding(Spacing.md)
                        .padding(.top, 8)
                }
                
                TextEditor(text: $text)
                    .font(Typography.bodyLarge)
                    .foregroundColor(.pitchTextAdaptive)
                    .padding(Spacing.sm)
                    .scrollContentBackground(.hidden)
                    .background(Color.pitchCardBackgroundAdaptive)
                    .cornerRadius(Spacing.cardCornerRadius)
                    .frame(minHeight: minHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: Spacing.cardCornerRadius)
                            .stroke(text.isEmpty && isRequired ? Color.pitchError.opacity(0.3) : Color.pitchDivider, lineWidth: 1)
                    )
            }
        }
    }
}

// MARK: - Primary Button

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    
    init(_ title: String, icon: String? = nil, isLoading: Bool = false, isDisabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(.pitchCharcoal)
                } else {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                    
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .foregroundColor(.pitchCharcoal)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isDisabled ? Color.gray.opacity(0.3) : Color.pitchLime)
                    .shadow(color: isDisabled ? .clear : Color.pitchLime.opacity(0.4), radius: 16, x: 0, y: 4)
            )
        }
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

// MARK: - Secondary Button

struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
                
                Text(title)
                    .font(.system(size: 17, weight: .medium))
            }
            .foregroundColor(.pitchTextAdaptive)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.pitchCardBackgroundAdaptive)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.pitchDivider, lineWidth: 1)
            )
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.base) {
        InputField(
            text: .constant(""),
            placeholder: "e.g., Acme Inc",
            label: "Startup Name",
            icon: "building.2.fill"
        )
        
        TextEditorField(
            label: "Problem Description",
            placeholder: "Describe the problem you're solving...",
            text: .constant(""),
            icon: "exclamationmark.triangle.fill"
        )
        
        PrimaryButton("Continue", icon: "arrow.right") {}
        
        SecondaryButton("Back", icon: "arrow.left") {}
    }
    .padding()
    .background(Color.pitchBackgroundAdaptive)
}

