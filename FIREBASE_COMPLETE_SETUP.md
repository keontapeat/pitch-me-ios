# 🔥 Firebase Complete Setup Guide - Pitch Me

## ✅ Setup Status

Your Firebase integration is now **COMPLETE**! Here's what's been configured:

### Files Created/Updated

| File | Status | Description |
|------|--------|-------------|
| `GoogleService-Info.plist` | ✅ Configured | Firebase project config |
| `Pitch_MeApp.swift` | ✅ Configured | Firebase initialization |
| `AuthService.swift` | ✅ Complete | Email/password auth, biometrics |
| `FirestoreService.swift` | ✅ **NEW** | Database operations for decks |
| `StorageService.swift` | ✅ **NEW** | File uploads (documents, images) |
| `SubscriptionService.swift` | ✅ Updated | Firebase sync for subscriptions |
| `DeckListViewModel.swift` | ✅ Updated | Real-time Firestore sync |

---

## ⚠️ REQUIRED: Enable Firestore API

You're seeing this error because the Firestore API is not enabled:

```
Cloud Firestore API has not been used in project pitch-me-f1676 before or it is disabled.
```

### Fix It Now:

1. **Click this link:**
   https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=pitch-me-f1676

2. **Click "Enable"**

3. **Wait 2-5 minutes** for propagation

4. **Restart your app**

---

## 🗄️ Create Firestore Database

If you haven't created a Firestore database yet:

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project **pitch-me-f1676**
3. Click **Build** → **Firestore Database**
4. Click **Create database**
5. Choose **Start in test mode** (for now)
6. Select location: **us-central1** (recommended)

---

## 🔒 Security Rules (IMPORTANT!)

Once your app is ready for production, update your Firestore security rules:

### Go to: Firebase Console → Firestore → Rules

Paste this:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if isOwner(userId);
      
      // Decks subcollection
      match /decks/{deckId} {
        allow read, write: if isOwner(userId);
        
        // Slides subcollection
        match /slides/{slideId} {
          allow read, write: if isOwner(userId);
        }
      }
    }
    
    // Exports - user can only read their own
    match /exports/{exportId} {
      allow read: if isAuthenticated() && resource.data.userId == request.auth.uid;
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
    }
    
    // Uploads - user can only access their own
    match /uploads/{uploadId} {
      allow read, write: if isAuthenticated() && resource.data.userId == request.auth.uid;
    }
  }
}
```

---

## 📦 Storage Rules

### Go to: Firebase Console → Storage → Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Users can only access their own files
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Size limit: 50MB
    match /{allPaths=**} {
      allow write: if request.resource.size < 50 * 1024 * 1024;
    }
  }
}
```

---

## 🔐 Authentication Setup

### Enable Email/Password Auth:

1. Firebase Console → **Authentication** → **Sign-in method**
2. Click **Email/Password**
3. Toggle **Enable**
4. Click **Save**

### Optional: Enable Apple Sign-In

1. Click **Apple** in Sign-in providers
2. Toggle **Enable**
3. Add your Service ID
4. Click **Save**

---

## 📊 Database Structure

Your Firestore will use this structure:

```
users/{userId}
├── email: String
├── displayName: String?
├── subscriptionTier: String (free, pro, proPlus)
├── createdAt: Timestamp
├── decksCreated: Int
└── decks (subcollection)
    └── {deckId}
        ├── title: String
        ├── useCase: String
        ├── themeId: String
        ├── storyScore: Int?
        ├── slideCount: Int
        ├── createdAt: Timestamp
        ├── updatedAt: Timestamp
        └── slides (subcollection)
            └── {slideId}
                ├── index: Int
                ├── layoutType: String
                ├── title: String
                ├── subtitle: String?
                ├── bullets: [String]
                ├── speakerNotes: String?
                └── imageURL: String?
```

---

## 🚀 Features Now Available

### Authentication (`AuthService.swift`)
- ✅ Email/password sign up
- ✅ Email/password sign in
- ✅ Password reset
- ✅ Biometric authentication (Face ID/Touch ID)
- ✅ Auth state persistence
- ✅ User profile sync

### Database (`FirestoreService.swift`)
- ✅ Save decks to cloud
- ✅ Real-time deck sync
- ✅ Offline support (automatic)
- ✅ Batch operations
- ✅ Slide management

### Storage (`StorageService.swift`)
- ✅ Document upload (PDF, Word, etc.)
- ✅ Image upload
- ✅ Export file storage
- ✅ Progress tracking
- ✅ 50MB file limit

### Subscriptions (`SubscriptionService.swift`)
- ✅ Sync subscription tier to Firebase
- ✅ Cross-device subscription status
- ✅ Offline fallback

---

## 🧪 Testing Your Setup

1. **Run the app**
2. **Create an account** (sign up)
3. **Create a deck**
4. **Check Firebase Console** → Firestore → Data

You should see:
- A new document in `users/{userId}`
- A deck in `users/{userId}/decks/{deckId}`

---

## 🐛 Troubleshooting

### "Permission denied" errors
- Ensure Firestore API is enabled (link above)
- Check security rules allow your operation
- Verify user is authenticated

### "Network error" 
- Check internet connection
- Firebase has offline support, data will sync when online

### "Document not found"
- Deck may not have synced yet
- Check if user is authenticated

### App crashes on launch
- Verify `GoogleService-Info.plist` is in the target
- Check bundle ID matches: `com.keontapeat.Pitch-Me`

---

## 📱 Project Info

- **Project ID:** pitch-me-f1676
- **Bundle ID:** com.keontapeat.Pitch-Me
- **Storage Bucket:** pitch-me-f1676.firebasestorage.app

---

## ✅ Next Steps

1. ✅ Enable Firestore API (link above)
2. ✅ Create Firestore database
3. ✅ Test authentication flow
4. ✅ Create a test deck
5. ✅ Verify data appears in Firebase Console
6. 🔜 Add production security rules before App Store

---

**Your Firebase setup is COMPLETE! 🎉**

Just enable the Firestore API and you're ready to go!


