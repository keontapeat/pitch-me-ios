# 🚀 Pitch Me - App Store Submission Checklist

## ✅ Code Ready - COMPLETED

### Info.plist
- [x] `CFBundleDisplayName` - "Pitch Me"
- [x] `MinimumOSVersion` - iOS 17.0
- [x] `NSFaceIDUsageDescription` - Face ID privacy description
- [x] `NSCameraUsageDescription` - Camera privacy description
- [x] `NSPhotoLibraryUsageDescription` - Photo library privacy description
- [x] `NSPhotoLibraryAddUsageDescription` - Save to photos privacy description
- [x] `NSDocumentsFolderUsageDescription` - Documents access privacy description
- [x] `NSAppTransportSecurity` - Properly configured (HTTPS only)
- [x] `UIBackgroundModes` - fetch, processing
- [x] `UILaunchScreen` - Configured with brand color

### App Icon
- [x] 1024x1024 icon in Assets.xcassets/AppIcon.appiconset
- [x] No alpha transparency
- [x] No rounded corners (iOS adds them)

### Subscription/IAP
- [x] Restore Purchases button in PaywallView
- [x] Terms of Service link in PaywallView
- [x] Privacy Policy link in PaywallView
- [x] Debug mode disabled (`debugUnlockAllFeatures = false`)
- [x] Product IDs defined in SubscriptionTier.swift

### Legal Links
- [x] Privacy Policy URL in AppConfig.swift
- [x] Terms of Service URL in AppConfig.swift
- [x] Support URL in AppConfig.swift

---

## ⚠️ BEFORE SUBMISSION - YOU MUST DO THESE

### 1. Create Legal Pages (REQUIRED)
You MUST host these pages before submission:

**Privacy Policy** (https://pitchme.app/privacy)
Must include:
- What data you collect
- How you use Firebase/Firestore
- AI data processing (OpenAI, Anthropic, Google)
- How users can delete their data
- Contact information

**Terms of Service** (https://pitchme.app/terms)
Must include:
- Subscription terms
- Auto-renewal disclosure
- Cancellation policy
- User content rights
- AI usage limitations

### 2. App Store Connect Setup

#### App Information
- [ ] App Name: "Pitch Me - AI Pitch Decks"
- [ ] Subtitle: "Create Investor Decks in Minutes"
- [ ] Primary Category: Business
- [ ] Secondary Category: Productivity
- [ ] Content Rights: Confirm you own all rights

#### Pricing & Availability
- [ ] Price: Free (with IAP)
- [ ] Availability: All territories (or select specific ones)

#### In-App Purchases (Create these in App Store Connect)
| Product ID | Type | Price | Description |
|------------|------|-------|-------------|
| `com.pitchme.pro.monthly` | Auto-Renewable | $9.99/mo | Pro Monthly |
| `com.pitchme.pro.yearly` | Auto-Renewable | $79.00/yr | Pro Yearly |
| `com.pitchme.proplus.monthly` | Auto-Renewable | $29.99/mo | Pro Plus Monthly |
| `com.pitchme.proplus.yearly` | Auto-Renewable | $249.00/yr | Pro Plus Yearly |

#### Screenshots Required
- [ ] 6.7" Display (iPhone 15 Pro Max) - 1290 x 2796 px
- [ ] 6.5" Display (iPhone 14 Plus) - 1284 x 2778 px  
- [ ] 5.5" Display (iPhone 8 Plus) - 1242 x 2208 px
- [ ] 12.9" iPad Pro - 2048 x 2732 px (if supporting iPad)

Recommended screenshots:
1. Deck list view showing created decks
2. Wizard flow / deck creation
3. AI-generated deck preview
4. Export options
5. Paywall / subscription plans

#### App Preview Video (Optional but Recommended)
- 15-30 seconds
- Show deck creation flow
- Highlight AI features

### 3. App Description

**Description (4000 chars max):**
```
Create stunning, investor-ready pitch decks in minutes with Pitch Me – the AI-powered pitch deck creator trusted by founders worldwide.

🚀 PERFECT FOR:
• Y Combinator applications
• NVIDIA Inception program
• Investor meetings (Seed to Series A)
• Demo Day presentations
• Sales decks

✨ KEY FEATURES:
• AI-powered deck generation using GPT-4 and Claude
• 6 deck templates optimized for different purposes
• 20+ professional themes
• Export to PDF, PowerPoint, and Google Slides
• Document upload & AI analysis (Pro)
• Story scoring and feedback (Pro Plus)

💡 HOW IT WORKS:
1. Answer simple questions about your startup
2. Our AI crafts compelling slides
3. Edit, customize, and export
4. Impress investors and win funding

🎯 DECK TYPES:
• Investor Pitch - Raise capital from VCs and angels
• Y Combinator - Stand out in YC's application
• NVIDIA Inception - Join the elite AI program
• Accelerator - Apply to Techstars, 500 Global
• Demo Day - 3-minute stage presentation
• Sales Deck - Win B2B customers

💰 PRICING:
• Free: 1 deck to try it out
• Pro ($9.99/mo): Unlimited decks, document upload, GPT-4
• Pro Plus ($29.99/mo): Elite AI, accelerator templates, story scoring

Start your 7-day free trial today!

Questions? Contact support@pitchme.app
```

**Keywords (100 chars max):**
```
pitch deck,startup,investor,presentation,ai,ycombinator,funding,slides,business plan,accelerator
```

**What's New (for updates):**
```
• Added Y Combinator and NVIDIA Inception deck templates
• Improved AI deck generation
• Bug fixes and performance improvements
```

### 4. Review Guidelines Compliance

#### 3.1.1 In-App Purchase
- [x] All premium features require IAP
- [x] No external payment links
- [x] Restore purchases available
- [x] Clear pricing displayed

#### 3.1.2 Subscriptions  
- [x] Auto-renewal disclosed
- [x] Subscription length stated
- [x] Price clearly shown
- [x] Cancel info provided
- [x] Terms & Privacy links

#### 4.2 Minimum Functionality
- [x] App provides value beyond web wrapper
- [x] Core features work offline (deck viewing)
- [x] AI features work with internet

#### 5.1.1 Data Collection
- [x] Privacy policy explains data use
- [x] Only necessary data collected
- [x] User can delete account

### 5. TestFlight Beta Testing
- [ ] Upload build to TestFlight
- [ ] Add beta testers
- [ ] Test full purchase flow
- [ ] Test restore purchases
- [ ] Test on multiple devices
- [ ] Verify AI features work
- [ ] Check export features

### 6. Final Pre-Submission
- [ ] Archive build in Xcode
- [ ] Upload to App Store Connect
- [ ] Fill in all metadata
- [ ] Submit screenshots
- [ ] Select age rating (4+)
- [ ] Submit for review

---

## 📱 Bundle Identifier
```
com.yourcompany.pitchme
```
(Update in Xcode project settings)

## 🔑 API Keys Checklist
Before release, ensure you have:
- [ ] Firebase project configured (GoogleService-Info.plist)
- [ ] OpenAI API key (in Secrets.plist)
- [ ] Anthropic API key (in Secrets.plist) 
- [ ] RevenueCat API key configured

---

## 🎉 Ready to Submit!

Once you've completed all items above:

1. **Archive** your app in Xcode (Product → Archive)
2. **Distribute** to App Store Connect
3. **Complete** all App Store Connect fields
4. **Submit** for review

Expected review time: 24-48 hours

Good luck! 🚀

