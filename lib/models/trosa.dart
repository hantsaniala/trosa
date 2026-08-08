import 'package:trosa/db/sqflite_provider.dart';

/// A debt record ("trosa").
///
/// `isInflow` is `true` when money is owed to the user (money to receive),
/// `false` when the user owes money (money to pay).
class Trosa {
  int? id;
  double amount;
  String owner;
  DateTime date;
  DateTime dueDate;
  bool isInflow;
  String? note;

  Trosa({
    this.id,
    this.amount = 0,
    this.owner = '',
    DateTime? date,
    DateTime? dueDate,
    this.isInflow = true,
    this.note,
  })  : date = date ?? DateTime.now(),
        dueDate = dueDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      DatabaseProvider.columnAmount: amount,
      DatabaseProvider.columnOwner: owner,
      DatabaseProvider.columnDate: date.toIso8601String(),
      DatabaseProvider.columnDueDate: dueDate.toIso8601String(),
      DatabaseProvider.columnIsInflow: isInflow ? 1 : 0,
      DatabaseProvider.columnNote: note,
    };
  }

  factory Trosa.fromMap(Map<String, dynamic> data) {
    return Trosa(
      id: data[DatabaseProvider.columnId] as int?,
      amount: double.tryParse(
              data[DatabaseProvider.columnAmount]?.toString() ?? '') ??
          0,
      owner: data[DatabaseProvider.columnOwner]?.toString() ?? '',
      date: _parseDate(data[DatabaseProvider.columnDate]),
      dueDate: _parseDate(data[DatabaseProvider.columnDueDate]),
      isInflow: data[DatabaseProvider.columnIsInflow] == 1,
      note: data[DatabaseProvider.columnNote]?.toString(),
    );
  }

  /// Parses a stored date string, falling back to now for legacy/corrupt rows
  /// so old databases never crash on load.
  static DateTime _parseDate(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    return parsed ?? DateTime.now();
  }
}
