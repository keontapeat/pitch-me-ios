#!/bin/bash

# 🔥 Pitch Me - Secure API Key Setup Script
# Adds your GPT-5.1 API key safely without exposing it

set -e

echo "🔑 Pitch Me - API Key Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_FILE="$PROJECT_DIR/Pitch Me/Secrets.plist"

# Function to read password securely (no echo)
read_password() {
    local prompt="$1"
    local password=""
    
    echo -n "$prompt"
    
    # Turn off echo
    stty -echo
    read password
    stty echo
    echo ""
    
    echo "$password"
}

# Check if Secrets.plist exists
if [ ! -f "$SECRETS_FILE" ]; then
    echo "⚠️  Secrets.plist not found. Creating from template..."
    cp "$PROJECT_DIR/Pitch Me/Secrets.plist.example" "$SECRETS_FILE"
fi

echo "📝 Enter your OpenAI API key (starts with sk-)"
echo "   Get it from: https://platform.openai.com/api-keys"
echo ""

# Read API key securely (no echo in terminal)
API_KEY=$(read_password "🔐 OpenAI API Key: ")

# Validate API key format
if [[ ! "$API_KEY" =~ ^sk- ]]; then
    echo ""
    echo "❌ ERROR: Invalid API key format"
    echo "   OpenAI keys start with 'sk-'"
    echo "   Example: sk-proj-abc123..."
    exit 1
fi

# Check key length (OpenAI keys are typically 48+ chars)
if [ ${#API_KEY} -lt 40 ]; then
    echo ""
    echo "⚠️  WARNING: API key seems too short (${#API_KEY} chars)"
    echo "   OpenAI keys are usually 48+ characters"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Cancelled"
        exit 1
    fi
fi

echo ""
echo "💾 Saving API key to Secrets.plist..."

# Update Secrets.plist with the API key
/usr/libexec/PlistBuddy -c "Set :OPENAI_API_KEY '$API_KEY'" "$SECRETS_FILE" 2>/dev/null || \
/usr/libexec/PlistBuddy -c "Add :OPENAI_API_KEY string '$API_KEY'" "$SECRETS_FILE"

# Optional: Gemini key
echo ""
read -p "🤔 Do you also have a Gemini API key? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    GEMINI_KEY=$(read_password "🔐 Gemini API Key: ")
    
    if [ -n "$GEMINI_KEY" ]; then
        /usr/libexec/PlistBuddy -c "Set :GEMINI_API_KEY '$GEMINI_KEY'" "$SECRETS_FILE" 2>/dev/null || \
        /usr/libexec/PlistBuddy -c "Add :GEMINI_API_KEY string '$GEMINI_KEY'" "$SECRETS_FILE"
        echo "✅ Gemini key added"
    fi
fi

# Ensure Secrets.plist is in .gitignore
GITIGNORE_FILE="$PROJECT_DIR/.gitignore"
if ! grep -q "Secrets.plist" "$GITIGNORE_FILE" 2>/dev/null; then
    echo "Secrets.plist" >> "$GITIGNORE_FILE"
    echo "🔒 Added Secrets.plist to .gitignore"
fi

# Set secure permissions
chmod 600 "$SECRETS_FILE"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ SUCCESS! API key configured"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📁 Location: Pitch Me/Secrets.plist"
echo "🔒 Permissions: 600 (secure)"
echo "🚫 Git Status: Ignored (not committed)"
echo ""
echo "🎯 What's next?"
echo "   1. Open Xcode: open \"Pitch Me.xcodeproj\""
echo "   2. Press ⌘R to run the app"
echo "   3. Your AI features are now enabled! 🔥"
echo ""
echo "💡 Test your API key:"
echo "   The app will automatically load it on launch"
echo "   Check Xcode console for: ✅ API keys loaded from Secrets.plist"
echo ""
echo "🚀 Ready to build elite pitch decks!"
echo ""

