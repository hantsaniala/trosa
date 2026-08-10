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
  double paidAmount;
  String category;
  int recurringDays;
  DateTime? paidDate;
  bool reminderEnabled;
  int reminderDaysBefore;
  int reminderTimeMinutes;

  Trosa({
    this.id,
    this.amount = 0,
    this.owner = '',
    DateTime? date,
    DateTime? dueDate,
    this.isInflow = true,
    this.note,
    this.paidAmount = 0,
    this.category = '',
    this.recurringDays = 0,
    this.paidDate,
    this.reminderEnabled = true,
    this.reminderDaysBefore = 1,
    this.reminderTimeMinutes = 540,
  })  : date = date ?? DateTime.now(),
        dueDate = dueDate ?? DateTime.now();

  /// Percent of the amount already paid (0..100).
  int get paidPercent =>
      amount <= 0 ? 0 : ((paidAmount / amount) * 100).round().clamp(0, 100);

  /// Amount still owed (never negative).
  double get remaining {
    final diff = amount - paidAmount;
    return diff < 0 ? 0 : diff;
  }

  bool get isPaid => remaining <= 0;

  /// True when the due date is in the past and the debt is still outstanding.
  bool get isOverdue => !isPaid && dueDate.isBefore(DateTime.now());

  /// True when the debt is due within the next 7 days and still outstanding.
  bool get isDueSoon {
    if (isPaid) return false;
    final now = DateTime.now();
    return !dueDate.isBefore(now) && dueDate.isBefore(now.add(const Duration(days: 7)));
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      DatabaseProvider.columnAmount: amount,
      DatabaseProvider.columnOwner: owner,
      DatabaseProvider.columnDate: date.toIso8601String(),
      DatabaseProvider.columnDueDate: dueDate.toIso8601String(),
      DatabaseProvider.columnIsInflow: isInflow ? 1 : 0,
      DatabaseProvider.columnNote: note,
      DatabaseProvider.columnPaidAmount: paidAmount,
      DatabaseProvider.columnCategory: category,
      DatabaseProvider.columnRecurringDays: recurringDays,
      DatabaseProvider.columnPaidDate: paidDate?.toIso8601String(),
      DatabaseProvider.columnReminderEnabled: reminderEnabled ? 1 : 0,
      DatabaseProvider.columnReminderDaysBefore: reminderDaysBefore,
      DatabaseProvider.columnReminderTimeMinutes: reminderTimeMinutes,
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
      paidAmount: double.tryParse(
              data[DatabaseProvider.columnPaidAmount]?.toString() ?? '') ??
          0,
      category: data[DatabaseProvider.columnCategory]?.toString() ?? '',
      recurringDays: int.tryParse(
              data[DatabaseProvider.columnRecurringDays]?.toString() ?? '') ??
          0,
      paidDate: _parseNullableDate(data[DatabaseProvider.columnPaidDate]),
      reminderEnabled: data[DatabaseProvider.columnReminderEnabled] != 0,
      reminderDaysBefore: int.tryParse(data[DatabaseProvider.columnReminderDaysBefore]
              ?.toString() ??
          '') ??
          1,
      reminderTimeMinutes: int.tryParse(
              data[DatabaseProvider.columnReminderTimeMinutes]?.toString() ??
                  '') ??
          540,
    );
  }

  /// Parses a stored date string, falling back to now for legacy/corrupt rows
  /// so old databases never crash on load.
  static DateTime _parseDate(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    return parsed ?? DateTime.now();
  }

  /// Parses a nullable date string (e.g. `paidDate`), null when absent.
  static DateTime? _parseNullableDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
