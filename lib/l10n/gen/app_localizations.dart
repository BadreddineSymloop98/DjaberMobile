import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
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
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'Djaber.ai'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In fr, this message translates to:
  /// **'Agent IA Social'**
  String get appTagline;

  /// No description provided for @commonBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get commonBack;

  /// No description provided for @commonDismiss.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get commonDismiss;

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get commonSave;

  /// No description provided for @commonRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get commonRetry;

  /// No description provided for @commonDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get commonDelete;

  /// No description provided for @commonConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get commonConfirm;

  /// No description provided for @commonSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get commonSearch;

  /// No description provided for @commonLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement…'**
  String get commonLoading;

  /// No description provided for @commonSeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout voir'**
  String get commonSeeAll;

  /// No description provided for @commonEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Rien ici'**
  String get commonEmpty;

  /// No description provided for @commonNext.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get commonNext;

  /// No description provided for @commonSkip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get commonSkip;

  /// No description provided for @commonStart.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get commonStart;

  /// No description provided for @onboardingAnswersTitle.
  ///
  /// In fr, this message translates to:
  /// **'L\'agent répond à vos clients'**
  String get onboardingAnswersTitle;

  /// No description provided for @onboardingAnswersBody.
  ///
  /// In fr, this message translates to:
  /// **'Il connaît votre catalogue, votre stock et vos prix. Il répond aux messages Facebook et Instagram à votre place, jour et nuit.'**
  String get onboardingAnswersBody;

  /// No description provided for @onboardingEscalationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vous intervenez quand il le faut'**
  String get onboardingEscalationTitle;

  /// No description provided for @onboardingEscalationBody.
  ///
  /// In fr, this message translates to:
  /// **'Quand l’IA ne peut plus suivre, elle s’arrête et vous prévient. Vous répondez depuis le téléphone, puis vous lui rendez la conversation.'**
  String get onboardingEscalationBody;

  /// No description provided for @onboardingStockTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre stock dans la poche'**
  String get onboardingStockTitle;

  /// No description provided for @onboardingStockBody.
  ///
  /// In fr, this message translates to:
  /// **'Produits, achats, ventes et commandes. Vérifiez une quantité pendant que le client attend, corrigez-la sur place.'**
  String get onboardingStockBody;

  /// No description provided for @onboardingSampleCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Amina B.'**
  String get onboardingSampleCustomer;

  /// No description provided for @onboardingSampleMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le noir est dispo en M ?'**
  String get onboardingSampleMessage;

  /// No description provided for @onboardingSampleReply.
  ///
  /// In fr, this message translates to:
  /// **'Oui — il en reste 4 en M. Livraison Oran 600 DA.'**
  String get onboardingSampleReply;

  /// No description provided for @onboardingSampleEscalation.
  ///
  /// In fr, this message translates to:
  /// **'La cliente demande un remboursement.'**
  String get onboardingSampleEscalation;

  /// No description provided for @onboardingSampleNeedsHuman.
  ///
  /// In fr, this message translates to:
  /// **'À traiter'**
  String get onboardingSampleNeedsHuman;

  /// No description provided for @onboardingSampleHandling.
  ///
  /// In fr, this message translates to:
  /// **'Agent en cours'**
  String get onboardingSampleHandling;

  /// No description provided for @onboardingShortcutProducts.
  ///
  /// In fr, this message translates to:
  /// **'Produits'**
  String get onboardingShortcutProducts;

  /// No description provided for @onboardingShortcutOrders.
  ///
  /// In fr, this message translates to:
  /// **'Commandes'**
  String get onboardingShortcutOrders;

  /// No description provided for @onboardingShortcutMovements.
  ///
  /// In fr, this message translates to:
  /// **'Mouvements'**
  String get onboardingShortcutMovements;

  /// No description provided for @errorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion. Vérifiez votre réseau et réessayez.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In fr, this message translates to:
  /// **'La requête a pris trop de temps.'**
  String get errorTimeout;

  /// No description provided for @errorUnauthorized.
  ///
  /// In fr, this message translates to:
  /// **'Votre session a expiré. Reconnectez-vous.'**
  String get errorUnauthorized;

  /// No description provided for @errorNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Introuvable.'**
  String get errorNotFound;

  /// No description provided for @errorServer.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue de notre côté.'**
  String get errorServer;

  /// No description provided for @errorUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue.'**
  String get errorUnknown;

  /// No description provided for @langEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get langFrench;

  /// No description provided for @langArabic.
  ///
  /// In fr, this message translates to:
  /// **'العربية'**
  String get langArabic;

  /// No description provided for @obStockValue.
  ///
  /// In fr, this message translates to:
  /// **'1,24'**
  String get obStockValue;

  /// No description provided for @obStockValueUnit.
  ///
  /// In fr, this message translates to:
  /// **'M DA'**
  String get obStockValueUnit;

  /// No description provided for @obStockValueLabel.
  ///
  /// In fr, this message translates to:
  /// **'Valeur du stock'**
  String get obStockValueLabel;

  /// No description provided for @obKpiProducts.
  ///
  /// In fr, this message translates to:
  /// **'Produits'**
  String get obKpiProducts;

  /// No description provided for @obKpiProductsValue.
  ///
  /// In fr, this message translates to:
  /// **'128'**
  String get obKpiProductsValue;

  /// No description provided for @obKpiPurchases.
  ///
  /// In fr, this message translates to:
  /// **'Achats'**
  String get obKpiPurchases;

  /// No description provided for @obKpiPurchasesValue.
  ///
  /// In fr, this message translates to:
  /// **'6'**
  String get obKpiPurchasesValue;

  /// No description provided for @obKpiSales.
  ///
  /// In fr, this message translates to:
  /// **'Ventes'**
  String get obKpiSales;

  /// No description provided for @obKpiSalesValue.
  ///
  /// In fr, this message translates to:
  /// **'24'**
  String get obKpiSalesValue;

  /// No description provided for @obKpiOrders.
  ///
  /// In fr, this message translates to:
  /// **'Cmd'**
  String get obKpiOrders;

  /// No description provided for @obKpiOrdersValue.
  ///
  /// In fr, this message translates to:
  /// **'12'**
  String get obKpiOrdersValue;

  /// No description provided for @obInStock.
  ///
  /// In fr, this message translates to:
  /// **'En stock'**
  String get obInStock;

  /// No description provided for @obStockRow1Name.
  ///
  /// In fr, this message translates to:
  /// **'Robe satin — Noir — M'**
  String get obStockRow1Name;

  /// No description provided for @obStockRow1Meta.
  ///
  /// In fr, this message translates to:
  /// **'Seuil 5 · Rupture'**
  String get obStockRow1Meta;

  /// No description provided for @obStockRow1Qty.
  ///
  /// In fr, this message translates to:
  /// **'0'**
  String get obStockRow1Qty;

  /// No description provided for @obStockRow2Name.
  ///
  /// In fr, this message translates to:
  /// **'Parfum Oud 50 ml'**
  String get obStockRow2Name;

  /// No description provided for @obStockRow2Meta.
  ///
  /// In fr, this message translates to:
  /// **'Seuil 10'**
  String get obStockRow2Meta;

  /// No description provided for @obStockRow2Qty.
  ///
  /// In fr, this message translates to:
  /// **'3'**
  String get obStockRow2Qty;

  /// No description provided for @obStockRow3Name.
  ///
  /// In fr, this message translates to:
  /// **'Sac cuir — Camel'**
  String get obStockRow3Name;

  /// No description provided for @obStockRow3Meta.
  ///
  /// In fr, this message translates to:
  /// **'Seuil 5'**
  String get obStockRow3Meta;

  /// No description provided for @obStockRow3Qty.
  ///
  /// In fr, this message translates to:
  /// **'7'**
  String get obStockRow3Qty;

  /// No description provided for @obEsc1Kind.
  ///
  /// In fr, this message translates to:
  /// **'IA bloquée'**
  String get obEsc1Kind;

  /// No description provided for @obEsc1Time.
  ///
  /// In fr, this message translates to:
  /// **'2 min'**
  String get obEsc1Time;

  /// No description provided for @obEsc1Name.
  ///
  /// In fr, this message translates to:
  /// **'Amina B.'**
  String get obEsc1Name;

  /// No description provided for @obEsc1Body.
  ///
  /// In fr, this message translates to:
  /// **'Elle veut changer la taille — commande déjà payée.'**
  String get obEsc1Body;

  /// No description provided for @obEsc2Kind.
  ///
  /// In fr, this message translates to:
  /// **'Commande à valider'**
  String get obEsc2Kind;

  /// No description provided for @obEsc2Time.
  ///
  /// In fr, this message translates to:
  /// **'18 min'**
  String get obEsc2Time;

  /// No description provided for @obEsc2Name.
  ///
  /// In fr, this message translates to:
  /// **'#1042 — Bab Ezzouar'**
  String get obEsc2Name;

  /// No description provided for @obEsc2Body.
  ///
  /// In fr, this message translates to:
  /// **'2 400 DA · créée par l’IA'**
  String get obEsc2Body;

  /// No description provided for @obEsc3Kind.
  ///
  /// In fr, this message translates to:
  /// **'Rupture de stock'**
  String get obEsc3Kind;

  /// No description provided for @obEsc3Time.
  ///
  /// In fr, this message translates to:
  /// **'1 h'**
  String get obEsc3Time;

  /// No description provided for @obEsc3Name.
  ///
  /// In fr, this message translates to:
  /// **'Robe satin — Noir — M'**
  String get obEsc3Name;

  /// No description provided for @obEsc3Body.
  ///
  /// In fr, this message translates to:
  /// **'0 en stock · 3 commandes en attente'**
  String get obEsc3Body;

  /// No description provided for @obEsc4Kind.
  ///
  /// In fr, this message translates to:
  /// **'Négociation'**
  String get obEsc4Kind;

  /// No description provided for @obEsc4Time.
  ///
  /// In fr, this message translates to:
  /// **'3 h'**
  String get obEsc4Time;

  /// No description provided for @obEsc4Name.
  ///
  /// In fr, this message translates to:
  /// **'Sofiane K.'**
  String get obEsc4Name;

  /// No description provided for @obEsc4Body.
  ///
  /// In fr, this message translates to:
  /// **'ndir lik 2 000 DA w nakhdo'**
  String get obEsc4Body;

  /// No description provided for @authLoginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous à votre compte pour continuer'**
  String get authLoginSubtitle;

  /// No description provided for @authSignupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Création de compte'**
  String get authSignupTitle;

  /// No description provided for @authSignupSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Commencez en moins d’une minute'**
  String get authSignupSubtitle;

  /// No description provided for @authEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get authPassword;

  /// No description provided for @authFirstName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get authFirstName;

  /// No description provided for @authLastName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get authLastName;

  /// No description provided for @authPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 8 caractères'**
  String get authPasswordHint;

  /// No description provided for @authRemember.
  ///
  /// In fr, this message translates to:
  /// **'Se souvenir de moi'**
  String get authRemember;

  /// No description provided for @authLoginSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get authLoginSubmit;

  /// No description provided for @authSignupSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Créer le compte'**
  String get authSignupSubmit;

  /// No description provided for @authForgot.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get authForgot;

  /// No description provided for @authNoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Vous n’avez pas de compte ?'**
  String get authNoAccount;

  /// No description provided for @authSignupLink.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get authSignupLink;

  /// No description provided for @authHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà un compte ?'**
  String get authHaveAccount;

  /// No description provided for @authSigninLink.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get authSigninLink;

  /// No description provided for @authEmailPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'you@example.com'**
  String get authEmailPlaceholder;

  /// No description provided for @authFirstNamePlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Jane'**
  String get authFirstNamePlaceholder;

  /// No description provided for @authLastNamePlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Doe'**
  String get authLastNamePlaceholder;

  /// No description provided for @authErrEmailRequired.
  ///
  /// In fr, this message translates to:
  /// **'L’e-mail est requis'**
  String get authErrEmailRequired;

  /// No description provided for @authErrInvalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir une adresse e-mail valide'**
  String get authErrInvalidEmail;

  /// No description provided for @authErrPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe est requis'**
  String get authErrPasswordRequired;

  /// No description provided for @authErrPasswordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit contenir au moins 8 caractères'**
  String get authErrPasswordTooShort;

  /// No description provided for @authErrFirstNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le prénom est requis'**
  String get authErrFirstNameRequired;

  /// No description provided for @authErrLastNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le nom est requis'**
  String get authErrLastNameRequired;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return L10nAr();
    case 'en':
      return L10nEn();
    case 'fr':
      return L10nFr();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
