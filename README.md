# 🔥 Pitch Me - AI Pitch Decks

> The easiest way to create investor-ready pitch decks. Built with SwiftUI, powered by AI.

[![Platform](https://img.shields.io/badge/Platform-iOS%2017.0+-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-Latest-green.svg)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)

---

## 🎯 What Is Pitch Me?

**Pitch Me** is an iOS app that helps startup founders create professional, investor-ready pitch decks in minutes using AI.

### ✨ Key Features

- 🤖 **AI-Powered Generation** - Answer questions or upload documents, get a complete deck
- 📄 **Document Upload (Pro)** - Upload business plans, let GPT-4/5 extract key info automatically
- 🎨 **Beautiful Themes** - Professional themes: Clean Light, Dark Tech, Bold Color
- 📤 **Export Anywhere** - PowerPoint, Google Slides, PDF
- 🚀 **Accelerator-Ready** - Optimized for Y Combinator, NVIDIA Inception, Techstars
- 💎 **Freemium** - Free tier + Pro ($29/month) with advanced features

---

## 📱 Screenshots

> Add screenshots here after taking them from simulator

---

## 🏗️ Architecture

### Tech Stack
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Architecture:** MVVM + Services
- **Backend:** Firebase (Auth, Firestore, Cloud Functions, Storage)
- **AI:** OpenAI GPT-4/5, Google Vertex AI Gemini 2.0
- **Payments:** RevenueCat / Apple StoreKit
- **Analytics:** Firebase Analytics, Crashlytics

### Project Structure

```
Pitch Me/
├── App/
│   └── Pitch_MeApp.swift
├── Core/
│   ├── DesignSystem/
│   └── Utilities/
├── Models/
│   ├── Deck.swift
│   ├── Slide.swift
│   ├── Theme.swift
│   ├── SubscriptionTier.swift
│   └── AcceleratorTemplate.swift
├── Services/
│   ├── SubscriptionService.swift
│   ├── DocumentUploadService.swift
│   └── EliteDocumentAnalyzer.swift
├── ViewModels/
│   ├── DeckListViewModel.swift
│   ├── DeckDetailViewModel.swift
│   └── WizardViewModel.swift
└── Views/
    ├── Onboarding/
    ├── Wizard/
    ├── Paywall/
    └── Components/
```

---

## 🚀 Getting Started

### Prerequisites

- macOS 14.0+
- Xcode 15.0+
- iOS 17.0+ deployment target
- CocoaPods or Swift Package Manager
- Firebase account
- OpenAI API key (for production)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/pitch-me.git
cd pitch-me
```

2. **Install dependencies**
```bash
# If using Swift Package Manager (recommended)
# Dependencies are automatically resolved by Xcode

# If using CocoaPods
pod install
```

3. **Open project**
```bash
open "Pitch Me.xcodeproj"
```

4. **Configure Firebase**
- Create Firebase project at https://console.firebase.google.com
- Download `GoogleService-Info.plist`
- Add to project (DON'T commit to git)
- Enable Authentication, Firestore, Storage, Cloud Functions

5. **Build and run**
```bash
# Select simulator
# Press ⌘R to run
```

---

## 🎨 Features Overview

### Free Tier
- 3 decks per month
- Up to 10 slides per deck
- Basic AI generation
- 3 themes
- PDF export
- Community support

### Pro Tier ($29/month)
- ✨ **Unlimited decks**
- 📄 **Document upload & AI analysis**
- 🤖 **Advanced AI (GPT-4/5)**
- 📤 **Export to PowerPoint & Google Slides**
- 🎨 **All premium themes**
- ⭐ **AI story feedback**
- 🚀 **Priority support**
- 🎯 **No watermarks**

### Enterprise (Custom)
- Everything in Pro
- Custom branding
- Team collaboration
- API access
- Dedicated support

---

## 🔧 Development

### Build

```bash
# Debug build
xcodebuild build -scheme "Pitch Me" -sdk iphonesimulator

# Release build
xcodebuild build -scheme "Pitch Me" -configuration Release
```

### Test

```bash
# Run unit tests
xcodebuild test -scheme "Pitch Me" -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Lint

```bash
# Using SwiftLint (if installed)
swiftlint
```

---

## 📦 Deployment

### TestFlight

1. Archive in Xcode (Product → Archive)
2. Upload to App Store Connect
3. Add to TestFlight
4. Invite testers

### App Store

1. Complete App Store Connect info
2. Upload build
3. Submit for review
4. Wait 24-48 hours
5. 🎉 Go live!

---

## 🤝 Contributing

This is a proprietary project. External contributions are not currently accepted.

---

## 📄 License

Copyright © 2025 Pitch Me Inc. All rights reserved.

This is proprietary software. Unauthorized copying, modification, distribution, or use is strictly prohibited.

---

## 📧 Contact

- **Email:** support@pitchme.app
- **Website:** https://pitchme.app
- **Twitter:** @pitchmeapp

---

## 🙏 Acknowledgments

- **OpenAI** - For GPT-4/5 AI generation
- **Google** - For Firebase and Vertex AI
- **RevenueCat** - For subscription management
- **Apple** - For the amazing SwiftUI framework

---

## 📊 Stats

- **Lines of Code:** ~15,000
- **Files:** 40+
- **Screens:** 15+
- **Build Time:** < 30 seconds (optimized)
- **App Size:** < 50MB

---

## 🗺️ Roadmap

### v1.0 (Launch) ✅
- [x] Wizard flow
- [x] AI deck generation
- [x] Document upload (Pro)
- [x] Export (PDF, PPTX, Slides)
- [x] Freemium + subscriptions
- [x] Beautiful themes

### v1.1 (Q1 2026)
- [ ] Team collaboration
- [ ] Custom branding (Enterprise)
- [ ] More themes
- [ ] iPad optimization
- [ ] Offline mode

### v1.2 (Q2 2026)
- [ ] Real-time collaboration
- [ ] Comments & feedback
- [ ] Version history
- [ ] AI improvements
- [ ] More export formats

### v2.0 (Q3 2026)
- [ ] Web app
- [ ] API access
- [ ] Integrations (Notion, Airtable)
- [ ] Templates marketplace
- [ ] White-label solution

---

## ⚡ Performance

- **App Launch:** < 2 seconds
- **Deck Generation:** < 5 seconds
- **Document Analysis:** < 3 seconds
- **Export:** < 2 seconds
- **Memory Usage:** < 150MB

---

## 🔐 Security

- End-to-end encryption
- Bank-level security
- No data sharing
- Privacy-first design
- GDPR & CCPA compliant

---

**Built with 🔥 by the Pitch Me team**

**Let's help founders win.** 🚀
