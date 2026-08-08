import 'package:trosa/db/sqflite_provider.dart';
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
  trosaNotifier.currentTrosaList = trosaList;
  trosaNotifier.sortType = 'date';
}
