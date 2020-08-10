import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:Trosa/models/trosa.dart';

class TrosaNotifier with ChangeNotifier {
  List<Trosa> _trosaList = [];
  Trosa _currentTrosa;
  double _totalInflow = 0.0, _totalOutflow = 0.0, _balance = 0.0;

  UnmodifiableListView<Trosa> get trosaList => UnmodifiableListView(_trosaList);

  Trosa get currentTrosa => _currentTrosa;
  double get totalInflow => _totalInflow;
  double get totalOutflow => _totalOutflow;
  double get balance => _balance;

  set trosaList(List<Trosa> trosaList) {
    _trosaList = trosaList;
    notifyListeners();
  }

  set currentTrosa(Trosa trosa) {
    _currentTrosa = trosa;
    notifyListeners();
  }

  void addTrosa(Trosa trosa) {
    _trosaList.add(trosa);
    notifyListeners();
  }

  void deleteTrosa(Trosa trosa) {
    _trosaList.remove(trosa);
    notifyListeners();
  }

  set totalInflow(totalInflow) {
    _totalInflow = totalInflow != null ? totalInflow : 0.0;
    notifyListeners();
  }

  set totalOutflow(totalOutflow) {
    _totalOutflow = totalOutflow != null ? totalOutflow : 0.0;
    notifyListeners();
  }

  set balance(balance) {
    _balance = balance != null ? balance : 0.0;
    notifyListeners();
  }
}
