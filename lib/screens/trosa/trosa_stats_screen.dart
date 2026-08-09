import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
                  _topOwnersSection(context, l10n, symbol),
                ],
              ),
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
              leading: CircleAvatar(
                child: Text(entry.key.characters.first.toUpperCase()),
              ),
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
