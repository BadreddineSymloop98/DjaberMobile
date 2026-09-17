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
  String get errorServer => 'Une erreur est survenue de notre côté.';

  @override
  String get toastProductCreated => 'Produit créé';

  @override
  String get toastAgentCreated => 'Agent IA créé';

  @override
  String get toastPageConnected => 'Page connectée';

  @override
  String get errorGeneric => 'Une erreur s’est produite. Veuillez réessayer.';

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
  String get obEsc2Body => '2400 DA · créée par l’IA';

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
  String get menuOverview => 'Vue d\'ensemble';

  @override
  String get menuInbox => 'Boîte de réception';

  @override
  String get menuSocial => 'Réseaux sociaux';

  @override
  String get menuServices => 'Services';

  @override
  String get menuProducts => 'Produits';

  @override
  String get menuAgents => 'Agents';

  @override
  String get menuCommercial => 'Commercial';

  @override
  String get menuSoon => 'Bientôt';

  @override
  String get menuNotifications => 'Notifications';

  @override
  String get menuAnalytics => 'Analyses';

  @override
  String get menuReports => 'Rapports';

  @override
  String get menuSettings => 'Paramètres';

  @override
  String get menuWebOnly => 'sur le web';

  @override
  String get tutorialStepAlreadyDone => 'Déjà fait — on continue';

  @override
  String get exitHint => 'Appuyez encore pour quitter';

  @override
  String get menuPages => 'Pages';

  @override
  String get menuPlan => 'Votre plan';

  @override
  String get menuPlanUnknown => '—';

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
  String get productsEyebrow => 'CATALOGUE';

  @override
  String get productsTitle => 'Produits';

  @override
  String productsSummary(int count, String value) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produits',
      one: '1 produit',
      zero: 'Aucun produit',
    );
    return 'Ce que votre agent vend. $_temp0, $value de valeur de stock.';
  }

  @override
  String get productsSearchLabel => 'RECHERCHE';

  @override
  String get productsSearchPlaceholder => 'Rechercher un produit…';

  @override
  String get productsFilterAll => 'Tous';

  @override
  String get productsFilterLowStock => 'Stock faible';

  @override
  String get productsSectionAll => 'TOUS LES PRODUITS';

  @override
  String get productsSectionLowStock => 'STOCK FAIBLE';

  @override
  String get productsInStock => 'EN STOCK';

  @override
  String get productsOutOfStock => 'RUPTURE';

  @override
  String productsThreshold(int count) {
    return 'SEUIL $count';
  }

  @override
  String get productsEmptyTitle => 'Aucun produit';

  @override
  String get productsEmptyBody =>
      'Ajoutez votre premier produit et votre agent pourra le vendre.';

  @override
  String get productsNoMatchTitle => 'Aucun résultat';

  @override
  String get productsNoMatchBody =>
      'Essayez un autre mot, ou retirez le filtre.';

  @override
  String get productsAdd => 'Ajouter un produit';

  @override
  String get productAddTitle => 'Ajouter un produit';

  @override
  String get productAlertThreshold => 'Seuil d’alerte';

  @override
  String get productAlertThresholdHint => 'Laissez vide pour aucune alerte';

  @override
  String get productCategory => 'Catégorie';

  @override
  String get productCategoryNone => 'Sans catégorie';

  @override
  String get productUnit => 'Unité';

  @override
  String get productUnitNone => 'Choisir une unité';

  @override
  String get productPhotos => 'Ajouter des photos';

  @override
  String get productPhotosHint => 'JPEG, PNG, WEBP · 5 MO MAX';

  @override
  String get productHasVariants => 'Ce produit a des variantes';

  @override
  String get productHasVariantsHint =>
      'Tailles ou couleurs — la quantité se règle par variante';

  @override
  String get productAddSubmit => 'Ajouter le produit';

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produits',
      one: '1 produit',
      zero: 'Aucun produit',
    );
    return '$_temp0';
  }

  @override
  String get productPhotosSoon =>
      'Les photos s’ajoutent depuis le web pour l’instant';

  @override
  String get productPhotosTooLarge =>
      'Les photos de plus de 5 Mo n’ont pas été ajoutées.';

  @override
  String get productPhotosWrongType =>
      'Seules les photos JPEG, PNG, WEBP ou GIF peuvent être ajoutées.';

  @override
  String get productPhotosTooMany => '10 photos maximum par produit.';

  @override
  String get productPhotosUploadFailed =>
      'Produit créé, mais ses photos n’ont pas pu être envoyées.';

  @override
  String get productPhotoRemove => 'Retirer la photo';

  @override
  String get productPhotoCamera => 'Prendre une photo';

  @override
  String get productPhotoGallery => 'Choisir dans la galerie';

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
  String get connectFailed =>
      'Votre page n’a pas pu être connectée. Réessayez, ou connectez-la plus tard.';

  @override
  String get connectNothingNew =>
      'Aucune nouvelle page n’a été connectée. Choisissez bien une page quand on vous le demande, puis réessayez.';

  @override
  String get connectLinkFailed =>
      'Page connectée, mais pas encore liée à votre agent. Vous pouvez la lier depuis les réglages de l’agent.';

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

  @override
  String get agentsTitle => 'Agents IA';

  @override
  String get agentsSubtitle =>
      'Créez et gérez des agents IA qui vendent vos produits sur les pages connectées';

  @override
  String get agentsActive => 'IA active';

  @override
  String get agentsInactive => 'IA en pause';

  @override
  String get agentsStatPages => 'Pages';

  @override
  String get agentsStatProducts => 'Produits';

  @override
  String get agentsStatModel => 'Modèle';

  @override
  String get agentsAllProducts => 'Tous';

  @override
  String get agentsNoPages => 'Ne répond encore sur aucune page';

  @override
  String get agentsPause => 'Mettre l’agent en pause';

  @override
  String get agentsResume => 'Réactiver l’agent';

  @override
  String get agentsPausedToast => 'Agent en pause — il ne répond plus';

  @override
  String get agentsResumedToast => 'Agent actif — il répond de nouveau';

  @override
  String get agentsEmptyTitle => 'Aucun agent';

  @override
  String get agentsEmptyBody =>
      'Créez un agent IA pour répondre automatiquement aux messages sur vos pages et vendre vos produits.';

  @override
  String get agentsEmptyCta => 'Créer votre agent';

  @override
  String get agentsActionInsights => 'Problèmes à traiter';

  @override
  String get agentsActionTest => 'Tester l’agent';

  @override
  String get agentsActionDetails => 'Détails et statistiques';

  @override
  String get agentsActionDelete => 'Supprimer l’agent';

  @override
  String get agentsDeleteTitle => 'Supprimer l’agent ?';

  @override
  String agentsDeleteBody(String name) {
    return '$name sera supprimé et ne répondra plus sur vos pages. Vous pourrez créer un nouvel agent ensuite.';
  }

  @override
  String get agentsDeleteConfirm => 'Supprimer';

  @override
  String get agentsDeletedToast => 'Agent supprimé';

  @override
  String get agentsInsightsTitle => 'Problèmes en attente';

  @override
  String get agentsInsightsEmpty =>
      'Aucun problème en attente — votre agent gère tout.';

  @override
  String get agentsInsightsNone => 'Rien ici.';

  @override
  String get agentsInsightUnclear => 'Pas clair';

  @override
  String get agentsInsightUnknown => 'Sujet inconnu';

  @override
  String get agentsInsightHandoff => 'Transmis à vous';

  @override
  String get agentsInsightCustomer => 'Client';

  @override
  String get agentsInsightAgent => 'Réponse de l’IA';

  @override
  String get agentsInsightResolve => 'Résoudre';

  @override
  String get agentsInsightDismiss => 'Ignorer';

  @override
  String get agentsInsightAddAndResolve => 'Ajouter et résoudre';

  @override
  String get agentsInsightInstructionHint =>
      'Ajoutez une consigne pour que l’agent gère mieux ce cas la prochaine fois…';

  @override
  String get agentsInsightResolved => 'Résolu';

  @override
  String get agentsInsightDismissed => 'Ignoré';

  @override
  String get agentsInsightPending => 'En attente';

  @override
  String get agentsInsightFailed => 'Le problème n’a pas pu être mis à jour.';

  @override
  String agentsTestTitle(String name) {
    return 'Tester — $name';
  }

  @override
  String get agentsTestEmpty => 'Envoyez un message pour tester';

  @override
  String get agentsTestNote =>
      'Un essai : aucun crédit consommé, aucune commande créée.';

  @override
  String get agentsTestPlaceholder => 'Écrivez un message…';

  @override
  String get agentsTestSend => 'Envoyer';

  @override
  String get agentsTestFailed => 'Pas de réponse — réessayez.';

  @override
  String get agentsDetailsConversations => 'Conversations';

  @override
  String agentsDetailsConversationsFoot(int received, int sent) {
    return '$received reçus · $sent envoyés';
  }

  @override
  String get agentsDetailsMessages => 'Messages';

  @override
  String agentsDetailsLastActive(String date) {
    return 'Dernier : $date';
  }

  @override
  String get agentsDetailsNoActivity => 'Aucune activité';

  @override
  String get agentsDetailsOrders => 'Commandes créées';

  @override
  String agentsDetailsResolvedFoot(int count) {
    return '$count résolus';
  }

  @override
  String get agentsDetailsInsights => 'Signalements de l’agent';

  @override
  String get agentsDetailsAll => 'Tous';

  @override
  String get agentsDetailsInstructions => 'Consignes personnalisées';

  @override
  String get agentsDetailsNoInstructions => 'Aucune consigne pour l’instant.';

  @override
  String get agentsDetailsEdit => 'Modifier';

  @override
  String get agentsDetailsSave => 'Enregistrer';

  @override
  String get agentsDetailsSaved => 'Consignes enregistrées';

  @override
  String get agentsDetailsSavedMerged =>
      'Consignes enregistrées — les lignes ajoutées sur le web sont conservées';

  @override
  String get agentsDetailsConflictTitle => 'Modifiées sur le web';

  @override
  String get agentsDetailsConflictBody =>
      'Ces consignes ont été modifiées pendant que vous écriviez. Version actuelle :';

  @override
  String get agentsDetailsUseLatest => 'Reprendre cette version';

  @override
  String get agentsDetailsKeepMine => 'Remplacer par la mienne';

  @override
  String get agentsNotFound => 'Agent introuvable.';

  @override
  String agentsTestEmptyFor(String name) {
    return 'Envoyez un message pour tester $name';
  }

  @override
  String get agentsTestProduct => 'Produit';

  @override
  String agentsTestProductId(String id) {
    return 'ID : $id…';
  }

  @override
  String get agentsPresetsTitle => 'Commencez avec un agent prêt à l’emploi';

  @override
  String get agentsPresetsBody =>
      'Chacun est configuré pour la vente en Algérie — darija, arabe et français, devis de livraison et gestion des commandes. Choisissez-en un, puis ajustez tout.';

  @override
  String get agentsPresetVisionVoice => 'VISION + VOIX';

  @override
  String get agentsPresetVoice => 'VOIX';

  @override
  String get agentsPresetCloserTagline =>
      'Transforme les conversations en commandes confirmées';

  @override
  String get agentsPresetCloser1 =>
      'Guide le client de la question à la commande confirmée';

  @override
  String get agentsPresetCloser2 =>
      'Chiffre la livraison par wilaya et clôture au total';

  @override
  String get agentsPresetCloser3 => 'Comprend les photos et les notes vocales';

  @override
  String get agentsPresetSupportTagline =>
      'Répond vite, vous transmet les problèmes';

  @override
  String get agentsPresetSupport1 =>
      'Répond poliment aux questions produits et commandes';

  @override
  String get agentsPresetSupport2 =>
      'Transmet réclamations et remboursements à un humain';

  @override
  String get agentsPresetSupport3 => 'Calme, exact, et va droit au but';

  @override
  String get agentsPresetAdvisorTagline =>
      'Aide le client à choisir le bon produit';

  @override
  String get agentsPresetAdvisor1 =>
      'Compare les options et explique les différences';

  @override
  String get agentsPresetAdvisor2 =>
      'Retrouve un produit à partir d’une photo du client';

  @override
  String get agentsPresetAdvisor3 =>
      'Idéal pour les catalogues à variantes et fiches techniques';

  @override
  String get agentsPresetExpressTagline =>
      'Réponses ultra-rapides pour gros volumes';

  @override
  String get agentsPresetExpress1 =>
      'Réponses courtes et rapides pour pages chargées';

  @override
  String get agentsPresetExpress2 =>
      'Consommation minimale — texte et voix uniquement';

  @override
  String get agentsPresetExpress3 => 'Crée et annule quand même les commandes';

  @override
  String get agentsPresetUse => 'Utiliser cet agent  →';

  @override
  String get agentsPresetOwn => 'Vous préférez créer le vôtre ?';

  @override
  String get agentsPresetScratch => 'Partir de zéro';

  @override
  String get agentsCreatedToast => 'Agent créé';

  @override
  String get agentFormSubtitle =>
      'Configurez un agent pour répondre à vos conversations. Seul le nom est obligatoire — tout le reste a une valeur par défaut.';

  @override
  String get agentFormBasics => 'Informations';

  @override
  String get agentFormDescription => 'Description';

  @override
  String get agentFormDescriptionPlaceholder =>
      'Décrivez brièvement ce que fait cet agent…';

  @override
  String get agentFormInstructions => 'Consignes personnalisées';

  @override
  String get agentFormInstructionsPlaceholder =>
      'Comment répondre, quoi éviter, comment gérer certains cas…';

  @override
  String get agentFormInstructionsHint =>
      'Ces consignes guident le comportement de l’agent dans les conversations.';

  @override
  String get agentFormAdvanced => 'Réglages avancés';

  @override
  String get agentFormAdvancedHint =>
      'Facultatif — des valeurs par défaut sont appliquées.';

  @override
  String get agentFormBehavior => 'Comportement';

  @override
  String get agentFormBehaviorSummary => 'Clôture · Transfert humain';

  @override
  String get agentFormClosing => 'Clôture de la conversation';

  @override
  String get agentFormClosingPlaceholder =>
      'Exemples :\n• Après une commande : « Merci ! Votre commande est en route. »\n• Le client dit au revoir : « Merci, à bientôt ! »\n• Client mécontent : « Désolé, je vous passe l’équipe. »';

  @override
  String get agentFormClosingHint =>
      'Quand et comment l’agent termine une conversation. Vide : il remercie après une commande et répond aux au revoir.';

  @override
  String get agentFormHandoff => 'Règles d’intervention humaine';

  @override
  String get agentFormHandoffPlaceholder =>
      'Exemples :\n• Remboursement ou retour → arrêter l’IA, me prévenir\n• Demande de remise → me laisser gérer\n• Réclamation → me transférer la conversation';

  @override
  String get agentFormHandoffHint =>
      'Quand l’agent s’arrête et vous passe la main. Les salutations (slm, cava, hi) restent toujours gérées par l’IA.';

  @override
  String get agentFormDisplay => 'Présentation des produits';

  @override
  String get agentFormDisplayDefault => 'Style par défaut';

  @override
  String get agentFormDisplayCustom => 'Personnalisé';

  @override
  String get agentFormDisplayHint =>
      'Comment l’agent présente un produit. Touchez une balise pour l’insérer — l’agent remplit les vraies données.';

  @override
  String get agentFormTemplate => 'Modèle';

  @override
  String get agentFormTemplatePlaceholder =>
      'Touchez les balises ci-dessus ou écrivez ici…';

  @override
  String get agentFormTagCard => 'Carte produit';

  @override
  String get agentFormTagName => 'Nom';

  @override
  String get agentFormTagPrice => 'Prix (DA)';

  @override
  String get agentFormTagDescription => 'Description';

  @override
  String get agentFormTagStock => 'Stock';

  @override
  String get agentFormTagNewLine => '↵ Nouvelle ligne';

  @override
  String get agentFormPreview => 'Aperçu';

  @override
  String get agentFormPreviewLive => 'Aperçu en direct';

  @override
  String get agentFormPreviewCustomer => 'Montrez-moi vos produits';

  @override
  String get agentFormPreviewDefault =>
      'Voici ce que nous avons !\n[PRODUCT_CARD]\nVous voulez commander ?';

  @override
  String get agentFormPreviewSampleName => 'Produit exemple';

  @override
  String get agentFormPreviewSampleDescription => 'Un excellent produit';

  @override
  String get agentFormModel => 'Modèle IA';

  @override
  String agentFormModelSummary(String model, String temperature, int tokens) {
    return '$model · $temperature · $tokens jetons';
  }

  @override
  String get agentFormModelPicker => 'Modèle';

  @override
  String agentFormModelCost(String usd) {
    return '≈ $usd / 1000 msgs';
  }

  @override
  String get agentFormModelsLoading => 'Chargement des modèles disponibles…';

  @override
  String get agentFormModelsUnavailable =>
      'Les modèles IA sont momentanément indisponibles. Réessayez plus tard.';

  @override
  String get agentFormTraitBestQuality => 'Meilleure qualité';

  @override
  String get agentFormTraitFastAffordable => 'Rapide et abordable';

  @override
  String get agentFormTraitLongContext128k => 'Contexte 128k';

  @override
  String get agentFormTraitLegacyFast => 'Ancien, rapide';

  @override
  String get agentFormTraitBestBalanced => 'Le plus équilibré';

  @override
  String get agentFormTraitFastCheap => 'Rapide et économique';

  @override
  String get agentFormTraitMostCapable => 'Le plus performant';

  @override
  String get agentFormTraitLatestFast => 'Récent, rapide';

  @override
  String get agentFormTraitLongContext1m => 'Contexte 1M';

  @override
  String get agentFormTraitBestOpenSource => 'Meilleur open source';

  @override
  String get agentFormTraitUltraFast => 'Ultra rapide';

  @override
  String get agentFormTraitMixtureOfExperts => 'MoE, contexte 32k';

  @override
  String get agentFormTraitReasoning => 'Modèle de raisonnement';

  @override
  String get agentFormTemperature => 'Température';

  @override
  String get agentFormPrecise => 'Précis';

  @override
  String get agentFormCreative => 'Créatif';

  @override
  String get agentFormMaxTokens => 'Jetons max';

  @override
  String get agentFormMaxTokensHint => 'Longueur max de réponse · 100 – 4096';

  @override
  String get agentFormImages => 'Reconnaissance d’images';

  @override
  String get agentFormImagesHint =>
      'L’IA voit les photos des clients et les compare à vos produits. 5 crédits par image (1 pour un texte).';

  @override
  String get agentFormVoice => 'Notes vocales';

  @override
  String get agentFormVoiceHint =>
      'L’IA écoute et transcrit les notes vocales (AR, FR, EN, darija). 3 crédits par note. Désactivé : l’agent demande un message écrit.';

  @override
  String get agentFormDelay => 'Délai de réponse';

  @override
  String agentFormDelayValue(int seconds) {
    return '$seconds s';
  }

  @override
  String get agentFormDelayMax => '10 s';

  @override
  String get agentFormDelayHint =>
      'Attend d’autres messages avant de répondre — les clients envoient souvent plusieurs messages courts, l’agent les regroupe.';

  @override
  String get agentFormPages => 'Pages connectées';

  @override
  String get agentFormPagesHint =>
      'Les pages où cet agent répond. Une page n’a qu’un seul agent.';

  @override
  String agentFormPagesSummary(int selected, int total) {
    return '$selected sur $total sélectionnées';
  }

  @override
  String agentFormPagesCount(int selected, int total) {
    return '$selected sur $total';
  }

  @override
  String get agentFormPagesNone => 'Aucune page connectée';

  @override
  String get agentFormPagesEmpty =>
      'Aucune page connectée pour l’instant. Connectez d’abord une page Facebook ou Instagram, puis liez-la à cet agent.';

  @override
  String agentFormPageTaken(String agent) {
    return 'Déjà liée à $agent';
  }

  @override
  String get agentFormPageActive => 'Active';

  @override
  String get agentFormPageInactive => 'Inactive';

  @override
  String get agentFormSelectAll => 'Tout sélectionner';

  @override
  String get agentFormClear => 'Effacer';

  @override
  String get agentFormProducts => 'Produits';

  @override
  String get agentFormSellAll => 'Vendre tout le catalogue';

  @override
  String get agentFormSellAllHint =>
      'L’agent connaît tous vos produits. Désactivez pour choisir.';

  @override
  String get agentFormProductsAll => 'Tout le catalogue';

  @override
  String agentFormProductsChosen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produits choisis',
      one: '1 produit choisi',
      zero: 'Aucun produit choisi',
    );
    return '$_temp0';
  }

  @override
  String get agentFormProductSearch => 'Recherche';

  @override
  String get agentFormProductSearchPlaceholder => 'Rechercher des produits…';

  @override
  String get agentFormProductsNone => 'Aucun produit disponible';

  @override
  String get agentFormProductsNoMatch =>
      'Aucun produit ne correspond à votre recherche';

  @override
  String get agentsNewTitle => 'Nouvel agent';
}
