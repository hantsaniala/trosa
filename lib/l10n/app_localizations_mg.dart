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
  String currencyPrefix(String symbol) {
    return '$symbol ';
  }

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
  String get stats => 'Statistika';

  @override
  String get settings => 'Fikirana';

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
  String get searchHint => 'Karohy (anarana, fanamarihana, sokajy)...';

  @override
  String get filterAll => 'Rehetra';

  @override
  String get filterUnpaid => 'Mbola tsy voaloa';

  @override
  String get filterPaid => 'Efa voaloa';

  @override
  String get filterOverdue => 'Lasa ny daty';

  @override
  String get paidBadge => 'Voaloa';

  @override
  String get remainingLabel => 'Sisa';

  @override
  String remainingText(String amount) {
    return 'Sisa $amount';
  }

  @override
  String get amountLabel => 'Ohatrinona';

  @override
  String currencySuffix(String symbol) {
    return '$symbol';
  }

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
  String get paidAmountLabel => 'Vola efa voaloa';

  @override
  String get categoryLabel => 'Sokajy';

  @override
  String get noCategory => 'Tsy misy sokajy';

  @override
  String get categoryFamily => 'Fianakaviana';

  @override
  String get categoryFriends => 'Namana';

  @override
  String get categoryWork => 'Asa';

  @override
  String get categoryOther => 'Hafa';

  @override
  String get recurringLabel => 'Averimberina isaky ny andro (0 = tsy misy)';

  @override
  String get aboutTitle => 'Mombamomba ny Trosa';

  @override
  String get aboutDescription =>
      'Application natao handraisana naoty ireo trosa tokony haloa sy mila takiana.';

  @override
  String get poweredBy => 'Powered by';

  @override
  String get deletedSnackBar => 'Voafafa ny trosa';

  @override
  String get undoAction => 'AVERY';

  @override
  String get settingsTitle => 'Fikirana';

  @override
  String get currencyLabel => 'Volan-karena';

  @override
  String get themeLabel => 'Endrika';

  @override
  String get themeSystem => 'Araka ny rafitra';

  @override
  String get themeLight => 'Mazava';

  @override
  String get themeDark => 'Maizina';

  @override
  String get backupExport => 'Export CSV';

  @override
  String get backupImport => 'Import CSV';

  @override
  String backupImported(int count) {
    return 'Trosa $count no nampidirina';
  }

  @override
  String get backupFailed => 'Tsy nahomby ny fanondranana';

  @override
  String notificationBody(String owner) {
    return 'Tsy maintsy haverina ny trosa ho an\'i $owner';
  }

  @override
  String get statsTitle => 'Statistika';

  @override
  String get statsTotal => 'Trosa rehetra';

  @override
  String get statsPaid => 'Efa voaloa';

  @override
  String get statsOutstanding => 'Mbola misy sisa';

  @override
  String get statsMonthly => 'Vola isam-bolana';

  @override
  String get statsTopOwners => 'Tompon-trosa ambony indrindra';

  @override
  String get statsEmpty => 'Mbola tsy misy trosa voasoratra.';
}
