import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trosa/api/trosa_api.dart';
import 'package:trosa/db/sqflite_provider.dart';
import 'package:trosa/l10n/app_localizations.dart';
import 'package:trosa/models/trosa.dart';
import 'package:trosa/notifier/trosa_notifier.dart';
import 'package:trosa/screens/trosa/components/trosa_card.dart';
import 'package:trosa/screens/trosa/trosa_about.dart';
import 'package:trosa/screens/trosa/trosa_form_screen.dart';

class TrosaPage extends StatefulWidget {
  const TrosaPage({super.key});

  @override
  State<TrosaPage> createState() => _TrosaPageState();
}

class _TrosaPageState extends State<TrosaPage> {
  final NumberFormat _formatter = NumberFormat('###,###', 'fr');
  static const String _appUrl = 'https://apkpure.com/p/mg.hantsaniala.trosa';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR');
    final trosaNotifier = Provider.of<TrosaNotifier>(context, listen: false);
    getTrosa(trosaNotifier);
  }

  Future<void> _refreshList(TrosaNotifier notifier) async {
    await getTrosa(notifier);
  }

  void _gotoAddPage() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => const TrosaAddPage()),
    );
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

  Future<void> _deleteTrosa(TrosaNotifier notifier, Trosa trosa) async {
    // Remove the item synchronously so the dismissed widget leaves the tree,
    // then persist and refresh the totals.
    notifier.deleteTrosa(trosa);
    await DatabaseProvider.db.delete(trosa);
    await getTrosa(notifier);
  }

  void _chooseMenuAction(TrosaNotifier notifier, String choice) {
    final l10n = AppLocalizations.of(context);
    if (choice == l10n.about) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (context) => const TrosaAboutPage()),
      );
    } else if (choice == l10n.sortByAmount) {
      setState(() {
        notifier.sortType = 'amount';
        _applySort(notifier);
      });
    } else if (choice == l10n.sortByDate) {
      setState(() {
        notifier.sortType = 'date';
        _applySort(notifier);
      });
    } else if (choice == l10n.sortByOwner) {
      setState(() {
        notifier.sortType = 'owner';
        _applySort(notifier);
      });
    }
  }

  void _toggleSortDirection(TrosaNotifier notifier) {
    setState(() {
      notifier.sortAscend = !notifier.sortAscend;
      _applySort(notifier);
    });
  }

  void _applySort(TrosaNotifier notifier) {
    final list = notifier.currentTrosaList;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final trosaNotifier = Provider.of<TrosaNotifier>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareApp,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (choice) => _chooseMenuAction(trosaNotifier, choice),
            itemBuilder: (context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: l10n.about,
                  child: Text(l10n.about),
                ),
              ];
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshList(trosaNotifier),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(l10n.moneyToReceive),
                          Text(l10n.moneyToPay),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '${l10n.currencyPrefix}${_formatter.format(trosaNotifier.totalInflow)}',
                            style: const TextStyle(
                                fontSize: 20, color: Colors.green),
                          ),
                          Text(
                            '${l10n.currencyPrefix}${_formatter.format(trosaNotifier.totalOutflow)}',
                            style: const TextStyle(
                                fontSize: 20, color: Colors.red),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: size.height * .03,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            l10n.balance,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '${l10n.currencyPrefix}${_formatter.format(trosaNotifier.balance)}',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w300,
                              color: (trosaNotifier.balance <= 0)
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 18, left: 18, top: 18),
              child: Row(
                children: [
                  Text(
                    l10n.debtListTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(trosaNotifier.sortAscend
                        ? Icons.arrow_downward
                        : Icons.arrow_upward),
                    onPressed: () => _toggleSortDirection(trosaNotifier),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.sort),
                    onSelected: (choice) =>
                        _chooseMenuAction(trosaNotifier, choice),
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
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: trosaNotifier.currentTrosaList.length,
                  itemExtent: 77,
                  itemBuilder: (context, index) {
                    final trosa = trosaNotifier.currentTrosaList[index];
                    return Dismissible(
                      key: ValueKey<Object>(trosa.id ?? index),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => _confirmDeleteTrosa(),
                      onDismissed: (_) => _deleteTrosa(trosaNotifier, trosa),
                      background: Container(
                        color: Colors.red[700],
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.delete_forever,
                          color: Colors.white,
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          trosaNotifier.currentTrosa = trosa;
                          _gotoAddPage();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 5, right: 5, top: 2, bottom: 0),
                          child: TrosaCard(
                            isInflow: trosa.isInflow,
                            amount:
                                _formatter.format(trosa.amount).toString(),
                            owner: trosa.owner,
                            dueDate: DateFormat('d/M/y').format(trosa.dueDate),
                            date: DateFormat('d/M/y').format(trosa.date),
                            note: trosa.note ?? '',
                          ),
                        ),
                      ),
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
          trosaNotifier.currentTrosa = null;
          _gotoAddPage();
        },
        tooltip: l10n.addDebt,
        child: const Icon(Icons.add),
      ),
    );
  }
}
