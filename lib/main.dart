import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trosa/const.dart';
import 'package:trosa/l10n/app_localizations.dart';
import 'package:trosa/notifier/trosa_notifier.dart';
import 'package:trosa/screens/trosa/trosa_screen.dart';

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
          create: (context) => TrosaNotifier(),
        )
      ],
      child: const Trosa(),
    );
  }
}

class Trosa extends StatelessWidget {
  const Trosa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trosa',
      theme: ThemeData(
        primarySwatch: kPrimaryColor,
      ),
      debugShowCheckedModeBanner: false,
      locale: const Locale('mg'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        // English defaults for framework-level strings (date picker, etc.);
        // the app's own strings come from the Malagasy AppLocalizations.
        const _EnglishMaterialLocalizationsDelegate(),
        const _EnglishCupertinoLocalizationsDelegate(),
      ],
      home: const TrosaPage(),
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
