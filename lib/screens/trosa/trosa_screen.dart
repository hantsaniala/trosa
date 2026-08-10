import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trosa/api/trosa_api.dart';
import 'package:trosa/components/currency_input_formatter.dart';
import 'package:trosa/db/sqflite_provider.dart';
import 'package:trosa/l10n/app_localizations.dart';
import 'package:trosa/models/trosa.dart';
import 'package:trosa/notifier/settings_notifier.dart';
import 'package:trosa/notifier/trosa_notifier.dart';
import 'package:trosa/screens/trosa/components/trosa_card.dart';
import 'package:trosa/screens/trosa/trosa_about.dart';
import 'package:trosa/screens/trosa/trosa_form_screen.dart';
import 'package:trosa/screens/trosa/trosa_settings_dialog.dart';
import 'package:trosa/screens/trosa/trosa_stats_screen.dart';
import 'package:trosa/services/notification_service.dart';
import 'package:trosa/theme.dart';

enum StatusFilter { all, unpaid, paid, overdue }

class TrosaPage extends StatefulWidget {
  const TrosaPage({super.key});

  @override
  State<TrosaPage> createState() => _TrosaPageState();
}

class _TrosaPageState extends State<TrosaPage> {
  final NumberFormat _formatter = NumberFormat('###,###', 'fr');
  // Hoisted once — DateFormat construction is expensive and was previously
  // done twice per list row on every build (lag on old devices).
  final DateFormat _dateFormat = DateFormat('d/M/y');
  final TextEditingController _searchController = TextEditingController();
  static const String _appUrl = 'https://apkpure.com/p/mg.hantsaniala.trosa';

  String _searchQuery = '';
  StatusFilter _statusFilter = StatusFilter.all;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings = Provider.of<SettingsNotifier>(context, listen: false);
      final notifier = Provider.of<TrosaNotifier>(context, listen: false);

      await settings.load();
      notifier.sortType = settings.sortType;
      notifier.sortAscend = settings.sortAscend;

      await rolloverRecurringDebts();
      await _reload(notifier);
      _rescheduleNotifications();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload(TrosaNotifier notifier) async {
    await getTrosa(notifier);
    _applyView(notifier);
  }

  void _rescheduleNotifications() {
    final l10n = AppLocalizations.of(context);
    NotificationService.instance
        .rescheduleAll(l10n.appName, (t) => l10n.notificationBody(t.owner));
  }

  Future<void> _refreshList() async {
    final notifier = Provider.of<TrosaNotifier>(context, listen: false);
    await _reload(notifier);
    _rescheduleNotifications();
  }

  Future<void> _gotoAddPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => const TrosaAddPage()),
    );
    _rescheduleNotifications();
  }

  Future<void> _shareApp() async {
    final l10n = AppLocalizations.of(context);
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        text: l10n.shareAppMessage(_appUrl),
        sharePositionOrigin:
            box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      ),
    );
  }

  Future<bool> _confirmDeleteTrosa() async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteDebtTitle),
          content: Text(l10n.deleteDebtMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.no),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                l10n.yes,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _deleteTrosa(Trosa trosa) async {
    final notifier = Provider.of<TrosaNotifier>(context, listen: false);
    notifier.removeCurrent(trosa);
    await DatabaseProvider.db.delete(trosa);
    await NotificationService.instance.cancel(trosa.id ?? -1);
    await _reload(notifier);
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.deletedSnackBar),
          action: SnackBarAction(
            label: l10n.undoAction,
            onPressed: () async {
              await DatabaseProvider.db.restore(trosa);
              await _reload(notifier);
              _rescheduleNotifications();
            },
          ),
        ),
      );
  }

  Future<void> _togglePaid(Trosa trosa) async {
    final notifier = Provider.of<TrosaNotifier>(context, listen: false);
    // Dismissible requires the item to leave the tree; remove it now and let
    // the reload bring it back with the new state.
    notifier.removeCurrent(trosa);
    final nowPaid = !trosa.isPaid;
    trosa.paidAmount = nowPaid ? trosa.amount : 0;
    trosa.paidDate = nowPaid ? DateTime.now() : null;
    await DatabaseProvider.db.update(trosa);
    if (nowPaid) {
      await NotificationService.instance.cancel(trosa.id ?? -1);
    }
    await _reload(notifier);
    _rescheduleNotifications();
  }

  /// Records a partial payment: adds to paidAmount and settles the debt (with
  /// the settle date) when the full amount is covered.
  Future<void> _recordPayment(Trosa trosa) async {
    final l10n = AppLocalizations.of(context);
    final settings = Provider.of<SettingsNotifier>(context, listen: false);
    final controller = TextEditingController(
      text: trosa.remaining > 0 ? _formatter.format(trosa.remaining) : '',
    );

    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.paymentDialogTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter(),
            ],
            textAlign: TextAlign.end,
            decoration: InputDecoration(
              labelText: l10n.paymentHint,
              suffixText: l10n.currencySuffix(settings.currencySymbol),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.no),
            ),
            TextButton(
              onPressed: () {
                final digits =
                    controller.text.replaceAll(RegExp(r'[^\d]'), '');
                Navigator.pop(dialogContext, double.tryParse(digits) ?? 0);
              },
              child: Text(l10n.yes),
            ),
          ],
        );
      },
    );

    if (amount == null || amount <= 0) return;
    if (!mounted) return;

    final notifier = Provider.of<TrosaNotifier>(context, listen: false);
    trosa.paidAmount = (trosa.paidAmount + amount).clamp(0.0, trosa.amount);
    final fullyPaid = trosa.paidAmount >= trosa.amount;
    trosa.paidDate = fullyPaid ? DateTime.now() : null;
    await DatabaseProvider.db.update(trosa);
    if (fullyPaid) {
      await NotificationService.instance.cancel(trosa.id ?? -1);
    }
    await _reload(notifier);
    _rescheduleNotifications();

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.paymentRecorded)));
  }

  /// Shows the quick actions for a debt: record a payment, mark as paid or
  /// edit. Triggered by tapping a card.
  void _showCardActions(Trosa trosa) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.payments),
                title: Text(l10n.recordPaymentAction),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _recordPayment(trosa);
                },
              ),
              if (!trosa.isPaid)
                ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(l10n.markPaidAction),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _togglePaid(trosa);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(l10n.editAction),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Provider.of<TrosaNotifier>(context, listen: false)
                      .currentTrosa = trosa;
                  _gotoAddPage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _applyView(TrosaNotifier notifier) {
    final query = _searchQuery.toLowerCase();
    final filtered = notifier.trosaList.where((t) {
      final matchesStatus = switch (_statusFilter) {
        StatusFilter.all => true,
        StatusFilter.unpaid => !t.isPaid,
        StatusFilter.paid => t.isPaid,
        StatusFilter.overdue => t.isOverdue,
      };
      if (!matchesStatus) return false;
      if (query.isEmpty) return true;
      return t.owner.toLowerCase().contains(query) ||
          (t.note ?? '').toLowerCase().contains(query) ||
          t.category.toLowerCase().contains(query);
    }).toList();

    notifier.currentTrosaList = filtered;
    _applySort(notifier);
  }

  void _applySort(TrosaNotifier notifier) {
    final list = notifier.currentTrosaList;
    // Paid archive: show recently settled debts first.
    if (_statusFilter == StatusFilter.paid) {
      list.sort((a, b) {
        final da = a.paidDate ?? a.date;
        final db = b.paidDate ?? b.date;
        return db.compareTo(da);
      });
      return;
    }
    switch (notifier.sortType) {
      case 'amount':
        list.sort((a, b) => notifier.sortAscend
            ? a.amount.compareTo(b.amount)
            : b.amount.compareTo(a.amount));
        break;
      case 'owner':
        list.sort((a, b) => notifier.sortAscend
            ? a.owner.toLowerCase().compareTo(b.owner.toLowerCase())
            : b.owner.toLowerCase().compareTo(a.owner.toLowerCase()));
        break;
      default:
        list.sort((a, b) => notifier.sortAscend
            ? a.date.compareTo(b.date)
            : b.date.compareTo(a.date));
        break;
    }
  }

  Future<void> _persistSort(TrosaNotifier notifier) async {
    final settings = Provider.of<SettingsNotifier>(context, listen: false);
    await settings.setSortPreference(notifier.sortType, notifier.sortAscend);
  }

  void _chooseMenuAction(String choice) {
    final l10n = AppLocalizations.of(context);
    final notifier = Provider.of<TrosaNotifier>(context, listen: false);
    if (choice == l10n.about) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (context) => const TrosaAboutPage()),
      );
    } else if (choice == l10n.stats) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (context) => const TrosaStatsScreen()),
      );
    } else if (choice == l10n.settings) {
      _showSettingsDialog();
    } else if (choice == l10n.sortByAmount) {
      notifier.sortType = 'amount';
      _applySort(notifier);
      _persistSort(notifier);
    } else if (choice == l10n.sortByDate) {
      notifier.sortType = 'date';
      _applySort(notifier);
      _persistSort(notifier);
    } else if (choice == l10n.sortByOwner) {
      notifier.sortType = 'owner';
      _applySort(notifier);
      _persistSort(notifier);
    }
  }

  void _toggleSortDirection() {
    final notifier = Provider.of<TrosaNotifier>(context, listen: false);
    notifier.sortAscend = !notifier.sortAscend;
    _applySort(notifier);
    _persistSort(notifier);
  }

  void _showSettingsDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => TrosaSettingsDialog(
        onDataChanged: _refreshList,
      ),
    );
  }

  // No setState here: _applyView pushes the result through the notifier, and
  // the Consumer-wrapped subtrees below rebuild on that notification. This
  // keeps per-keystroke search work limited to the list instead of the whole
  // page (lag on old devices).
  void _onSearchChanged(String value) {
    _searchQuery = value;
    final notifier = Provider.of<TrosaNotifier>(context, listen: false);
    _applyView(notifier);
  }

  void _onFilterChanged(StatusFilter filter) {
    _statusFilter = filter;
    final notifier = Provider.of<TrosaNotifier>(context, listen: false);
    _applyView(notifier);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = Provider.of<SettingsNotifier>(context);
    final symbol = settings.currencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            tooltip: Theme.of(context).brightness == Brightness.dark
                ? l10n.themeLight
                : l10n.themeDark,
            onPressed: () {
              final settings =
                  Provider.of<SettingsNotifier>(context, listen: false);
              settings.setThemeMode(
                Theme.of(context).brightness == Brightness.dark
                    ? ThemeMode.light
                    : ThemeMode.dark,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareApp,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _chooseMenuAction,
            itemBuilder: (context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: l10n.about,
                  child: Text(l10n.about),
                ),
                PopupMenuItem<String>(
                  value: l10n.stats,
                  child: Text(l10n.stats),
                ),
                PopupMenuItem<String>(
                  value: l10n.settings,
                  child: Text(l10n.settings),
                ),
              ];
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshList,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Consumer<TrosaNotifier>(
              builder: (context, notifier, _) {
                final balance = notifier.balance;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.brand, AppTheme.brandDeep],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33C78E00),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            _heroLabel(l10n.moneyToReceive, Icons.south_west),
                            _heroLabel(l10n.moneyToPay, Icons.north_east),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              '${l10n.currencyPrefix(symbol)}${_formatter.format(notifier.totalInflow)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E6B2F),
                              ),
                            ),
                            Text(
                              '${l10n.currencyPrefix(symbol)}${_formatter.format(notifier.totalOutflow)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFB3261E),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(
                            height: 1,
                            color: Color(0x55241D00),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              l10n.balance,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xB3241D00),
                              ),
                            ),
                            Text(
                              '${l10n.currencyPrefix(symbol)}${_formatter.format(balance)}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: balance <= 0
                                    ? const Color(0xFFB3261E)
                                    : const Color(0xFF1E6B2F),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l10n.searchHint,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Consumer<TrosaNotifier>(
                  builder: (context, _, __) {
                    return Row(
                      children: <Widget>[
                        _filterChip(l10n.filterAll, StatusFilter.all),
                        _filterChip(l10n.filterUnpaid, StatusFilter.unpaid),
                        _filterChip(l10n.filterPaid, StatusFilter.paid),
                        _filterChip(l10n.filterOverdue, StatusFilter.overdue),
                      ],
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 18, left: 18),
              child: Row(
                children: [
                  Text(
                    l10n.debtListTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Consumer<TrosaNotifier>(
                      builder: (context, notifier, _) => Icon(
                        notifier.sortAscend
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                      ),
                    ),
                    onPressed: _toggleSortDirection,
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.sort),
                    onSelected: _chooseMenuAction,
                    itemBuilder: (context) {
                      return <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: l10n.sortByDate,
                          child: Text(l10n.sortByDate),
                        ),
                        PopupMenuItem<String>(
                          value: l10n.sortByOwner,
                          child: Text(l10n.sortByOwner),
                        ),
                        PopupMenuItem<String>(
                          value: l10n.sortByAmount,
                          child: Text(l10n.sortByAmount),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Consumer<TrosaNotifier>(
                  builder: (context, notifier, _) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: notifier.currentTrosaList.length,
                      itemExtent: 96,
                      itemBuilder: (context, index) {
                        final trosa = notifier.currentTrosaList[index];
                        return Dismissible(
                          key: ValueKey<Object>(trosa.id ?? index),
                          direction: DismissDirection.horizontal,
                          confirmDismiss: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              return _confirmDeleteTrosa();
                            }
                            return Future.value(true);
                          },
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              _deleteTrosa(trosa);
                            } else {
                              _togglePaid(trosa);
                            }
                          },
                          background: Container(
                            color: Colors.red[700],
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete_forever,
                              color: Colors.white,
                            ),
                          ),
                          secondaryBackground: Container(
                            color: Colors.green,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () => _showCardActions(trosa),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 2, bottom: 0),
                              child: TrosaCard(
                                isInflow: trosa.isInflow,
                                amount: _formatter.format(trosa.amount),
                                remaining:
                                    _formatter.format(trosa.remaining),
                                owner: trosa.owner,
                                dueDate: _dateFormat.format(trosa.dueDate),
                                date: _dateFormat.format(trosa.date),
                                note: trosa.note ?? '',
                                isPaid: trosa.isPaid,
                                isOverdue: trosa.isOverdue,
                                isDueSoon: trosa.isDueSoon,
                                paidAmount: trosa.paidAmount,
                                paidPercent: trosa.paidPercent,
                                category: trosa.category,
                                symbol: symbol,
                                settledDate: trosa.isPaid &&
                                        trosa.paidDate != null
                                    ? _dateFormat.format(trosa.paidDate!)
                                    : null,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<TrosaNotifier>(context, listen: false).currentTrosa =
              null;
          _gotoAddPage();
        },
        tooltip: l10n.addDebt,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _filterChip(String label, StatusFilter filter) {
    final scheme = Theme.of(context).colorScheme;
    final bool selected = _statusFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: selected ? scheme.onPrimary : scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        selected: selected,
        onSelected: (_) => _onFilterChanged(filter),
      ),
    );
  }

  /// Small label with an icon used inside the brand hero card.
  Widget _heroLabel(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 15, color: const Color(0xB3241D00)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xB3241D00),
          ),
        ),
      ],
    );
  }
}
