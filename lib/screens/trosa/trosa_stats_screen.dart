import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trosa/components/owner_avatar.dart';
import 'package:trosa/db/sqflite_provider.dart';
import 'package:trosa/l10n/app_localizations.dart';
import 'package:trosa/models/trosa.dart';
import 'package:trosa/notifier/settings_notifier.dart';

class TrosaStatsScreen extends StatefulWidget {
  const TrosaStatsScreen({super.key});

  @override
  State<TrosaStatsScreen> createState() => _TrosaStatsScreenState();
}

class _TrosaStatsScreenState extends State<TrosaStatsScreen> {
  final NumberFormat _formatter = NumberFormat('###,###', 'fr');
  final DateFormat _monthFormat = DateFormat('MMM', 'fr');
  List<Trosa> _debts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final debts = await DatabaseProvider.db.getTrosa();
    if (mounted) {
      setState(() {
        _debts = debts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = Provider.of<SettingsNotifier>(context);
    final symbol = settings.currencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stats),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: l10n.statsShare,
            onPressed: () => _shareReport(context, l10n, symbol),
          ),
        ],
      ),
      body: _debts.isEmpty
          ? Center(child: Text(l10n.statsEmpty))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  _countsSection(context, l10n),
                  const SizedBox(height: 24),
                  _monthlySection(context, l10n, symbol),
                  const SizedBox(height: 24),
                  _trendSection(context, l10n, symbol),
                  const SizedBox(height: 24),
                  _topOwnersSection(context, l10n, symbol),
                ],
              ),
            ),
    );
  }

  Future<void> _shareReport(
      BuildContext context, AppLocalizations l10n, String symbol) async {
    final paid = _debts.where((t) => t.isPaid).length;
    final outstanding = _debts.length - paid;

    final byOwner = <String, double>{};
    for (final t in _debts) {
      if (t.owner.trim().isEmpty || t.remaining <= 0) continue;
      byOwner[t.owner] = (byOwner[t.owner] ?? 0) + t.remaining;
    }
    final sorted = byOwner.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final buffer = StringBuffer()
      ..writeln('${l10n.appName} — ${l10n.stats}')
      ..writeln('${l10n.statsTotal}: ${_debts.length}')
      ..writeln('${l10n.statsPaid}: $paid')
      ..writeln('${l10n.statsOutstanding}: $outstanding');
    if (sorted.isNotEmpty) {
      buffer.writeln('${l10n.statsTopOwners}:');
      for (final entry in sorted.take(5)) {
        buffer.writeln(
            '  • ${entry.key}: ${l10n.currencyPrefix(symbol)}${_formatter.format(entry.value)}');
      }
    }

    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        text: buffer.toString(),
        sharePositionOrigin:
            box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      ),
    );
  }

  Widget _countsSection(BuildContext context, AppLocalizations l10n) {
    final paid = _debts.where((t) => t.isPaid).length;
    return Row(
      children: <Widget>[
        _statCard(context, l10n.statsTotal, '${_debts.length}'),
        const SizedBox(width: 8),
        _statCard(context, l10n.statsPaid, '$paid'),
        const SizedBox(width: 8),
        _statCard(
            context, l10n.statsOutstanding, '${_debts.length - paid}'),
      ],
    );
  }

  Widget _statCard(BuildContext context, String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: <Widget>[
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _monthlySection(
      BuildContext context, AppLocalizations l10n, String symbol) {
    final now = DateTime.now();
    final months = <DateTime>[
      for (var i = 5; i >= 0; i--)
        DateTime(now.year, now.month - i, 1),
    ];

    final netByMonth = <DateTime, double>{
      for (final m in months) m: 0.0,
    };
    for (final t in _debts) {
      final month = DateTime(t.date.year, t.date.month, 1);
      if (netByMonth.containsKey(month)) {
        netByMonth[month] =
            (netByMonth[month] ?? 0) + (t.isInflow ? t.remaining : -t.remaining);
      }
    }

    final maxNet =
        netByMonth.values.map((v) => v.abs()).fold<double>(0, (a, b) => a > b ? a : b);

    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.statsMonthly, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: months.map((m) {
              final value = netByMonth[m] ?? 0;
              final height = maxNet == 0
                  ? 0.0
                  : (value.abs() / maxNet) * 100;
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      value == 0 ? '' : _formatter.format(value.abs()),
                      style: TextStyle(fontSize: 9, color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: height,
                      width: 22,
                      decoration: BoxDecoration(
                        color: value >= 0
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _monthFormat.format(m),
                      style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        Text(
          '${l10n.moneyToReceive}: + / ${l10n.moneyToPay}: -',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  /// Cumulative balance-over-time line chart: the running balance after each
  /// month, showing progress (e.g. "down 200,000 since January").
  Widget _trendSection(
      BuildContext context, AppLocalizations l10n, String symbol) {
    final now = DateTime.now();
    final months = <DateTime>[
      for (var i = 5; i >= 0; i--)
        DateTime(now.year, now.month - i, 1),
    ];

    // Running balance: sum outstanding net per month of creation.
    final values = <double>[];
    var running = 0.0;
    for (final m in months) {
      for (final t in _debts) {
        if (DateTime(t.date.year, t.date.month, 1) == m) {
          running += t.isInflow ? t.remaining : -t.remaining;
        }
      }
      values.add(running);
    }

    final maxAbs = values
        .map((v) => v.abs())
        .fold<double>(0, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.statsTrend, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: CustomPaint(
            size: const Size(double.infinity, 150),
            painter: _TrendPainter(
              values: values,
              labels: months.map(_monthFormat.format).toList(),
              maxAbs: maxAbs,
              color: Theme.of(context).colorScheme.primary,
              gridColor: Theme.of(context).colorScheme.outlineVariant,
              textColor: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${l10n.currencyPrefix(symbol)}${_formatter.format(values.last)}',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _topOwnersSection(
      BuildContext context, AppLocalizations l10n, String symbol) {
    final byOwner = <String, double>{};
    for (final t in _debts) {
      if (t.owner.trim().isEmpty || t.remaining <= 0) continue;
      byOwner[t.owner] = (byOwner[t.owner] ?? 0) + t.remaining;
    }
    final sorted = byOwner.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.statsTopOwners, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (sorted.isEmpty)
          Text(l10n.statsEmpty)
        else
          for (final entry in sorted.take(5))
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: OwnerAvatar(owner: entry.key, size: 38, fontSize: 15),
              title: Text(entry.key),
              trailing: Text(
                '${l10n.currencyPrefix(symbol)}${_formatter.format(entry.value)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
      ],
    );
  }
}

/// Lightweight line chart for the cumulative balance trend. No chart package
/// needed — a simple polyline with dots and month labels.
class _TrendPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final double maxAbs;
  final Color color;
  final Color gridColor;
  final Color textColor;

  _TrendPainter({
    required this.values,
    required this.labels,
    required this.maxAbs,
    required this.color,
    required this.gridColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || maxAbs == 0) return;

    const topPad = 8.0;
    const bottomPad = 22.0;
    const sidePad = 6.0;
    final chartH = size.height - topPad - bottomPad;
    final chartW = size.width - sidePad * 2;

    double xFor(int i) =>
        sidePad + (values.length == 1 ? chartW / 2 : chartW * i / (values.length - 1));
    double yFor(double v) =>
        topPad + chartH - ((v + maxAbs) / (2 * maxAbs)) * chartH;

    // Zero line + mid grid.
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.4)
      ..strokeWidth = 1;
    final zeroY = yFor(0);
    canvas.drawLine(Offset(sidePad, zeroY), Offset(size.width - sidePad, zeroY), gridPaint);

    // Polyline.
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = xFor(i);
      final y = yFor(values[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);

    // Dots + labels.
    final dotPaint = Paint()..color = color;
    for (var i = 0; i < values.length; i++) {
      final x = xFor(i);
      final y = yFor(values[i]);
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(fontSize: 10, color: textColor),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - bottomPad + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.maxAbs != maxAbs ||
      oldDelegate.color != color;
}
