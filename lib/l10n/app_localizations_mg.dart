// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malagasy (`mg`).
class AppLocalizationsMg extends AppLocalizations {
  AppLocalizationsMg([String locale = 'mg']) : super(locale);

  @override
  String get appName => 'Trosa';

  @override
  String get moneyToReceive => 'Vola ho raisina';

  @override
  String get moneyToPay => 'Vola mila haloa';

  @override
  String get balance => 'Toe-bolanao';

  @override
  String get currencyPrefix => 'Ar ';

  @override
  String get debtListTitle => 'Lisitr\'ireo Trosa';

  @override
  String get addDebt => 'Hampiditra Trosa';

  @override
  String get editDebt => 'Fanitsiana Trosa';

  @override
  String get deleteDebtTitle => 'Hamafa Trosa';

  @override
  String get deleteDebtMessage =>
      'Tena tianao ho fafana tokoa ve io trosa io ?';

  @override
  String get no => 'TSIA';

  @override
  String get yes => 'ENY';

  @override
  String get about => 'Mombamomba';

  @override
  String get sortByDate => 'Daty';

  @override
  String get sortByOwner => 'Anarana';

  @override
  String get sortByAmount => 'Sandany';

  @override
  String shareAppMessage(String appUrl) {
    return 'Ndao hampiasa an\'ito $appUrl';
  }

  @override
  String get amountLabel => 'Ohatrinona';

  @override
  String get currencySuffix => 'MGA';

  @override
  String get amountRequired => 'Mila soratana hoe ohatrinona azafady.';

  @override
  String get ownerLabel => 'Ilay olona';

  @override
  String get ownerRequired => 'Mila fenoina ny anaran\'ilay olona.';

  @override
  String get dueDateLabel => 'Haverina ny ';

  @override
  String get noteLabel => 'Fanamarihana';

  @override
  String get aboutTitle => 'Mombamomba ny Trosa';

  @override
  String get aboutDescription =>
      'Application natao handraisana naoty ireo trosa tokony haloa sy mila takiana.';

  @override
  String get poweredBy => 'Powered by';
}
