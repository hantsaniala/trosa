import 'package:Trosa/api/trosa_api.dart';
import 'package:Trosa/components/currency_input_formatter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:Trosa/db/sqflite_provider.dart';
import 'package:Trosa/models/trosa.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:Trosa/notifier/trosa_notifier.dart';

class TrosaAddPage extends StatefulWidget {
  TrosaAddPage({Key? key}) : super(key: key);

  @override
  _TrosaAddPageState createState() => _TrosaAddPageState();
}

class _TrosaAddPageState extends State<TrosaAddPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final formatter = new NumberFormat('###,###', 'fr_FR');
  FocusNode? focusNode;
  Trosa? _currentTrosa;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    TrosaNotifier trosaNotifier =
        Provider.of<TrosaNotifier>(context, listen: false);

    if (trosaNotifier.currentTrosa != null) {
      print('Updating trosa');
      _currentTrosa = trosaNotifier.currentTrosa;
    } else {
      print('Adding new trosa');
      _currentTrosa =
          new Trosa("", 0, "", Timestamp.fromDate(DateTime.now()), true, "");
    }
  }

  @override
  void dispose() {
    focusNode?.dispose();
    super.dispose();
  }

// Date Picker
  Future<DateTime> _selectDate(DateTime selectedDate) async {
    DateTime _initialDate = selectedDate;
    final DateTime? _pickedDate = await showDatePicker(
      context: context,
      initialDate: _initialDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (_pickedDate != null) {
      selectedDate = DateTime(
          _pickedDate.year,
          _pickedDate.month,
          _pickedDate.day,
          _initialDate.hour,
          _initialDate.minute,
          _initialDate.second,
          _initialDate.millisecond,
          _initialDate.microsecond);
    }
    return selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    TrosaNotifier trosaNotifier =
        Provider.of<TrosaNotifier>(context, listen: false);
    DateTime _selectedDate;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Hampiditra Trosa'),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.black,
            onPressed: () {
              // FIXME: DRY with save button at the end
              // TODO: Show button only when one the fields is updated
              FocusScope.of(context).requestFocus(new FocusNode());
              if (!_formKey.currentState!.validate()) return;
              _formKey.currentState?.save();
              setState(() {
                if (trosaNotifier.currentTrosa != null) {
                  trosaNotifier.currentTrosa = _currentTrosa;
                  DatabaseProvider.db.update(_currentTrosa);
                } else {
                  trosaNotifier.addTrosa(_currentTrosa);
                  DatabaseProvider.db.insert(_currentTrosa);
                }
              });
              getTrosa(trosaNotifier);
              trosaNotifier.currentTrosa = null;
              Navigator.pop(context);
            },
            child: Icon(
              Icons.check,
              size: 30,
            ),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ],
      ),
      // FIXME : Form stay behind the keyboard
      body: ListView(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CurrencyInputFormatter()
                    ],
                    initialValue: (trosaNotifier.currentTrosa?.amount != null)
                        ? formatter.format(trosaNotifier.currentTrosa?.amount)
                        : null,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.end,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Ohatrinona',
                        suffix: Text('MGA'),
                        suffixIcon: IconButton(
                          icon: (_currentTrosa?.isInflow != null &&
                                  _currentTrosa?.isInflow == true)
                              ? Icon(Icons.add, color: Colors.green, size: 30)
                              : Icon(Icons.remove, color: Colors.red, size: 30),
                          onPressed: () {
                            setState(() {
                              if (_currentTrosa?.isInflow != null &&
                                  _currentTrosa?.isInflow == true) {
                                _currentTrosa?.isInflow = false;
                              } else {
                                _currentTrosa?.isInflow = true;
                              }
                            });
                          },
                        )),
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'Mila soratana hoe ohatrinona azafady.';
                      }
                      return null;
                    },
                    onSaved: (amount) {
                      var newAmount = formatter.parse(amount.toString());
                      _currentTrosa?.amount =
                          double.tryParse(newAmount.toString());
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextFormField(
                    initialValue: _currentTrosa?.owner,
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Ilay olona',
                    ),
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'Mila fenoina ny anaran\'ilay olona.';
                      }
                      return null;
                    },
                    onSaved: (String? owner) => _currentTrosa?.owner = owner,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Haverina ny '),
                      FlatButton(
                        padding: EdgeInsets.all(0.0),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.calendar_today,
                                size: 22.0, color: Colors.black54),
                            SizedBox(width: 16.0),
                            Text(
                                DateFormat.yMMMEd()
                                    .format(_currentTrosa!.dueDate.toDate()),
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold)),
                            Icon(Icons.arrow_drop_down, color: Colors.black54),
                          ],
                        ),
                        onPressed: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          DateTime _pickerDate = await _selectDate(
                              _currentTrosa!.dueDate.toDate());
                          setState(() {
                            _selectedDate = _pickerDate;
                            _currentTrosa?.dueDate =
                                Timestamp.fromDate(_selectedDate);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextFormField(
                    initialValue: _currentTrosa?.note,
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Fanamarihana',
                    ),
                    onSaved: (String? note) {
                      _currentTrosa?.note = note;
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
