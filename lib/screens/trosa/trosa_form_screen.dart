import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trosa/api/trosa_api.dart';
import 'package:trosa/components/currency_input_formatter.dart';
import 'package:trosa/db/sqflite_provider.dart';
import 'package:trosa/models/trosa.dart';
import 'package:trosa/notifier/trosa_notifier.dart';

class TrosaAddPage extends StatefulWidget {
  const TrosaAddPage({super.key});

  @override
  State<TrosaAddPage> createState() => _TrosaAddPageState();
}

class _TrosaAddPageState extends State<TrosaAddPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final NumberFormat _formatter = NumberFormat('###,###', 'fr_FR');
  Trosa? _currentTrosa;

  @override
  void initState() {
    super.initState();
    final trosaNotifier = Provider.of<TrosaNotifier>(context, listen: false);

    if (trosaNotifier.currentTrosa != null) {
      _currentTrosa = trosaNotifier.currentTrosa;
    } else {
      _currentTrosa = Trosa(isInflow: true);
    }
  }

  Future<void> _saveTrosa() async {
    final trosaNotifier = Provider.of<TrosaNotifier>(context, listen: false);
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final trosa = _currentTrosa!;
    if (trosa.id != null) {
      await DatabaseProvider.db.update(trosa);
    } else {
      trosaNotifier.addTrosa(trosa);
      await DatabaseProvider.db.insert(trosa);
    }

    await getTrosa(trosaNotifier);
    trosaNotifier.currentTrosa = null;
    if (mounted) Navigator.pop(context);
  }

  Future<DateTime> _selectDate(DateTime selectedDate) async {
    final initialDate = selectedDate;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        initialDate.hour,
        initialDate.minute,
        initialDate.second,
        initialDate.millisecond,
        initialDate.microsecond,
      );
    }
    return selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    final trosa = _currentTrosa!;
    final isNew = trosa.id == null;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(isNew ? 'Hampiditra Trosa' : 'Fanitsiana Trosa'),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              shape: const CircleBorder(
                side: BorderSide(color: Colors.transparent),
              ),
            ),
            onPressed: _saveTrosa,
            child: const Icon(Icons.check, size: 30),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CurrencyInputFormatter(),
                    ],
                    initialValue: trosa.amount > 0
                        ? _formatter.format(trosa.amount)
                        : null,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.end,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Ohatrinona',
                      suffixText: 'MGA',
                      suffixIcon: IconButton(
                        icon: Icon(
                          trosa.isInflow
                              ? Icons.add
                              : Icons.remove,
                          color: trosa.isInflow ? Colors.green : Colors.red,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            trosa.isInflow = !trosa.isInflow;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Mila soratana hoe ohatrinona azafady.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      final digitsOnly = value?.replaceAll(RegExp(r'[^\d]'), '');
                      trosa.amount = double.tryParse(digitsOnly ?? '') ?? 0;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextFormField(
                    initialValue: trosa.owner,
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Ilay olona',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Mila fenoina ny anaran\'ilay olona.';
                      }
                      return null;
                    },
                    onSaved: (value) => trosa.owner = value ?? '',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('Haverina ny '),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              Icons.calendar_today,
                              size: 22.0,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 16.0),
                            Text(
                              DateFormat.yMMMEd().format(trosa.dueDate),
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          final picked =
                              await _selectDate(trosa.dueDate);
                          if (!mounted) return;
                          setState(() {
                            trosa.dueDate = picked;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextFormField(
                    initialValue: trosa.note,
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Fanamarihana',
                    ),
                    onSaved: (value) {
                      trosa.note = value;
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
