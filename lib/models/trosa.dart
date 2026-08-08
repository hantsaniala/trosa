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
      DatabaseProvider.COLUMN_AMOUNT: amount,
      DatabaseProvider.COLUMN_OWNER: owner,
      DatabaseProvider.COLUMN_DATE: date.toIso8601String(),
      DatabaseProvider.COLUMN_DUEDATE: dueDate.toIso8601String(),
      DatabaseProvider.COLUMN_ISINFLOW: isInflow ? 1 : 0,
      DatabaseProvider.COLUMN_NOTE: note,
    };
  }

  factory Trosa.fromMap(Map<String, dynamic> data) {
    return Trosa(
      id: data[DatabaseProvider.COLUMN_ID] as int?,
      amount: double.tryParse(
              data[DatabaseProvider.COLUMN_AMOUNT]?.toString() ?? '') ??
          0,
      owner: data[DatabaseProvider.COLUMN_OWNER]?.toString() ?? '',
      date: _parseDate(data[DatabaseProvider.COLUMN_DATE]),
      dueDate: _parseDate(data[DatabaseProvider.COLUMN_DUEDATE]),
      isInflow: data[DatabaseProvider.COLUMN_ISINFLOW] == 1,
      note: data[DatabaseProvider.COLUMN_NOTE]?.toString(),
    );
  }

  /// Parses a stored date string, falling back to now for legacy/corrupt rows
  /// so old databases never crash on load.
  static DateTime _parseDate(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    return parsed ?? DateTime.now();
  }
}
