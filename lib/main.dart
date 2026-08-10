import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:trosa/components/trosa_mark.dart';
import 'package:trosa/l10n/app_localizations.dart';
import 'package:trosa/notifier/settings_notifier.dart';
import 'package:trosa/notifier/trosa_notifier.dart';
import 'package:trosa/screens/trosa/trosa_onboarding.dart';
import 'package:trosa/screens/trosa/trosa_screen.dart';
import 'package:trosa/theme.dart';

void main() {
  runApp(const TrosaApp());
}

class TrosaApp extends StatelessWidget {
  const TrosaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => SettingsNotifier(),
        ),
        ChangeNotifierProvider(
          create: (context) => TrosaNotifier(),
        ),
      ],
      child: const Trosa(),
    );
  }
}

/// Loads persisted settings before deciding whether to show the onboarding
/// flow or the dashboard.
class Trosa extends StatefulWidget {
  const Trosa({super.key});

  @override
  State<Trosa> createState() => _TrosaState();
}

class _TrosaState extends State<Trosa> {
  bool _settingsLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings =
          Provider.of<SettingsNotifier>(context, listen: false);
      await settings.load();
      if (mounted) {
        setState(() => _settingsLoaded = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsNotifier>(context);
    return MaterialApp(
      title: 'Trosa',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      debugShowCheckedModeBanner: false,
      locale: Locale(settings.language),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        // Framework strings (date pickers, dialogs, etc.) for fr/en. The app
        // locale can also be mg, which GlobalMaterialLocalizations does not
        // cover — the English fallback delegate below handles that.
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        _EnglishMaterialLocalizationsDelegate(),
        _EnglishCupertinoLocalizationsDelegate(),
      ],
      home: !_settingsLoaded
          ? const _Splash()
          : settings.onboardingDone
              ? const TrosaPage()
              : const TrosaOnboardingScreen(),
    );
  }
}

/// Brand-yellow splash shown while the persisted settings are loading.
class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.brand,
      body: Center(child: TrosaMark(size: 96)),
    );
  }
}

/// `DefaultMaterialLocalizations.delegate` only claims support for English, so
/// it is skipped when the app locale is `mg`. This delegate always loads the
/// English defaults, keeping framework strings available under any locale.
class _EnglishMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _EnglishMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return DefaultMaterialLocalizations.load(locale);
  }

  @override
  bool shouldReload(_EnglishMaterialLocalizationsDelegate old) => false;
}

class _EnglishCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _EnglishCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return DefaultCupertinoLocalizations.load(locale);
  }

  @override
  bool shouldReload(_EnglishCupertinoLocalizationsDelegate old) => false;
}
