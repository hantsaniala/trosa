import 'package:flutter/material.dart';
import 'package:trosa/l10n/app_localizations.dart';

class TrosaCard extends StatelessWidget {
  final bool isInflow;
  final String amount;
  final String remaining;
  final String owner;
  final String dueDate;
  final String date;
  final String note;
  final bool isPaid;
  final bool isOverdue;
  final bool isDueSoon;
  final double paidAmount;
  final String category;
  final String symbol;

  // Pre-computed translucent tints. Building these per row with
  // withValues(alpha:) was wasted work (and per-frame alpha compositing is
  // costly on old GPUs like the GT-i9500's Adreno 320).
  static const Color _paidBackground = Color(0x1A4CAF50); // green @ 10%
  static const Color _overdueBackground = Color(0x1AF44336); // red @ 10%
  static const Color _dueSoonBackground = Color(0x2EFFC107); // amber @ 18%

  static const Color _green = Color(0xFF2E7D32);
  static const Color _red = Color(0xFFC62828);

  const TrosaCard({
    super.key,
    required this.isInflow,
    required this.amount,
    this.remaining = '',
    required this.owner,
    required this.dueDate,
    required this.date,
    this.note = '',
    this.isPaid = false,
    this.isOverdue = false,
    this.isDueSoon = false,
    this.paidAmount = 0,
    this.category = '',
    this.symbol = 'Ar',
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final Color cardColor;
    if (isPaid) {
      cardColor = _paidBackground;
    } else if (isOverdue) {
      cardColor = _overdueBackground;
    } else if (isDueSoon) {
      cardColor = _dueSoonBackground;
    } else {
      cardColor = scheme.surfaceContainerLow;
    }

    final partial =
        !isPaid && paidAmount > 0 && remaining.isNotEmpty;
    final amountText =
        '${l10n.currencyPrefix(symbol)}$amount${partial ? ' (${l10n.remainingText(remaining)})' : ''}';

    final bool strongInflow = isInflow && !isPaid;
    final Color accent = isPaid ? _green : (strongInflow ? _green : _red);

    // elevation: 0 + transparent surface tint: card rows are cheap flat
    // surfaces instead of shadow-blended layers (list rows + shadows were a
    // big per-frame GPU cost on old hardware).
    return Card(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        dense: true,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isPaid
                ? _green
                : strongInflow
                    ? const Color(0x1E4CAF50)
                    : const Color(0x1EF44336),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isPaid
                ? Icons.check
                : strongInflow
                    ? Icons.south_west
                    : Icons.north_east,
            size: 20,
            color: isPaid ? Colors.white : accent,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    amountText,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (category.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    owner,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (isPaid) ...[
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(
                      Icons.check_circle,
                      color: _green,
                      size: 14,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Text(
                      l10n.paidBadge,
                      style: const TextStyle(fontSize: 11, color: _green),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        subtitle: Text(
          note,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: scheme.onSurfaceVariant,
                ),
                Text(
                  ' $dueDate',
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.drive_file_rename_outline,
                  size: 12,
                  color: scheme.onSurfaceVariant,
                ),
                Text(
                  ' $date',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
