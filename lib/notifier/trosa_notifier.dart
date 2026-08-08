import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:trosa/models/trosa.dart';

class TrosaNotifier extends ChangeNotifier {
  List<Trosa> _trosaList = [];
  List<Trosa> _currentTrosaList = [];
  Trosa? _currentTrosa;
  double _totalInflow = 0.0;
  double _totalOutflow = 0.0;
  double _balance = 0.0;
  bool _sortAscend = true;
  String _sortType = 'date';

  UnmodifiableListView<Trosa> get trosaList =>
      UnmodifiableListView(_trosaList);

  List<Trosa> get currentTrosaList => _currentTrosaList;
  Trosa? get currentTrosa => _currentTrosa;
  double get totalInflow => _totalInflow;
  double get totalOutflow => _totalOutflow;
  double get balance => _balance;
  bool get sortAscend => _sortAscend;
  String get sortType => _sortType;

  set trosaList(List<Trosa> value) {
    _trosaList = value;
    notifyListeners();
  }

  set currentTrosaList(List<Trosa> value) {
    _currentTrosaList = value;
    notifyListeners();
  }

  set currentTrosa(Trosa? value) {
    _currentTrosa = value;
    notifyListeners();
  }

  set totalInflow(double value) {
    _totalInflow = value;
    notifyListeners();
  }

  set totalOutflow(double value) {
    _totalOutflow = value;
    notifyListeners();
  }

  set balance(double value) {
    _balance = value;
    notifyListeners();
  }

  set sortAscend(bool value) {
    _sortAscend = value;
    notifyListeners();
  }

  set sortType(String value) {
    _sortType = value;
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

  /// Removes a record from the currently displayed list (used right after a
  /// Dismissible animation so the widget leaves the tree).
  void removeCurrent(Trosa trosa) {
    _currentTrosaList.remove(trosa);
    notifyListeners();
  }
}
