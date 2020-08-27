import 'package:flutter/material.dart';

class TrosaCard extends StatelessWidget {
  final bool isInflow;
  final String amount;
  final String owner;
  final String dueDate;
  final String date;
  final String note;
  const TrosaCard({
    Key key,
    this.data,
    this.amount,
    this.owner,
    this.dueDate,
    this.date,
    this.isInflow,
    this.note,
  }) : super(key: key);

  final List data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isInflow ? Icons.add : Icons.remove,
                    color: isInflow ? Colors.green : Colors.red,
                    size: 35,
                  ),
                ],
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Ar ' + amount.toString(),
                  style: TextStyle(fontSize: 18),
                ),
                Text(owner,
                    style: Theme.of(context).textTheme.bodyText1,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 5),
              child: Text(
                note,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Haverina ny ' + dueDate.toString(),
                  style: TextStyle(fontSize: 15),
                ),
                Text(
                  'Natao ny ' + date.toString(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
