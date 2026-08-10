import 'package:flutter_test/flutter_test.dart';
import 'package:trosa/db/sqflite_provider.dart';
import 'package:trosa/models/trosa.dart';

void main() {
  group('Trosa model', () {
    test('toMap stores ISO date strings and normalized flags', () {
      final trosa = Trosa(
        amount: 15000,
        owner: 'Jean',
        date: DateTime(2026, 1, 5, 10, 30),
        dueDate: DateTime(2026, 2, 1),
        isInflow: false,
        note: 'emboka',
        paidAmount: 3000,
        category: 'Namana',
        recurringDays: 30,
        paidDate: DateTime(2026, 2, 3),
        reminderEnabled: false,
        reminderDaysBefore: 7,
        reminderTimeMinutes: 480,
      );

      final map = trosa.toMap();

      expect(map[DatabaseProvider.columnAmount], 15000);
      expect(map[DatabaseProvider.columnOwner], 'Jean');
      expect(map[DatabaseProvider.columnIsInflow], 0);
      expect(map[DatabaseProvider.columnNote], 'emboka');
      expect(map[DatabaseProvider.columnPaidAmount], 3000);
      expect(map[DatabaseProvider.columnCategory], 'Namana');
      expect(map[DatabaseProvider.columnRecurringDays], 30);
      expect(map[DatabaseProvider.columnDate], '2026-01-05T10:30:00.000');
      expect(map[DatabaseProvider.columnDueDate], '2026-02-01T00:00:00.000');
      expect(map[DatabaseProvider.columnPaidDate], '2026-02-03T00:00:00.000');
      expect(map[DatabaseProvider.columnReminderEnabled], 0);
      expect(map[DatabaseProvider.columnReminderDaysBefore], 7);
      expect(map[DatabaseProvider.columnReminderTimeMinutes], 480);
    });

    test('fromMap parses stored rows back into a Trosa', () {
      final trosa = Trosa.fromMap(<String, dynamic>{
        DatabaseProvider.columnId: 7,
        DatabaseProvider.columnAmount: '5000',
        DatabaseProvider.columnOwner: 'Rabe',
        DatabaseProvider.columnDate: '2026-03-01T08:00:00.000',
        DatabaseProvider.columnDueDate: '2026-03-20T00:00:00.000',
        DatabaseProvider.columnIsInflow: 1,
        DatabaseProvider.columnNote: null,
        DatabaseProvider.columnPaidAmount: '0',
        DatabaseProvider.columnCategory: 'Asa',
        DatabaseProvider.columnRecurringDays: '7',
      });

      expect(trosa.id, 7);
      expect(trosa.amount, 5000);
      expect(trosa.owner, 'Rabe');
      expect(trosa.isInflow, true);
      expect(trosa.note, isNull);
      expect(trosa.paidAmount, 0);
      expect(trosa.category, 'Asa');
      expect(trosa.recurringDays, 7);
      expect(trosa.date, DateTime(2026, 3, 1, 8));
      expect(trosa.dueDate, DateTime(2026, 3, 20));
    });

    test('fromMap falls back to safe defaults for corrupt or legacy rows', () {
      final trosa = Trosa.fromMap(<String, dynamic>{
        DatabaseProvider.columnAmount: 'not-a-number',
        DatabaseProvider.columnOwner: null,
        DatabaseProvider.columnDate: 'garbage',
        DatabaseProvider.columnDueDate: null,
        DatabaseProvider.columnIsInflow: null,
        DatabaseProvider.columnPaidAmount: null,
        DatabaseProvider.columnCategory: null,
        DatabaseProvider.columnRecurringDays: null,
      });

      expect(trosa.amount, 0);
      expect(trosa.owner, '');
      expect(trosa.isInflow, false);
      expect(trosa.paidAmount, 0);
      expect(trosa.category, '');
      expect(trosa.recurringDays, 0);
      expect(trosa.date.isAfter(DateTime(2025)), isTrue);
      expect(trosa.dueDate.isAfter(DateTime(2025)), isTrue);
    });

    test('remaining is amount minus paid and never negative', () {
      final partial = Trosa(amount: 10000, paidAmount: 4000);
      final overpaid = Trosa(amount: 10000, paidAmount: 12000);
      final fresh = Trosa(amount: 10000);

      expect(partial.remaining, 6000);
      expect(overpaid.remaining, 0);
      expect(fresh.remaining, 10000);
    });

    test('isPaid is true only when nothing remains', () {
      expect(Trosa(amount: 5000, paidAmount: 5000).isPaid, isTrue);
      expect(Trosa(amount: 5000, paidAmount: 6000).isPaid, isTrue);
      expect(Trosa(amount: 5000).isPaid, isFalse);
    });

    test('isOverdue only for outstanding debts past their due date', () {
      final past = Trosa(
        amount: 1000,
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
      );
      final paidLate = Trosa(
        amount: 1000,
        paidAmount: 1000,
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
      );
      final future = Trosa(
        amount: 1000,
        dueDate: DateTime.now().add(const Duration(days: 5)),
      );

      expect(past.isOverdue, isTrue);
      expect(paidLate.isOverdue, isFalse);
      expect(future.isOverdue, isFalse);
    });

    test('isDueSoon only for outstanding debts within the next 7 days', () {
      final soon = Trosa(
        amount: 1000,
        dueDate: DateTime.now().add(const Duration(days: 3)),
      );
      final paidSoon = Trosa(
        amount: 1000,
        paidAmount: 1000,
        dueDate: DateTime.now().add(const Duration(days: 3)),
      );
      final far = Trosa(
        amount: 1000,
        dueDate: DateTime.now().add(const Duration(days: 30)),
      );

      expect(soon.isDueSoon, isTrue);
      expect(paidSoon.isDueSoon, isFalse);
      expect(far.isDueSoon, isFalse);
    });

    test('toMap/fromMap round-trip preserves all fields', () {
      final original = Trosa(
        id: 42,
        amount: 2500.5,
        owner: 'Nivo',
        date: DateTime(2026, 4, 10, 14, 45),
        dueDate: DateTime(2026, 5, 1, 9),
        isInflow: true,
        note: 'vidy vary',
        paidAmount: 500,
        category: 'Fianakaviana',
        recurringDays: 0,
        paidDate: DateTime(2026, 6, 1),
        reminderEnabled: false,
        reminderDaysBefore: 2,
        reminderTimeMinutes: 600,
      );

      final copy = Trosa.fromMap(original.toMap()..[DatabaseProvider.columnId] = 42);

      expect(copy.id, original.id);
      expect(copy.amount, original.amount);
      expect(copy.owner, original.owner);
      expect(copy.date, original.date);
      expect(copy.dueDate, original.dueDate);
      expect(copy.isInflow, original.isInflow);
      expect(copy.note, original.note);
      expect(copy.paidAmount, original.paidAmount);
      expect(copy.category, original.category);
      expect(copy.recurringDays, original.recurringDays);
      expect(copy.paidDate, original.paidDate);
      expect(copy.reminderEnabled, original.reminderEnabled);
      expect(copy.reminderDaysBefore, original.reminderDaysBefore);
      expect(copy.reminderTimeMinutes, original.reminderTimeMinutes);
    });

    test('legacy rows without new columns fall back to defaults', () {
      final trosa = Trosa.fromMap(<String, dynamic>{
        DatabaseProvider.columnAmount: '1000',
        DatabaseProvider.columnOwner: 'Jean',
        DatabaseProvider.columnDate: '2026-01-05T10:30:00.000',
        DatabaseProvider.columnDueDate: '2026-02-01T00:00:00.000',
        DatabaseProvider.columnIsInflow: 1,
      });

      expect(trosa.paidDate, isNull);
      expect(trosa.reminderEnabled, isTrue);
      expect(trosa.reminderDaysBefore, 1);
      expect(trosa.reminderTimeMinutes, 540);
    });

    test('paidPercent reflects partial payments', () {
      expect(Trosa(amount: 10000, paidAmount: 3000).paidPercent, 30);
      expect(Trosa(amount: 10000, paidAmount: 10000).paidPercent, 100);
      expect(Trosa(amount: 10000, paidAmount: 0).paidPercent, 0);
      expect(Trosa(amount: 0).paidPercent, 0);
    });
  });
}
