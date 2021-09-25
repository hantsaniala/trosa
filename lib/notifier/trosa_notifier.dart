import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:Trosa/models/trosa.dart';

class TrosaNotifier with ChangeNotifier {
  List<Trosa?> _trosaList = [];
  List<Trosa?> _currentTrosaList = [];
  Trosa? _currentTrosa;
  double _totalInflow = 0.0, _totalOutflow = 0.0, _balance = 0.0;
  bool _sortAscend = true;
  String _sortType = 'date';

  UnmodifiableListView<Trosa?> get trosaList =>
      UnmodifiableListView(_trosaList);

  Trosa? get currentTrosa => _currentTrosa;
  List<Trosa?> get currentTrosaList => _currentTrosaList;
  double? get totalInflow => _totalInflow;
  double? get totalOutflow => _totalOutflow;
  double? get balance => _balance;

  String get sortType => _sortType;
  bool get sortAscend => _sortAscend;

  set trosaList(List<Trosa?> trosaList) {
    _trosaList = trosaList;
    notifyListeners();
  }

  set currentTrosaList(List<Trosa?> currentTrosaList) {
    _currentTrosaList = currentTrosaList;
    notifyListeners();
  }

  set currentTrosa(Trosa? trosa) {
    _currentTrosa = trosa;
    notifyListeners();
  }

  void addTrosa(Trosa? trosa) {
    _trosaList.add(trosa);
    notifyListeners();
  }

  void deleteTrosa(Trosa? trosa) {
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

  set sortAscend(sortAscend) {
    _sortAscend = sortAscend;
    notifyListeners();
  }

  set sortType(sortType) {
    _sortType = sortType;
    notifyListeners();
  }
}
