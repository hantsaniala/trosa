// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Trosa';

  @override
  String get moneyToReceive => 'Argent à recevoir';

  @override
  String get moneyToPay => 'Argent à payer';

  @override
  String get balance => 'Votre solde';

  @override
  String currencyPrefix(String symbol) {
    return '$symbol ';
  }

  @override
  String get debtListTitle => 'Liste des dettes';

  @override
  String get addDebt => 'Ajouter une dette';

  @override
  String get editDebt => 'Modifier la dette';

  @override
  String get deleteDebtTitle => 'Supprimer la dette';

  @override
  String get deleteDebtMessage =>
      'Voulez-vous vraiment supprimer cette dette ?';

  @override
  String get no => 'NON';

  @override
  String get yes => 'OUI';

  @override
  String get about => 'À propos';

  @override
  String get stats => 'Statistiques';

  @override
  String get settings => 'Réglages';

  @override
  String get sortByDate => 'Date';

  @override
  String get sortByOwner => 'Nom';

  @override
  String get sortByAmount => 'Montant';

  @override
  String shareAppMessage(String appUrl) {
    return 'Venez utiliser $appUrl';
  }

  @override
  String get searchHint => 'Rechercher (nom, note, catégorie)...';

  @override
  String get filterAll => 'Tout';

  @override
  String get filterUnpaid => 'Non payées';

  @override
  String get filterPaid => 'Payées';

  @override
  String get filterOverdue => 'En retard';

  @override
  String get paidBadge => 'Payée';

  @override
  String get remainingLabel => 'Reste';

  @override
  String remainingText(String amount) {
    return 'Reste $amount';
  }

  @override
  String get amountLabel => 'Montant';

  @override
  String currencySuffix(String symbol) {
    return '$symbol';
  }

  @override
  String get amountRequired => 'Veuillez saisir un montant.';

  @override
  String get ownerLabel => 'La personne';

  @override
  String get ownerRequired => 'Veuillez saisir le nom de la personne.';

  @override
  String get dueDateLabel => 'À rendre le ';

  @override
  String get noteLabel => 'Note';

  @override
  String get paidAmountLabel => 'Montant déjà payé';

  @override
  String get categoryLabel => 'Catégorie';

  @override
  String get noCategory => 'Aucune catégorie';

  @override
  String get categoryFamily => 'Famille';

  @override
  String get categoryFriends => 'Amis';

  @override
  String get categoryWork => 'Travail';

  @override
  String get categoryOther => 'Autre';

  @override
  String get recurringLabel => 'Répéter tous les N jours (0 = jamais)';

  @override
  String get aboutTitle => 'À propos de Trosa';

  @override
  String get aboutDescription =>
      'Application pour suivre les dettes à payer et à récupérer.';

  @override
  String get poweredBy => 'Propulsé par';

  @override
  String get deletedSnackBar => 'Dette supprimée';

  @override
  String get undoAction => 'ANNULER';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get currencyLabel => 'Devise';

  @override
  String get themeLabel => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get languageLabel => 'Langue';

  @override
  String get languageMg => 'Malagasy';

  @override
  String get languageFr => 'Français';

  @override
  String get languageEn => 'English';

  @override
  String get backupExport => 'Exporter CSV';

  @override
  String get backupImport => 'Importer CSV';

  @override
  String backupImported(int count) {
    return '$count dettes importées';
  }

  @override
  String get backupFailed => 'Échec de l\'exportation';

  @override
  String get jsonExport => 'Exporter JSON';

  @override
  String get jsonImport => 'Importer JSON';

  @override
  String jsonImported(int count) {
    return '$count dettes et réglages restaurés';
  }

  @override
  String notificationBody(String owner) {
    return 'La dette de $owner doit être remboursée';
  }

  @override
  String get statsTitle => 'Statistiques';

  @override
  String get statsTotal => 'Toutes les dettes';

  @override
  String get statsPaid => 'Payées';

  @override
  String get statsOutstanding => 'En cours';

  @override
  String get statsMonthly => 'Montants mensuels';

  @override
  String get statsTopOwners => 'Principaux débiteurs';

  @override
  String get statsEmpty => 'Aucune dette enregistrée pour le moment.';

  @override
  String get statsTrend => 'Évolution de votre solde';

  @override
  String get statsShare => 'Partager le rapport';

  @override
  String get reminderSection => 'Rappels';

  @override
  String get reminderEnabledLabel => 'Activer le rappel';

  @override
  String get reminderLeadLabel => 'Avant la date d\'échéance';

  @override
  String get reminderLeadSameDay => 'Le jour même';

  @override
  String get reminderLeadOneDay => '1 jour avant';

  @override
  String get reminderLeadTwoDays => '2 jours avant';

  @override
  String get reminderLeadOneWeek => '1 semaine avant';

  @override
  String get reminderTimeLabel => 'Heure du rappel';

  @override
  String get paymentDialogTitle => 'Enregistrer un paiement';

  @override
  String get paymentHint => 'Combien a été payé ?';

  @override
  String get paymentRecorded => 'Paiement enregistré';

  @override
  String get recordPaymentAction => 'Enregistrer un paiement';

  @override
  String get markPaidAction => 'Marquer comme payée';

  @override
  String get editAction => 'Modifier';

  @override
  String settledLabel(String date) {
    return 'Payée le $date';
  }

  @override
  String progressPaid(int percent) {
    return 'Payée à $percent%';
  }

  @override
  String get addCategory => 'Nouvelle catégorie';

  @override
  String get newCategoryHint => 'Nom de la catégorie';

  @override
  String get categoryAdded => 'Catégorie ajoutée';

  @override
  String get categoryExists => 'Cette catégorie existe déjà';

  @override
  String get contactLabel => 'Choisir un contact du téléphone';

  @override
  String get onboardingTitle1 => 'Bienvenue sur Trosa';

  @override
  String get onboardingBody1 =>
      'Notez l\'argent qu\'on vous doit et vos dettes, au même endroit.';

  @override
  String get onboardingTitle2 => 'Argent entrant et sortant';

  @override
  String get onboardingBody2 =>
      'Visualisez l\'argent à recevoir, à payer et votre solde.';

  @override
  String get onboardingTitle3 => 'Gestes';

  @override
  String get onboardingBody3 =>
      'Glissez à gauche pour supprimer, à droite pour marquer payé. Touchez une dette pour enregistrer un paiement.';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingStart => 'Commencer';
}
