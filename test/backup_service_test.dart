import 'package:flutter_test/flutter_test.dart';
import 'package:trosa/models/trosa.dart';
import 'package:trosa/services/backup_service.dart';

void main() {
  group('BackupService serialization', () {
    final debts = <Trosa>[
      Trosa(
        id: 1,
        amount: 15000,
        owner: 'Jean',
        date: DateTime(2026, 1, 5, 10, 30),
        dueDate: DateTime(2026, 2, 1),
        isInflow: true,
        note: 'emboka',
        paidAmount: 4000,
        category: 'Namana',
        recurringDays: 30,
        paidDate: null,
        reminderEnabled: false,
        reminderDaysBefore: 7,
        reminderTimeMinutes: 480,
      ),
      Trosa(
        id: 2,
        amount: 5000,
        owner: 'Nivo',
        date: DateTime(2026, 2, 3),
        dueDate: DateTime(2026, 3, 15),
        isInflow: false,
        note: null,
        paidAmount: 5000,
        category: '',
        recurringDays: 0,
        paidDate: DateTime(2026, 3, 1),
        reminderEnabled: true,
        reminderDaysBefore: 1,
        reminderTimeMinutes: 540,
      ),
    ];

    test('JSON build encodes debts and settings', () {
      final json = BackupService.buildJson(debts, {
        'currency': 'EUR',
        'language': 'fr',
        'customCategories': '["Asa","Hafa"]',
      });

      expect(json, contains('"version":1'));
      expect(json, contains('"currency":"EUR"'));
      expect(json, contains('"language":"fr"'));
      expect(json, contains('"owner":"Jean"'));
      expect(json, contains('"owner":"Nivo"'));
    });

    test('CSV header and rows round-trip key fields', () {
      final csv = BackupService.buildCsv(debts);
      final lines = csv.trim().split('\n');

      expect(lines.length, 3); // header + 2 debts
      expect(lines.first,
          'id;amount;owner;date;dueDate;isInflow;note;paidAmount;category;recurringDays;paidDate;reminderEnabled;reminderDaysBefore;reminderTimeMinutes');
      expect(csv, contains('Jean'));
      expect(csv, contains('Nivo'));
      expect(csv, contains('2026-03-01T00:00:00.000')); // paidDate serialized
      expect(csv, contains('0;7;480')); // reminderEnabled=0, days=7, minutes=480
    });
  });
}
