# ArvyaX - Immersive Session App

A premium mindfulness and meditation app built with Flutter that helps users relax, focus, and reflect through immersive audio sessions.

## 🎯 Features

### Core Features
- **Ambience Library** - Browse 8+ ambient soundscapes with search and filter
- **Audio Player** - Play ambient sounds with subtle animations
- **Session Timer** - Auto-completes after set duration
- **Journaling** - Reflect on sessions with mood tracking
- **History** - View past journal entries
- **Mini Player** - Persistent player across screens

### Technical Features
- ✅ Clean Architecture with Riverpod
- ✅ Local persistence with Hive
- ✅ Audio playback with audioplayers
- ✅ Smooth animations
- ✅ Responsive design
- ✅ Error handling & loading states
- ✅ Pull to refresh
- ✅ Empty states

## 📱 Screenshots

screenshts added in assets image file

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.8.0)
- Dart SDK (^3.8.0)
- Android Studio / VS Code
- Git

### Installation Steps

1. **Clone the repository**
```bash
git clone https://github.com/ArpitaRoul-2024/arvyax_assignment/blob/main/README.md
cd arvyax_assignment
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate Hive adapters** (if not already generated)
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

4. **Add assets**

   Create the following folders and add assets:
   ```
   assets/
   ├── images/           # Add your images/GIFs here
   │   ├── forest.jpg
   │   ├── ocean.jpg
   │   ├── sleep.jpg
   │   ├── morning.jpg
   │   ├── rain.jpg
   │   ├── garden.jpg
   │   ├── mountain.jpg
   │   └── desert.jpg
   ├── audio/            # Add your audio files here
   │   ├── forest_focus.mp3
   │   ├── ocean_calm.mp3
   │   ├── deep_sleep.mp3
   │   ├── morning_reset.mp3
   │   ├── rainy_focus.mp3
   │   ├── zen_garden.mp3
   │   ├── mountain_peak.mp3
   │   └── desert_night.mp3
   └── ambiences.json    # Ambience data
   ```

5. **Run the app**
```bash
flutter run
```

### Build APK
```bash
flutter build apk --release
```
APK location: `build/app/outputs/flutter-apk/app-release.apk`

## 🏗️ Architecture

### Folder Structure
```
lib/
├── core/                 # Core functionality
│   ├── constants/        # App constants
│   ├── theme/            # App themes (light/dark)
│   ├── utils/            # Utilities (Hive, formatters)
│   └── routing/          # GoRouter configuration
│
├── data/                 # Data layer
│   ├── models/           # Data models
│   │   ├── ambience_model.dart
│   │   ├── journal_entry.dart
│   │   ├── mood.dart
│   │   └── session_state.dart
│   ├── repositories/     # Data repositories
│   │   ├── ambience_repository.dart
│   │   ├── journal_repository.dart
│   │   └── session_repository.dart
│   └── datasources/      # Data sources (local, assets)
│
├── features/             # Feature modules
│   ├── ambience/         # Ambience feature
│   │   ├── providers/    # Riverpod providers
│   │   ├── screens/      # UI screens
│   │   └── widgets/      # Reusable widgets
│   ├── player/           # Player feature
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   └── journal/          # Journal feature
│       ├── providers/
│       ├── screens/
│       └── widgets/
│
└── shared/               # Shared widgets
    └── widgets/          # Reusable UI components
```

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                       UI Layer (Screens)                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │ Home     │ │ Details  │ │ Player   │ │ Journal  │      │
│  │ Screen   │ │ Screen   │ │ Screen   │ │ Screens  │      │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘      │
│       │            │            │            │             │
└───────┼────────────┼────────────┼────────────┼─────────────┘
        │            │            │            │
        ▼            ▼            ▼            ▼
┌─────────────────────────────────────────────────────────────┐
│                 Riverpod Providers (State Management)        │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ ambienceProvider  │ playerProvider  │ journalProvider│    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Repository Layer                          │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐        │
│  │ AmbienceRepo │ │ JournalRepo  │ │ SessionRepo  │        │
│  └──────┬───────┘ └──────┬───────┘ └──────┬───────┘        │
└─────────┼─────────────────┼─────────────────┼───────────────┘
          │                 │                 │
          ▼                 ▼                 ▼
┌─────────────────────────────────────────────────────────────┐
│                   Data Sources                               │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐        │
│  │  JSON Asset  │ │   Hive DB    │ │   Hive DB    │        │
│  │ (ambiences)  │ │  (journal)   │ │  (session)   │        │
│  └──────────────┘ └──────────────┘ └──────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 Data Flow

### Example: Loading Ambiences
1. **UI** requests data via `ref.watch(ambienceListProvider)`
2. **Provider** calls `ambienceRepository.getAmbiences()`
3. **Repository** loads from JSON asset or returns cached data
4. **Provider** updates state (loading/data/error)
5. **UI** rebuilds based on state

### Example: Saving Journal Entry
1. **User** taps "Save" in Reflection Screen
2. **Screen** calls `journalRepository.createEntry()`
3. **Repository** creates entry and saves to Hive
4. **Provider** invalidates `journalEntriesProvider`
5. **History Screen** auto-refreshes with new data

## 📦 Packages Used

### State Management
- **flutter_riverpod: ^2.5.1** - Selected for its simplicity, type safety, and excellent testing capabilities. Provides reactive state management without boilerplate.

### Navigation
- **go_router: ^14.0.2** - Chosen for declarative routing, deep linking support, and easy URL-based navigation.

### Local Storage
- **hive_flutter: ^1.1.0** - Fast, lightweight NoSQL database. Selected over SQLite for its simplicity and performance with object storage.
- **hive: ^2.2.3** - Core Hive package
- **hive_generator: ^2.0.1** - For generating type adapters

### Audio
- **audioplayers: ^5.2.1** - Comprehensive audio solution with excellent Flutter integration and support for looping.

### Utilities
- **intl: ^0.19.0** - Date formatting
- **uuid: ^4.4.0** - Generate unique IDs
- **equatable: ^2.0.5** - Simplify equality comparisons

### Development
- **build_runner: ^2.4.9** - Code generation
- **flutter_lints: ^4.0.0** - Code quality

## 🎨 Design Decisions

### State Management: Riverpod
- **Why?** Better than Provider, no BuildContext dependency, compile-time safety
- **How?** Used for all app state (ambiences, player, journal)

### Storage: Hive
- **Why?** Fast, simple, no SQL, perfect for local data
- **How?** Two boxes: `journalBox` for entries, `sessionBox` for active session

### Architecture: Clean + Feature-first
- **Why?** Scalable, testable, maintainable
- **How?** Separated into core, data, features, shared

## 🎯 Tradeoffs & Future Improvements

### If I had 2 more days, I would:

1. **Add Audio Visualizer**
    - Real-time frequency visualization
    - More immersive experience

2. **Implement Dark Mode**
    - Theme switching
    - System preference detection

3. **Add Haptic Feedback**
    - On play/pause
    - On session complete
    - On journal save

4. **Background Audio Support**
    - Continue playing when app is backgrounded
    - Proper lifecycle management

5. **Add More Animations**
    - Page transitions
    - Micro-interactions
    - Loading animations

6. **Improve Accessibility**
    - Screen reader support
    - Large text scaling
    - High contrast mode

7. **Add Analytics**
    - Track popular ambiences
    - Session completion rates
    - User engagement metrics

### Current Tradeoffs

1. **Images vs Performance**
    - Using high-quality images affects initial load time
    - Added caching and placeholders to mitigate

2. **Simplicity vs Features**
    - Focused on core requirements over bonus features
    - Ensured stability and correctness first

3. **Asset Management**
    - Local assets ensure offline functionality
    - Increases app size but improves reliability

## 🧪 Testing

Run tests:
```bash
flutter test
```

## 📝 License

This project is created for ArvyaX Flutter Developer Assignment.

## 👨‍💻 Author

[Your Name]

---

**Built with ❤️ using Flutter**