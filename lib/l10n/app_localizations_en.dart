// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Trosa';

  @override
  String get moneyToReceive => 'Money to receive';

  @override
  String get moneyToPay => 'Money to pay';

  @override
  String get balance => 'Your balance';

  @override
  String currencyPrefix(String symbol) {
    return '$symbol ';
  }

  @override
  String get debtListTitle => 'Debt list';

  @override
  String get addDebt => 'Add debt';

  @override
  String get editDebt => 'Edit debt';

  @override
  String get deleteDebtTitle => 'Delete debt';

  @override
  String get deleteDebtMessage => 'Are you sure you want to delete this debt?';

  @override
  String get no => 'NO';

  @override
  String get yes => 'YES';

  @override
  String get about => 'About';

  @override
  String get stats => 'Stats';

  @override
  String get settings => 'Settings';

  @override
  String get sortByDate => 'Date';

  @override
  String get sortByOwner => 'Name';

  @override
  String get sortByAmount => 'Amount';

  @override
  String shareAppMessage(String appUrl) {
    return 'Come and use $appUrl';
  }

  @override
  String get searchHint => 'Search (name, note, category)...';

  @override
  String get filterAll => 'All';

  @override
  String get filterUnpaid => 'Unpaid';

  @override
  String get filterPaid => 'Paid';

  @override
  String get filterOverdue => 'Overdue';

  @override
  String get paidBadge => 'Paid';

  @override
  String get remainingLabel => 'Left';

  @override
  String remainingText(String amount) {
    return 'Left $amount';
  }

  @override
  String get amountLabel => 'Amount';

  @override
  String currencySuffix(String symbol) {
    return '$symbol';
  }

  @override
  String get amountRequired => 'Please enter an amount.';

  @override
  String get ownerLabel => 'The person';

  @override
  String get ownerRequired => 'Please enter the person\'s name.';

  @override
  String get dueDateLabel => 'Due on ';

  @override
  String get noteLabel => 'Note';

  @override
  String get paidAmountLabel => 'Amount already paid';

  @override
  String get categoryLabel => 'Category';

  @override
  String get noCategory => 'No category';

  @override
  String get categoryFamily => 'Family';

  @override
  String get categoryFriends => 'Friends';

  @override
  String get categoryWork => 'Work';

  @override
  String get categoryOther => 'Other';

  @override
  String get recurringLabel => 'Repeat every N days (0 = never)';

  @override
  String get aboutTitle => 'About Trosa';

  @override
  String get aboutDescription =>
      'App for keeping track of debts to pay and money to collect.';

  @override
  String get poweredBy => 'Powered by';

  @override
  String get deletedSnackBar => 'Debt deleted';

  @override
  String get undoAction => 'UNDO';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageLabel => 'Language';

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
    return '$count debts imported';
  }

  @override
  String get backupFailed => 'Export failed';

  @override
  String get jsonExport => 'Export JSON';

  @override
  String get jsonImport => 'Import JSON';

  @override
  String jsonImported(int count) {
    return '$count debts and settings restored';
  }

  @override
  String notificationBody(String owner) {
    return '$owner\'s debt must be repaid';
  }

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsTotal => 'All debts';

  @override
  String get statsPaid => 'Paid';

  @override
  String get statsOutstanding => 'Outstanding';

  @override
  String get statsMonthly => 'Monthly amounts';

  @override
  String get statsTopOwners => 'Top debtors';

  @override
  String get statsEmpty => 'No debts recorded yet.';

  @override
  String get statsTrend => 'Balance over time';

  @override
  String get statsShare => 'Share report';

  @override
  String get reminderSection => 'Reminders';

  @override
  String get reminderEnabledLabel => 'Enable reminder';

  @override
  String get reminderLeadLabel => 'Before due date';

  @override
  String get reminderLeadSameDay => 'Same day';

  @override
  String get reminderLeadOneDay => '1 day before';

  @override
  String get reminderLeadTwoDays => '2 days before';

  @override
  String get reminderLeadOneWeek => '1 week before';

  @override
  String get reminderTimeLabel => 'Reminder time';

  @override
  String get paymentDialogTitle => 'Record a payment';

  @override
  String get paymentHint => 'How much was paid?';

  @override
  String get paymentRecorded => 'Payment recorded';

  @override
  String get recordPaymentAction => 'Record a payment';

  @override
  String get markPaidAction => 'Mark as paid';

  @override
  String get editAction => 'Edit';

  @override
  String settledLabel(String date) {
    return 'Paid on $date';
  }

  @override
  String progressPaid(int percent) {
    return 'Paid $percent%';
  }

  @override
  String get addCategory => 'New category';

  @override
  String get newCategoryHint => 'Category name';

  @override
  String get categoryAdded => 'Category added';

  @override
  String get categoryExists => 'This category already exists';

  @override
  String get contactLabel => 'Pick from phone contacts';

  @override
  String get onboardingTitle1 => 'Welcome to Trosa';

  @override
  String get onboardingBody1 =>
      'Track money people owe you and what you owe, all in one place.';

  @override
  String get onboardingTitle2 => 'Money in and out';

  @override
  String get onboardingBody2 =>
      'See what\'s due to you, what you owe, and your balance at a glance.';

  @override
  String get onboardingTitle3 => 'Gestures';

  @override
  String get onboardingBody3 =>
      'Swipe left to delete, right to mark paid. Tap a debt to record a payment.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get started';
}
