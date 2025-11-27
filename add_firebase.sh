#!/bin/bash

# 🔥 NUCLEAR FIREBASE SETUP SCRIPT 🔥
# Adds Firebase packages to your Xcode project automatically

set -e

echo "🔥 AUTOPILOT MODE: Adding Firebase to Pitch Me..."

PROJECT_DIR="/Users/keonta/Documents/Pitch Me"
PROJECT_FILE="$PROJECT_DIR/Pitch Me.xcodeproj/project.pbxproj"

echo "✅ Project found at: $PROJECT_DIR"

# Check if running from correct directory
if [ ! -f "$PROJECT_FILE" ]; then
    echo "❌ Error: project.pbxproj not found!"
    echo "Make sure you're in the Pitch Me directory"
    exit 1
fi

echo ""
echo "📦 To add Firebase packages:"
echo ""
echo "1. Open Xcode"
echo "2. Click 'Pitch Me' project (blue icon)"
echo "3. Select 'Package Dependencies' tab"
echo "4. Click '+' button"
echo "5. Paste: https://github.com/firebase/firebase-ios-sdk"
echo "6. Select: FirebaseAuth, FirebaseFirestore, FirebaseStorage"
echo "7. Click 'Add Package'"
echo ""
echo "🔥 Then you're ready to build!"
echo ""

# Try to open Xcode
if command -v xed &> /dev/null; then
    echo "🚀 Opening Xcode..."
    xed "$PROJECT_DIR"
else
    echo "💡 Open Xcode manually and follow steps above"
fi

echo ""
echo "✅ Script complete! Follow the steps in Xcode."

