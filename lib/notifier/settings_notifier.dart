import 'package:flutter/material.dart';
import 'package:trosa/db/sqflite_provider.dart';

/// Persisted app preferences (currency, theme, sort preference).
class SettingsNotifier extends ChangeNotifier {
  static const String _keyCurrency = 'currency';
  static const String _keyThemeMode = 'themeMode';
  static const String _keySortType = 'sortType';
  static const String _keySortAscend = 'sortAscend';

  static const List<String> currencies = ['MGA', 'EUR', 'USD'];

  String _currency = 'MGA';
  ThemeMode _themeMode = ThemeMode.system;
  String _sortType = 'date';
  bool _sortAscend = true;

  String get currency => _currency;
  ThemeMode get themeMode => _themeMode;
  String get sortType => _sortType;
  bool get sortAscend => _sortAscend;

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
}
