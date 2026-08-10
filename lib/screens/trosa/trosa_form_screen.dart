import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
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
  final TextEditingController _ownerController = TextEditingController();
  Trosa? _currentTrosa;

  static const List<String> _builtInCategories = [
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
    final settings = Provider.of<SettingsNotifier>(context, listen: false);

    if (trosaNotifier.currentTrosa != null) {
      _currentTrosa = trosaNotifier.currentTrosa;
    } else {
      _currentTrosa = Trosa(
        isInflow: true,
        reminderEnabled: true,
        reminderDaysBefore: settings.reminderDaysBefore,
        reminderTimeMinutes: settings.reminderTimeMinutes,
      );
    }
    _ownerController.text = _currentTrosa!.owner;
  }

  @override
  void dispose() {
    _ownerController.dispose();
    super.dispose();
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
    trosa.owner = _ownerController.text.trim();
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

  /// Requests contacts permission and lets the user pick an owner from their
  /// phone contacts, filling the owner field with the display name.
  Future<void> _pickContact() async {
    final l10n = AppLocalizations.of(context);
    try {
      final status =
          await FlutterContacts.permissions.request(PermissionType.read);
      if (status != PermissionStatus.granted &&
          status != PermissionStatus.limited) {
        return;
      }
      final contacts = await FlutterContacts.getAll();
      if (!mounted) return;
      if (contacts.isEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.statsEmpty)));
        return;
      }

      final picked = await showModalBottomSheet<Contact>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => _ContactPickerSheet(contacts: contacts),
      );
      final name = picked?.displayName;
      if (name != null && name.isNotEmpty && mounted) {
        setState(() {
          _ownerController.text = name;
        });
      }
    } catch (_) {
      // Plugin missing or permission flow interrupted: fall back to typing.
    }
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

  Future<void> _addCustomCategory(AppLocalizations l10n) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.addCategory),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: l10n.newCategoryHint),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.no),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, controller.text.trim()),
              child: Text(l10n.yes),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (name == null || name.isEmpty || !mounted) return;

    final settings = Provider.of<SettingsNotifier>(context, listen: false);
    final added = await settings.addCustomCategory(name);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(added ? l10n.categoryAdded : l10n.categoryExists),
      ));
  }

  String _formatTime(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickReminderTime() async {
    final trosa = _currentTrosa!;
    final initial = TimeOfDay(
      hour: trosa.reminderTimeMinutes ~/ 60,
      minute: trosa.reminderTimeMinutes % 60,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null && mounted) {
      setState(() {
        trosa.reminderTimeMinutes = picked.hour * 60 + picked.minute;
      });
    }
  }

  int _leadToDays(String lead) {
    switch (lead) {
      case '0':
        return 0;
      case '2':
        return 2;
      case '7':
        return 7;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = Provider.of<SettingsNotifier>(context);
    final trosa = _currentTrosa!;
    final isNew = trosa.id == null;
    final symbol = settings.currencySymbol;
    final hintColor = Theme.of(context).colorScheme.onSurfaceVariant;

    // Built-in + custom categories, then the "add new" entry.
    final categoryItems = <String>[
      ..._builtInCategories,
      ...settings.customCategories,
    ];

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
                    controller: _ownerController,
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: l10n.ownerLabel,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.contacts),
                        tooltip: l10n.contactLabel,
                        onPressed: _pickContact,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.ownerRequired;
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: DropdownButtonFormField<String>(
                    initialValue: trosa.category,
                    decoration: InputDecoration(
                      labelText: l10n.categoryLabel,
                    ),
                    items: [
                      ...categoryItems.map((c) => DropdownMenuItem<String>(
                            value: c,
                            child: Text(_categoryLabel(l10n, c)),
                          )),
                      DropdownMenuItem<String>(
                        value: '__add__',
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.add, size: 18),
                            const SizedBox(width: 6),
                            Text(l10n.addCategory),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == '__add__') {
                        _addCustomCategory(l10n);
                        return;
                      }
                      setState(() {
                        trosa.category = value ?? '';
                      });
                    },
                    onSaved: (value) {
                      if (value != '__add__') {
                        trosa.category = value ?? '';
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.reminderSection,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.reminderEnabledLabel),
                        value: trosa.reminderEnabled,
                        onChanged: (value) {
                          setState(() {
                            trosa.reminderEnabled = value;
                          });
                        },
                      ),
                      if (trosa.reminderEnabled) ...[
                        DropdownButtonFormField<String>(
                          initialValue: '${trosa.reminderDaysBefore}',
                          decoration: InputDecoration(
                            labelText: l10n.reminderLeadLabel,
                          ),
                          items: [
                            DropdownMenuItem<String>(
                              value: '0',
                              child: Text(l10n.reminderLeadSameDay),
                            ),
                            DropdownMenuItem<String>(
                              value: '1',
                              child: Text(l10n.reminderLeadOneDay),
                            ),
                            DropdownMenuItem<String>(
                              value: '2',
                              child: Text(l10n.reminderLeadTwoDays),
                            ),
                            DropdownMenuItem<String>(
                              value: '7',
                              child: Text(l10n.reminderLeadOneWeek),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                trosa.reminderDaysBefore =
                                    _leadToDays(value);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.schedule),
                          title: Text(l10n.reminderTimeLabel),
                          trailing: TextButton(
                            onPressed: _pickReminderTime,
                            child: Text(
                              _formatTime(trosa.reminderTimeMinutes),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isNew) ...[
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
                ],
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

/// Searchable list of phone contacts shown in a bottom sheet so the user can
/// pick an owner without typing the full name.
class _ContactPickerSheet extends StatefulWidget {
  final List<Contact> contacts;

  const _ContactPickerSheet({required this.contacts});

  @override
  State<_ContactPickerSheet> createState() => _ContactPickerSheetState();
}

class _ContactPickerSheetState extends State<_ContactPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final filtered = _query.isEmpty
        ? widget.contacts
        : widget.contacts
            .where((c) => (c.displayName ?? '')
                .toLowerCase()
                .contains(_query.toLowerCase()))
            .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                autofocus: true,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l10n.searchHint,
                ),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        l10n.statsEmpty,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final contact = filtered[index];
                        final name = contact.displayName ?? '';
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(name.isNotEmpty
                                ? name.characters.first.toUpperCase()
                                : '?'),
                          ),
                          title: Text(name),
                          subtitle: contact.phones.isNotEmpty
                              ? Text(contact.phones.first.number)
                              : null,
                          onTap: () => Navigator.pop(context, contact),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
