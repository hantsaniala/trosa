# Trosa

**Trosa** (Malagasy for *debt*) is a mobile app for keeping track of debts and
loans: money people owe you, money you owe them, and your overall balance.

## Features

### Core tracking
- Track amounts in Ariary (MGA), Euro (EUR) or US Dollar (USD)
- Record the person involved, the due date, a note and a category
- Classify each debt as **money to receive** (inflow) or **money to pay** (outflow)
- Edit any debt at any time, even after creation
- Dashboard with totals, paid count and your net balance

### Search, filters & sorting
- Full-text search across all debt notes and owners
- Filter by status: **all**, **unpaid**, **overdue**, **paid**
- Sort the list by date, owner or amount, ascending or descending
- Paid archive is sorted by settlement date (most recent first)

### Partial payments & settlement
- Record partial payments against any debt — the remaining amount updates live
- Each debt card shows a **progress bar** when partially paid
- A **paid date** is recorded when the debt is fully settled
- Swipe to mark a debt as paid (or undo), or use the tap-and-choose action

### Categories
- Choose from built-in categories: *Fianakaviana* (family), *Namana* (friends),
  *Asa* (work), *Sakafo* (food), *Fifindra-monina* (moving)
- **Create custom categories** on the fly from the add/edit form
- Manage custom categories in the settings dialog

### Reminders & notifications
- Each debt has its own **reminder toggle** — opt out of reminders per debt
- Choose how many days before the due date to be reminded (same day, 1 day,
  2 days or 1 week)
- Pick the **time of day** the reminder fires (default 09:00)
- Overdue debts get a **daily nag** at the configured reminder time until paid
- Reminders persist across device reboots (boot receiver registered)

### Owner avatars
- Every person in the list gets a **deterministic colour avatar** with their
  initial — scannable at a glance across the dashboard, debt cards and stats
- Pick the owner from your **phone contacts** (Android & iOS) with a searchable
  bottom sheet, or type the name manually

### Multi-language
- **Malagasy** (default), **French** and **English**
- Switch languages at any time in the settings — the app reloads immediately
- Framework strings (date pickers, dialogs) follow the selected locale

### Statistics
- Monthly breakdown of new debts, paid amounts and balance per month
- **Cumulative balance trend** — a 6-month line chart of your net position
- **Top owners** ranked by outstanding amount
- Share a plain-text stats report via the share sheet

### First-run onboarding
- Three-slide intro explaining the app's purpose and swipe gestures
- Shown once on first launch; skip or finish to reach the dashboard
- A brand-yellow splash screen is shown while settings load

### Backup & data portability
- **CSV export/import** — semicolon-separated file with all debt fields
- **JSON backup** — full snapshot of debts **and** settings (currency, theme,
  language, custom categories, reminder defaults, sort preferences)
- Share the JSON file via the system share sheet and restore it later

### Theme
- **White mode** — clean, pure-white surfaces for a bright, modern look
- **Dark mode** — system-aware dark theme for low-light use
- Toggle theme instantly from the app bar icon, or follow the system setting
- App bar also includes a quick theme toggle (sun/moon icon)

### And more
- Stats screen with a **share report** button
- **Swipe to delete** with confirmation undo
- Pull to refresh the list
- **Share the app** with friends via the system share sheet
- All data is stored **locally** on the device (SQLite) — no account or
  internet required

## Tech stack

- [Flutter](https://flutter.dev/) **3.44** (Dart 3) targeting **Android** and **iOS**
- Local persistence with [sqflite](https://pub.dev/packages/sqflite)
- State management with [provider](https://pub.dev/packages/provider)
- Local notifications with [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) + [timezone](https://pub.dev/packages/timezone)
- Contact access with [flutter_contacts](https://pub.dev/packages/flutter_contacts)
- Share sheet with [share_plus](https://pub.dev/packages/share_plus)
- File picking with [file_picker](https://pub.dev/packages/file_picker)
- Localization with Flutter's built-in `gen-l10n` (Malagasy, French, English)

## Prerequisites

- Flutter SDK **3.44** (stable channel) — see the
  [official install guide](https://docs.flutter.dev/get-started/install)
- For Android builds: Android SDK (`compileSdk` 36, `minSdk` 24, `targetSdk` 36)
  and JDK 17
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
├── api/                    # data loading orchestration
├── components/             # shared widgets / input formatters
│   ├── currency_input_formatter.dart
│   ├── owner_avatar.dart   # colour-coded owner avatars
│   └── trosa_mark.dart     # brand double-arrow mark
├── db/
│   └── sqflite_provider.dart   # SQLite database, migrations v1→v4
├── l10n/                   # localized strings (mg, fr, en)
├── models/
│   └── trosa.dart          # debt model (amount, owner, dates, reminders…)
├── notifier/
│   ├── settings_notifier.dart  # app preferences (currency, theme, language…)
│   └── trosa_notifier.dart     # debt list state, search, sort, filters
├── screens/trosa/
│   ├── components/
│   │   └── trosa_card.dart     # debt card with avatar, progress bar, dates
│   ├── trosa_form_screen.dart   # add / edit debt form
│   ├── trosa_onboarding.dart   # first-run 3-slide intro
│   ├── trosa_screen.dart       # main dashboard
│   ├── trosa_settings_dialog.dart  # settings (currency, theme, language…)
│   └── trosa_stats_screen.dart # stats, trend chart, top owners
└── services/
    ├── backup_service.dart     # CSV + JSON export/import
    └── notification_service.dart  # local notification scheduling
```

## Permissions

The app requests the following runtime permissions:

| Permission              | Platform | Purpose                                         |
|-------------------------|----------|-------------------------------------------------|
| `POST_NOTIFICATIONS`    | Android 13+ | Scheduling debt reminders                 |
| `READ_CONTACTS`         | Android      | Pick an owner from phone contacts          |
| `RECEIVE_BOOT_COMPLETED`| Android      | Re-schedule reminders after device reboot  |
| `VIBRATE`               | Android      | Vibration on notification delivery         |
| `NSContactsUsageDescription` | iOS   | Pick an owner from phone contacts          |

## Credits

Icons made by [Freepik](http://www.freepik.com/) from
[www.flaticon.com](https://www.flaticon.com/)

&copy; Copyright Hantsaniala 2020