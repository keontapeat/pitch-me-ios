# 🚀 Getting Started with Pitch Me

Welcome! You now have a **rock-solid foundation** for the best pitch deck app in the world. Here's everything you need to know.

---

## ✅ What's Ready RIGHT NOW

### 1️⃣ **Beautiful Design System**
Your app has a premium Apple-quality design system that's ready to use:

```swift
// Use brand colors anywhere
Color.pitchLime           // Neon lime accent
Color.pitchCharcoal       // Dark charcoal
Color.pitchBackgroundAdaptive  // Auto light/dark

// Typography helpers
Text("Title").titleLarge()
Text("Body").bodyLarge()

// Spacing tokens
.padding(Spacing.base)    // 16pt
.cornerRadius(Spacing.cardCornerRadius)  // 12pt
.cardShadow()             // Consistent shadow
```

### 2️⃣ **Complete Data Models**
All models are `Codable` and ready for API integration:

```swift
// Create a deck
let deck = Deck(
    userId: "user-123",
    title: "My Startup Pitch",
    useCase: .investor,
    themeId: Theme.cleanLight.id
)

// Add slides
deck.addSlide(Slide(
    deckId: deck.id,
    index: 0,
    layoutType: .titleBullets,
    title: "The Problem",
    bullets: ["Point 1", "Point 2"]
))

// Change themes
deck.themeId = Theme.darkTech.id
```

### 3️⃣ **Working iOS App**
Open the project and you'll see:

- **Deck List** with 3 sample decks
- **Search** functionality
- **Context menus** (long-press to duplicate/delete)
- **Deck editor** with slide carousel
- **Live editing** of titles, bullets, speaker notes
- **Theme picker** with visual previews
- **Export options** (UI ready, needs backend)

### 4️⃣ **SwiftUI Previews**
Every view has previews. Open any view file and press **⌘⌥P**:

```swift
#Preview("Deck List with Decks") {
    DeckListView()
}

#Preview("Deck Card") {
    DeckCardView(deck: .sampleInvestorDeck)
}
```

---

## 🎯 Your Next Mission: Build the Wizard

The **#1 priority** is the wizard flow – the heart of the user experience.

### Step 1: Create Wizard State Model

Create `PitchMe/Models/WizardState.swift`:

```swift
struct WizardState: Codable {
    // Step 1: Basics
    var startupName: String = ""
    var oneLiner: String = ""
    var stage: StartupStage = .idea
    
    // Step 2: Problem
    var targetUser: String = ""
    var problem: String = ""
    
    // Step 3: Solution
    var solution: String = ""
    var whyNow: String = ""
    
    // Step 4: Market
    var marketSize: String = ""
    var businessModel: String = ""
    
    // Step 5: Traction
    var traction: String = ""
    var team: String = ""
    
    // Step 6: Config
    var useCase: DeckUseCase = .investor
    var preferredTheme: String = Theme.default.id
    
    // Progress tracking
    var currentStep: Int = 0
    var isComplete: Bool = false
}

enum StartupStage: String, Codable, CaseIterable {
    case idea = "Idea Stage"
    case mvp = "MVP Built"
    case revenue = "Generating Revenue"
    case growth = "Growth Stage"
}
```

### Step 2: Create Wizard ViewModel

Create `PitchMe/ViewModels/WizardViewModel.swift`:

```swift
@MainActor
final class WizardViewModel: ObservableObject {
    @Published var state = WizardState()
    @Published var isGenerating = false
    @Published var generatedDeck: Deck?
    @Published var errorMessage: String?
    
    let totalSteps = 7
    
    var progress: Double {
        Double(state.currentStep) / Double(totalSteps)
    }
    
    var canGoBack: Bool {
        state.currentStep > 0
    }
    
    var canGoForward: Bool {
        // Add validation per step
        true
    }
    
    func goToNextStep() {
        guard state.currentStep < totalSteps else { return }
        withAnimation {
            state.currentStep += 1
        }
    }
    
    func goToPreviousStep() {
        guard canGoBack else { return }
        withAnimation {
            state.currentStep -= 1
        }
    }
    
    func generateDeck() async {
        isGenerating = true
        errorMessage = nil
        
        // TODO: Call DeckGenerationService
        // For now, create mock deck
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        generatedDeck = Deck(
            userId: "user-1",
            title: state.startupName,
            useCase: state.useCase,
            themeId: state.preferredTheme,
            slides: [] // Will be populated by AI
        )
        
        isGenerating = false
    }
}
```

### Step 3: Create Wizard Views

Create `PitchMe/Views/Wizard/WizardContainerView.swift`:

```swift
struct WizardContainerView: View {
    @StateObject private var viewModel = WizardViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.pitchBackgroundAdaptive.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress bar
                    ProgressView(value: viewModel.progress)
                        .tint(.pitchLime)
                        .padding()
                    
                    // Step content
                    TabView(selection: $viewModel.state.currentStep) {
                        PitchIntroView(viewModel: viewModel)
                            .tag(0)
                        StartupBasicsStepView(viewModel: viewModel)
                            .tag(1)
                        ProblemStepView(viewModel: viewModel)
                            .tag(2)
                        SolutionStepView(viewModel: viewModel)
                            .tag(3)
                        MarketStepView(viewModel: viewModel)
                            .tag(4)
                        TractionStepView(viewModel: viewModel)
                            .tag(5)
                        SummaryStepView(viewModel: viewModel)
                            .tag(6)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .fullScreenCover(item: $viewModel.generatedDeck) { deck in
            NavigationStack {
                DeckDetailView(deck: deck)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { dismiss() }
                        }
                    }
            }
        }
    }
}
```

### Step 4: Create Individual Step Views

Each step view should follow this pattern:

```swift
struct StartupBasicsStepView: View {
    @ObservedObject var viewModel: WizardViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                // Header
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Let's start with the basics")
                        .font(Typography.displayMedium)
                        .foregroundColor(.pitchTextAdaptive)
                    
                    Text("Tell me about your startup")
                        .font(Typography.bodyLarge)
                        .foregroundColor(.pitchTextSecondary)
                }
                
                // Input fields
                VStack(alignment: .leading, spacing: Spacing.base) {
                    InputField(
                        label: "Startup Name",
                        placeholder: "e.g., FinanceAI",
                        text: $viewModel.state.startupName
                    )
                    
                    InputField(
                        label: "One-line description",
                        placeholder: "e.g., AI-powered financial planning for SMBs",
                        text: $viewModel.state.oneLiner
                    )
                    
                    // Stage picker
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Current Stage")
                            .font(Typography.labelMedium)
                            .foregroundColor(.pitchTextSecondary)
                        
                        Picker("Stage", selection: $viewModel.state.stage) {
                            ForEach(StartupStage.allCases, id: \.self) { stage in
                                Text(stage.rawValue).tag(stage)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                
                Spacer()
                
                // Navigation buttons
                HStack(spacing: Spacing.base) {
                    if viewModel.canGoBack {
                        Button("Back") {
                            viewModel.goToPreviousStep()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    
                    Button("Next: The Problem") {
                        viewModel.goToNextStep()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!viewModel.canGoForward)
                }
            }
            .padding(Spacing.screenMarginHorizontal)
        }
    }
}

// Reusable input field component
struct InputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(label)
                .font(Typography.labelMedium)
                .foregroundColor(.pitchTextSecondary)
            
            TextField(placeholder, text: $text, axis: .vertical)
                .font(Typography.bodyLarge)
                .foregroundColor(.pitchTextAdaptive)
                .padding(Spacing.md)
                .background(Color.pitchCardBackgroundAdaptive)
                .cornerRadius(Spacing.cardCornerRadius)
                .lineLimit(3...6)
        }
    }
}

// Button styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.labelLarge)
            .foregroundColor(.pitchCharcoal)
            .frame(maxWidth: .infinity)
            .frame(height: Spacing.buttonHeight)
            .background(Color.pitchLime)
            .cornerRadius(Spacing.buttonCornerRadius)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.labelLarge)
            .foregroundColor(.pitchTextAdaptive)
            .frame(maxWidth: .infinity)
            .frame(height: Spacing.buttonHeight)
            .background(Color.pitchCardBackgroundAdaptive)
            .cornerRadius(Spacing.buttonCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.buttonCornerRadius)
                    .stroke(Color.pitchDivider, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
```

### Step 5: Connect Wizard to Deck List

Update `DeckListView.swift`:

```swift
.sheet(isPresented: $showingNewDeckWizard) {
    WizardContainerView()
}
```

---

## 🔌 Backend Integration Guide

Once the wizard is done, connect to your backend:

### Option 1: Supabase (Recommended)

1. **Create project** at [supabase.com](https://supabase.com)
2. **Run SQL** from README to create tables
3. **Setup Auth** (email, social login)
4. **Add Swift client**:

```swift
// Add to Package.swift or SPM
.package(url: "https://github.com/supabase/supabase-swift", from: "1.0.0")
```

5. **Create APIClient.swift**:

```swift
import Supabase

final class APIClient {
    static let shared = APIClient()
    
    let client = SupabaseClient(
        supabaseURL: URL(string: "YOUR_SUPABASE_URL")!,
        supabaseKey: "YOUR_SUPABASE_ANON_KEY"
    )
    
    func generateDeck(_ request: GenerateDeckRequest) async throws -> Deck {
        let response = try await client.functions
            .invoke("generateDeck", body: request)
        
        // Parse response into Deck model
        return try JSONDecoder().decode(Deck.self, from: response.data)
    }
}
```

### Option 2: Custom Backend

If you prefer your own backend:

```swift
final class APIClient {
    static let shared = APIClient()
    private let baseURL = URL(string: "https://api.pitchme.app")!
    
    func generateDeck(_ request: GenerateDeckRequest) async throws -> Deck {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent("/generateDeck"))
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError
        }
        
        return try JSONDecoder().decode(Deck.self, from: data)
    }
}
```

---

## 🎨 Customization Tips

### Add New Themes

```swift
// In Theme.swift
extension Theme {
    static let sunset = Theme(
        id: "sunset",
        name: "sunset",
        displayName: "Sunset",
        description: "Warm and inviting",
        primaryColorHex: "#FF6B35",
        backgroundColorHex: "#FFF8F0",
        cardBackgroundColorHex: "#FFFFFF",
        textColorHex: "#1C1C1E",
        accentColorHex: "#FF6B35",
        titleFontWeight: .bold,
        bodyFontWeight: .regular,
        cardCornerRadius: 16,
        usesGradient: true,
        gradientStartHex: "#FF6B35",
        gradientEndHex: "#F7931E"
    )
}

// Add to allThemes array
static let allThemes: [Theme] = [.cleanLight, .darkTech, .boldColor, .sunset]
```

### Add New Slide Layouts

```swift
// In SlideLayoutType enum
case threeColumn = "three_column"

// Add display name
case .threeColumn: return "Three Column"

// Add icon
case .threeColumn: return "square.grid.3x1"
```

### Customize Colors

```swift
// In Colors.swift
static let pitchCustomAccent = Color(red: 0.2, green: 0.8, blue: 0.9)
```

---

## 🐛 Troubleshooting

### Xcode Won't Show Previews
1. Clean build folder: **⌘⇧K**
2. Restart Xcode
3. Make sure you're on macOS 14+ and Xcode 15+

### Navigation Not Working
Make sure you're wrapping views in `NavigationStack`, not `NavigationView` (deprecated).

### Colors Not Showing
Check that you've imported `SwiftUI` in your files.

### Models Won't Save
Make sure all model changes call `.touch()` to update `updatedAt` timestamp.

---

## 📚 Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Supabase Swift Docs](https://supabase.com/docs/reference/swift)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SF Symbols](https://developer.apple.com/sf-symbols/) – Free icon library

---

## 🎉 You're Ready!

You now have:
- ✅ A beautiful, working iOS app
- ✅ Complete design system
- ✅ Solid architecture (MVVM)
- ✅ Sample data and previews
- ✅ Clear roadmap to V1

**Next up:** Build that wizard flow and watch your app come to life! 🚀

---

Questions? Just ask! I'm here to help you build the best pitch deck app in the world. 🔥

