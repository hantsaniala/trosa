import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trosa/db/sqflite_provider.dart';
import 'package:trosa/models/trosa.dart';

/// CSV backup/restore for the local database.
class BackupService {
  static const String _header =
      'id;amount;owner;date;dueDate;isInflow;note;paidAmount;category;recurringDays';

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
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) {
      return 0;
    }
    final path = result.files.single.path;
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
      );
      await DatabaseProvider.db.insert(trosa);
      count++;
    }
    return count;
  }
}
