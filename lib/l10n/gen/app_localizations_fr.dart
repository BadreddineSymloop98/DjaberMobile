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
  String get onboardingEscalationTitle => 'Vous intervenez quand il le faut';

  @override
  String get onboardingEscalationBody =>
      'Quand l’IA ne peut plus suivre, elle s’arrête et vous prévient. Vous répondez depuis le téléphone, puis vous lui rendez la conversation.';

  @override
  String get onboardingStockTitle => 'Votre stock dans la poche';

  @override
  String get onboardingStockBody =>
      'Produits, achats, ventes et commandes. Vérifiez une quantité pendant que le client attend, corrigez-la sur place.';

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

  @override
  String get obStockValue => '1,24';

  @override
  String get obStockValueUnit => 'M DA';

  @override
  String get obStockValueLabel => 'Valeur du stock';

  @override
  String get obKpiProducts => 'Produits';

  @override
  String get obKpiProductsValue => '128';

  @override
  String get obKpiPurchases => 'Achats';

  @override
  String get obKpiPurchasesValue => '6';

  @override
  String get obKpiSales => 'Ventes';

  @override
  String get obKpiSalesValue => '24';

  @override
  String get obKpiOrders => 'Cmd';

  @override
  String get obKpiOrdersValue => '12';

  @override
  String get obInStock => 'En stock';

  @override
  String get obStockRow1Name => 'Robe satin — Noir — M';

  @override
  String get obStockRow1Meta => 'Seuil 5 · Rupture';

  @override
  String get obStockRow1Qty => '0';

  @override
  String get obStockRow2Name => 'Parfum Oud 50 ml';

  @override
  String get obStockRow2Meta => 'Seuil 10';

  @override
  String get obStockRow2Qty => '3';

  @override
  String get obStockRow3Name => 'Sac cuir — Camel';

  @override
  String get obStockRow3Meta => 'Seuil 5';

  @override
  String get obStockRow3Qty => '7';

  @override
  String get obEsc1Kind => 'IA bloquée';

  @override
  String get obEsc1Time => '2 min';

  @override
  String get obEsc1Name => 'Amina B.';

  @override
  String get obEsc1Body => 'Elle veut changer la taille — commande déjà payée.';

  @override
  String get obEsc2Kind => 'Commande à valider';

  @override
  String get obEsc2Time => '18 min';

  @override
  String get obEsc2Name => '#1042 — Bab Ezzouar';

  @override
  String get obEsc2Body => '2 400 DA · créée par l’IA';

  @override
  String get obEsc3Kind => 'Rupture de stock';

  @override
  String get obEsc3Time => '1 h';

  @override
  String get obEsc3Name => 'Robe satin — Noir — M';

  @override
  String get obEsc3Body => '0 en stock · 3 commandes en attente';

  @override
  String get obEsc4Kind => 'Négociation';

  @override
  String get obEsc4Time => '3 h';

  @override
  String get obEsc4Name => 'Sofiane K.';

  @override
  String get obEsc4Body => 'ndir lik 2 000 DA w nakhdo';

  @override
  String get authLoginTitle => 'Connexion';

  @override
  String get authLoginSubtitle =>
      'Connectez-vous à votre compte pour continuer';

  @override
  String get authSignupTitle => 'Création de compte';

  @override
  String get authSignupSubtitle => 'Commencez en moins d’une minute';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authFirstName => 'Prénom';

  @override
  String get authLastName => 'Nom';

  @override
  String get authPasswordHint => 'Au moins 8 caractères';

  @override
  String get authRemember => 'Se souvenir de moi';

  @override
  String get authLoginSubmit => 'Se connecter';

  @override
  String get authSignupSubmit => 'Créer le compte';

  @override
  String get authForgot => 'Mot de passe oublié ?';

  @override
  String get authNoAccount => 'Vous n’avez pas de compte ?';

  @override
  String get authSignupLink => 'Commencer';

  @override
  String get authHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get authSigninLink => 'Se connecter';

  @override
  String get authEmailPlaceholder => 'you@example.com';

  @override
  String get authFirstNamePlaceholder => 'Jane';

  @override
  String get authLastNamePlaceholder => 'Doe';

  @override
  String get authErrEmailRequired => 'L’e-mail est requis';

  @override
  String get authErrInvalidEmail => 'Veuillez saisir une adresse e-mail valide';

  @override
  String get authErrPasswordRequired => 'Le mot de passe est requis';

  @override
  String get authErrPasswordTooShort =>
      'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get authErrFirstNameRequired => 'Le prénom est requis';

  @override
  String get authErrLastNameRequired => 'Le nom est requis';

  @override
  String get authForgotBack => 'Retour à la connexion';

  @override
  String get authForgotTitle => 'Mot de passe oublié ?';

  @override
  String get authForgotSubtitle =>
      'Entrez votre e-mail pour recevoir un lien de réinitialisation';

  @override
  String get authForgotEmail => 'Adresse e-mail';

  @override
  String get authForgotEmailPlaceholder => 'vous@entreprise.com';

  @override
  String get authForgotSubmit => 'Envoyer le lien';

  @override
  String get authForgotSecure =>
      'Votre lien de réinitialisation est chiffré et expire dans 1 heure';

  @override
  String get authForgotRemember => 'Vous vous souvenez de votre mot de passe ?';

  @override
  String get authSentTitle => 'Vérifiez votre e-mail';

  @override
  String get authSentMessage =>
      'Nous avons envoyé un lien de réinitialisation à';

  @override
  String get authSentNoReceive => 'Vous n’avez pas reçu l’e-mail ?';

  @override
  String get authSentTryAnother => 'Essayez une autre adresse e-mail';
}
