import 'package:flutter/material.dart';
import 'package:trosa/l10n/app_localizations.dart';

class TrosaCard extends StatelessWidget {
  final bool isInflow;
  final String amount;
  final String owner;
  final String dueDate;
  final String date;
  final String note;

  const TrosaCard({
    super.key,
    required this.isInflow,
    required this.amount,
    required this.owner,
    required this.dueDate,
    required this.date,
    this.note = '',
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: ListTile(
        dense: true,
        leading: Icon(
          isInflow ? Icons.add : Icons.remove,
          color: isInflow ? Colors.green : Colors.red,
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
                  '${l10n.currencyPrefix}$amount',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  owner,
                  style: Theme.of(context).textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
        subtitle: Text(
          note,
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
                  const Icon(Icons.calendar_today, size: 12),
                  Text(
                    ' $dueDate',
                    style: const TextStyle(fontSize: 13),
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
                  const Icon(Icons.drive_file_rename_outline, size: 12),
                  Text(
                    ' $date',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w400),
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
