import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trosa/api/trosa_api.dart';
import 'package:trosa/components/currency_input_formatter.dart';
import 'package:trosa/db/sqflite_provider.dart';
import 'package:trosa/l10n/app_localizations.dart';
import 'package:trosa/models/trosa.dart';
import 'package:trosa/notifier/settings_notifier.dart';
import 'package:trosa/notifier/trosa_notifier.dart';

class TrosaAddPage extends StatefulWidget {
  const TrosaAddPage({super.key});

  @override
  State<TrosaAddPage> createState() => _TrosaAddPageState();
}

class _TrosaAddPageState extends State<TrosaAddPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final NumberFormat _formatter = NumberFormat('###,###', 'fr_FR');
  // Reused by both money fields; avoids re-allocating a NumberFormat (inside
  // CurrencyInputFormatter) on every rebuild.
  final CurrencyInputFormatter _currencyFormatter = CurrencyInputFormatter();
  Trosa? _currentTrosa;

  static const List<String> _categories = [
    '',
    'Fianakaviana',
    'Namana',
    'Asa',
    'Hafa',
  ];

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

  String _categoryLabel(AppLocalizations l10n, String category) {
    switch (category) {
      case 'Fianakaviana':
        return l10n.categoryFamily;
      case 'Namana':
        return l10n.categoryFriends;
      case 'Asa':
        return l10n.categoryWork;
      case 'Hafa':
        return l10n.categoryOther;
      default:
        return l10n.noCategory;
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
    final l10n = AppLocalizations.of(context);
    final settings = Provider.of<SettingsNotifier>(context);
    final trosa = _currentTrosa!;
    final isNew = trosa.id == null;
    final symbol = settings.currencySymbol;
    final hintColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(isNew ? l10n.addDebt : l10n.editDebt),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                      _currencyFormatter,
                    ],
                    initialValue: trosa.amount > 0
                        ? _formatter.format(trosa.amount)
                        : null,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.end,
                    decoration: InputDecoration(
                      labelText: l10n.amountLabel,
                      suffixText: l10n.currencySuffix(symbol),
                      suffixIcon: IconButton(
                        icon: Icon(
                          trosa.isInflow ? Icons.add : Icons.remove,
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
                        return l10n.amountRequired;
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
                    decoration: InputDecoration(
                      labelText: l10n.ownerLabel,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.ownerRequired;
                      }
                      return null;
                    },
                    onSaved: (value) => trosa.owner = value ?? '',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: DropdownButtonFormField<String>(
                    initialValue: trosa.category,
                    decoration: InputDecoration(
                      labelText: l10n.categoryLabel,
                    ),
                    items: _categories
                        .map((c) => DropdownMenuItem<String>(
                              value: c,
                              child: Text(_categoryLabel(l10n, c)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        trosa.category = value ?? '';
                      });
                    },
                    onSaved: (value) {
                      trosa.category = value ?? '';
                    },
                  ),
                ),
                if (!isNew)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextFormField(
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _currencyFormatter,
                      ],
                      initialValue: trosa.paidAmount > 0
                          ? _formatter.format(trosa.paidAmount)
                          : null,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: l10n.paidAmountLabel,
                        suffixText: l10n.currencySuffix(symbol),
                      ),
                      onSaved: (value) {
                        final digitsOnly =
                            value?.replaceAll(RegExp(r'[^\d]'), '');
                        trosa.paidAmount = double.tryParse(digitsOnly ?? '') ?? 0;
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextFormField(
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    initialValue:
                        trosa.recurringDays > 0 ? '${trosa.recurringDays}' : null,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.recurringLabel,
                    ),
                    onSaved: (value) {
                      trosa.recurringDays = int.tryParse(value ?? '') ?? 0;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(l10n.dueDateLabel),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.calendar_today,
                              size: 22.0,
                              color: hintColor,
                            ),
                            const SizedBox(width: 16.0),
                            Text(
                              DateFormat.yMMMEd().format(trosa.dueDate),
                              style: TextStyle(color: hintColor),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: hintColor,
                            ),
                          ],
                        ),
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          final picked = await _selectDate(trosa.dueDate);
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
                    decoration: InputDecoration(
                      labelText: l10n.noteLabel,
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
