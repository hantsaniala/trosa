# Trosa

**Trosa** (Malagasy for *debt*) is a mobile app for keeping track of debts and
loans: money people owe you, money you owe them, and your overall balance.

- Track amounts in Ariary (MGA), the person involved, the due date and a note
- Classify each debt as **money to receive** (inflow) or **money to pay** (outflow)
- Dashboard with totals and your balance
- Sort the list by date, owner or amount, ascending or descending
- Swipe to delete with confirmation, pull to refresh, share the app
- All data is stored locally on the device (SQLite) — no account or internet needed

## Tech stack

- [Flutter](https://flutter.dev/) 3.x (Dart 3) targeting **Android** and **iOS**
- Local persistence with [sqflite](https://pub.dev/packages/sqflite)
- State management with [provider](https://pub.dev/packages/provider)
- Localization with Flutter's built-in `gen-l10n` (Malagasy strings in `lib/l10n/`)

## Prerequisites

- Flutter SDK **3.x** (stable channel) — see the
  [official install guide](https://docs.flutter.dev/get-started/install)
- For Android builds: Android SDK (compileSdk/targetSdk 36, minSdk 24) and JDK 17
- For iOS builds: macOS with Xcode and CocoaPods

## Getting started

```bash
flutter pub get        # install dependencies (also generates l10n files)
flutter run            # run on a connected device or emulator
flutter test           # run the widget tests
flutter analyze        # static analysis
flutter build apk --release   # build a release APK
```

> **Note:** release builds are currently signed with the debug keystore. To
> publish to the Play Store, set up your own signing key in
> `android/app/build.gradle.kts`.

## Project structure

```
lib/
├── api/                # data loading orchestration
├── components/         # shared widgets / input formatters
├── db/                 # SQLite provider and migrations
├── l10n/               # localized strings (Malagasy)
├── models/             # domain model (Trosa)
├── notifier/           # state (ChangeNotifier + provider)
└── screens/trosa/      # list, add/edit form, about page
```

## Credits

Icons made by [Freepik](http://www.freepik.com/) from
[www.flaticon.com](https://www.flaticon.com/)

&copy; Copyright Hantsaniala 2020
