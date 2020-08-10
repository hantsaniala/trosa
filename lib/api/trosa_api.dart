import 'package:Trosa/db/sqflite_provider.dart';
import 'package:Trosa/models/trosa.dart';
import 'package:Trosa/notifier/trosa_notifier.dart';

/// Get list of Trosa object from Firestore or Sqflite.
getTrosa(TrosaNotifier trosaNotifier) async {
  List<Trosa> _trosaList = [];
  double _totalInflow = 0.0, _totalOutflow = 0.0, _balance = 0.0;

  _trosaList = await DatabaseProvider.db.getTrosa();
  _totalInflow = await DatabaseProvider.db.totalInflow();
  _totalOutflow = await DatabaseProvider.db.totalOutflow();

/*  List<Trosa> _trosaList = [];

   QuerySnapshot snapshot =
      await Firestore.instance.collection('Trosa').getDocuments();

  snapshot.documents.forEach((document) {
    Trosa trosa = Trosa.fromMap(document.data);
    _trosaList.add(trosa);
  });

  trosaNotifier.trosaList = _trosaList; */

  _balance = _totalInflow - _totalOutflow;

  trosaNotifier.trosaList = _trosaList;
  trosaNotifier.totalInflow = _totalInflow;
  trosaNotifier.totalOutflow = _totalOutflow;
  trosaNotifier.balance = _balance;
}
