import 'package:flutter/material.dart';

class TrosaCard extends StatelessWidget {
  final bool? isInflow;
  final String? amount;
  final String? owner;
  final String? dueDate;
  final String? date;
  final String? note;
  final List? data;

  const TrosaCard({
    Key? key,
    this.data,
    this.amount,
    this.owner,
    this.dueDate,
    this.date,
    this.isInflow,
    this.note,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        dense: true,
        leading: Icon(
          isInflow ?? true ? Icons.add : Icons.remove,
          color: isInflow ?? true ? Colors.green : Colors.red,
          size: 35,
        ),
        title: SizedBox(
          height: 40,
          child: Align(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  'Ar ' + amount.toString(),
                  style: TextStyle(fontSize: 18),
                ),
                Text(owner ?? "",
                    style: Theme.of(context).textTheme.bodyText1,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ],
            ),
          ),
        ),
        subtitle: Text(
          note ?? "",
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              width: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                  ),
                  Text(
                    " " + dueDate.toString(),
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.drive_file_rename_outline,
                    size: 12,
                  ),
                  Text(
                    " " + date.toString(),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
