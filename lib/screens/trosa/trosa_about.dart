import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:trosa/components/trosa_mark.dart';
import 'package:trosa/l10n/app_localizations.dart';

class TrosaAboutPage extends StatefulWidget {
  const TrosaAboutPage({super.key});

  @override
  State<TrosaAboutPage> createState() => _TrosaAboutPageState();
}

class _TrosaAboutPageState extends State<TrosaAboutPage> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final info = _packageInfo;
    final version =
        info != null ? '${info.version}.${info.buildNumber}' : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aboutTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Brand mark: the same yellow double-arrow as the launcher icon.
            const Center(child: TrosaMark(size: 112)),
            const SizedBox(height: 20),
            Center(
              child: Text(
                l10n.appName,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                version,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              l10n.aboutDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const Spacer(),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(l10n.poweredBy),
                  const SizedBox(width: 8),
                  const FlutterLogo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
