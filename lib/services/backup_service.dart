import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trosa/db/sqflite_provider.dart';
import 'package:trosa/models/trosa.dart';

/// CSV backup/restore for the local database.
class BackupService {
  static const String _header =
      'id;amount;owner;date;dueDate;isInflow;note;paidAmount;category;recurringDays;paidDate;reminderEnabled;reminderDaysBefore;reminderTimeMinutes';

  /// Serializes all debts to a semicolon-separated CSV string.
  static String buildCsv(List<Trosa> debts) {
    final buffer = StringBuffer('$_header\n');
    for (final t in debts) {
      buffer.writeln([
        '${t.id ?? ''}',
        '${t.amount}',
        _escape(t.owner),
        t.date.toIso8601String(),
        t.dueDate.toIso8601String(),
        t.isInflow ? '1' : '0',
        _escape(t.note ?? ''),
        '${t.paidAmount}',
        _escape(t.category),
        '${t.recurringDays}',
        t.paidDate?.toIso8601String() ?? '',
        t.reminderEnabled ? '1' : '0',
        '${t.reminderDaysBefore}',
        '${t.reminderTimeMinutes}',
      ].join(';'));
    }
    return buffer.toString();
  }

  static String _escape(String value) =>
      value.replaceAll(';', ',').replaceAll('\n', ' ');

  /// Shares a CSV file with the whole database through the share sheet.
  static Future<void> exportCsv() async {
    final debts = await DatabaseProvider.db.getTrosa();
    final dir = await Directory.systemTemp.createTemp('trosa');
    final file = File('${dir.path}/trosa_backup.csv');
    await file.writeAsString(buildCsv(debts));
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: 'text/csv')]),
    );
  }

  /// Lets the user pick a CSV file and imports every row.
  /// Returns the number of imported debts.
  static Future<int> importCsv() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    final path = file?.path;
    if (path == null) {
      return 0;
    }

    final content = await File(path).readAsString();
    final lines = content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .skip(1);

    var count = 0;
    for (final line in lines) {
      final parts = line.split(';');
      // Legacy exports had 10 columns; the current format has 14.
      if (parts.length < 10) continue;

      final trosa = Trosa(
        amount: double.tryParse(parts[1]) ?? 0,
        owner: parts[2],
        date: DateTime.tryParse(parts[3]) ?? DateTime.now(),
        dueDate: DateTime.tryParse(parts[4]) ?? DateTime.now(),
        isInflow: parts[5] == '1',
        note: parts[6].isEmpty ? null : parts[6],
        paidAmount: double.tryParse(parts[7]) ?? 0,
        category: parts[8],
        recurringDays: int.tryParse(parts[9]) ?? 0,
        paidDate: parts.length > 10 && parts[10].isNotEmpty
            ? DateTime.tryParse(parts[10])
            : null,
        reminderEnabled: parts.length > 11 ? parts[11] != '0' : true,
        reminderDaysBefore: parts.length > 12
            ? int.tryParse(parts[12]) ?? 1
            : 1,
        reminderTimeMinutes: parts.length > 13
            ? int.tryParse(parts[13]) ?? 540
            : 540,
      );
      await DatabaseProvider.db.insert(trosa);
      count++;
    }
    return count;
  }

  /// Full JSON backup: debts **and** settings (currency, theme, language,
  /// custom categories, reminder defaults, sort preference).
  static String buildJson(List<Trosa> debts, Map<String, String> settings) {
    return jsonEncode(<String, dynamic>{
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': settings,
      'debts': debts.map((t) => t.toMap()).toList(),
    });
  }

  /// Shares a JSON backup file with the whole database through the share
  /// sheet.
  static Future<void> exportJson() async {
    final debts = await DatabaseProvider.db.getTrosa();
    final settings = await DatabaseProvider.db.getAllSettings();
    final dir = await Directory.systemTemp.createTemp('trosa');
    final file = File('${dir.path}/trosa_backup.json');
    await file.writeAsString(buildJson(debts, settings));
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: 'application/json')]),
    );
  }

  /// Lets the user pick a JSON backup file and restores debts and settings.
  /// Returns the number of restored debts.
  static Future<int> importJson() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = file?.path;
    if (path == null) {
      return 0;
    }

    final content = await File(path).readAsString();
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      throw const FormatException('Invalid JSON backup');
    }

    final settings = data['settings'];
    if (settings is Map) {
      for (final entry in settings.entries) {
        if (entry.key is String && entry.value is String) {
          await DatabaseProvider.db.setSetting(entry.key, entry.value as String);
        }
      }
    }

    final rawDebts = data['debts'];
    if (rawDebts is! List) {
      throw const FormatException('Backup contains no debts');
    }

    // Replace the current database contents with the backup.
    final restored = rawDebts
        .whereType<Map>()
        .map((row) => Trosa.fromMap(Map<String, dynamic>.from(row)))
        .toList();
    await DatabaseProvider.db.replaceAllTrosa(restored);
    return restored.length;
  }
}
