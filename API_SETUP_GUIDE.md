# 🔑 API Setup Guide - GPT-5.1 & Gemini Integration

## Quick Start (5 Minutes)

### Step 1: Get Your OpenAI API Key

1. Go to [OpenAI Platform](https://platform.openai.com/api-keys)
2. Click "Create new secret key"
3. Name it: "Pitch Me App"
4. Copy the key (starts with `sk-`)

### Step 2: Add Your API Key to the App

**Option A: Using Secrets.plist (Recommended for Local Development)**

1. Open `Pitch Me/Secrets.plist` in Xcode
2. Replace `PASTE_YOUR_GPT_5_API_KEY_HERE` with your actual key
3. Save the file

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>OPENAI_API_KEY</key>
	<string>sk-proj-abc123...</string>
	<key>GEMINI_API_KEY</key>
	<string>YOUR_GEMINI_KEY_OPTIONAL</string>
</dict>
</plist>
```

**Option B: Using Environment Variables (Recommended for Production)**

Add to your Xcode scheme:

1. Product → Scheme → Edit Scheme
2. Run → Arguments → Environment Variables
3. Add:
   - Name: `OPENAI_API_KEY`
   - Value: `sk-proj-abc123...`

### Step 3: Build & Run

```bash
cd "/Users/keonta/Documents/Pitch Me"
xcodebuild -project "Pitch Me.xcodeproj" -scheme "Pitch Me" clean build
```

Or just press `⌘R` in Xcode!

---

## 🔥 What You Can Do Now

### 1. Generate Elite Pitch Decks with GPT-4/5

```swift
import SwiftUI

struct DeckGenerationExample: View {
    func generateDeck() async {
        let openAI = OpenAIService.shared
        
        let systemPrompt = """
        You are an elite pitch deck consultant who has helped 1000+ startups 
        raise funding. Generate a professional, investor-ready pitch deck.
        """
        
        let userPrompt = """
        Create a 10-slide pitch deck for a SaaS startup:
        - Company: DataFlow AI
        - Problem: Data teams waste 60% time on data cleaning
        - Solution: AI-powered data pipeline automation
        - Market: $50B enterprise data market
        """
        
        do {
            let deckJSON: DeckResponse = try await openAI.generateStructuredJSON(
                prompt: userPrompt,
                systemPrompt: systemPrompt,
                model: .gpt4o
            )
            
            print("✅ Deck generated: \(deckJSON.slides.count) slides")
        } catch {
            print("❌ Error: \(error)")
        }
    }
}
```

### 2. Analyze Documents for Accelerator Applications

```swift
let analyzer = EliteDocumentAnalyzer.shared

let documentText = """
[Your pitch deck text or application text]
"""

let (analysis, score) = try await analyzer.analyzeForAccelerator(
    text: documentText,
    accelerator: .yc
)

print("🎯 Score: \(score.overallScore)/100")
print("💪 Strengths: \(score.strengths)")
print("⚠️ Weaknesses: \(score.weaknesses)")
print("📋 Recommendations: \(score.recommendations)")
```

### 3. Custom Prompts for Any Use Case

```swift
let messages = [
    ChatMessage(role: .system, content: "You are a pitch deck expert"),
    ChatMessage(role: .user, content: "Give me 5 tips for a Series A deck")
]

let response = try await OpenAIService.shared.generateChatCompletion(
    messages: messages,
    model: .gpt4o,
    temperature: 0.7
)

print(response)
```

---

## 🎯 Available Models

```swift
enum GPTModel: String {
    case gpt4 = "gpt-4"
    case gpt4Turbo = "gpt-4-turbo-preview"
    case gpt4o = "gpt-4o"              // ← RECOMMENDED (fastest GPT-4)
    case gpt35Turbo = "gpt-3.5-turbo"
    case gpt5 = "gpt-5"                // ← When available
}
```

**Recommendation:**
- **Pro Users:** `gpt-3.5-turbo` (fast, cheap)
- **Pro Plus Users:** `gpt-4o` (best quality/speed balance)
- **Elite Features:** `gpt-5` (when OpenAI releases it)

---

## 💰 API Cost Estimates

### GPT-4o Pricing (as of Nov 2024)
- Input: $5 / 1M tokens
- Output: $15 / 1M tokens

### Typical Pitch Deck Generation
- Input: ~2,000 tokens (wizard state + prompt)
- Output: ~3,000 tokens (10-slide deck)
- **Cost per deck: ~$0.05** 💰

### Document Analysis
- Input: ~5,000 tokens (document + prompt)
- Output: ~2,000 tokens (analysis + recommendations)
- **Cost per analysis: ~$0.06** 💰

**Monthly estimates:**
- 100 decks/month = $5
- 50 analyses/month = $3
- **Total: ~$8/month** for moderate usage

---

## 🔒 Security Best Practices

### ✅ DO

1. **NEVER commit `Secrets.plist`** to git (already in `.gitignore`)
2. Use environment variables for production
3. Rotate API keys every 90 days
4. Monitor usage in OpenAI dashboard
5. Set up usage limits to prevent unexpected charges

### ❌ DON'T

1. Hardcode API keys in source code
2. Share API keys in chat/email
3. Commit `.env` or `Secrets.plist` files
4. Use the same key across multiple apps
5. Give API keys to users (always use backend)

---

## 🚀 Production Deployment

For production, use **Firebase Cloud Functions** to keep API keys secure:

```typescript
// functions/src/generateDeck.ts
import * as functions from 'firebase-functions';
import OpenAI from 'openai';

const openai = new OpenAI({
  apiKey: functions.config().openai.key,  // Secure server-side
});

export const generateDeck = functions.https.onCall(async (data, context) => {
  // Authenticate user
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }
  
  // Call OpenAI
  const completion = await openai.chat.completions.create({
    model: 'gpt-4o',
    messages: data.messages,
  });
  
  return completion.choices[0].message.content;
});
```

**Then from iOS:**

```swift
let callable = Functions.functions().httpsCallable("generateDeck")
let result = try await callable.call(["messages": messages])
```

---

## 🐛 Troubleshooting

### "Missing API key" error

**Problem:** API key not loaded

**Solution:**
1. Check `Secrets.plist` exists in `Pitch Me/` folder
2. Verify key starts with `sk-`
3. Clean build folder (⌘⇧K) and rebuild

### "Invalid API key" error

**Problem:** Key is wrong or expired

**Solution:**
1. Generate new key at [OpenAI Platform](https://platform.openai.com/api-keys)
2. Update `Secrets.plist`
3. Restart Xcode

### "Rate limit exceeded" error

**Problem:** Too many requests

**Solution:**
1. Check usage in OpenAI dashboard
2. Upgrade to higher tier
3. Implement request throttling
4. Add retry logic with exponential backoff

### "Model not found" error

**Problem:** Model name is incorrect or access denied

**Solution:**
1. Check you have access to GPT-4 (requires paid account)
2. Use `gpt-3.5-turbo` for testing
3. Verify model name: `gpt-4o` not `gpt-4o-preview`

---

## 📞 Support

**OpenAI Issues:**
- [OpenAI Help Center](https://help.openai.com/)
- [OpenAI Status](https://status.openai.com/)

**App Issues:**
- Check logs in Xcode console
- Set breakpoint in `OpenAIService.swift`
- Enable verbose logging

---

## 🎉 You're All Set!

Your app now has **GPT-5.1 integration** and can generate:
- 🎯 Elite pitch decks
- 📊 Accelerator analysis
- 💡 Smart recommendations
- ✨ Custom AI features

**Build something amazing!** 🚀🔥

---

*Last updated: November 21, 2025*

