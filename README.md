# CuffNotes

**Policing legislation flashcards with spaced repetition.**

Built by a Special, for Specials. Open source. Community-driven. Always free.

## What is this?

CuffNotes is a Flutter mobile app that helps policing students learn legislation
through flashcards, quickfire quizzes, and pocket reference guides. Content covers
the College of Policing educational curriculum including:

- Theft Act 1968
- Assault Offences (OAPA 1861, CJA 1988)
- Public Order Act 1986 & 2023
- Anti-Social Behaviour, Crime and Policing Act 2014
- PACE 1984 (arrest, stop & search, detention, entry)
- Drone Laws (ANO 2016, ATMUA 2021)
- Criminal Damage Act 1971

## Architecture

```
cuffnotes-app (this repo)        cuffnotes-content (separate repo)
    Flutter UI code          <-->      JSON flashcard data
    SRS engine                         Editable via GitHub PRs
    Offline cache                      Auto-validated on PR
    Store builds                       No app update needed
```

The app fetches content from `raw.githubusercontent.com` on launch.
If offline, it falls back to the locally cached or bundled content.
SRS progress is stored on-device and never leaves the phone.

## Getting Started

### Prerequisites

- Flutter SDK 3.5+ (https://flutter.dev/docs/get-started/install)
- Android Studio (for Android) or Xcode (for iOS, macOS only)
- Git

### Setup

```bash
git clone https://github.com/YOUR_USERNAME/cuffnotes-app.git
cd cuffnotes-app
flutter pub get
flutter run
```

### Building for release

```bash
# Android (App Bundle for Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ipa --release
```

## Project Structure

```
lib/
  main.dart                 # Entry point, Hive init, dynamic theming
  theme/app_theme.dart      # Material You theme configuration
  models/
    flashcard.dart          # Card data model
    topic.dart              # Topic/category model
    srs_state.dart          # Spaced repetition state + engine
  services/
    content_service.dart    # Fetches JSON from GitHub, caches locally
    storage_service.dart    # Hive-based local storage
  screens/
    home_screen.dart        # Main screen with search, topics, stats
    study_screen.dart       # Flashcard study with SRS rating
    quiz_screen.dart        # Quickfire random quiz mode
    pocket_reference_screen.dart  # GOWISELY, necessity criteria, etc.
  widgets/
    flashcard_widget.dart   # Animated flashcard with flip
    srs_buttons.dart        # Again/Hard/Good/Easy rating buttons
    topic_card.dart         # Expandable topic card for home screen
assets/
  content/                  # Bundled fallback JSON (offline first launch)
```

## Contributing

### Adding or editing flashcard content

Content lives in a separate repository: `cuffnotes-content`.
You do NOT need Flutter or Dart to contribute content.

1. Fork the content repo
2. Edit or add JSON files
3. Open a Pull Request
4. Once merged, users get updates on next app launch

### Contributing to the app code

1. Fork this repo
2. Create a feature branch
3. Make changes and test on a device/emulator
4. Open a PR with screenshots

## Licence

App code: MIT Licence
Content: CC BY 4.0
