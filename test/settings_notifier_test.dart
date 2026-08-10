import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:trosa/db/sqflite_provider.dart';
import 'package:trosa/notifier/settings_notifier.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    DatabaseProvider.db.debugUseInMemory = true;
    await DatabaseProvider.db.database;
  });

  tearDown(() async {
    await DatabaseProvider.db.debugClose();
  });

  group('SettingsNotifier', () {
    test('defaults to MGA, system theme, date sort ascending', () {
      final settings = SettingsNotifier();
      expect(settings.currency, 'MGA');
      expect(settings.currencySymbol, 'Ar');
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.sortType, 'date');
      expect(settings.sortAscend, isTrue);
    });

    test('currencySymbol maps EUR and USD', () async {
      final settings = SettingsNotifier();
      await settings.setCurrency('EUR');
      expect(settings.currencySymbol, '€');
      await settings.setCurrency('USD');
      expect(settings.currencySymbol, r'$');
    });

    test('setCurrency persists and notifies', () async {
      final settings = SettingsNotifier();
      var notified = 0;
      settings.addListener(() => notified++);

      await settings.setCurrency('EUR');

      expect(settings.currency, 'EUR');
      expect(notified, greaterThan(0));
      expect(await DatabaseProvider.db.getSetting('currency'), 'EUR');
    });

    test('setThemeMode persists its name', () async {
      final settings = SettingsNotifier();
      await settings.setThemeMode(ThemeMode.dark);
      expect(await DatabaseProvider.db.getSetting('themeMode'), 'dark');
    });

    test('setSortPreference persists type and direction', () async {
      final settings = SettingsNotifier();
      await settings.setSortPreference('amount', false);

      expect(settings.sortType, 'amount');
      expect(settings.sortAscend, isFalse);
      expect(await DatabaseProvider.db.getSetting('sortType'), 'amount');
      expect(await DatabaseProvider.db.getSetting('sortAscend'), 'false');
    });

    test('load restores persisted values', () async {
      await DatabaseProvider.db.setSetting('currency', 'USD');
      await DatabaseProvider.db.setSetting('themeMode', 'light');
      await DatabaseProvider.db.setSetting('sortType', 'owner');
      await DatabaseProvider.db.setSetting('sortAscend', 'false');

      final settings = SettingsNotifier();
      await settings.load();

      expect(settings.currency, 'USD');
      expect(settings.currencySymbol, r'$');
      expect(settings.themeMode, ThemeMode.light);
      expect(settings.sortType, 'owner');
      expect(settings.sortAscend, isFalse);
    });
  });
}
