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
  String get toastProductUpdated => 'Produit mis à jour';

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
      'Si un compte existe pour cette adresse, un lien de réinitialisation vient d’y être envoyé';

  @override
  String get authSentNoReceive => 'Vous n’avez pas reçu l’e-mail ?';

  @override
  String get authSentTryAnother => 'Essayez une autre adresse e-mail';

  @override
  String get authSentResend => 'Renvoyer le lien';

  @override
  String authSentResendIn(int seconds) {
    return 'Renvoyer le lien dans $seconds s';
  }

  @override
  String get authSentResent => 'Un nouveau lien a été envoyé';

  @override
  String get authSentNextStep =>
      'Ouvrez le lien reçu par e-mail pour choisir un nouveau mot de passe.';

  @override
  String get authResetTitle => 'Nouveau mot de passe';

  @override
  String get authResetSubtitle =>
      'Choisissez un nouveau mot de passe pour votre compte';

  @override
  String get authResetDeadSubtitle =>
      'Demandez un nouveau lien pour réinitialiser votre mot de passe';

  @override
  String get authResetChecking => 'Vérification du lien…';

  @override
  String get authResetPasswordLabel => 'Nouveau mot de passe';

  @override
  String get authResetConfirmLabel => 'Confirmer le mot de passe';

  @override
  String get authErrPasswordMismatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get authResetSubmit => 'Enregistrer le mot de passe';

  @override
  String get authResetDone => 'Mot de passe mis à jour';

  @override
  String get authResetRequestNew => 'Demander un nouveau lien';

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
  String get stockOverviewTitle => 'Aperçu du stock';

  @override
  String get stockOverviewSubtitle => 'Résumé inventaire, ventes et achats';

  @override
  String get stockOverviewHintSimple =>
      'Le mode Simple affiche produits, commandes et clients. Passez en Avancé pour les ventes, achats, fournisseurs, caisse et mouvements.';

  @override
  String get stockOverviewHintAdvanced =>
      'Mode Avancé : ERP complet — ventes, achats, fournisseurs, caisse et mouvements de stock sont activés.';

  @override
  String get stockTotalProducts => 'Total produits';

  @override
  String get stockLowStock => 'Stock faible';

  @override
  String get stockValue => 'Valeur du stock';

  @override
  String get stockRetailValue => 'Valeur de vente';

  @override
  String get stockCategories => 'Catégories';

  @override
  String get stockSuppliers => 'Fournisseurs';

  @override
  String get stockTotalItems => 'Total articles en stock';

  @override
  String get stockSalesMonth => 'Ventes ce mois';

  @override
  String get stockTotalSales => 'Total ventes';

  @override
  String get stockRevenue => 'Chiffre d’affaires';

  @override
  String get stockPaid => 'Payé';

  @override
  String get stockPending => 'En attente';

  @override
  String get stockPurchasesMonth => 'Achats ce mois';

  @override
  String get stockTotalPurchases => 'Total achats';

  @override
  String get stockTotalSpent => 'Total dépensé';

  @override
  String get stockReceived => 'Reçu';

  @override
  String get stockRecentMovements => 'Mouvements récents';

  @override
  String get stockMovementsEmpty =>
      'Aucun mouvement enregistré. Les mouvements apparaîtront ici quand des produits sont ajoutés, vendus ou ajustés.';

  @override
  String get stockMoveIn => 'Entrée';

  @override
  String get stockMoveOut => 'Sortie';

  @override
  String get stockMoveAdjustment => 'Ajustement';

  @override
  String get stockMoveReturn => 'Retour';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSubtitle =>
      'Gérez votre compte et les paramètres de l’application';

  @override
  String get settingsStockMode => 'Gestion du stock';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageFrench => 'Français';

  @override
  String get settingsLanguageEnglish => 'Anglais';

  @override
  String get settingsLanguageArabic => 'Arabe';

  @override
  String get settingsLanguageHelp =>
      'L’application reste dans la langue choisie, même si celle du téléphone change.';

  @override
  String get planNameIndividual => 'Individual';

  @override
  String get planNamePro => 'Pro';

  @override
  String get planNameTeams => 'Teams';

  @override
  String get planDescIndividual =>
      'Pour démarrer: connectez votre page et laissez l\'IA répondre à vos clients.';

  @override
  String get planDescPro =>
      'Pour les vendeurs actifs: vision, notes vocales et plus de volume.';

  @override
  String get planDescTeams =>
      'Pour les boutiques établies: volume maximal et priorité support.';

  @override
  String planFeaturePages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages Facebook / Instagram',
      one: '1 page Facebook ou Instagram',
    );
    return '$_temp0';
  }

  @override
  String planFeatureCredits(String amount) {
    return '$amount crédits IA / mois';
  }

  @override
  String planFeatureProducts(String amount) {
    return '$amount produits';
  }

  @override
  String planFeatureDelivery(int count, String carriers) {
    return 'Livraison $count wilayas ($carriers)';
  }

  @override
  String get planFeatureAgentText => 'Agent IA 24/7 (texte)';

  @override
  String get planFeatureAgentFull => 'Agent IA 24/7 (texte + images + vocal)';

  @override
  String get planFeatureStock => 'Gestion de stock & commandes';

  @override
  String get planFeatureCallConfirmation => 'Confirmation par appel';

  @override
  String get planFeatureVision => 'Reconnaissance d\'images (vision)';

  @override
  String get planFeatureVoiceNotes => 'Notes vocales (transcription)';

  @override
  String get planFeatureCrossSell => 'Cross-sell / Up-sell IA';

  @override
  String get planFeatureUnlimitedProducts => 'Produits illimités';

  @override
  String get planFeatureUnlimitedConversations => 'Conversations illimitées';

  @override
  String get planFeatureEverythingPro => 'Toutes les fonctionnalités Pro';

  @override
  String get planFeaturePrioritySupport => 'Support prioritaire';

  @override
  String get settingsAccount => 'Informations du compte';

  @override
  String get settingsBilling => 'Plan & facturation';

  @override
  String get settingsCurrentPlan => 'Plan actuel';

  @override
  String get settingsMonthly => 'Mensuel';

  @override
  String get settingsYearly => 'Annuel';

  @override
  String get settingsFree => 'Gratuit';

  @override
  String settingsPerMonth(String currency) {
    return '$currency / mois';
  }

  @override
  String settingsPerYear(String currency) {
    return '$currency / an';
  }

  @override
  String get settingsBadgeCurrent => 'Actuel';

  @override
  String get settingsBadgePopular => 'Populaire';

  @override
  String get settingsYourPlan => 'Votre plan actuel';

  @override
  String get settingsFreeNoPayment => 'Gratuit — aucun paiement requis';

  @override
  String settingsSubscribe(String price) {
    return 'Souscrire — $price';
  }

  @override
  String get settingsRedirecting => 'Redirection…';

  @override
  String get settingsVerifying => 'Vérification du paiement…';

  @override
  String get settingsNoPlans => 'Aucun plan disponible pour le moment.';

  @override
  String settingsCheckoutPaid(String plan) {
    return 'Paiement confirmé — votre plan $plan est actif.';
  }

  @override
  String get settingsCheckoutPending =>
      'Paiement pas encore confirmé. S’il est passé, votre plan sera activé sous peu.';

  @override
  String get settingsCheckoutFailed => 'Le paiement n’a pas abouti.';

  @override
  String get settingsFbTitle => 'Permissions API Facebook';

  @override
  String get settingsFbActive => 'Permissions actuellement actives';

  @override
  String get settingsFbAvailable => 'Permissions avancées disponibles';

  @override
  String get settingsFbReviewHint =>
      'Ces permissions nécessitent l’approbation par Facebook App Review.';

  @override
  String get settingsDangerTitle => 'Zone de danger';

  @override
  String get settingsDeleteAccount => 'Supprimer le compte';

  @override
  String get settingsDeleteHelp =>
      'Supprimer définitivement votre compte et toutes les données associées.';

  @override
  String get inboxTitle => 'Boîte de réception';

  @override
  String get inboxSubtitle => 'Lisez et répondez aux messages de vos clients.';

  @override
  String get inboxNoPagesTitle => 'Aucune page connectée';

  @override
  String get inboxNoPagesBody =>
      'Connectez une page Facebook ou Instagram pour commencer à recevoir des messages ici.';

  @override
  String get inboxConnectPage => 'Connecter une page';

  @override
  String get inboxPlatformMessenger => 'Messenger';

  @override
  String get inboxPlatformInstagram => 'DM Instagram';

  @override
  String inboxSynced(String time) {
    return 'synchronisé $time';
  }

  @override
  String get inboxSwitchPage => 'Changer de page';

  @override
  String get inboxConnectAnother => 'Connecter une autre page';

  @override
  String get inboxSync => 'Synchroniser';

  @override
  String get inboxSyncing => 'Synchronisation…';

  @override
  String get inboxTabAll => 'Tous';

  @override
  String get inboxTabActive => 'Actifs';

  @override
  String get inboxTabResolved => 'Terminés';

  @override
  String get inboxTabArchived => 'Archivés';

  @override
  String get inboxSearchHint => 'Rechercher par nom ou message…';

  @override
  String get inboxNoMatches => 'Aucune correspondance';

  @override
  String get inboxNoConversations => 'Aucune conversation';

  @override
  String get inboxNothingHere => 'Rien dans cette vue';

  @override
  String get inboxPullFromFacebook => 'Récupérer depuis Facebook';

  @override
  String get inboxUpToDate => 'À jour';

  @override
  String inboxSyncedCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Synchronisé — $n nouveaux messages',
      one: 'Synchronisé — 1 nouveau message',
    );
    return '$_temp0';
  }

  @override
  String get inboxAttachment => 'Pièce jointe';

  @override
  String get inboxEmptyMessage => 'Message vide';

  @override
  String get inboxAiPaused => 'IA en pause';

  @override
  String get inboxStatusActive => 'Active';

  @override
  String get inboxStatusResolved => 'Terminée';

  @override
  String get inboxStatusArchived => 'Archivée';

  @override
  String get inboxTimeNow => 'maintenant';

  @override
  String inboxTimeMinutes(int n) {
    return '$n min';
  }

  @override
  String inboxTimeHours(int n) {
    return '$n h';
  }

  @override
  String get conversationMarkResolved => 'Marquer terminé';

  @override
  String get conversationArchive => 'Archiver la conversation';

  @override
  String get conversationReopen => 'Rouvrir';

  @override
  String get conversationResumeAi => 'Réactiver l’IA';

  @override
  String get conversationPausedNotice =>
      'L’agent ne répond plus à ce client. Répondez-lui ici.';

  @override
  String get conversationReplyHint => 'Écrivez votre réponse…';

  @override
  String get conversationSend => 'Envoyer';

  @override
  String get conversationSending => 'Envoi…';

  @override
  String get conversationReopenHint =>
      'Rouvrir cette conversation pour répondre.';

  @override
  String get conversationEmpty => 'Aucun message';

  @override
  String get conversationResolvedToast => 'Marqué comme terminé';

  @override
  String get conversationArchivedToast => 'Archivé';

  @override
  String get conversationReopenedToast => 'Conversation rouverte';

  @override
  String get conversationAiResumedToast => 'L’IA répond de nouveau';

  @override
  String get conversationAuthorAi => 'IA';

  @override
  String get conversationAuthorYou => 'Vous';

  @override
  String get productVariantsTitle => 'Variantes';

  @override
  String productVariantsTotal(int count) {
    return 'Total qté : $count';
  }

  @override
  String get productVariantAdd => 'Ajouter une variante';

  @override
  String get productVariantsEmpty =>
      'Aucune variante. Touchez « Ajouter une variante » pour en créer une.';

  @override
  String get productVariantName => 'Nom';

  @override
  String get productVariantNamePlaceholder => 'ex. Rouge - L';

  @override
  String get productVariantSku => 'SKU';

  @override
  String get productVariantSkuPlaceholder => 'Facultatif';

  @override
  String get productVariantCost => 'Coût';

  @override
  String get productVariantPrice => 'Prix';

  @override
  String get productVariantQuantity => 'Qté';

  @override
  String get productVariantMinQuantity => 'Qté min';

  @override
  String get productVariantRemove => 'Supprimer la variante';

  @override
  String get productVariantDuplicate =>
      'Deux variantes ne peuvent pas avoir le même nom';

  @override
  String get productVariantsRequired =>
      'Ajoutez au moins une variante, ou décochez la case.';

  @override
  String get productVariantsRetryHint =>
      'Le produit est créé — seules les variantes manquantes seront renvoyées.';

  @override
  String get productDetailEyebrow => 'DÉTAILS DU PRODUIT';

  @override
  String get productDetailNoImages => 'Aucune image';

  @override
  String get productDetailCost => 'Prix d’achat';

  @override
  String get productDetailSelling => 'Prix de vente';

  @override
  String get productDetailProfit => 'Bénéfice / marge';

  @override
  String get productDetailInStock => 'En stock';

  @override
  String get productDetailStatus => 'Statut';

  @override
  String get productDetailActive => 'Actif';

  @override
  String get productDetailInactive => 'Inactif';

  @override
  String productDetailVariants(int count) {
    return 'Variantes ($count)';
  }

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
  String productsVariantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count VARIANTES',
      one: '1 VARIANTE',
    );
    return '$_temp0';
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
  String get productEditTitle => 'Modifier le produit';

  @override
  String get productEditSubmit => 'Mettre à jour le produit';

  @override
  String get productEditVariantsHint =>
      'Pour ajuster les quantités des variantes, utilisez « Ajuster le stock ».';

  @override
  String get productEditLeaveBody => 'Les modifications seront perdues.';

  @override
  String get productEditDeleteVariantsTitle => 'Supprimer des variantes ?';

  @override
  String productEditDeleteVariantsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count variantes seront supprimées définitivement.',
      one: '1 variante sera supprimée définitivement.',
    );
    return '$_temp0';
  }

  @override
  String productEditDeleteVariantsStock(int count, int stock) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count variantes seront supprimées définitivement, et leurs $stock unités retirées de votre stock.',
      one:
          '1 variante sera supprimée définitivement, et ses $stock unités retirées de votre stock.',
    );
    return '$_temp0';
  }

  @override
  String get productEditDeleteVariantsConfirm => 'Supprimer et enregistrer';

  @override
  String get productUnitAdd => 'Ajouter une unité';

  @override
  String get productUnitName => 'Nom de l’unité';

  @override
  String get productUnitNamePlaceholder => 'ex. Douzaine';

  @override
  String get productUnitAbbreviation => 'Abréviation';

  @override
  String get productUnitAbbreviationPlaceholder => 'ex. dz';

  @override
  String get productUnitCreate => 'Ajouter l’unité';

  @override
  String get stockAdjustTitle => 'Ajuster le stock';

  @override
  String stockAdjustSubtitle(String product, String stock) {
    return '$product  ·  Stock actuel : $stock';
  }

  @override
  String get stockAdjustIn => 'Entrée (+)';

  @override
  String get stockAdjustOut => 'Sortie (−)';

  @override
  String get stockAdjustSet => 'Fixer';

  @override
  String get stockAdjustReason => 'Motif';

  @override
  String stockAdjustCurrent(int count) {
    return 'QTÉ : $count';
  }

  @override
  String stockAdjustResult(int count) {
    return 'Nouvelle quantité : $count';
  }

  @override
  String stockAdjustInsufficient(int count) {
    return '$count seulement en stock';
  }

  @override
  String get stockAdjustNothing =>
      'Saisissez une quantité sur au moins une ligne.';

  @override
  String get stockAdjustSubmit => 'Ajuster le stock';

  @override
  String get stockAdjustDone => 'Stock ajusté';

  @override
  String get expensesTitle => 'Dépenses du produit';

  @override
  String get expensesEyebrow => 'DÉPENSES DU PRODUIT';

  @override
  String get expensesMarginSummary => 'Résumé de la marge';

  @override
  String get expensesTotal => 'Total des dépenses';

  @override
  String get expensesPerUnit => 'Dépense / unité';

  @override
  String get expensesTrueCost => 'Coût réel';

  @override
  String get expensesNetMargin => 'Marge nette';

  @override
  String expensesSection(int count) {
    return 'Dépenses ($count)';
  }

  @override
  String get expensesEmpty =>
      'Aucune dépense pour l’instant. Ajoutez-en une ci-dessous et la marge en tiendra compte.';

  @override
  String get expensesAddSection => 'Ajouter une dépense';

  @override
  String get expenseCategory => 'Catégorie';

  @override
  String get expenseCategoryMarketing => 'Marketing';

  @override
  String get expenseCategoryShipping => 'Livraison';

  @override
  String get expenseCategoryPackaging => 'Emballage';

  @override
  String get expenseCategoryCustoms => 'Douane';

  @override
  String get expenseCategoryStorage => 'Stockage';

  @override
  String get expenseCategoryOther => 'Autre';

  @override
  String get expenseAmount => 'Montant (DA)';

  @override
  String get expenseAmountPlaceholder => 'Montant';

  @override
  String get expenseDescriptionPlaceholder => 'Description (facultatif)';

  @override
  String get expenseFixed => 'Fixe';

  @override
  String get expensePerUnit => 'Par unité';

  @override
  String get expensePerUnitTag => '/ unité';

  @override
  String get expenseAdd => 'Ajouter la dépense';

  @override
  String get expenseAdded => 'Dépense ajoutée';

  @override
  String get expenseDeleteTitle => 'Supprimer cette dépense ?';

  @override
  String expenseDeleteBody(String category, String amount) {
    return '$category — $amount sera retirée, et la marge recalculée.';
  }

  @override
  String get expenseDeleted => 'Dépense supprimée';

  @override
  String get productDeleteTitle => 'Supprimer le produit';

  @override
  String productDeleteBody(String name) {
    return 'Voulez-vous vraiment supprimer $name ? Cette action est irréversible.';
  }

  @override
  String get productDeleteDone => 'Produit supprimé';

  @override
  String get productDetailActions => 'Actions';

  @override
  String get productDetailAdjustMeta => 'Entrée, sortie ou quantité exacte';

  @override
  String get productDetailExpensesMeta => 'Coût réel et marge nette';

  @override
  String get productDetailDeleteMeta => 'Le retire de votre catalogue';

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
  String get productPhotosUploadFailedEdit =>
      'Produit mis à jour, mais les nouvelles photos n’ont pas pu être envoyées.';

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
  String get agentFormEditTitle => 'Modifier l’agent';

  @override
  String get agentFormEditSubtitle =>
      'Mettez à jour la configuration de votre agent IA. Les changements s’appliquent aux prochains messages.';

  @override
  String get agentFormEditAdvancedHint =>
      'Touchez une section pour la modifier.';

  @override
  String get agentFormActive => 'Agent actif';

  @override
  String get agentFormActiveHint =>
      'Il répond aux messages de ses pages tant qu’il est actif.';

  @override
  String get agentFormSave => 'Enregistrer les modifications';

  @override
  String get agentFormSavedToast => 'Agent mis à jour';

  @override
  String get agentFormSavedMergedToast =>
      'Agent mis à jour — les consignes ajoutées sur le web sont conservées';

  @override
  String get agentFormLeaveTitle => 'Quitter sans enregistrer ?';

  @override
  String agentFormLeaveBody(String name) {
    return 'Vos modifications de $name seront perdues.';
  }

  @override
  String get productFormLeaveBody => 'Le produit commencé sera perdu.';

  @override
  String get conversationLeaveBody => 'Votre réponse non envoyée sera perdue.';

  @override
  String get agentDetailsLeaveBody =>
      'Vos modifications des instructions seront perdues.';

  @override
  String get agentGenerateLeaveBody => 'L’agent généré sera abandonné.';

  @override
  String get tutorialAgentLeaveBody => 'L’agent commencé sera perdu.';

  @override
  String get checkoutLeaveTitle => 'Quitter la page de paiement ?';

  @override
  String get checkoutLeaveBody => 'Votre paiement n’est pas terminé.';

  @override
  String get agentFormKeepEditing => 'Continuer à modifier';

  @override
  String get agentFormLeave => 'Quitter sans enregistrer';

  @override
  String get agentsDetailsEditAgent => 'Modifier l’agent';

  @override
  String get pagesEyebrow => 'Canaux connectés';

  @override
  String get pagesTitle => 'Pages & boîtes de réception';

  @override
  String get pagesSubtitle =>
      'Chaque page connectée a sa propre boîte de réception, son stock et son agent IA dédié.';

  @override
  String get pagesStatTotal => 'Total des pages';

  @override
  String get pagesStatPlanLimit => 'Limite du plan';

  @override
  String get pagesFilterAll => 'Toutes les plateformes';

  @override
  String get pagesEmptyTitle => 'Aucune page connectée';

  @override
  String get pagesEmptyBody =>
      'Connectez vos pages pour commencer à les gérer avec l’IA.';

  @override
  String pagesEmptyPlatformTitle(String platform) {
    return 'Aucune page $platform';
  }

  @override
  String pagesEmptyPlatformBody(String platform) {
    return 'Connectez vos pages $platform pour commencer.';
  }

  @override
  String get pagesDisconnectTitle => 'Déconnecter la page ?';

  @override
  String pagesDisconnectBody(String name) {
    return 'Vous ne recevrez plus les messages de $name et l’agent IA arrêtera d’y répondre.';
  }

  @override
  String get pagesDisconnectConfirm => 'Déconnecter';

  @override
  String get pagesDisconnectedToast => 'Page déconnectée';

  @override
  String get pageCardAiOn => 'IA active';

  @override
  String get pageCardAiOff => 'IA désactivée';

  @override
  String get pageCardStatConvos => 'Conv.';

  @override
  String get pageCardStatMsgs7d => 'Msg 7j';

  @override
  String get pageCardStatUnread => 'Non lus';

  @override
  String get pageCardStatStock => 'Stock';

  @override
  String pageCardStatActive(int n) {
    return '$n actifs';
  }

  @override
  String pageCardStatIn(int n) {
    return '$n entr.';
  }

  @override
  String get pageCardStatNeedsReply => 'à répondre';

  @override
  String get pageCardStatProducts => 'produits';

  @override
  String get pageCardAgentReady => 'Agent IA prêt';

  @override
  String get pageCardAgentTailored => 'Adapté à la boîte de cette page.';

  @override
  String get pageCardAgentNotReady => 'Pas encore d’agent personnalisé';

  @override
  String get pageCardAgentNotReadyHint =>
      'Générez-en un à partir des conversations récentes de cette page.';

  @override
  String get pageCardAgentGenerate => 'Générer';

  @override
  String get pageCardAgentRegenerate => 'Régénérer';

  @override
  String get pageCardActionInbox => 'Boîte';

  @override
  String get pageCardActionStock => 'Stock';

  @override
  String get pageCardActionConfigure => 'Configurer';

  @override
  String get pageCardActionDisconnect => 'Déconnecter';

  @override
  String get pageCardNoActivity => 'Aucune activité';

  @override
  String get pageCardNow => 'à l’instant';

  @override
  String pageCardMinutesAgo(int n) {
    return 'il y a $n min';
  }

  @override
  String pageCardHoursAgo(int n) {
    return 'il y a $n h';
  }

  @override
  String pageCardDaysAgo(int n) {
    return 'il y a $n j';
  }

  @override
  String get agentGenTitle =>
      'Générer un agent IA depuis la boîte de réception';

  @override
  String agentGenSubtitle(String pageName) {
    return 'Nous lirons les conversations récentes sur $pageName et rédigerons un agent sur mesure.';
  }

  @override
  String get agentGenWhatTitle => 'Ce que ça fait';

  @override
  String get agentGenWhat1 =>
      'Lit jusqu’à 25 conversations récentes (aucune copie n’est stockée)';

  @override
  String get agentGenWhat2 =>
      'Détecte ce que vous vendez, les langues utilisées et les questions les plus fréquentes';

  @override
  String get agentGenWhat3 =>
      'Rédige une personnalité, un ton, une longueur de réponse et des instructions adaptées';

  @override
  String get agentGenWhat4 =>
      'Vous prévisualisez, modifiez et appliquez — rien ne change avant d’appuyer sur Appliquer';

  @override
  String get agentGenStart => 'Lire la boîte & générer';

  @override
  String get agentGenPhaseReading => 'Lecture des conversations récentes…';

  @override
  String get agentGenPhaseAnalyzing =>
      'Compréhension du contexte — produits, langue, ton…';

  @override
  String get agentGenPhaseDrafting => 'Rédaction de votre agent IA sur mesure…';

  @override
  String get agentGenPhaseSubhint =>
      'Cela prend généralement 10 à 30 secondes.';

  @override
  String get agentGenStepRead => 'Lire';

  @override
  String get agentGenStepAnalyze => 'Analyser';

  @override
  String get agentGenStepDraft => 'Rédiger';

  @override
  String get agentGenSummary => 'Résumé de l’activité';

  @override
  String agentGenSampled(int conversations, int messages) {
    return '$conversations conversations · $messages messages';
  }

  @override
  String get agentGenLanguages => 'Langues';

  @override
  String get agentGenTopQuestions => 'Questions fréquentes';

  @override
  String get agentGenPersonality => 'Personnalité';

  @override
  String get agentGenTone => 'Ton';

  @override
  String get agentGenLength => 'Longueur';

  @override
  String get agentGenInstructions => 'Instructions personnalisées';

  @override
  String get agentGenEditHint =>
      'Modifiez avant d’appliquer. Ces instructions sont enregistrées sur les paramètres IA de cette page.';

  @override
  String agentGenChars(int n) {
    return '$n car.';
  }

  @override
  String get agentGenDiscard => 'Annuler';

  @override
  String agentGenApply(String pageName) {
    return 'Appliquer à $pageName';
  }

  @override
  String get agentGenApplying => 'Application des paramètres…';

  @override
  String agentGenCreated(String pageName) {
    return 'Agent IA créé et lié à $pageName';
  }

  @override
  String agentGenUpdated(String pageName) {
    return 'Agent IA mis à jour pour $pageName';
  }

  @override
  String get agentGenApplyFail => 'Impossible d’appliquer les paramètres';

  @override
  String get agentGenToneBalanced => 'Équilibré';

  @override
  String get agentGenToneFormal => 'Formel';

  @override
  String get agentGenToneCasual => 'Décontracté';

  @override
  String get agentGenToneEnthusiastic => 'Enthousiaste';

  @override
  String get agentGenLengthShort => 'Courte';

  @override
  String get agentGenLengthMedium => 'Moyenne';

  @override
  String get agentGenLengthDetailed => 'Détaillée';

  @override
  String get agentsNewTitle => 'Nouvel agent';

  @override
  String get commonYes => 'Oui';

  @override
  String get commonNo => 'Non';

  @override
  String get menuCategories => 'Catégories';

  @override
  String get categoriesTitle => 'Catégories';

  @override
  String categoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count catégories',
      one: '1 catégorie',
      zero: '0 catégorie',
    );
    return '$_temp0';
  }

  @override
  String get categoriesSearchPlaceholder => 'Rechercher des catégories...';

  @override
  String get categoriesFilters => 'Filtres';

  @override
  String categoriesFiltersActive(int count) {
    return 'Filtres · $count';
  }

  @override
  String get categoriesSection => 'Toutes les catégories';

  @override
  String categoriesProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produits',
      one: '1 produit',
      zero: '0 produit',
    );
    return '$_temp0';
  }

  @override
  String get categoriesEmptyTitle => 'Aucune catégorie';

  @override
  String get categoriesEmptyBody =>
      'Créez des catégories pour organiser vos produits';

  @override
  String get categoriesNoMatchBody =>
      'Aucune catégorie ne correspond à la recherche ou aux filtres.';

  @override
  String get categoriesFilterMin => 'Produits · min';

  @override
  String get categoriesFilterMax => 'Produits · max';

  @override
  String get categoriesFilterRangeInvalid => 'Doit être au moins le minimum';

  @override
  String get categoriesFilterHasDescription => 'A une description';

  @override
  String categoriesFilterColorsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sélectionnées',
      one: '1 sélectionnée',
    );
    return '$_temp0';
  }

  @override
  String get categoriesFilterApply => 'Appliquer les filtres';

  @override
  String get categoriesFilterClear => 'Tout effacer';

  @override
  String get categoryAddTitle => 'Ajouter une catégorie';

  @override
  String get categoryEditTitle => 'Modifier la catégorie';

  @override
  String get categoryName => 'Nom';

  @override
  String get categoryNamePlaceholder => 'ex. Électronique';

  @override
  String get categoryDescriptionPlaceholder => 'Description facultative';

  @override
  String get categoryColor => 'Couleur';

  @override
  String get categoryColorCustom => 'Couleur personnalisée';

  @override
  String get categoryColorHex => 'Code hexadécimal';

  @override
  String get categoryColorInvalid => 'Six caractères hexadécimaux, ex. EC4899';

  @override
  String get categoryColorApply => 'Utiliser cette couleur';

  @override
  String get categoryCreate => 'Ajouter la catégorie';

  @override
  String get categoryUpdate => 'Mettre à jour la catégorie';

  @override
  String get categoryNameTooShort => 'Au moins 2 caractères';

  @override
  String get categoryNameTaken => 'Vous avez déjà une catégorie avec ce nom';

  @override
  String get categoryAdded => 'Catégorie ajoutée';

  @override
  String get categoryUpdated => 'Catégorie mise à jour';

  @override
  String get categoryDeleted => 'Catégorie supprimée';

  @override
  String get categoryDeleteTitle => 'Supprimer la catégorie';

  @override
  String categoryDeleteBody(String name) {
    return 'Voulez-vous vraiment supprimer $name ?';
  }

  @override
  String categoryDeleteNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cette catégorie contient $count produits.',
      one: 'Cette catégorie contient 1 produit.',
    );
    return '$_temp0';
  }

  @override
  String get categoryDeleteNoticeBody => 'Ils n’auront plus de catégorie.';

  @override
  String get menuClients => 'Clients';

  @override
  String get clientsEyebrow => 'VENTES';

  @override
  String get clientsTitle => 'Clients';

  @override
  String get clientsSubtitle =>
      'Clients enregistrés depuis les conversations IA et les commandes confirmées';

  @override
  String get clientsStatTotal => 'Total clients';

  @override
  String get clientsStatActive => 'Actifs';

  @override
  String get clientsStatWithOrders => 'Avec commandes';

  @override
  String get clientsStatTotalSpent => 'Total dépensé';

  @override
  String get clientsSearchName => 'Rechercher par nom ou e-mail...';

  @override
  String get clientsSearchPhone => 'Rechercher par téléphone...';

  @override
  String get clientsSection => 'Tous les clients';

  @override
  String get clientsSourceAi => 'Chat IA';

  @override
  String get clientsSourceManual => 'Manuel';

  @override
  String clientsOrderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commandes',
      one: '1 commande',
      zero: '0 commande',
    );
    return '$_temp0';
  }

  @override
  String clientsConversationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conversations',
      one: '1 conversation',
    );
    return '$_temp0';
  }

  @override
  String get clientsEmptyTitle => 'Aucun client';

  @override
  String get clientsEmptyBody =>
      'Les clients apparaissent ici automatiquement quand le chatbot IA confirme une commande, ou ajoutez-les manuellement.';

  @override
  String get clientsNoMatchBody =>
      'Aucun client ne correspond à la recherche ou aux filtres.';

  @override
  String get clientsFilterStatus => 'Statut';

  @override
  String get clientsFilterActive => 'Actifs';

  @override
  String get clientsFilterInactive => 'Inactifs';

  @override
  String get clientsFilterSource => 'Source';

  @override
  String get clientsFilterOrdersMin => 'Commandes · min';

  @override
  String get clientsFilterOrdersMax => 'Commandes · max';

  @override
  String get clientsFilterSpentMin => 'Dépensé (DA) · min';

  @override
  String get clientsFilterSpentMax => 'Dépensé (DA) · max';

  @override
  String get dateFrom => 'Date de début';

  @override
  String get dateTo => 'Date de fin';

  @override
  String get dateClear => 'Effacer la date';

  @override
  String get datePickerToday => 'Aujourd’hui';

  @override
  String get clientAddTitle => 'Ajouter un client';

  @override
  String get clientEditTitle => 'Modifier le client';

  @override
  String get clientCreate => 'Ajouter le client';

  @override
  String get clientUpdate => 'Mettre à jour le client';

  @override
  String get clientNamePlaceholder => 'Nom du client';

  @override
  String get clientPhone => 'Téléphone';

  @override
  String get clientAddress => 'Adresse';

  @override
  String get clientAddressPlaceholder => 'Adresse du client';

  @override
  String get clientNotes => 'Notes';

  @override
  String get clientNotesPlaceholder => 'Notes facultatives';

  @override
  String get clientErrNoLetters =>
      'Doit contenir au moins une lettre ou un chiffre';

  @override
  String get clientErrPhone =>
      'Le téléphone doit comporter 8 à 15 chiffres (ex. 0555 12 34 56)';

  @override
  String clientErrPhoneTaken(String name) {
    return 'Un client existe déjà avec ce téléphone ($name)';
  }

  @override
  String get clientAdded => 'Client ajouté';

  @override
  String get clientUpdated => 'Client mis à jour';

  @override
  String get clientDeleted => 'Client supprimé';

  @override
  String get clientDeleteTitle => 'Supprimer le client';

  @override
  String clientDeleteBody(String name) {
    return 'Voulez-vous vraiment supprimer $name ?';
  }

  @override
  String clientDeleteNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ce client a $count commandes liées.',
      one: 'Ce client a 1 commande liée.',
    );
    return '$_temp0';
  }

  @override
  String get clientDetailEyebrow => 'DÉTAILS DU CLIENT';

  @override
  String get clientDetailTotalOrders => 'Total commandes';

  @override
  String get clientDetailLastOrder => 'Dernière commande';

  @override
  String get clientDetailMetrics => 'Métriques des conversations IA';

  @override
  String get clientDetailConversations => 'Conversations';

  @override
  String get clientDetailMessages => 'Messages';

  @override
  String get clientDetailAiResponses => 'Réponses IA';

  @override
  String get clientDetailClientMessages => 'Messages du client';

  @override
  String get clientDetailLastMessage => 'Dernier message';

  @override
  String get clientDetailHistory => 'Historique des conversations';

  @override
  String get clientDetailMsgs => 'MSGS';

  @override
  String get clientDetailFromAi => 'IA :';

  @override
  String get clientDetailFromClient => 'Client :';

  @override
  String get clientViewOrders => 'Voir les commandes';

  @override
  String get clientOrdersSoon =>
      'Les commandes ne sont pas encore disponibles sur mobile';

  @override
  String get menuSuppliers => 'Fournisseurs';

  @override
  String get suppliersEyebrow => 'ACHATS';

  @override
  String get suppliersTitle => 'Fournisseurs';

  @override
  String suppliersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fournisseurs',
      one: '1 fournisseur',
      zero: '0 fournisseur',
    );
    return '$_temp0';
  }

  @override
  String get suppliersStatTotal => 'Total fournisseurs';

  @override
  String get suppliersStatWithPurchases => 'Avec achats';

  @override
  String get suppliersSearch => 'Rechercher des fournisseurs...';

  @override
  String get suppliersSection => 'Tous les fournisseurs';

  @override
  String suppliersPurchaseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count achats',
      one: '1 achat',
      zero: '0 achat',
    );
    return '$_temp0';
  }

  @override
  String get suppliersEmptyTitle => 'Aucun fournisseur';

  @override
  String get suppliersEmptyBody =>
      'Ajoutez des fournisseurs pour gérer vos achats';

  @override
  String get suppliersNoMatchBody =>
      'Aucun fournisseur ne correspond à la recherche ou aux filtres.';

  @override
  String get suppliersFilterPurchasesMin => 'Achats · min';

  @override
  String get suppliersFilterPurchasesMax => 'Achats · max';

  @override
  String get supplierActive => 'Actif';

  @override
  String get supplierInactive => 'Inactif';

  @override
  String get supplierAddTitle => 'Ajouter un fournisseur';

  @override
  String get supplierEditTitle => 'Modifier le fournisseur';

  @override
  String get supplierCreate => 'Ajouter le fournisseur';

  @override
  String get supplierUpdate => 'Mettre à jour le fournisseur';

  @override
  String get supplierNamePlaceholder => 'Nom du fournisseur';

  @override
  String get supplierAddressPlaceholder => 'Adresse du fournisseur';

  @override
  String get supplierErrNameTaken =>
      'Vous avez déjà un fournisseur avec ce nom';

  @override
  String get supplierAdded => 'Fournisseur ajouté';

  @override
  String get supplierUpdated => 'Fournisseur mis à jour';

  @override
  String get supplierDeleted => 'Fournisseur supprimé';

  @override
  String get supplierDeleteTitle => 'Supprimer le fournisseur';

  @override
  String supplierDeleteBody(String name) {
    return 'Voulez-vous vraiment supprimer $name ?';
  }

  @override
  String supplierDeleteNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ce fournisseur a $count achats liés.',
      one: 'Ce fournisseur a 1 achat lié.',
    );
    return '$_temp0';
  }

  @override
  String get supplierDetailEyebrow => 'DÉTAILS DU FOURNISSEUR';

  @override
  String get supplierDetailPurchases => 'Achats';

  @override
  String get supplierDetailMemberSince => 'Membre depuis';

  @override
  String get supplierViewPurchases => 'Voir les achats';

  @override
  String get supplierPurchasesSoon =>
      'Les achats ne sont pas encore disponibles sur mobile';

  @override
  String get supplierNotFound => 'Ce fournisseur n’existe plus.';

  @override
  String get ordersEyebrow => 'VENTES';

  @override
  String get ordersTitle => 'Commandes';

  @override
  String ordersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commandes',
      one: '1 commande',
    );
    return '$_temp0';
  }

  @override
  String get ordersStatTotal => 'Total commandes';

  @override
  String get ordersStatPending => 'En attente';

  @override
  String get ordersStatDelivered => 'Livrées';

  @override
  String get ordersStatValue => 'Valeur totale';

  @override
  String get ordersSearch =>
      'Rechercher par # commande, client, téléphone, produit...';

  @override
  String get ordersSection => 'Toutes les commandes';

  @override
  String get ordersSelectAll => 'Tout sélectionner';

  @override
  String get ordersNew => 'Nouvelle commande';

  @override
  String get ordersEmptyTitle => 'Aucune commande';

  @override
  String get ordersEmptyBody =>
      'Les commandes arrivent des confirmations du chatbot IA, ou créez-en une à la main.';

  @override
  String get ordersNoMatchBody =>
      'Aucune commande ne correspond à votre recherche ou à vos filtres.';

  @override
  String get orderStatusAll => 'Tous';

  @override
  String get orderStatusPending => 'Nouveau';

  @override
  String get orderStatusConfirmed => 'Confirmée';

  @override
  String get orderStatusPreparing => 'En préparation';

  @override
  String get orderStatusShipped => 'Expédiée';

  @override
  String get orderStatusDelivered => 'Livrée';

  @override
  String get orderStatusCancelled => 'Annulée';

  @override
  String get orderStatusReturned => 'Retournée';

  @override
  String get orderConfirmNotCalled => 'Non appelé';

  @override
  String get orderConfirmNoAnswer => 'Sans réponse';

  @override
  String get orderConfirmConfirmed => 'Confirmé';

  @override
  String get orderConfirmRejected => 'Rejeté';

  @override
  String orderConfirmWithCount(String label, int count) {
    return '$label ($count)';
  }

  @override
  String get orderSourceAi => 'IA';

  @override
  String get orderSourceAiLong => 'Chatbot IA';

  @override
  String get orderSourceManual => 'Manuel';

  @override
  String get paymentStatusPaid => 'Payé';

  @override
  String get paymentStatusPending => 'En attente';

  @override
  String get paymentStatusPartial => 'Partiel';

  @override
  String ordersRowItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
    );
    return '$_temp0';
  }

  @override
  String ordersRowMeta(String items, String paid, String remaining) {
    return '$items  ·  PAYÉ $paid  ·  RESTANT $remaining';
  }

  @override
  String get ordersRowNoRemaining => '–';

  @override
  String get orderActionCallConfirm => 'Appeler et confirmer';

  @override
  String get orderActionRetry => 'Réessayer';

  @override
  String get orderActionPrepare => 'Préparer';

  @override
  String get orderActionMarkShipped => 'Marquer expédiée';

  @override
  String get orderActionMarkDelivered => 'Marquer livrée';

  @override
  String get orderActionOpen => 'Ouvrir';

  @override
  String get orderActionMarkReturned => 'Marquer comme retournée';

  @override
  String get orderActionDelete => 'Supprimer la commande';

  @override
  String ordersSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commandes sélectionnées',
      one: '1 commande sélectionnée',
    );
    return '$_temp0';
  }

  @override
  String get ordersClearSelection => 'Effacer';

  @override
  String get ordersBulkConfirm => 'Tout confirmer';

  @override
  String get ordersBulkPrepare => 'Tout préparer';

  @override
  String get ordersBulkShip => 'Tout expédier';

  @override
  String get ordersBulkDeliver => 'Tout marquer livrées';

  @override
  String get ordersBulkReturn => 'Tout marquer retournées';

  @override
  String get ordersBulkCancel => 'Tout annuler';

  @override
  String get ordersBulkNone => 'Aucune action groupée pour cette sélection';

  @override
  String ordersBulkFailed(int failed, int total) {
    return '$failed commande(s) sur $total n’ont pas pu être mises à jour';
  }

  @override
  String get ordersFilters => 'Filtres';

  @override
  String ordersFiltersActive(int count) {
    return 'Filtres · $count';
  }

  @override
  String get ordersFilterStatus => 'Statut de la commande';

  @override
  String get ordersFilterStatusAll => 'Tous les statuts';

  @override
  String get ordersFilterConfirmation => 'Confirmation';

  @override
  String get ordersFilterPayment => 'Statut du paiement';

  @override
  String get ordersFilterAny => 'Tous';

  @override
  String get ordersFilterHasRemaining => 'Solde restant à payer';

  @override
  String get ordersFilterPaymentDisabled =>
      'Désactivé — « Solde restant » est actif';

  @override
  String get ordersFilterTotalMin => 'Montant total (DA) · min';

  @override
  String get ordersFilterTotalMax => 'Montant total (DA) · max';

  @override
  String get ordersFilterApply => 'Appliquer les filtres';

  @override
  String get ordersFilterClear => 'Tout effacer';

  @override
  String get orderEyebrow => 'Commande';

  @override
  String get orderStepReview => 'Vérification';

  @override
  String get orderStepCall => 'Appel';

  @override
  String get orderStepResult => 'Résultat';

  @override
  String orderCallsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appels',
      one: '1 appel',
      zero: 'aucun appel',
    );
    return '$_temp0';
  }

  @override
  String get orderClientSection => 'Client';

  @override
  String get orderEditContact => 'Modifier';

  @override
  String get orderEditContactDone => 'Terminé';

  @override
  String get orderFieldName => 'Nom';

  @override
  String get orderFieldPhone => 'Téléphone';

  @override
  String get orderFieldAddress => 'Adresse';

  @override
  String get orderFieldRegion => 'Région';

  @override
  String get orderNoPhone => 'sans téléphone';

  @override
  String get orderNoAddress => 'sans adresse';

  @override
  String get orderPhoneHint => '0555 12 34 56';

  @override
  String get orderAddressHint => 'Wilaya, commune, rue, bâtiment...';

  @override
  String get orderContactSavedWithCall =>
      'Les modifications sont enregistrées avec le résultat de l’appel.';

  @override
  String get orderStopdeskChip => 'Stopdesk (retrait en agence)';

  @override
  String get orderItemsSection => 'Articles';

  @override
  String orderUnitLine(int qty, String price) {
    return '×$qty · $price / unité';
  }

  @override
  String get orderTotalLabel => 'Total';

  @override
  String get orderPaidLabel => 'Payé';

  @override
  String get orderRemainingLabel => 'Restant';

  @override
  String get orderNotesSection => 'Notes';

  @override
  String get orderAttemptsSection => 'Tentatives précédentes';

  @override
  String get orderCallHistorySection => 'Historique des appels';

  @override
  String get orderLogCall => 'Enregistrer le résultat de l’appel';

  @override
  String get orderAlreadyConfirmed => 'Déjà confirmée';

  @override
  String get orderClose => 'Fermer';

  @override
  String orderReadOnlyNotice(String status) {
    return 'Cette commande est $status — l’enregistrement des appels est désactivé.';
  }

  @override
  String get orderReadOnlyResell =>
      'Créez une nouvelle commande pour revendre.';

  @override
  String get orderCallQuestion => 'Comment s’est passé l’appel ?';

  @override
  String get orderCallSubtitle =>
      'Nous enregistrons la tentative et mettons la commande à jour en conséquence.';

  @override
  String get orderOutcomeConfirmed => 'Confirmée';

  @override
  String get orderOutcomeConfirmedHint =>
      'Le client veut la commande — elle passe prête à expédier.';

  @override
  String get orderOutcomeNoAnswer => 'Sans réponse';

  @override
  String get orderOutcomeNoAnswerHint =>
      'Tentative enregistrée — reste dans la file en attente.';

  @override
  String get orderOutcomeBusy => 'Occupé';

  @override
  String get orderOutcomeBusyHint =>
      'Réessayez plus tard — reste dans la file en attente.';

  @override
  String get orderOutcomeVoicemail => 'Messagerie';

  @override
  String get orderOutcomeVoicemailHint =>
      'Tentative enregistrée — reste dans la file en attente.';

  @override
  String get orderOutcomeRejected => 'Rejetée';

  @override
  String get orderOutcomeRejectedHint =>
      'Le client n’en veut pas — la commande sera annulée.';

  @override
  String get orderCallNotesLabel => 'Notes (facultatif, pour vos dossiers)';

  @override
  String get orderCallNotesHintConfirmed =>
      'Heure de livraison confirmée, instructions, paiement…';

  @override
  String get orderCallNotesHintRejected => 'Pourquoi le client a-t-il refusé ?';

  @override
  String get orderCallNotesHintOther => 'Que s’est-il passé ?';

  @override
  String get orderSaveOutcome => 'Enregistrer le résultat';

  @override
  String get orderBackToReview => 'Retour';

  @override
  String get orderNoAddressWarning =>
      'Cette commande n’a pas encore d’adresse de livraison.';

  @override
  String get orderNoAddressBody =>
      'Revenez à « Vérification » et modifiez la fiche client avant de confirmer.';

  @override
  String get orderResultConfirmedTitle => 'Commande confirmée';

  @override
  String get orderResultConfirmedBody =>
      'Prête à être envoyée à votre transporteur.';

  @override
  String get orderResultCancelledTitle => 'Commande annulée';

  @override
  String get orderResultCancelledBody =>
      'Le stock est restauré. Le paiement enregistré est annulé — un remboursement éventuel reste à faire à la main.';

  @override
  String get orderResultAttemptTitle => 'Tentative enregistrée';

  @override
  String orderResultAttemptBody(int count) {
    return 'Tentative n° $count enregistrée. Reste dans votre file en attente.';
  }

  @override
  String get orderNextSection => 'Suite : préparer et expédier';

  @override
  String get orderNextBody =>
      'Envoyez cette commande à votre transporteur, ou marquez-la en préparation pendant que vous l’emballez.';

  @override
  String get orderSendToDelivery => 'Envoyer en livraison';

  @override
  String get orderSendToDeliverySoon => 'Yalidine / ZR — bientôt';

  @override
  String get orderMarkPreparing => 'Marquer en préparation';

  @override
  String get orderDone => 'Terminé';

  @override
  String get orderReturnTitle => 'Marquer comme retournée';

  @override
  String orderReturnBody(String number) {
    return 'Voulez-vous vraiment marquer la commande $number comme retournée ? Le stock sera restauré et le paiement annulé.';
  }

  @override
  String get orderReturnNoticeTitle => 'Le remboursement n’est pas automatique';

  @override
  String get orderReturnNoticeBody =>
      'L’argent déjà encaissé doit être rendu au client et saisi en dépense dans la caisse.';

  @override
  String get orderDeleteTitle => 'Supprimer la commande';

  @override
  String orderDeleteBody(String number) {
    return 'Voulez-vous vraiment supprimer la commande $number ? Le stock sera restauré.';
  }

  @override
  String get orderDeleteNoticeBody =>
      'La commande, ses lignes et son historique d’appels sont effacés pour de bon.';

  @override
  String get newOrderTitle => 'Nouvelle commande';

  @override
  String get newOrderClientSection => 'Client';

  @override
  String get newOrderSearchClient => 'Rechercher un client';

  @override
  String get newOrderSearchClientHint =>
      'Rechercher un client par nom ou téléphone...';

  @override
  String get newOrderNoClients => 'Aucun client trouvé';

  @override
  String get newOrderOrType => 'Ou bien saisir';

  @override
  String get newOrderClientName => 'Nom du client';

  @override
  String get newOrderClientPhone => 'Téléphone';

  @override
  String get newOrderDeliveryAddress => 'Adresse de livraison';

  @override
  String get newOrderWilaya => 'Wilaya';

  @override
  String get newOrderWilayaHint => 'Choisir une wilaya…';

  @override
  String get newOrderCommune => 'Commune';

  @override
  String get newOrderCommuneHint => 'Commune (facultatif)';

  @override
  String get newOrderStopdesk => 'Stopdesk (retrait en agence — moins cher)';

  @override
  String get newOrderProductsSection => 'Produits';

  @override
  String get newOrderAddProducts => 'Ajouter des produits';

  @override
  String get newOrderProductHint => 'Rechercher un produit par nom ou SKU…';

  @override
  String get newOrderNoProducts => 'Aucun produit trouvé';

  @override
  String newOrderVariantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count variantes',
      one: '1 variante',
    );
    return '$_temp0';
  }

  @override
  String newOrderInStock(int count) {
    return '$count en stock';
  }

  @override
  String get newOrderOutOfStock => 'Rupture';

  @override
  String get newOrderQty => 'Qté';

  @override
  String get newOrderUnitPrice => 'Prix (DA)';

  @override
  String get newOrderLineTotal => 'Total';

  @override
  String get newOrderNoLines =>
      'Recherchez et sélectionnez des produits ci-dessus pour les ajouter';

  @override
  String get newOrderNotesSection => 'Remarque / Notes';

  @override
  String get newOrderNotes => 'Notes';

  @override
  String get newOrderNotesHint => 'Ajouter une note pour cette commande…';

  @override
  String get newOrderSummary => 'Récapitulatif';

  @override
  String get newOrderSubtotal => 'Sous-total';

  @override
  String get newOrderDelivery => 'Livraison';

  @override
  String get newOrderTotal => 'Total';

  @override
  String get newOrderPayInFull => 'Payé en totalité';

  @override
  String get newOrderAmountPaid => 'Montant payé (DA)';

  @override
  String get newOrderCodHint =>
      'Laissez 0 pour le paiement à la livraison — il est enregistré automatiquement à la livraison.';

  @override
  String get newOrderRemainingDebt => 'Restant (dette)';

  @override
  String get newOrderFullyPaid => 'Payé en totalité';

  @override
  String get newOrderPayment => 'Paiement';

  @override
  String get newOrderStatus => 'Statut de la commande';

  @override
  String get newOrderPaymentMethod => 'Mode de paiement';

  @override
  String get paymentMethodCash => 'Espèces';

  @override
  String get paymentMethodCard => 'Carte';

  @override
  String get paymentMethodTransfer => 'Virement';

  @override
  String get paymentMethodCcp => 'CCP';

  @override
  String get newOrderSubmit => 'Créer la commande';

  @override
  String get newOrderStockReserved =>
      'Le stock est réservé dès la création, même pour une commande en attente.';

  @override
  String get newOrderErrNoItems => 'Ajoutez au moins un produit';

  @override
  String get newOrderErrName => 'Le nom du client est obligatoire';

  @override
  String get newOrderErrPhone =>
      'Un numéro de téléphone est obligatoire pour contacter le client';

  @override
  String get newOrderErrWilaya => 'La wilaya de livraison est obligatoire';

  @override
  String get newOrderErrAddress =>
      'L’adresse est obligatoire pour une livraison à domicile (ou cochez Stopdesk)';

  @override
  String newOrderErrStock(String name, int count) {
    return '$name — il ne reste que $count en stock';
  }

  @override
  String get orderCreatedToast => 'Commande créée';

  @override
  String get orderCallLoggedToast => 'Résultat de l’appel enregistré';

  @override
  String get orderStatusChangedToast => 'Commande mise à jour';

  @override
  String get orderReturnedToast => 'Commande marquée comme retournée';

  @override
  String get orderDeletedToast => 'Commande supprimée';

  @override
  String newOrderDraftLinesDropped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count lignes de votre brouillon n’ont pas pu être rétablies : les produits n’existent plus ou sont en rupture.',
      one: '1 ligne de votre brouillon n’a pas pu être rétablie : le produit n’existe plus ou est en rupture.',
    );
    return '$_temp0';
  }

  @override
  String get productsFilterPriceMin => 'Prix de vente (DA) · min';

  @override
  String get productsFilterPriceMax => 'Prix de vente (DA) · max';

  @override
  String get productsFilterCostMin => 'Prix de revient (DA) · min';

  @override
  String get productsFilterCostMax => 'Prix de revient (DA) · max';

  @override
  String get productsFilterQtyMin => 'Quantité · min';

  @override
  String get productsFilterQtyMax => 'Quantité · max';

  @override
  String get productsFilterProfitMin => 'Bénéfice net (DA) · min';

  @override
  String get productsFilterProfitMax => 'Bénéfice net (DA) · max';

  @override
  String get productsFilterMarginMin => 'Marge (%) · min';

  @override
  String get productsFilterMarginMax => 'Marge (%) · max';

  @override
  String get productsSectionInactive => 'PRODUITS INACTIFS';

  @override
  String get menuDelivery => 'Livraison';

  @override
  String get deliveryEyebrow => 'VENTES';

  @override
  String get deliveryTitle => 'Livraison';

  @override
  String get deliverySubtitle =>
      'Envoyez les commandes aux transporteurs et suivez les expéditions';

  @override
  String get deliveryFeesAction => 'Tarifs';

  @override
  String get deliveryProvidersAction => 'Transporteurs';

  @override
  String get deliveryRefresh => 'Actualiser';

  @override
  String get deliveryStatReady => 'PRÊT À EXPÉDIER';

  @override
  String get deliveryStatShipped => 'EXPÉDIÉES';

  @override
  String get deliveryStatInTransit => 'EN TRANSIT';

  @override
  String get deliveryStatDelivered => 'LIVRÉES';

  @override
  String get deliverySearchLabel => 'RECHERCHE';

  @override
  String get deliverySearchPlaceholder => 'Rechercher des commandes...';

  @override
  String get deliveryTabAll => 'Tous';

  @override
  String get deliveryTabReady => 'Prêt';

  @override
  String get deliveryTabSent => 'Envoyée';

  @override
  String get deliveryTabInTransit => 'En transit';

  @override
  String get deliveryTabDelivered => 'Livrée';

  @override
  String get deliveryOrdersSection => 'COMMANDES';

  @override
  String get deliveryPillNotSent => 'NON ENVOYÉE';

  @override
  String get deliveryPillSent => 'ENVOYÉE';

  @override
  String get deliveryPillInTransit => 'EN TRANSIT';

  @override
  String get deliveryPillDelivered => 'LIVRÉE';

  @override
  String deliveryMetaLine(String provider, String tracking) {
    return 'TRANSPORTEUR $provider  ·  SUIVI $tracking';
  }

  @override
  String get deliverySend => 'Envoyer';

  @override
  String get deliveryTrack => 'Suivre';

  @override
  String get deliveryLabel => 'Étiquette';

  @override
  String get deliveryEmptyTitle => 'Aucune commande';

  @override
  String get deliveryEmptyBody =>
      'Les commandes apparaissent ici, prêtes à être envoyées à un transporteur.';

  @override
  String get deliveryNoMatchTitle => 'Aucun résultat';

  @override
  String get deliveryNoMatchBody => 'Essayez un autre mot ou un autre onglet.';

  @override
  String deliverySendTitle(String order) {
    return 'Envoyer $order en livraison';
  }

  @override
  String get deliveryClient => 'Client';

  @override
  String get deliveryPhone => 'Téléphone';

  @override
  String get deliveryAddress => 'Adresse';

  @override
  String get deliveryTotal => 'Total';

  @override
  String get deliveryProviderLabel => 'TRANSPORTEUR';

  @override
  String deliveryProviderDefault(String name) {
    return '$name (par défaut)';
  }

  @override
  String get deliveryDestination => 'WILAYA DE DESTINATION';

  @override
  String get deliveryChooseWilaya => 'Choisir une wilaya';

  @override
  String get deliveryStopdesk => 'Livraison en stop desk';

  @override
  String get deliveryNote => 'NOTE';

  @override
  String get deliveryNotePlaceholder =>
      'Note facultative pour la société de livraison...';

  @override
  String get deliveryRates => 'TARIFS ESTIMÉS';

  @override
  String get deliveryRateHome => 'Livraison à domicile';

  @override
  String get deliveryRateStopdesk => 'Stop desk';

  @override
  String get deliveryConfirmSend => 'Confirmer et envoyer';

  @override
  String get deliveryNoProviders => 'Aucun transporteur de livraison configuré';

  @override
  String get deliveryAddProvider => 'Ajouter un transporteur';

  @override
  String deliverySentToast(String order, String provider) {
    return '$order envoyée à $provider';
  }

  @override
  String deliveryTrackTitle(String order) {
    return 'Suivi — $order';
  }

  @override
  String deliveryCourierResponse(String provider) {
    return 'RÉPONSE DU TRANSPORTEUR · $provider';
  }

  @override
  String get deliveryTrackEmpty =>
      'Le transporteur n’a renvoyé aucune information.';

  @override
  String get deliveryLabelNotReady =>
      'Le transporteur n’a pas encore produit d’étiquette.';

  @override
  String get deliveryLabelOpenFailed =>
      'Impossible d’ouvrir l’étiquette sur ce téléphone.';

  @override
  String get deliveryFeesEyebrow => 'LIVRAISON';

  @override
  String get deliveryFeesTitle => 'Tarifs de livraison';

  @override
  String get deliveryFeesSubtitle =>
      'Fixez votre prix de livraison par wilaya. Utilisé automatiquement à la création des commandes et par l’agent IA pour les devis Messenger.';

  @override
  String get deliveryFeesFillMissing => 'Compléter les manquants';

  @override
  String get deliveryFeesResetAll => 'Tout réinitialiser';

  @override
  String get deliveryFeesSearch => 'Rechercher une wilaya…';

  @override
  String get deliveryFeesSection => 'WILAYAS';

  @override
  String get deliveryFeesDefault => 'PAR DÉFAUT';

  @override
  String get deliveryFeesCustom => 'PERSONNALISÉ';

  @override
  String get deliveryFeesHome => 'DOMICILE (DA)';

  @override
  String get deliveryFeesStopdesk => 'STOPDESK (DA)';

  @override
  String get deliveryFeesReturn => 'RETOUR (DA)';

  @override
  String get deliveryFeesReset => 'Réinitialiser';

  @override
  String get deliveryFeesResetAllTitle => 'Tout réinitialiser par défaut';

  @override
  String get deliveryFeesResetAllBody =>
      'Remplacer tous vos prix personnalisés par les valeurs par défaut du système ?';

  @override
  String deliveryFeesSaved(String wilaya) {
    return 'Tarifs de $wilaya enregistrés';
  }

  @override
  String deliveryFeesResetDone(String wilaya) {
    return '$wilaya revient aux tarifs par défaut';
  }

  @override
  String deliveryFeesFilled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wilayas complétées',
      one: '1 wilaya complétée',
      zero: 'Rien à compléter : chaque wilaya a déjà ses tarifs',
    );
    return '$_temp0';
  }

  @override
  String get deliveryFeesResetAllDone =>
      'Tous les tarifs sont revenus aux valeurs par défaut';

  @override
  String get deliveryProvidersTitle => 'Transporteurs de livraison';

  @override
  String get deliveryProvidersSubtitle =>
      'Configurez les sociétés de livraison pour expédier les commandes';

  @override
  String get deliveryProvidersSection => 'TRANSPORTEURS';

  @override
  String get deliveryDefaultBadge => 'PAR DÉFAUT';

  @override
  String get deliveryCardProvider => 'Transporteur :';

  @override
  String get deliveryCardSender => 'Expéditeur :';

  @override
  String get deliveryCardPhone => 'Téléphone :';

  @override
  String get deliveryCardWilaya => 'Wilaya :';

  @override
  String get deliveryEdit => 'Modifier';

  @override
  String get deliveryProvidersEmptyTitle => 'Aucun transporteur configuré';

  @override
  String get deliveryProvidersEmptyBody =>
      'Ajoutez un transporteur pour commencer à expédier des commandes';

  @override
  String get deliveryDeleteTitle => 'Supprimer le transporteur';

  @override
  String get deliveryDeleteBody =>
      'Voulez-vous vraiment retirer ce transporteur de livraison ? Cette action est irréversible.';

  @override
  String deliveryProviderDeleted(String name) {
    return '$name supprimé';
  }

  @override
  String get deliveryFormAddTitle => 'Ajouter un transporteur';

  @override
  String get deliveryFormEditTitle => 'Modifier le transporteur';

  @override
  String get deliveryFormCourier => 'TRANSPORTEUR';

  @override
  String get deliveryFormChooseCourier => 'Choisir un transporteur';

  @override
  String get deliveryFormDisplayName => 'NOM D’AFFICHAGE';

  @override
  String get deliveryFormCredentials => 'IDENTIFIANTS API';

  @override
  String get deliveryFormUnchanged => '(inchangé — saisir pour modifier)';

  @override
  String get deliveryFormTest => 'Tester les identifiants';

  @override
  String deliveryFormTestOk(String name) {
    return 'Identifiants valides — connexion à $name réussie.';
  }

  @override
  String deliveryFormTestFailed(String name, String reason) {
    return 'Connexion à $name refusée : $reason';
  }

  @override
  String get deliveryFormSender => 'INFORMATIONS DE L’EXPÉDITEUR';

  @override
  String get deliveryFormSenderName => 'NOM DE L’EXPÉDITEUR';

  @override
  String get deliveryFormSenderPhone => 'TÉLÉPHONE';

  @override
  String get deliveryFormSenderAddress => 'ADRESSE DE L’EXPÉDITEUR';

  @override
  String get deliveryFormSenderWilaya => 'WILAYA DE L’EXPÉDITEUR';

  @override
  String get deliveryFormSetDefault => 'Définir comme transporteur par défaut';

  @override
  String get deliveryFormAdd => 'Ajouter le transporteur';

  @override
  String get deliveryFormUpdate => 'Mettre à jour';

  @override
  String deliveryProviderAdded(String name) {
    return '$name ajouté';
  }

  @override
  String deliveryProviderUpdated(String name) {
    return '$name mis à jour';
  }

  @override
  String get deliveryFormAllTaken =>
      'Chaque transporteur pris en charge est déjà configuré.';

  @override
  String get deliveryDeleteNoticeTitle => 'Commandes déjà envoyées';

  @override
  String deliveryDeleteNoticeBody(String name) {
    return 'Celles envoyées avec $name garderont leur numéro de suivi, mais ne pourront plus être suivies ni leur étiquette imprimée.';
  }

  @override
  String get deliveryDeleteNoticeDefault =>
      'C’est votre transporteur par défaut : choisissez-en un autre ensuite.';

  @override
  String deliveryProviderAlreadyGone(String name) {
    return '$name avait déjà été supprimé';
  }

  @override
  String get menuSales => 'Ventes';

  @override
  String get salesEyebrow => 'VENTES';

  @override
  String get salesTitle => 'Ventes';

  @override
  String salesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ventes',
      one: '1 vente',
      zero: '0 vente',
    );
    return '$_temp0';
  }

  @override
  String get salesPeriodToday => 'Aujourd’hui';

  @override
  String get salesPeriodWeek => 'Semaine';

  @override
  String get salesPeriodMonth => 'Mois';

  @override
  String get salesPeriodYear => 'Année';

  @override
  String get salesStatTotal => 'Total ventes';

  @override
  String get salesStatRevenue => 'Chiffre d’affaires';

  @override
  String get salesStatAverage => 'Valeur moyenne';

  @override
  String get salesStatPending => 'En attente';

  @override
  String get salesSearch => 'Rechercher des ventes…';

  @override
  String get salesQuickAll => 'Tous';

  @override
  String get salesQuickPaid => 'Payées';

  @override
  String get salesQuickRemaining => 'Restant à payer';

  @override
  String get salesSection => 'Toutes les ventes';

  @override
  String get salesView => 'Voir';

  @override
  String get salesNew => 'Nouvelle vente';

  @override
  String get salesEmptyTitle => 'Aucune vente';

  @override
  String get salesEmptyBody =>
      'Enregistrez votre première vente pour suivre votre chiffre d’affaires';

  @override
  String get salesNoMatchBody => 'Aucune vente ne correspond à ces critères.';

  @override
  String get salesFilterMethodAny => 'Tous les modes';

  @override
  String get saleStatusPaid => 'Payée';

  @override
  String get saleStatusPending => 'En attente';

  @override
  String get saleStatusPartial => 'Partielle';

  @override
  String get saleDeleteTitle => 'Supprimer la vente';

  @override
  String saleDeleteBody(String number) {
    return 'Voulez-vous vraiment supprimer la vente $number ?';
  }

  @override
  String get saleDeleteNotice =>
      'Cette action est irréversible. Les quantités en stock seront restaurées.';

  @override
  String saleDeletedToast(String number) {
    return 'Vente $number supprimée';
  }

  @override
  String saleAlreadyGone(String number) {
    return 'La vente $number avait déjà été supprimée';
  }

  @override
  String get saleEyebrow => 'VENTE';

  @override
  String get saleFieldCustomer => 'Client';

  @override
  String get saleFieldPhone => 'Téléphone';

  @override
  String get saleFieldDate => 'Date';

  @override
  String get saleFieldMethod => 'Mode de paiement';

  @override
  String get saleFieldItems => 'Articles';

  @override
  String get saleWalkIn => 'Client de passage';

  @override
  String get saleItemsSection => 'Articles';

  @override
  String saleLineMeta(int qty, String price) {
    return '×$qty  ·  $price';
  }

  @override
  String saleLineDiscount(String amount) {
    return 'Remise $amount';
  }

  @override
  String get saleSubtotal => 'Sous-total';

  @override
  String get saleDiscount => 'Remise';

  @override
  String get saleTax => 'Taxe';

  @override
  String get saleTotal => 'Total';

  @override
  String get salePaymentStatus => 'Statut du paiement';

  @override
  String get saleMarkPaid => 'Marquer comme payée';

  @override
  String get saleEdit => 'Modifier';

  @override
  String get saleMarkedPaidToast => 'Vente marquée comme payée';

  @override
  String saleEditTitle(String number) {
    return 'Modifier la vente $number';
  }

  @override
  String get saleEditSubtitle =>
      'Modifiez le paiement et les notes. Les articles et les prix ne peuvent plus être changés une fois la vente enregistrée.';

  @override
  String get saleMethodHint => 'Choisir un mode';

  @override
  String get saleEditPartialMissing => 'Saisissez le montant reçu';

  @override
  String saleEditPartialTooHigh(String total) {
    return 'Doit être inférieur au total ($total) — sinon choisissez « Payée »';
  }

  @override
  String saleEditCaisse(String from, String to) {
    return 'La caisse passera de $from à $to.';
  }

  @override
  String get saleEditSave => 'Enregistrer les modifications';

  @override
  String get saleUpdatedToast => 'Vente mise à jour';

  @override
  String get saleEditLeaveBody => 'Vos modifications seront perdues.';

  @override
  String get newSaleNotesHint => 'Ajouter une note pour cette vente…';

  @override
  String get newSaleSummary => 'Résumé du paiement';

  @override
  String get newSaleFullyPaid => 'Entièrement payée';

  @override
  String get newSaleStatus => 'Statut';

  @override
  String get newSalePayInFull => 'Payée en totalité';

  @override
  String newSaleChangeDue(String amount) {
    return 'Monnaie à rendre : $amount';
  }

  @override
  String get newSaleSubmit => 'Finaliser la vente';

  @override
  String get newSaleStockNote =>
      'Le stock est déduit dès l’enregistrement de la vente.';

  @override
  String get newSaleErrPhone => 'Numéro de téléphone incomplet';

  @override
  String newSaleCreatedToast(String number) {
    return 'Vente $number enregistrée';
  }

  @override
  String get newSaleDateTitle => 'Date de la vente';

  @override
  String get newSaleLeaveBody => 'La vente commencée sera perdue.';

  @override
  String get menuPurchases => 'Achats';

  @override
  String get menuMovements => 'Mouvements';

  @override
  String get purchasesEyebrow => 'ACHATS';

  @override
  String get purchasesTitle => 'Achats';

  @override
  String purchasesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count achats',
      one: '1 achat',
      zero: '0 achat',
    );
    return '$_temp0';
  }

  @override
  String get purchasesStatTotal => 'Total achats';

  @override
  String get purchasesStatSpent => 'Total dépensé';

  @override
  String get purchasesStatToReceive => 'À recevoir';

  @override
  String get purchasesStatReceived => 'Reçus';

  @override
  String get purchasesSearch => 'Rechercher des achats…';

  @override
  String get purchasesQuickAll => 'Tous';

  @override
  String get purchasesQuickPaid => 'Payés';

  @override
  String get purchasesQuickToPay => 'À payer';

  @override
  String get purchasesSection => 'Tous les achats';

  @override
  String purchasesRowMeta(String items, String paid, String remaining) {
    return '$items  ·  PAYÉ $paid  ·  RESTE À PAYER $remaining';
  }

  @override
  String get purchasesReceive => 'Réceptionner';

  @override
  String get purchasesNew => 'Nouvel achat';

  @override
  String get purchasesEmptyTitle => 'Aucun achat';

  @override
  String get purchasesEmptyBody =>
      'Enregistrez votre premier achat auprès d’un fournisseur';

  @override
  String get purchasesNoMatchBody =>
      'Aucun achat ne correspond à ces critères.';

  @override
  String get purchasesFilterStatus => 'Statut de réception';

  @override
  String get purchasesFilterSupplierAny => 'Tous les fournisseurs';

  @override
  String get purchasesFilterHasRemaining => 'Reste à payer au fournisseur';

  @override
  String get purchaseStatusPending => 'À recevoir';

  @override
  String get purchaseStatusPartial => 'Reçu en partie';

  @override
  String get purchaseStatusReceived => 'Reçu';

  @override
  String get purchaseStatusCancelled => 'Annulé';

  @override
  String get purchasePayPending => 'Non payé';

  @override
  String get purchasePayPartial => 'Payé en partie';

  @override
  String get purchasePayPaid => 'Payé';

  @override
  String get purchaseDeleteTitle => 'Supprimer l’achat';

  @override
  String purchaseDeleteBody(String number) {
    return 'Voulez-vous vraiment supprimer l’achat $number ?';
  }

  @override
  String get purchaseDeleteNotice => 'Cette action est irréversible.';

  @override
  String purchaseDeletedToast(String number) {
    return 'Achat $number supprimé';
  }

  @override
  String purchaseAlreadyGone(String number) {
    return 'L’achat $number avait déjà été supprimé';
  }

  @override
  String get purchaseEyebrow => 'ACHAT';

  @override
  String get purchaseFieldSupplier => 'Fournisseur';

  @override
  String get purchaseFieldReceiving => 'Réception';

  @override
  String get purchaseFieldPayment => 'Paiement';

  @override
  String get purchaseFieldPaid => 'Montant payé';

  @override
  String get purchaseFieldRemaining => 'Reste à payer';

  @override
  String get purchaseFieldReceivedOn => 'Reçu le';

  @override
  String get purchaseNoSupplier => 'Sans fournisseur';

  @override
  String purchaseLineMeta(int ordered, int received, String cost) {
    return 'Commandé $ordered  ·  Reçu $received  ·  Coût $cost / unité';
  }

  @override
  String get purchaseMarkPaid => 'Marquer comme payé';

  @override
  String get purchaseMarkedPaidToast => 'Achat marqué comme payé';

  @override
  String get purchaseReceiveDelivery => 'Réceptionner la livraison';

  @override
  String get purchaseCancel => 'Annuler l’achat';

  @override
  String get purchaseCancelKeep => 'Garder l’achat';

  @override
  String purchaseCancelBody(String number) {
    return 'L’achat $number sera annulé.';
  }

  @override
  String get purchaseCancelNoticeTitle => 'Ce qui va se passer';

  @override
  String purchaseCancelStock(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unités déjà reçues seront retirées du stock.',
      one: '1 unité déjà reçue sera retirée du stock.',
    );
    return '$_temp0';
  }

  @override
  String purchaseCancelMoney(String amount) {
    return 'Le paiement de $amount sera retiré de la caisse. Enregistrez vous-même le remboursement du fournisseur.';
  }

  @override
  String get purchaseCancelFinal =>
      'Un achat annulé ne peut plus être réceptionné ni payé.';

  @override
  String purchaseCancelledToast(String number) {
    return 'Achat $number annulé';
  }

  @override
  String get receiveBody =>
      'Saisissez la quantité livrée par le fournisseur pour chaque article. Le stock sera mis à jour automatiquement.';

  @override
  String receiveLineMeta(int ordered, int received) {
    return 'Commandé $ordered  ·  Déjà reçu $received';
  }

  @override
  String get receiveNowLabel => 'Reçu maintenant';

  @override
  String receiveToCome(int count) {
    return '$count à recevoir';
  }

  @override
  String get receiveComplete => 'Complet';

  @override
  String receiveOver(int count) {
    return 'Au plus $count';
  }

  @override
  String get receiveSubmit => 'Valider la réception';

  @override
  String get receiveNothing => 'Saisissez au moins une quantité';

  @override
  String get receivedToast => 'Réception enregistrée · stock mis à jour';

  @override
  String get newPurchaseSearchSupplier => 'Rechercher un fournisseur';

  @override
  String get newPurchaseSearchSupplierHint =>
      'Rechercher un fournisseur par nom ou téléphone…';

  @override
  String get newPurchaseNoSuppliers => 'Aucun fournisseur trouvé';

  @override
  String get newPurchaseUnitCost => 'Coût unitaire (DA)';

  @override
  String get newPurchaseNotesHint => 'Ajouter une note pour cet achat…';

  @override
  String get newPurchaseSummary => 'Paiement au fournisseur';

  @override
  String get newPurchaseAmountPaid => 'Montant versé au fournisseur (DA)';

  @override
  String get newPurchaseFullyPaid => 'Entièrement payé';

  @override
  String get newPurchasePayInFull => 'Payer en totalité';

  @override
  String newPurchaseOverpaid(String total) {
    return 'Plus que le total : seul $total sera enregistré.';
  }

  @override
  String get newPurchaseStockNote =>
      'Le stock sera ajouté à la réception de la livraison.';

  @override
  String get newPurchaseSubmit => 'Enregistrer l’achat';

  @override
  String newPurchaseCreatedToast(String number) {
    return 'Achat $number enregistré';
  }

  @override
  String get newPurchaseDateTitle => 'Date de l’achat';

  @override
  String get newPurchaseLeaveBody => 'L’achat commencé sera perdu.';

  @override
  String get movementsEyebrow => 'STOCK';

  @override
  String get movementsTitle => 'Mouvements de stock';

  @override
  String get movementsSubtitle => 'Historique de tous les changements de stock';

  @override
  String get movementsSection => 'Mouvements';

  @override
  String get movementsEmptyTitle => 'Aucun mouvement';

  @override
  String get movementsEmptyBody =>
      'Les mouvements de stock apparaîtront ici quand des produits sont ajoutés, vendus ou ajustés';

  @override
  String get movementsNoMatchBody =>
      'Aucun mouvement ne correspond à ces critères.';

  @override
  String get movementsFilterType => 'Type de mouvement';

  @override
  String get movementsFilterTypeAny => 'Tous les types';

  @override
  String get movementsFilterProduct => 'Produit';

  @override
  String get movementsFilterProductAny => 'Tous les produits';

  @override
  String movementReasonSale(String number) {
    return 'Vente $number';
  }

  @override
  String movementReasonSaleDeleted(String number) {
    return 'Vente $number supprimée';
  }

  @override
  String movementReasonPurchase(String number) {
    return 'Réception d’achat $number';
  }

  @override
  String movementReasonPurchaseCancelled(String number) {
    return 'Achat $number annulé';
  }

  @override
  String movementReasonOrder(String number) {
    return 'Commande $number';
  }

  @override
  String movementReasonOrderCancelled(String number) {
    return 'Commande annulée $number';
  }

  @override
  String movementReasonOrderReturned(String number) {
    return 'Commande retournée $number';
  }

  @override
  String movementReasonOrderDeleted(String number) {
    return 'Commande supprimée $number';
  }

  @override
  String get movementReasonInitial => 'Stock initial';

  @override
  String get movementReasonVariantDeleted => 'Variante supprimée';

  @override
  String saleDeleteMoney(String amount) {
    return 'Les $amount déjà encaissés seront retirés de la caisse.';
  }

  @override
  String get menuCaisse => 'Caisse';

  @override
  String get caisseEyebrow => 'FINANCES';

  @override
  String get caisseTitle => 'Caisse';

  @override
  String get caisseSubtitle => 'Caisse et gestion de trésorerie';

  @override
  String get caissePeriodToday => 'Aujourd’hui';

  @override
  String get caissePeriodWeek => 'Cette semaine';

  @override
  String get caissePeriodMonth => 'Ce mois-ci';

  @override
  String get caissePeriodYear => 'Cette année';

  @override
  String get caisseStatBalance => 'Solde';

  @override
  String get caisseStatIncome => 'Total revenus';

  @override
  String get caisseStatExpense => 'Total dépenses';

  @override
  String get caisseStatCount => 'Transactions';

  @override
  String get caisseSearch => 'Rechercher une référence ou description…';

  @override
  String get caisseSection => 'Transactions';

  @override
  String get caisseEmptyTitle => 'Aucune transaction trouvée';

  @override
  String get caisseEmptyBody =>
      'Les ventes, commandes et achats payés s’inscrivent ici automatiquement. Ajoutez vos autres entrées et sorties d’argent.';

  @override
  String get caisseNoMatchBody =>
      'Aucune transaction ne correspond à ces critères.';

  @override
  String get caisseTypeIncome => 'Revenu';

  @override
  String get caisseTypeExpense => 'Dépense';

  @override
  String get caisseCatSale => 'Vente';

  @override
  String get caisseCatOrder => 'Commande';

  @override
  String get caisseCatPurchase => 'Achat';

  @override
  String get caisseCatRent => 'Loyer';

  @override
  String get caisseCatSalary => 'Salaire';

  @override
  String get caisseCatUtilities => 'Services';

  @override
  String get caisseCatMarketing => 'Marketing';

  @override
  String get caisseCatShipping => 'Livraison';

  @override
  String get caisseCatOther => 'Autre';

  @override
  String caisseRef(String reference) {
    return 'Réf. $reference';
  }

  @override
  String get caisseAuto => 'Auto';

  @override
  String get caisseManual => 'Manuel';

  @override
  String caisseAutoSale(String number) {
    return 'Vente $number';
  }

  @override
  String caisseAutoOrder(String number) {
    return 'Commande $number';
  }

  @override
  String caisseAutoPurchase(String number) {
    return 'Achat $number';
  }

  @override
  String get caisseFilterType => 'Type';

  @override
  String get caisseFilterCategory => 'Catégorie';

  @override
  String get caisseFilterCategoryAny => 'Toutes les catégories';

  @override
  String get caisseAddTitle => 'Ajouter une transaction';

  @override
  String get caisseEditTitle => 'Modifier la transaction';

  @override
  String get caisseFieldAmount => 'Montant (DA)';

  @override
  String get caisseFieldReference => 'Référence';

  @override
  String get caisseReferenceHint => 'ex. Facture n°123';

  @override
  String get caisseFieldDescription => 'Description';

  @override
  String get caisseDescriptionHint => 'Détails de cette transaction';

  @override
  String get caisseFieldDate => 'Date';

  @override
  String get caisseAdd => 'Ajouter';

  @override
  String get caisseUpdate => 'Mettre à jour';

  @override
  String get caisseErrAmount => 'Saisissez un montant';

  @override
  String get caisseErrAmountPositive => 'Le montant doit être supérieur à 0';

  @override
  String get caisseAddedToast => 'Transaction ajoutée';

  @override
  String get caisseUpdatedToast => 'Transaction mise à jour';

  @override
  String get caisseDeletedToast => 'Transaction supprimée';

  @override
  String get caisseAlreadyGone => 'Cette transaction avait déjà été supprimée';

  @override
  String get caisseDeleteTitle => 'Supprimer la transaction';

  @override
  String get caisseDeleteBody =>
      'Voulez-vous vraiment supprimer cette transaction ?';

  @override
  String get menuCrossSell => 'Ventes croisées';

  @override
  String get recoEyebrow => 'VENTES';

  @override
  String get recoTitle => 'Vente croisée / Montée en gamme';

  @override
  String get recoSubtitle =>
      'Recommandations de produits par IA pour booster les ventes';

  @override
  String get recoStatRules => 'Total des règles';

  @override
  String recoStatActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actives',
      one: '1 active',
      zero: '0 active',
    );
    return '$_temp0';
  }

  @override
  String get recoStatImpressions => 'Impressions';

  @override
  String get recoStatImpressionsNote => 'Fois affichées';

  @override
  String get recoStatConversions => 'Conversions';

  @override
  String recoStatRate(String rate) {
    return 'Taux $rate';
  }

  @override
  String get recoStatRevenue => 'Chiffre d’affaires';

  @override
  String get recoStatRevenueNote => 'Depuis la vente croisée';

  @override
  String get recoSearch => 'Rechercher des produits…';

  @override
  String get recoTypeAll => 'Tous les types';

  @override
  String get recoFilterCross => 'Vente croisée';

  @override
  String get recoFilterUp => 'Montée en gamme';

  @override
  String get recoTagCross => 'Vente croisée';

  @override
  String get recoTagUp => 'Montée en gamme';

  @override
  String get recoStatusAll => 'Toutes';

  @override
  String get recoStatusActive => 'Actives';

  @override
  String get recoStatusInactive => 'Inactives';

  @override
  String get recoSection => 'Recommandations';

  @override
  String recoShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recommandations affichées',
      one: '1 recommandation affichée',
    );
    return '$_temp0';
  }

  @override
  String get recoActive => 'Active';

  @override
  String recoImpressions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count impressions',
      one: '1 impression',
      zero: '0 impression',
    );
    return '$_temp0';
  }

  @override
  String recoConversions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conversions',
      one: '1 conversion',
      zero: '0 conversion',
    );
    return '$_temp0';
  }

  @override
  String get recoGenerate => 'Générer des recommandations';

  @override
  String get recoGenerateNow => 'Générer maintenant';

  @override
  String get recoAnalyzing => 'Analyse en cours…';

  @override
  String recoGeneratedToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recommandations mises à jour',
      one: '1 recommandation mise à jour',
      zero: 'Aucune nouvelle recommandation trouvée',
    );
    return '$_temp0';
  }

  @override
  String get recoEmptyTitle => 'Aucune recommandation pour le moment';

  @override
  String get recoEmptyBody =>
      'Touchez « Générer maintenant » pour analyser vos produits';

  @override
  String get recoNoMatchBody =>
      'Aucune recommandation ne correspond à ces critères.';

  @override
  String get recoDeleteAsk => 'Supprimer ?';

  @override
  String get recoYes => 'Oui';

  @override
  String get recoNo => 'Non';

  @override
  String get recoDeleteHint =>
      'Elle peut revenir à la prochaine génération — désactivez-la pour la masquer.';

  @override
  String get recoDeletedToast => 'Recommandation supprimée';

  @override
  String get recoAlreadyGone => 'Cette recommandation avait déjà été supprimée';

  @override
  String recoReasonBought(int count, String percent) {
    return 'Souvent achetés ensemble ($count fois, $percent des commandes)';
  }

  @override
  String recoReasonPremium(String percent) {
    return 'Alternative haut de gamme, même catégorie (+$percent de prix)';
  }

  @override
  String recoReasonSimilar(String percent) {
    return 'Description de produit similaire ($percent de correspondance)';
  }

  @override
  String recoReasonRelated(String percent) {
    return 'Produits liés ($percent de description commune)';
  }
}
