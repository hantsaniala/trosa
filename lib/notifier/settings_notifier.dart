import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:trosa/db/sqflite_provider.dart';

/// Persisted app preferences (currency, theme, language, sort preference,
/// custom categories, reminder defaults, onboarding state).
class SettingsNotifier extends ChangeNotifier {
  static const String _keyCurrency = 'currency';
  static const String _keyThemeMode = 'themeMode';
  static const String _keySortType = 'sortType';
  static const String _keySortAscend = 'sortAscend';
  static const String _keyLanguage = 'language';
  static const String _keyOnboardingDone = 'onboardingDone';
  static const String _keyCustomCategories = 'customCategories';
  static const String _keyReminderDaysBefore = 'reminderDaysBefore';
  static const String _keyReminderTimeMinutes = 'reminderTimeMinutes';

  static const List<String> currencies = ['MGA', 'EUR', 'USD'];
  static const List<String> languages = ['mg', 'fr', 'en'];

  String _currency = 'MGA';
  ThemeMode _themeMode = ThemeMode.system;
  String _sortType = 'date';
  bool _sortAscend = true;
  String _language = 'mg';
  bool _onboardingDone = false;
  List<String> _customCategories = [];
  int _reminderDaysBefore = 1;
  int _reminderTimeMinutes = 540; // 09:00

  String get currency => _currency;
  ThemeMode get themeMode => _themeMode;
  String get sortType => _sortType;
  bool get sortAscend => _sortAscend;
  String get language => _language;
  bool get onboardingDone => _onboardingDone;
  List<String> get customCategories => List.unmodifiable(_customCategories);
  int get reminderDaysBefore => _reminderDaysBefore;
  int get reminderTimeMinutes => _reminderTimeMinutes;

  String get currencySymbol {
    switch (_currency) {
      case 'EUR':
        return '€';
      case 'USD':
        return r'$';
      default:
        return 'Ar';
    }
  }

  /// Loads persisted values from the database (defaults when absent).
  Future<void> load() async {
    _currency = await DatabaseProvider.db.getSetting(_keyCurrency) ?? 'MGA';
    _themeMode = _parseThemeMode(
        await DatabaseProvider.db.getSetting(_keyThemeMode));
    _sortType = await DatabaseProvider.db.getSetting(_keySortType) ?? 'date';
    _sortAscend =
        (await DatabaseProvider.db.getSetting(_keySortAscend)) != 'false';
    _language = await DatabaseProvider.db.getSetting(_keyLanguage) ?? 'mg';
    _onboardingDone =
        (await DatabaseProvider.db.getSetting(_keyOnboardingDone)) == 'true';
    _customCategories =
        _parseCategories(await DatabaseProvider.db.getSetting(_keyCustomCategories));
    _reminderDaysBefore = int.tryParse(
            await DatabaseProvider.db.getSetting(_keyReminderDaysBefore) ??
                '') ??
        1;
    _reminderTimeMinutes = int.tryParse(
            await DatabaseProvider.db.getSetting(_keyReminderTimeMinutes) ??
                '') ??
        540;
    notifyListeners();
  }

  Future<void> setCurrency(String value) async {
    if (_currency == value) return;
    _currency = value;
    notifyListeners();
    await DatabaseProvider.db.setSetting(_keyCurrency, value);
  }

  Future<void> setThemeMode(ThemeMode value) async {
    if (_themeMode == value) return;
    _themeMode = value;
    notifyListeners();
    await DatabaseProvider.db.setSetting(_keyThemeMode, value.name);
  }

  Future<void> setSortPreference(String type, bool ascend) async {
    _sortType = type;
    _sortAscend = ascend;
    notifyListeners();
    await DatabaseProvider.db.setSetting(_keySortType, type);
    await DatabaseProvider.db.setSetting(_keySortAscend, ascend.toString());
  }

  Future<void> setLanguage(String value) async {
    if (_language == value) return;
    _language = value;
    notifyListeners();
    await DatabaseProvider.db.setSetting(_keyLanguage, value);
  }

  Future<void> setOnboardingDone() async {
    if (_onboardingDone) return;
    _onboardingDone = true;
    notifyListeners();
    await DatabaseProvider.db.setSetting(_keyOnboardingDone, 'true');
  }

  /// Adds a custom category (ignores duplicates), persisting the list.
  /// Returns true when the category was actually added.
  Future<bool> addCustomCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || _customCategories.contains(trimmed)) return false;
    _customCategories = [..._customCategories, trimmed];
    notifyListeners();
    await DatabaseProvider.db.setSetting(
        _keyCustomCategories, jsonEncode(_customCategories));
    return true;
  }

  Future<void> removeCustomCategory(String name) async {
    if (!_customCategories.contains(name)) return;
    _customCategories = [..._customCategories]..remove(name);
    notifyListeners();
    await DatabaseProvider.db.setSetting(
        _keyCustomCategories, jsonEncode(_customCategories));
  }

  Future<void> setReminderDefaults(int daysBefore, int timeMinutes) async {
    _reminderDaysBefore = daysBefore;
    _reminderTimeMinutes = timeMinutes;
    notifyListeners();
    await DatabaseProvider.db.setSetting(_keyReminderDaysBefore, '$daysBefore');
    await DatabaseProvider.db
        .setSetting(_keyReminderTimeMinutes, '$timeMinutes');
  }

  static ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static List<String> _parseCategories(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } catch (_) {
      // Corrupt value: start fresh.
    }
    return [];
  }
}
