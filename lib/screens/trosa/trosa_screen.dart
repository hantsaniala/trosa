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
import 'package:share/share.dart';

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
    String sortType = 'date';

    final formatter = new NumberFormat('###,###', 'fr');
    Future<void> _refreshList() async {
      print('Refreshing the Trosa list');
      getTrosa(trosaNotifier);
    }

    /* final RenderBox box = context.findRenderObject(); */
    final String appURL = 'http://shorturl.at/cflmC';

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

    // TODO : Save filter type
    void choiceAction(String choice) {
      if (choice == Constants.About) {
        Navigator.push(
          context,
          new MaterialPageRoute(builder: (context) => new TrosaAboutPage()),
        );
      } else if (choice == Constants.SortByAmount) {
        setState(() {
          trosaNotifier.sortType = 'amount';
          trosaNotifier.currentTrosaList.sort((a, b) => trosaNotifier.sortAscend
              ? a.amount.compareTo(b.amount)
              : b.amount.compareTo(a.amount));
        });
      } else if (choice == Constants.SortByDate) {
        setState(() {
          trosaNotifier.sortType = 'date';
          trosaNotifier.currentTrosaList.sort((a, b) => trosaNotifier.sortAscend
              ? a.date.compareTo(b.date)
              : b.date.compareTo(a.date));
        });
      } else if (choice == Constants.SortByOwner) {
        setState(() {
          trosaNotifier.sortType = 'owner';
          trosaNotifier.currentTrosaList.sort((a, b) => trosaNotifier.sortAscend
              ? a.owner.compareTo(b.owner)
              : b.owner.compareTo(a.owner));
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Trosa"),
        actions: <Widget>[
          // TODO : Share the app and note the app on store
          /* IconButton(icon: Icon(Icons.favorite), onPressed: () {}), */
          IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                Share.share(
                  "Ndao hampiasa an'ito $appURL",
                  /*subject: 'Ndao hampiasa',
                   sharePositionOrigin:
                        box.localToGlobal(Offset.zero) & box.size */
                );
              }),
          // TODO : Use menu item instead of direct page
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: choiceAction,
            itemBuilder: (BuildContext context) {
              return Constants.menuChoices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
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
                        children: [
                          Text('Vola ho raisina'),
                          Text('Vola mila aloha')
                        ],
                      ),
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
              child: Row(
                children: [
                  Text(
                    "Lisitr’ireo Trosa",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Spacer(),
                  /* Expanded(
                    child: TextField(
                      // TODO : UI Animation expand en touch
                      decoration: InputDecoration(
                        fillColor: Colors.yellowAccent,
                        contentPadding: EdgeInsets.only(left: 15),
                        border: OutlineInputBorder(
                            /* borderRadius: BorderRadius.circular(5), */
                            ),
                        suffixIcon: IconButton(
                            icon: Icon(Icons.search), onPressed: () {}),
                      ),
                      // TODO : Filter Trosa list dynamicaly based on text value change
                      onChanged: (value) {},
                    ),
                  ), */

                  IconButton(
                      icon: Icon(trosaNotifier.sortAscend
                          ? Icons.arrow_downward
                          : Icons.arrow_upward),
                      onPressed: () {
                        print(trosaNotifier.sortType);
                        setState(() {
                          switch (trosaNotifier.sortType) {
                            case 'date':
                              trosaNotifier.currentTrosaList.sort((a, b) =>
                                  trosaNotifier.sortAscend
                                      ? a.date.compareTo(b.date)
                                      : b.date.compareTo(a.date));
                              break;
                            case 'amount':
                              trosaNotifier.currentTrosaList.sort((a, b) =>
                                  trosaNotifier.sortAscend
                                      ? a.amount.compareTo(b.amount)
                                      : b.amount.compareTo(a.amount));
                              break;
                            case 'owner':
                              trosaNotifier.currentTrosaList.sort((a, b) =>
                                  trosaNotifier.sortAscend
                                      ? a.owner.compareTo(b.owner)
                                      : b.owner.compareTo(a.owner));
                              break;
                          }
                          trosaNotifier.sortAscend = !trosaNotifier.sortAscend;

                          // TODO : Sort without calling the drop down
                        });
                        print('\n');
                        for (var item in trosaNotifier.currentTrosaList) {
                          print(item.owner + ' - ' + item.amount.toString());
                        }
                      }),
                  // TODO : Sort Trosa list (only search result if exist) by name, amount, dueDate, type, date
                  PopupMenuButton<String>(
                    icon: Icon(Icons.sort),
                    onSelected: choiceAction,
                    itemBuilder: (BuildContext context) {
                      return Constants.sortChoices.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: trosaNotifier.currentTrosaList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Dismissible(
                      onDismissed: (dismissDirection) => {},
                      confirmDismiss: (direction) async {
                        bool confirmDelete = await _confirmDeleteTrosa();
                        if (confirmDelete) {
                          DatabaseProvider.db
                              .delete(trosaNotifier.currentTrosaList[index]);
                          getTrosa(trosaNotifier);
                          trosaNotifier.deleteTrosa(
                              trosaNotifier.currentTrosaList[index]);
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
                              trosaNotifier.currentTrosaList[index];
                          _gotoAddPage();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 5, right: 5, top: 2, bottom: 0),
                          child: TrosaCard(
                            isInflow:
                                trosaNotifier.currentTrosaList[index].isInflow,
                            amount: formatter
                                .format(trosaNotifier
                                    .currentTrosaList[index].amount)
                                .toString(),
                            owner: trosaNotifier.currentTrosaList[index].owner,
                            dueDate:
                                trosaNotifier.currentTrosaList[index].dueDate !=
                                        null
                                    ? DateFormat('d/M/y').format(trosaNotifier
                                        .currentTrosaList[index].dueDate
                                        .toDate())
                                    : DateFormat('d/M/y')
                                        .format(DateTime.now())
                                        .toString(),
                            date: trosaNotifier.currentTrosaList[index].date !=
                                    null
                                ? DateFormat('d/M/y').format(trosaNotifier
                                    .currentTrosaList[index].date
                                    .toDate())
                                : DateFormat('d/M/y')
                                    .format(DateTime.now())
                                    .toString(),
                            note: trosaNotifier.currentTrosaList[index].note !=
                                    null
                                ? trosaNotifier.currentTrosaList[index].note
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

class Constants {
  static const String About = 'About';

  static const String SortByDate = 'By Date';
  static const String SortByOwner = 'By Owner';
  static const String SortByAmount = 'By Amount';

  static const List<String> menuChoices = <String>[About];
  static const List<String> sortChoices = <String>[
    SortByDate,
    SortByOwner,
    SortByAmount
  ];
}
