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

  @override
  String get authErrInvalidCredentials => 'E-mail ou mot de passe incorrect';

  @override
  String get authErrUserExists => 'Un compte avec cet e-mail existe déjà';

  @override
  String get authErrNetwork =>
      'Impossible de joindre le serveur. Vérifiez votre connexion.';

  @override
  String get authErrUnknown => 'Une erreur s’est produite. Veuillez réessayer.';

  @override
  String get menuSignOut => 'Déconnexion';

  @override
  String get tutorialStepMode => 'Choisir votre mode de stock';

  @override
  String get tutorialStepProduct => 'Créer votre premier produit';

  @override
  String get tutorialStepAgent => 'Créer votre agent IA';

  @override
  String get tutorialStepPage => 'Connecter votre page';

  @override
  String get tutorialWelcomeTitle => 'Bienvenue sur Djaber.ai';

  @override
  String get tutorialWelcomeBody =>
      'On met votre boutique en route ensemble. Quatre étapes, et votre agent commence à répondre à vos clients.';

  @override
  String get tutorialStockTitle => 'D’abord, votre stock';

  @override
  String get tutorialStockBody =>
      'Vous choisissez comment gérer votre stock, puis vous créez votre premier produit — nom, prix, quantité.';

  @override
  String get tutorialAgentTitle => 'Puis votre agent';

  @override
  String get tutorialAgentBody =>
      'Créez-le en trois champs, connectez votre page Facebook, et il répond dès la première question.';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get commonActive => 'ACTIF';

  @override
  String tutorialStepCounter(int step, int total) {
    return 'ÉTAPE $step SUR $total';
  }

  @override
  String get tutorialModeTitle => 'Comment gérez-vous votre stock ?';

  @override
  String get tutorialModeSubtitle =>
      'Ce choix décide de ce que vous voyez dans l’application. Vous pouvez le changer à tout moment dans les paramètres.';

  @override
  String get stockModeSimple => 'Simple';

  @override
  String get stockModeAdvanced => 'Avancé';

  @override
  String get stockModeSimpleDesc =>
      'Produits, Catégories & Commandes — gérez votre inventaire et commandes sans complexité.';

  @override
  String get stockModeAdvancedDesc =>
      'Suite complète — Fournisseurs, Clients, Ventes, Achats, Caisse, Mouvements, Livraison et plus.';

  @override
  String get tutorialProductTitle => 'Votre premier produit';

  @override
  String get tutorialProductSubtitle =>
      'C’est ce que votre agent vendra. La description est ce qu’il lira pour répondre aux clients.';

  @override
  String get tutorialProductSubmit => 'Créer le produit';

  @override
  String get productName => 'Nom';

  @override
  String get productNamePlaceholder => 'Robe satin — Noir';

  @override
  String get productSku => 'Référence (SKU)';

  @override
  String get productSkuPlaceholder => 'PRD-001';

  @override
  String get productDescription => 'Description';

  @override
  String get productDescriptionPlaceholder =>
      'Décrivez le produit — l’agent s’en sert pour le vendre';

  @override
  String get productCostPrice => 'Prix d’achat (DA)';

  @override
  String get productSellingPrice => 'Prix de vente (DA)';

  @override
  String get productQuantity => 'Quantité initiale';

  @override
  String get productErrRequired => 'Ce champ est requis';

  @override
  String get productErrNotANumber => 'Entrez un nombre';

  @override
  String get productErrMustBePositive => 'Doit être supérieur à 0';

  @override
  String get productErrBelowCost =>
      'Doit être supérieur ou égal au prix d’achat';

  @override
  String get tutorialAgentSubtitle =>
      'Il répond à vos clients avec votre catalogue et vos prix. Trois champs suffisent — tout s’ajuste plus tard.';

  @override
  String get tutorialAgentSubmit => 'Créer l’agent';

  @override
  String get agentName => 'Nom de l’agent';

  @override
  String get agentNamePlaceholder => 'ex. Assistant de vente';

  @override
  String get agentPersonality => 'Personnalité';

  @override
  String get agentToneProfessional => 'Professionnel';

  @override
  String get agentToneProfessionalDesc => 'Formel et orienté business';

  @override
  String get agentToneFriendly => 'Amical';

  @override
  String get agentToneFriendlyDesc => 'Chaleureux et accessible';

  @override
  String get agentToneCasual => 'Décontracté';

  @override
  String get agentToneCasualDesc => 'Détendu et conversationnel';

  @override
  String get agentToneTechnical => 'Technique';

  @override
  String get agentToneTechnicalDesc => 'Détaillé et précis';

  @override
  String get agentInstructions => 'Instructions';

  @override
  String get agentInstructionsPlaceholder =>
      'Comment doit-il répondre, et quand vous passer la main';

  @override
  String get tutorialConnectTitle => 'Connectez votre page';

  @override
  String get tutorialConnectSubtitle =>
      'C’est la dernière étape. Votre agent répond dans la boîte de réception de cette page — dès qu’elle est connectée, il travaille.';

  @override
  String get connectPermissionsHeading => 'Facebook vous demandera';

  @override
  String get connectPermissionPages => 'Voir la liste de vos pages';

  @override
  String get connectPermissionMessages =>
      'Lire et envoyer les messages de la page';

  @override
  String get connectPermissionInfo => 'Accéder aux informations de la page';

  @override
  String get connectFacebook => 'Connecter Facebook';

  @override
  String get connectInstagram => 'Connecter Instagram';

  @override
  String get oauthLoading => 'Chargement de Facebook…';

  @override
  String get oauthLoadingHint =>
      'La page d’autorisation de Facebook s’affiche ici.';

  @override
  String get connectLater => 'Connecter plus tard';

  @override
  String get oauthDenied =>
      'Autorisation annulée. Vous pouvez réessayer quand vous voulez.';

  @override
  String get tutorialReadyTitle => 'Votre agent est en ligne';

  @override
  String get tutorialReadySubtitle =>
      'Il répond déjà aux messages de votre page, avec votre catalogue et vos prix. Ajoutez d’autres produits quand vous voulez.';

  @override
  String get tutorialReadyTitlePending => 'Vous y êtes presque';

  @override
  String get tutorialReadySubtitlePending =>
      'Votre catalogue et votre agent sont prêts. Il ne reste qu’à connecter votre page — votre agent commencera à répondre dès ce moment-là.';

  @override
  String get tutorialReadySubmit => 'Ouvrir l’application';

  @override
  String get tutorialReadyModeSimple =>
      'Simple — produits, catégories et commandes';

  @override
  String get tutorialReadyModeAdvanced => 'Avancé — la suite complète';

  @override
  String get homeGreetingMorning => 'Bonjour';

  @override
  String get homeGreetingAfternoon => 'Bon après-midi';

  @override
  String get homeGreetingEvening => 'Bonsoir';

  @override
  String get homeSnapshot => 'voici un aperçu';

  @override
  String get homeQueue => 'À traiter';

  @override
  String get homeQueueStuck => 'IA bloquée';

  @override
  String get homeQueueEmpty =>
      'Rien en attente. L’agent gère toutes les conversations.';

  @override
  String get homeQueueNoPage =>
      'Aucune page connectée, donc aucune conversation ne peut encore vous parvenir.';

  @override
  String homeQueueMore(int count) {
    return '+ $count autres';
  }

  @override
  String homeAgeMinutes(int count) {
    return '$count MIN';
  }

  @override
  String homeAgeHours(int count) {
    return '$count H';
  }

  @override
  String homeAgeDays(int count) {
    return '$count J';
  }

  @override
  String get homeNoPageTitle => 'Aucune page connectée';

  @override
  String get homeNoPageBody =>
      'Votre agent n’a encore nulle part où répondre. Connectez votre page Facebook ou Instagram et il se met au travail dès le premier message.';

  @override
  String get homeOverview => 'Aperçu';

  @override
  String get homeKpiPages => 'Pages connectées';

  @override
  String get homeKpiProducts => 'Produits';

  @override
  String homeKpiLowStock(int count) {
    return '$count stock faible';
  }

  @override
  String get homeKpiRevenue => 'Chiffre d’affaires (30j)';

  @override
  String homeKpiSales(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ventes',
      one: '$count vente',
    );
    return '$_temp0';
  }

  @override
  String get homeKpiStockValue => 'Valeur du stock';

  @override
  String get homeQuickActions => 'Actions rapides';

  @override
  String get homeActionConnectTitle => 'Connecter une page';

  @override
  String get homeActionConnectBody => 'Liez votre page Facebook';

  @override
  String get homeActionProductsTitle => 'Ajouter des produits';

  @override
  String get homeActionProductsBody => 'Construisez votre catalogue';

  @override
  String get homeActionAgentsTitle => 'Agents IA';

  @override
  String get homeActionAgentsBody => 'Gérez vos assistants';

  @override
  String get homeYourPages => 'Vos pages';

  @override
  String get homeManageAll => 'TOUT GÉRER →';

  @override
  String get homePagesEmpty => 'Aucune page connectée pour l’instant.';

  @override
  String get homePageActive => 'ACTIVE';

  @override
  String get homePageInactive => 'EN PAUSE';

  @override
  String homePageConnectedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'CONNECTÉE LE $dateString';
  }

  @override
  String get platformFacebook => 'Facebook';

  @override
  String get platformInstagram => 'Instagram';

  @override
  String get homeGetStarted => 'Démarrer';

  @override
  String get homeStepConnectTitle => 'Connecter une page';

  @override
  String get homeStepConnectBody => 'Liez Facebook pour commencer à discuter';

  @override
  String get homeStepProductsTitle => 'Ajouter des produits';

  @override
  String get homeStepProductsBody => 'Constituez votre catalogue';

  @override
  String get homeStepAgentTitle => 'Configurer votre agent IA';

  @override
  String get homeStepAgentBody => 'Personnalisez le ton et le comportement';

  @override
  String get homeStepSaleTitle => 'Réalisez votre première vente';

  @override
  String get homeStepSaleBody => 'Regardez l’IA gérer les demandes';

  @override
  String get navHome => 'ACCUEIL';

  @override
  String get navQueue => 'FILE';

  @override
  String get navInbox => 'BOÎTE';

  @override
  String get navStock => 'STOCK';

  @override
  String get navOrders => 'CMD';

  @override
  String get commonNotBuilt => 'pas encore disponible';
}
