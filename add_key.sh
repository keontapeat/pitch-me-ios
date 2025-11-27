#!/bin/bash

# 🔥 Simple API Key Setup - Just Works

clear
echo ""
echo "🔑 Pitch Me - Add Your OpenAI API Key"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Get your key: https://platform.openai.com/api-keys"
echo ""
echo "📋 Just paste your API key below and press Enter"
echo ""
read -p "API Key: " API_KEY

# Trim whitespace
API_KEY=$(echo "$API_KEY" | xargs)

# Check if empty
if [ -z "$API_KEY" ]; then
    echo ""
    echo "❌ No key entered. Try again!"
    exit 1
fi

# Basic validation
if [[ ! "$API_KEY" =~ ^sk- ]]; then
    echo ""
    echo "⚠️  Key doesn't start with 'sk-' but saving anyway..."
fi

# Save to Secrets.plist
PLIST="Pitch Me/Secrets.plist"

echo ""
echo "💾 Saving..."

# Update or add the key
/usr/libexec/PlistBuddy -c "Set :OPENAI_API_KEY '$API_KEY'" "$PLIST" 2>/dev/null
if [ $? -ne 0 ]; then
    /usr/libexec/PlistBuddy -c "Add :OPENAI_API_KEY string '$API_KEY'" "$PLIST" 2>/dev/null
fi

# Secure the file
chmod 600 "$PLIST"

# Make sure it's in gitignore
if ! grep -q "Secrets.plist" ".gitignore" 2>/dev/null; then
    echo "Secrets.plist" >> ".gitignore"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ SUCCESS!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📁 Saved to: Pitch Me/Secrets.plist"
echo "🔒 Secure: ✓"
echo "🚫 Git Ignored: ✓"
echo ""
echo "🚀 Now open Xcode and run your app!"
echo "   open \"Pitch Me.xcodeproj\""
echo ""

