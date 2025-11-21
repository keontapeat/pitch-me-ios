//
//  InputField.swift
//  Pitch Me
//
//  Reusable input components
//

import SwiftUI

// MARK: - Text Input Field

struct InputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isRequired: Bool = true
    var minLines: Int = 1
    var maxLines: Int = 5
    var icon: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Label with icon
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
            
            // Text field
            TextField(placeholder, text: $text, axis: .vertical)
                .font(Typography.bodyLarge)
                .foregroundColor(.pitchTextAdaptive)
                .padding(Spacing.md)
                .background(Color.pitchCardBackgroundAdaptive)
                .cornerRadius(Spacing.cardCornerRadius)
                .lineLimit(minLines...maxLines)
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.cardCornerRadius)
                        .stroke(text.isEmpty && isRequired ? Color.pitchError.opacity(0.3) : Color.clear, lineWidth: 1)
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
            HStack(spacing: Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(.pitchCharcoal)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                }
                
                Text(title)
                    .font(Typography.labelLarge)
                    .fontWeight(.bold)
            }
            .foregroundColor(.pitchCharcoal)
            .frame(maxWidth: .infinity)
            .frame(height: Spacing.buttonHeight)
            .background(isDisabled ? Color.gray : Color.pitchLime)
            .cornerRadius(Spacing.buttonCornerRadius)
            .shadow(color: isDisabled ? Color.clear : Color.pitchLime.opacity(0.3), radius: 12, x: 0, y: 4)
        }
        .disabled(isDisabled || isLoading)
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
            HStack(spacing: Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
                
                Text(title)
                    .font(Typography.labelLarge)
            }
            .foregroundColor(.pitchTextAdaptive)
            .frame(maxWidth: .infinity)
            .frame(height: Spacing.buttonHeight)
            .background(Color.pitchCardBackgroundAdaptive)
            .cornerRadius(Spacing.buttonCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.buttonCornerRadius)
                    .stroke(Color.pitchDivider, lineWidth: 1)
            )
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.base) {
        InputField(
            label: "Startup Name",
            placeholder: "e.g., Acme Inc",
            text: .constant(""),
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

