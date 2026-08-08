import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_mg.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('mg')];

  /// No description provided for @appName.
  ///
  /// In mg, this message translates to:
  /// **'Trosa'**
  String get appName;

  /// No description provided for @moneyToReceive.
  ///
  /// In mg, this message translates to:
  /// **'Vola ho raisina'**
  String get moneyToReceive;

  /// No description provided for @moneyToPay.
  ///
  /// In mg, this message translates to:
  /// **'Vola mila haloa'**
  String get moneyToPay;

  /// No description provided for @balance.
  ///
  /// In mg, this message translates to:
  /// **'Toe-bolanao'**
  String get balance;

  /// No description provided for @currencyPrefix.
  ///
  /// In mg, this message translates to:
  /// **'{symbol} '**
  String currencyPrefix(String symbol);

  /// No description provided for @debtListTitle.
  ///
  /// In mg, this message translates to:
  /// **'Lisitr\'ireo Trosa'**
  String get debtListTitle;

  /// No description provided for @addDebt.
  ///
  /// In mg, this message translates to:
  /// **'Hampiditra Trosa'**
  String get addDebt;

  /// No description provided for @editDebt.
  ///
  /// In mg, this message translates to:
  /// **'Fanitsiana Trosa'**
  String get editDebt;

  /// No description provided for @deleteDebtTitle.
  ///
  /// In mg, this message translates to:
  /// **'Hamafa Trosa'**
  String get deleteDebtTitle;

  /// No description provided for @deleteDebtMessage.
  ///
  /// In mg, this message translates to:
  /// **'Tena tianao ho fafana tokoa ve io trosa io ?'**
  String get deleteDebtMessage;

  /// No description provided for @no.
  ///
  /// In mg, this message translates to:
  /// **'TSIA'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In mg, this message translates to:
  /// **'ENY'**
  String get yes;

  /// No description provided for @about.
  ///
  /// In mg, this message translates to:
  /// **'Mombamomba'**
  String get about;

  /// No description provided for @stats.
  ///
  /// In mg, this message translates to:
  /// **'Statistika'**
  String get stats;

  /// No description provided for @settings.
  ///
  /// In mg, this message translates to:
  /// **'Fikirana'**
  String get settings;

  /// No description provided for @sortByDate.
  ///
  /// In mg, this message translates to:
  /// **'Daty'**
  String get sortByDate;

  /// No description provided for @sortByOwner.
  ///
  /// In mg, this message translates to:
  /// **'Anarana'**
  String get sortByOwner;

  /// No description provided for @sortByAmount.
  ///
  /// In mg, this message translates to:
  /// **'Sandany'**
  String get sortByAmount;

  /// No description provided for @shareAppMessage.
  ///
  /// In mg, this message translates to:
  /// **'Ndao hampiasa an\'ito {appUrl}'**
  String shareAppMessage(String appUrl);

  /// No description provided for @searchHint.
  ///
  /// In mg, this message translates to:
  /// **'Karohy (anarana, fanamarihana, sokajy)...'**
  String get searchHint;

  /// No description provided for @filterAll.
  ///
  /// In mg, this message translates to:
  /// **'Rehetra'**
  String get filterAll;

  /// No description provided for @filterUnpaid.
  ///
  /// In mg, this message translates to:
  /// **'Mbola tsy voaloa'**
  String get filterUnpaid;

  /// No description provided for @filterPaid.
  ///
  /// In mg, this message translates to:
  /// **'Efa voaloa'**
  String get filterPaid;

  /// No description provided for @filterOverdue.
  ///
  /// In mg, this message translates to:
  /// **'Lasa ny daty'**
  String get filterOverdue;

  /// No description provided for @paidBadge.
  ///
  /// In mg, this message translates to:
  /// **'Voaloa'**
  String get paidBadge;

  /// No description provided for @remainingLabel.
  ///
  /// In mg, this message translates to:
  /// **'Sisa'**
  String get remainingLabel;

  /// No description provided for @remainingText.
  ///
  /// In mg, this message translates to:
  /// **'Sisa {amount}'**
  String remainingText(String amount);

  /// No description provided for @amountLabel.
  ///
  /// In mg, this message translates to:
  /// **'Ohatrinona'**
  String get amountLabel;

  /// No description provided for @currencySuffix.
  ///
  /// In mg, this message translates to:
  /// **'{symbol}'**
  String currencySuffix(String symbol);

  /// No description provided for @amountRequired.
  ///
  /// In mg, this message translates to:
  /// **'Mila soratana hoe ohatrinona azafady.'**
  String get amountRequired;

  /// No description provided for @ownerLabel.
  ///
  /// In mg, this message translates to:
  /// **'Ilay olona'**
  String get ownerLabel;

  /// No description provided for @ownerRequired.
  ///
  /// In mg, this message translates to:
  /// **'Mila fenoina ny anaran\'ilay olona.'**
  String get ownerRequired;

  /// No description provided for @dueDateLabel.
  ///
  /// In mg, this message translates to:
  /// **'Haverina ny '**
  String get dueDateLabel;

  /// No description provided for @noteLabel.
  ///
  /// In mg, this message translates to:
  /// **'Fanamarihana'**
  String get noteLabel;

  /// No description provided for @paidAmountLabel.
  ///
  /// In mg, this message translates to:
  /// **'Vola efa voaloa'**
  String get paidAmountLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In mg, this message translates to:
  /// **'Sokajy'**
  String get categoryLabel;

  /// No description provided for @noCategory.
  ///
  /// In mg, this message translates to:
  /// **'Tsy misy sokajy'**
  String get noCategory;

  /// No description provided for @categoryFamily.
  ///
  /// In mg, this message translates to:
  /// **'Fianakaviana'**
  String get categoryFamily;

  /// No description provided for @categoryFriends.
  ///
  /// In mg, this message translates to:
  /// **'Namana'**
  String get categoryFriends;

  /// No description provided for @categoryWork.
  ///
  /// In mg, this message translates to:
  /// **'Asa'**
  String get categoryWork;

  /// No description provided for @categoryOther.
  ///
  /// In mg, this message translates to:
  /// **'Hafa'**
  String get categoryOther;

  /// No description provided for @recurringLabel.
  ///
  /// In mg, this message translates to:
  /// **'Averimberina isaky ny andro (0 = tsy misy)'**
  String get recurringLabel;

  /// No description provided for @aboutTitle.
  ///
  /// In mg, this message translates to:
  /// **'Mombamomba ny Trosa'**
  String get aboutTitle;

  /// No description provided for @aboutDescription.
  ///
  /// In mg, this message translates to:
  /// **'Application natao handraisana naoty ireo trosa tokony haloa sy mila takiana.'**
  String get aboutDescription;

  /// No description provided for @poweredBy.
  ///
  /// In mg, this message translates to:
  /// **'Powered by'**
  String get poweredBy;

  /// No description provided for @deletedSnackBar.
  ///
  /// In mg, this message translates to:
  /// **'Voafafa ny trosa'**
  String get deletedSnackBar;

  /// No description provided for @undoAction.
  ///
  /// In mg, this message translates to:
  /// **'AVERY'**
  String get undoAction;

  /// No description provided for @settingsTitle.
  ///
  /// In mg, this message translates to:
  /// **'Fikirana'**
  String get settingsTitle;

  /// No description provided for @currencyLabel.
  ///
  /// In mg, this message translates to:
  /// **'Volan-karena'**
  String get currencyLabel;

  /// No description provided for @themeLabel.
  ///
  /// In mg, this message translates to:
  /// **'Endrika'**
  String get themeLabel;

  /// No description provided for @themeSystem.
  ///
  /// In mg, this message translates to:
  /// **'Araka ny rafitra'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In mg, this message translates to:
  /// **'Mazava'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In mg, this message translates to:
  /// **'Maizina'**
  String get themeDark;

  /// No description provided for @backupExport.
  ///
  /// In mg, this message translates to:
  /// **'Export CSV'**
  String get backupExport;

  /// No description provided for @backupImport.
  ///
  /// In mg, this message translates to:
  /// **'Import CSV'**
  String get backupImport;

  /// No description provided for @backupImported.
  ///
  /// In mg, this message translates to:
  /// **'Trosa {count} no nampidirina'**
  String backupImported(int count);

  /// No description provided for @backupFailed.
  ///
  /// In mg, this message translates to:
  /// **'Tsy nahomby ny fanondranana'**
  String get backupFailed;

  /// No description provided for @notificationBody.
  ///
  /// In mg, this message translates to:
  /// **'Tsy maintsy haverina ny trosa ho an\'i {owner}'**
  String notificationBody(String owner);

  /// No description provided for @statsTitle.
  ///
  /// In mg, this message translates to:
  /// **'Statistika'**
  String get statsTitle;

  /// No description provided for @statsTotal.
  ///
  /// In mg, this message translates to:
  /// **'Trosa rehetra'**
  String get statsTotal;

  /// No description provided for @statsPaid.
  ///
  /// In mg, this message translates to:
  /// **'Efa voaloa'**
  String get statsPaid;

  /// No description provided for @statsOutstanding.
  ///
  /// In mg, this message translates to:
  /// **'Mbola misy sisa'**
  String get statsOutstanding;

  /// No description provided for @statsMonthly.
  ///
  /// In mg, this message translates to:
  /// **'Vola isam-bolana'**
  String get statsMonthly;

  /// No description provided for @statsTopOwners.
  ///
  /// In mg, this message translates to:
  /// **'Tompon-trosa ambony indrindra'**
  String get statsTopOwners;

  /// No description provided for @statsEmpty.
  ///
  /// In mg, this message translates to:
  /// **'Mbola tsy misy trosa voasoratra.'**
  String get statsEmpty;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['mg'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'mg':
      return AppLocalizationsMg();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
