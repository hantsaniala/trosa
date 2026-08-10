import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trosa/l10n/app_localizations.dart';
import 'package:trosa/notifier/settings_notifier.dart';
import 'package:trosa/services/backup_service.dart';

/// App settings: currency, theme, language, reminders, custom categories and
/// backup/restore (CSV + JSON).
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
            Text(l10n.languageLabel,
                style: Theme.of(context).textTheme.titleMedium),
            DropdownButton<String>(
              value: settings.language,
              items: SettingsNotifier.languages
                  .map((l) => DropdownMenuItem<String>(
                        value: l,
                        child: Text(_languageLabel(l10n, l)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  settings.setLanguage(value);
                }
              },
            ),
            const SizedBox(height: 16),
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
            Text(l10n.reminderSection,
                style: Theme.of(context).textTheme.titleMedium),
            _ReminderDefaultsTile(settings: settings, l10n: l10n),
            const SizedBox(height: 16),
            if (settings.customCategories.isNotEmpty) ...[
              Text(l10n.categoryLabel,
                  style: Theme.of(context).textTheme.titleMedium),
              for (final category in settings.customCategories)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.label_outline, size: 18),
                  title: Text(category),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () => settings.removeCustomCategory(category),
                  ),
                ),
              const SizedBox(height: 8),
            ],
            Text(l10n.backupExport,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportCsv(context, l10n),
                    icon: const Icon(Icons.upload_file),
                    label: Text(l10n.backupExport),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _importCsv(context, l10n),
                    icon: const Icon(Icons.download),
                    label: Text(l10n.backupImport),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportJson(context, l10n),
                    icon: const Icon(Icons.save_alt),
                    label: Text(l10n.jsonExport),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _importJson(context, l10n),
                    icon: const Icon(Icons.settings_backup_restore),
                    label: Text(l10n.jsonImport),
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

  String _languageLabel(AppLocalizations l10n, String language) {
    switch (language) {
      case 'fr':
        return l10n.languageFr;
      case 'en':
        return l10n.languageEn;
      default:
        return l10n.languageMg;
    }
  }

  void _setTheme(SettingsNotifier settings, String? value) {
    if (value == null) return;
    settings.setThemeMode(
        ThemeMode.values.firstWhere((m) => m.name == value));
  }

  Future<void> _exportCsv(BuildContext context, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await BackupService.exportCsv();
    } catch (_) {
      _showMessage(messenger, l10n.backupFailed);
    }
  }

  Future<void> _importCsv(BuildContext context, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final count = await BackupService.importCsv();
      onDataChanged?.call();
      _showMessage(messenger, l10n.backupImported(count));
    } catch (_) {
      _showMessage(messenger, l10n.backupFailed);
    }
  }

  Future<void> _exportJson(BuildContext context, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await BackupService.exportJson();
    } catch (_) {
      _showMessage(messenger, l10n.backupFailed);
    }
  }

  Future<void> _importJson(BuildContext context, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final count = await BackupService.importJson();
      if (!context.mounted) return;
      // Settings changed under the notifier: reload them.
      await Provider.of<SettingsNotifier>(context, listen: false).load();
      onDataChanged?.call();
      _showMessage(messenger, l10n.jsonImported(count));
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

/// Lets the user adjust the default reminder lead time and time of day that
/// new debts start with.
class _ReminderDefaultsTile extends StatelessWidget {
  final SettingsNotifier settings;
  final AppLocalizations l10n;

  const _ReminderDefaultsTile({required this.settings, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: settings.reminderDaysBefore,
                decoration: InputDecoration(labelText: l10n.reminderLeadLabel),
                items: [
                  DropdownMenuItem<int>(
                      value: 0, child: Text(l10n.reminderLeadSameDay)),
                  DropdownMenuItem<int>(
                      value: 1, child: Text(l10n.reminderLeadOneDay)),
                  DropdownMenuItem<int>(
                      value: 2, child: Text(l10n.reminderLeadTwoDays)),
                  DropdownMenuItem<int>(
                      value: 7, child: Text(l10n.reminderLeadOneWeek)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    settings.setReminderDefaults(
                        value, settings.reminderTimeMinutes);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () async {
                final initial = TimeOfDay(
                  hour: settings.reminderTimeMinutes ~/ 60,
                  minute: settings.reminderTimeMinutes % 60,
                );
                final picked =
                    await showTimePicker(context: context, initialTime: initial);
                if (picked != null) {
                  settings.setReminderDefaults(settings.reminderDaysBefore,
                      picked.hour * 60 + picked.minute);
                }
              },
              child: Text(
                '${(settings.reminderTimeMinutes ~/ 60).toString().padLeft(2, '0')}:'
                '${(settings.reminderTimeMinutes % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
