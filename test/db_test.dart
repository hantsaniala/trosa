import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:trosa/api/trosa_api.dart';
import 'package:trosa/db/sqflite_provider.dart';
import 'package:trosa/models/trosa.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Use an isolated in-memory database for every test.
    DatabaseProvider.db.debugUseInMemory = true;
    await DatabaseProvider.db.database;
  });

  tearDown(() async {
    await DatabaseProvider.db.debugClose();
  });

  group('DatabaseProvider', () {
    test('insert assigns an id and getTrosa returns the row', () async {
      final trosa = Trosa(amount: 8000, owner: 'Jean', isInflow: true);
      await DatabaseProvider.db.insert(trosa);

      final all = await DatabaseProvider.db.getTrosa();
      expect(all.length, 1);
      expect(all.single.id, isNotNull);
      expect(all.single.owner, 'Jean');
      expect(all.single.amount, 8000);
    });

    test('update persists changes', () async {
      final trosa = Trosa(amount: 5000, owner: 'Rabe');
      await DatabaseProvider.db.insert(trosa);

      trosa.paidAmount = 2000;
      await DatabaseProvider.db.update(trosa);

      final all = await DatabaseProvider.db.getTrosa();
      expect(all.single.paidAmount, 2000);
    });

    test('delete removes a record and restore brings it back with its id',
        () async {
      final trosa = Trosa(amount: 3000, owner: 'Nivo');
      await DatabaseProvider.db.insert(trosa);
      final id = trosa.id!;

      await DatabaseProvider.db.delete(trosa);
      expect(await DatabaseProvider.db.getTrosa(), isEmpty);

      await DatabaseProvider.db.restore(trosa);
      final all = await DatabaseProvider.db.getTrosa();
      expect(all.length, 1);
      expect(all.single.id, id);
      expect(all.single.owner, 'Nivo');
    });

    test('totals ignore paid debts and use remaining amounts', () async {
      await DatabaseProvider.db.insert(Trosa(amount: 10000, isInflow: true));
      await DatabaseProvider.db
          .insert(Trosa(amount: 6000, paidAmount: 6000, isInflow: true));
      await DatabaseProvider.db.insert(Trosa(amount: 4000, isInflow: false));
      await DatabaseProvider.db
          .insert(Trosa(amount: 2000, paidAmount: 500, isInflow: false));

      expect(await DatabaseProvider.db.totalInflow(), 10000);
      expect(await DatabaseProvider.db.totalOutflow(), 5500);
    });

    test('settings persist and round-trip', () async {
      expect(await DatabaseProvider.db.getSetting('theme'), isNull);

      await DatabaseProvider.db.setSetting('theme', 'dark');
      await DatabaseProvider.db.setSetting('currency', 'EUR');

      expect(await DatabaseProvider.db.getSetting('theme'), 'dark');
      expect(await DatabaseProvider.db.getSetting('currency'), 'EUR');
    });
  });

  group('rolloverRecurringDebts', () {
    test('creates next occurrences for overdue recurring debts', () async {
      final past = DateTime.now().subtract(const Duration(days: 10));
      await DatabaseProvider.db.insert(Trosa(
        amount: 5000,
        owner: 'Rent',
        dueDate: past,
        recurringDays: 7,
      ));

      await rolloverRecurringDebts();

      final all = await DatabaseProvider.db.getTrosa();
      expect(all.length, greaterThan(1));
      // The most recent occurrence must be in the future.
      final dues = all.map((t) => t.dueDate).toList();
      expect(dues.any((d) => d.isAfter(DateTime.now())), isTrue);
    });

    test('does nothing for non-recurring or paid debts', () async {
      await DatabaseProvider.db.insert(Trosa(
        amount: 5000,
        owner: 'Plain',
        dueDate: DateTime.now().subtract(const Duration(days: 10)),
        recurringDays: 0,
      ));
      await DatabaseProvider.db.insert(Trosa(
        amount: 5000,
        owner: 'PaidRecurring',
        dueDate: DateTime.now().subtract(const Duration(days: 10)),
        paidAmount: 5000,
        recurringDays: 7,
      ));

      await rolloverRecurringDebts();
      expect((await DatabaseProvider.db.getTrosa()).length, 2);
    });
  });
}
