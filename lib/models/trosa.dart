import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Trosa/db/sqflite_provider.dart';

/// Class for Trosa object
class Trosa {
  String id;
  double amount;
  String owner;
  Timestamp date;
  Timestamp dueDate;
  bool isInflow;
  String note;

  Trosa(
      {this.amount,
      this.owner,
      this.date,
      this.isInflow,
      this.dueDate,
      this.note});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      DatabaseProvider.COLUMN_AMOUNT: amount,
      DatabaseProvider.COLUMN_OWNER: owner,
      DatabaseProvider.COLUMN_DATE:
          date != null ? date.toDate().toString() : DateTime.now().toString(),
      DatabaseProvider.COLUMN_DUEDATE: dueDate.toDate().toString(),
      DatabaseProvider.COLUMN_ISINFLOW: isInflow ? 1 : 0,
      DatabaseProvider.COLUMN_NOTE: note,
    };

    if (id != null) {
      map[DatabaseProvider.COLUMN_ID] = id;
    }
    return map;
  }

  Trosa.fromMap(Map<String, dynamic> data) {
    id = data[DatabaseProvider.COLUMN_ID].toString();
    amount = double.tryParse(data[DatabaseProvider.COLUMN_AMOUNT]);
    owner = data[DatabaseProvider.COLUMN_OWNER];
    date = Timestamp.fromDate(
        DateTime.tryParse(data[DatabaseProvider.COLUMN_DATE]));
    dueDate = Timestamp.fromDate(
        DateTime.tryParse(data[DatabaseProvider.COLUMN_DUEDATE]));
    isInflow = data[DatabaseProvider.COLUMN_ISINFLOW] == 1 ? true : false;
    note = data[DatabaseProvider.COLUMN_NOTE];
  }
}
