// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class L10nFr extends L10n {
  L10nFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Djaber.ai';

  @override
  String get appTagline => 'Agent IA Social';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonDismiss => 'Fermer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonConfirm => 'Confirmer';

  @override
  String get commonSearch => 'Rechercher';

  @override
  String get commonLoading => 'Chargement…';

  @override
  String get commonSeeAll => 'Tout voir';

  @override
  String get commonEmpty => 'Rien ici';

  @override
  String get commonNext => 'Suivant';

  @override
  String get commonSkip => 'Passer';

  @override
  String get commonStart => 'Commencer';

  @override
  String get onboardingAnswersTitle => 'L\'agent répond à vos clients';

  @override
  String get onboardingAnswersBody =>
      'Il connaît votre catalogue, votre stock et vos prix. Il répond aux messages Facebook et Instagram à votre place, jour et nuit.';

  @override
  String get onboardingEscalationTitle => 'Vous intervenez quand il faut';

  @override
  String get onboardingEscalationBody =>
      'Quand l\'agent ne peut plus suivre la conversation, votre téléphone sonne. Vous reprenez la main, vous répondez, puis vous la lui rendez.';

  @override
  String get onboardingStockTitle => 'Votre stock dans votre poche';

  @override
  String get onboardingStockBody =>
      'Vérifiez une disponibilité, corrigez une quantité, recevez une livraison — sans revenir au bureau.';

  @override
  String get onboardingSampleCustomer => 'Amina B.';

  @override
  String get onboardingSampleMessage => 'Le noir est dispo en M ?';

  @override
  String get onboardingSampleReply =>
      'Oui — il en reste 4 en M. Livraison Oran 600 DA.';

  @override
  String get onboardingSampleEscalation =>
      'La cliente demande un remboursement.';

  @override
  String get onboardingSampleNeedsHuman => 'À traiter';

  @override
  String get onboardingSampleHandling => 'Agent en cours';

  @override
  String get onboardingShortcutProducts => 'Produits';

  @override
  String get onboardingShortcutOrders => 'Commandes';

  @override
  String get onboardingShortcutMovements => 'Mouvements';

  @override
  String get errorNetwork =>
      'Pas de connexion. Vérifiez votre réseau et réessayez.';

  @override
  String get errorTimeout => 'La requête a pris trop de temps.';

  @override
  String get errorUnauthorized => 'Votre session a expiré. Reconnectez-vous.';

  @override
  String get errorNotFound => 'Introuvable.';

  @override
  String get errorServer => 'Une erreur est survenue de notre côté.';

  @override
  String get errorUnknown => 'Une erreur est survenue.';

  @override
  String get langEnglish => 'English';

  @override
  String get langFrench => 'Français';

  @override
  String get langArabic => 'العربية';
}
