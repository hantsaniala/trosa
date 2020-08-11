import 'package:Trosa/screens/trosa/trosa_about.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:Trosa/api/trosa_api.dart';
import 'package:Trosa/db/sqflite_provider.dart';
import 'package:Trosa/notifier/trosa_notifier.dart';
import 'package:Trosa/screens/trosa/trosa_form_screen.dart';
import 'package:Trosa/screens/trosa/components/trosa_card.dart';
import 'package:provider/provider.dart';

class TrosaPage extends StatefulWidget {
  TrosaPage({Key key}) : super(key: key);

  @override
  _TrosaPageState createState() => _TrosaPageState();
}

class _TrosaPageState extends State<TrosaPage> {
  void _gotoAddPage() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new TrosaAddPage()),
    );
  }

  @override
  void initState() {
    TrosaNotifier trosaNotifier =
        Provider.of<TrosaNotifier>(context, listen: false);
    getTrosa(trosaNotifier);
    initializeDateFormatting('fr_FR');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TrosaNotifier trosaNotifier = Provider.of<TrosaNotifier>(context);
    var size = MediaQuery.of(context).size;

    final formatter = new NumberFormat('###,000', 'fr');
    Future<void> _refreshList() async {
      print('Refreshing the Trosa list');
      getTrosa(trosaNotifier);
    }

    Future<bool> _confirmDeleteTrosa() async {
      return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Hamafa Trosa"),
            content: Text("Tena tianao ho fafana tokoa ve io trosa io ?"),
            actions: <Widget>[
              FlatButton(
                child: Text('TSIA'),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              FlatButton(
                child: Text(
                  'ENY',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Trosa"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => new TrosaAboutPage()),
              );
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshList,
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
                          Text(
                            'Ar ' +
                                formatter
                                    .format(trosaNotifier.totalInflow ?? 0.0)
                                    .toString(),
                            style: TextStyle(fontSize: 20, color: Colors.green),
                          ),
                          Text(
                            'Ar ' +
                                formatter
                                    .format(trosaNotifier.totalOutflow ?? 0.0)
                                    .toString(),
                            style: TextStyle(fontSize: 20, color: Colors.red),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: size.height * .05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            'Toe-bolanao',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Text(
                            'Ar ' +
                                formatter
                                    .format(trosaNotifier.balance ?? 0.0)
                                    .toString(),
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w300,
                                color: (trosaNotifier.balance <= 0)
                                    ? Colors.red
                                    : Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 18, left: 18, top: 22),
              child: Text(
                "Lisitr'ireo Trosa",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: trosaNotifier.trosaList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Dismissible(
                      onDismissed: (dismissDirection) => {},
                      confirmDismiss: (direction) async {
                        bool confirmDelete = await _confirmDeleteTrosa();
                        if (confirmDelete) {
                          DatabaseProvider.db
                              .delete(trosaNotifier.trosaList[index]);
                          getTrosa(trosaNotifier);
                          trosaNotifier
                              .deleteTrosa(trosaNotifier.trosaList[index]);
                        }
                      },
                      background: Container(
                        child: Icon(
                          Icons.delete_forever,
                          color: Colors.white,
                        ),
                        decoration: BoxDecoration(color: Colors.red[700]),
                      ),
                      key: ValueKey(index),
                      child: GestureDetector(
                        onTap: () {
                          trosaNotifier.currentTrosa =
                              trosaNotifier.trosaList[index];
                          _gotoAddPage();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 5, right: 5, top: 2, bottom: 0),
                          child: TrosaCard(
                            isInflow: trosaNotifier.trosaList[index].isInflow,
                            amount: formatter
                                .format(trosaNotifier.trosaList[index].amount)
                                .toString(),
                            owner: trosaNotifier.trosaList[index].owner,
                            dueDate:
                                trosaNotifier.trosaList[index].dueDate != null
                                    ? DateFormat('d/M/y').format(trosaNotifier
                                        .trosaList[index].dueDate
                                        .toDate())
                                    : DateFormat('d/M/y')
                                        .format(DateTime.now())
                                        .toString(),
                            date: trosaNotifier.trosaList[index].date != null
                                ? DateFormat('d/M/y').format(trosaNotifier
                                    .trosaList[index].date
                                    .toDate())
                                : DateFormat('d/M/y')
                                    .format(DateTime.now())
                                    .toString(),
                            note: trosaNotifier.trosaList[index].note != null
                                ? trosaNotifier.trosaList[index].note
                                : '',
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
        tooltip: 'Hampiditra Trosa',
        child: Icon(Icons.add),
      ),
    );
  }
}
