import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trosa/l10n/app_localizations.dart';
import 'package:trosa/notifier/settings_notifier.dart';
import 'package:trosa/services/backup_service.dart';

/// App settings: currency, theme and CSV backup/restore.
class TrosaSettingsDialog extends StatelessWidget {
  /// Invoked after a data-changing operation (e.g. CSV import).
  final VoidCallback? onDataChanged;

  const TrosaSettingsDialog({super.key, this.onDataChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = Provider.of<SettingsNotifier>(context);

    return AlertDialog(
      title: Text(l10n.settingsTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.currencyLabel,
                style: Theme.of(context).textTheme.titleMedium),
            DropdownButton<String>(
              value: settings.currency,
              items: SettingsNotifier.currencies
                  .map((c) => DropdownMenuItem<String>(
                        value: c,
                        child: Text(c),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  settings.setCurrency(value);
                }
              },
            ),
            const SizedBox(height: 16),
            Text(l10n.themeLabel,
                style: Theme.of(context).textTheme.titleMedium),
            RadioGroup<String>(
              groupValue: settings.themeMode.name,
              onChanged: (v) => _setTheme(settings, v),
              child: Column(
                children: <Widget>[
                  RadioListTile<String>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.themeSystem),
                    value: 'system',
                  ),
                  RadioListTile<String>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.themeLight),
                    value: 'light',
                  ),
                  RadioListTile<String>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.themeDark),
                    value: 'dark',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _export(context, l10n),
                    icon: const Icon(Icons.upload_file),
                    label: Text(l10n.backupExport),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _import(context, l10n),
                    icon: const Icon(Icons.download),
                    label: Text(l10n.backupImport),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.no),
        ),
      ],
    );
  }

  void _setTheme(SettingsNotifier settings, String? value) {
    if (value == null) return;
    settings.setThemeMode(
        ThemeMode.values.firstWhere((m) => m.name == value));
  }

  Future<void> _export(BuildContext context, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await BackupService.exportCsv();
    } catch (_) {
      _showMessage(messenger, l10n.backupFailed);
    }
  }

  Future<void> _import(BuildContext context, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final count = await BackupService.importCsv();
      onDataChanged?.call();
      _showMessage(messenger, l10n.backupImported(count));
    } catch (_) {
      _showMessage(messenger, l10n.backupFailed);
    }
  }

  void _showMessage(ScaffoldMessengerState messenger, String message) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

}
