import 'package:trosa/db/sqflite_provider.dart';
import 'package:trosa/models/trosa.dart';
import 'package:trosa/notifier/trosa_notifier.dart';

/// Loads all debts from the local database into the notifier
/// and refreshes the totals.
Future<void> getTrosa(TrosaNotifier trosaNotifier) async {
  final trosaList = await DatabaseProvider.db.getTrosa();
  final totalInflow = await DatabaseProvider.db.totalInflow();
  final totalOutflow = await DatabaseProvider.db.totalOutflow();

  trosaNotifier.trosaList = trosaList;
  trosaNotifier.totalInflow = totalInflow;
  trosaNotifier.totalOutflow = totalOutflow;
  trosaNotifier.balance = totalInflow - totalOutflow;
  trosaNotifier.currentTrosaList = List.of(trosaList);
}

/// Creates the next occurrence of every recurring debt whose due date has
/// passed while it is still outstanding. Runs on app start.
Future<void> rolloverRecurringDebts() async {
  final debts = await DatabaseProvider.db.getTrosa();
  final now = DateTime.now();

  for (final trosa in debts) {
    if (trosa.recurringDays <= 0 || trosa.isPaid) continue;
    // Only roll over debts whose due date has already arrived.
    if (!trosa.dueDate.isBefore(now)) continue;

    // Create one record per missed period, then the next upcoming one so the
    // chain continues into the future.
    var nextDue = trosa.dueDate.add(Duration(days: trosa.recurringDays));
    while (!nextDue.isAfter(now)) {
      await _insertOccurrence(trosa, nextDue, now);
      nextDue = nextDue.add(Duration(days: trosa.recurringDays));
    }
    await _insertOccurrence(trosa, nextDue, now);
  }
}

Future<void> _insertOccurrence(
    Trosa trosa, DateTime dueDate, DateTime now) async {
  final copy = Trosa(
    amount: trosa.amount,
    owner: trosa.owner,
    date: now,
    dueDate: dueDate,
    isInflow: trosa.isInflow,
    note: trosa.note,
    category: trosa.category,
    recurringDays: trosa.recurringDays,
  );
  await DatabaseProvider.db.insert(copy);
}
