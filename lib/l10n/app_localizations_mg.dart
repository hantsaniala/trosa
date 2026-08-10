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
  String get languageLabel => 'Fiteny';

  @override
  String get languageMg => 'Malagasy';

  @override
  String get languageFr => 'Français';

  @override
  String get languageEn => 'English';

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
  String get jsonExport => 'Export JSON';

  @override
  String get jsonImport => 'Import JSON';

  @override
  String jsonImported(int count) {
    return 'Trosa $count sy ny fikirana no naverina';
  }

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

  @override
  String get statsTrend => 'Fivoaran\'ny toe-bolanao';

  @override
  String get statsShare => 'Hizara tatitra';

  @override
  String get reminderSection => 'Fampahatsiahivana';

  @override
  String get reminderEnabledLabel => 'Alefa ny fampahatsiahivana';

  @override
  String get reminderLeadLabel => 'Alohan\'ny andro haverina';

  @override
  String get reminderLeadSameDay => 'Andro iray ihany';

  @override
  String get reminderLeadOneDay => 'Andro 1 aloha';

  @override
  String get reminderLeadTwoDays => 'Andro 2 aloha';

  @override
  String get reminderLeadOneWeek => 'Herinandro 1 aloha';

  @override
  String get reminderTimeLabel => 'Ora fampahatsiahivana';

  @override
  String get paymentDialogTitle => 'Rekordera fandoavana';

  @override
  String get paymentHint => 'Ohatrinona no voaloa?';

  @override
  String get paymentRecorded => 'Voarakitra ny fandoavana';

  @override
  String get recordPaymentAction => 'Rekordera fandoavana';

  @override
  String get markPaidAction => 'Marika ho voaloa';

  @override
  String get editAction => 'Hanova';

  @override
  String settledLabel(String date) {
    return 'Voaloa tamin\'ny $date';
  }

  @override
  String progressPaid(int percent) {
    return 'Voaloa $percent%';
  }

  @override
  String get addCategory => 'Sokajy vaovao';

  @override
  String get newCategoryHint => 'Anaran\'ny sokajy';

  @override
  String get categoryAdded => 'Nampidirina ny sokajy';

  @override
  String get categoryExists => 'Efa misy io sokajy io';

  @override
  String get contactLabel => 'Misafidy olona amin\'ny finday';

  @override
  String get onboardingTitle1 => 'Tongasoa eto amin\'ny Trosa';

  @override
  String get onboardingBody1 =>
      'Raketo ireo vola trosain\'ny olona aminao sy ny trosanao amin\'ny olona, ao amin\'ny toerana iray.';

  @override
  String get onboardingTitle2 => 'Vola miditra sy mivoaka';

  @override
  String get onboardingBody2 =>
      'Asehona ny vola tokony horaisina sy ny vola tokony haloa, miaraka amin\'ny toe-bolanao.';

  @override
  String get onboardingTitle3 => 'Fikafiky ny tanana';

  @override
  String get onboardingBody3 =>
      'Swipe miankavia hamafa, miankavanana hanamarika voaloa. Tsindrio ny trosa iray hisafidianana fandoavana.';

  @override
  String get onboardingSkip => 'Atsaharo';

  @override
  String get onboardingNext => 'Manaraka';

  @override
  String get onboardingStart => 'Manomboka';
}
