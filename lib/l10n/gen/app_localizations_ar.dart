// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class L10nAr extends L10n {
  L10nAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Djaber.ai';

  @override
  String get appTagline => 'وكيل ذكاء اصطناعي اجتماعي';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonDismiss => 'إغلاق';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get commonSearch => 'بحث';

  @override
  String get commonLoading => 'جارٍ التحميل…';

  @override
  String get commonSeeAll => 'عرض الكل';

  @override
  String get commonEmpty => 'لا يوجد شيء هنا';

  @override
  String get commonNext => 'التالي';

  @override
  String get commonSkip => 'تخطّي';

  @override
  String get commonStart => 'ابدأ';

  @override
  String get onboardingAnswersTitle => 'الوكيل يردّ على زبائنك';

  @override
  String get onboardingAnswersBody =>
      'يعرف كتالوجك ومخزونك وأسعارك. يردّ على رسائل فيسبوك وإنستغرام بدلاً عنك، ليلاً ونهاراً.';

  @override
  String get onboardingEscalationTitle => 'تتدخّل أنت عند الحاجة';

  @override
  String get onboardingEscalationBody =>
      'عندما لا يعود الذكاء الاصطناعي قادراً على المتابعة، يتوقّف وينبّهك. تردّ من هاتفك، ثم تعيد إليه المحادثة.';

  @override
  String get onboardingStockTitle => 'مخزونك في جيبك';

  @override
  String get onboardingStockBody =>
      'المنتجات والمشتريات والمبيعات والطلبات. تحقّق من كمية والزبون ينتظر، وصحّحها في مكانك.';

  @override
  String get onboardingSampleCustomer => 'أمينة ب.';

  @override
  String get onboardingSampleMessage => 'الأسود متوفّر في مقاس M؟';

  @override
  String get onboardingSampleReply =>
      'نعم — بقيت 4 قطع في M. التوصيل إلى وهران 600 دج.';

  @override
  String get onboardingSampleEscalation => 'الزبونة تطلب استرجاع المبلغ.';

  @override
  String get onboardingSampleNeedsHuman => 'بانتظارك';

  @override
  String get onboardingSampleHandling => 'الوكيل يتولّاها';

  @override
  String get onboardingShortcutProducts => 'المنتجات';

  @override
  String get onboardingShortcutOrders => 'الطلبات';

  @override
  String get onboardingShortcutMovements => 'الحركات';

  @override
  String get errorNetwork => 'لا يوجد اتصال. تحقق من الشبكة وحاول مرة أخرى.';

  @override
  String get errorTimeout => 'استغرق الطلب وقتًا طويلاً.';

  @override
  String get errorUnauthorized => 'انتهت الجلسة. سجّل الدخول مرة أخرى.';

  @override
  String get errorServer => 'حدث خطأ من جانبنا.';

  @override
  String get toastProductCreated => 'تم إنشاء المنتج';

  @override
  String get toastProductUpdated => 'تم تحديث المنتج';

  @override
  String get toastAgentCreated => 'تم إنشاء وكيل الذكاء الاصطناعي';

  @override
  String get toastPageConnected => 'تم ربط الصفحة';

  @override
  String get errorGeneric => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get langEnglish => 'English';

  @override
  String get langFrench => 'Français';

  @override
  String get langArabic => 'العربية';

  @override
  String get obStockValue => '1,24';

  @override
  String get obStockValueUnit => 'م دج';

  @override
  String get obStockValueLabel => 'قيمة المخزون';

  @override
  String get obKpiProducts => 'منتجات';

  @override
  String get obKpiProductsValue => '128';

  @override
  String get obKpiPurchases => 'مشتريات';

  @override
  String get obKpiPurchasesValue => '6';

  @override
  String get obKpiSales => 'مبيعات';

  @override
  String get obKpiSalesValue => '24';

  @override
  String get obKpiOrders => 'طلبات';

  @override
  String get obKpiOrdersValue => '12';

  @override
  String get obInStock => 'في المخزون';

  @override
  String get obStockRow1Name => 'فستان ساتان — أسود — M';

  @override
  String get obStockRow1Meta => 'الحدّ 5 · نفد';

  @override
  String get obStockRow1Qty => '0';

  @override
  String get obStockRow2Name => 'عطر عود 50 مل';

  @override
  String get obStockRow2Meta => 'الحدّ 10';

  @override
  String get obStockRow2Qty => '3';

  @override
  String get obStockRow3Name => 'حقيبة جلد — بيج';

  @override
  String get obStockRow3Meta => 'الحدّ 5';

  @override
  String get obStockRow3Qty => '7';

  @override
  String get obEsc1Kind => 'الوكيل متوقّف';

  @override
  String get obEsc1Time => '2 د';

  @override
  String get obEsc1Name => 'أمينة ب.';

  @override
  String get obEsc1Body => 'تريد تغيير المقاس — الطلب مدفوع مسبقاً.';

  @override
  String get obEsc2Kind => 'طلب للتأكيد';

  @override
  String get obEsc2Time => '18 د';

  @override
  String get obEsc2Name => '‏#1042 — باب الزوار';

  @override
  String get obEsc2Body => '2400 دج · أنشأه الوكيل';

  @override
  String get obEsc3Kind => 'نفاد المخزون';

  @override
  String get obEsc3Time => '1 س';

  @override
  String get obEsc3Name => 'فستان ساتان — أسود — M';

  @override
  String get obEsc3Body => '0 في المخزون · 3 طلبات في الانتظار';

  @override
  String get obEsc4Kind => 'مساومة';

  @override
  String get obEsc4Time => '3 س';

  @override
  String get obEsc4Name => 'سفيان ك.';

  @override
  String get obEsc4Body => 'ndir lik 2 000 DA w nakhdo';

  @override
  String get authLoginTitle => 'تسجيل الدخول';

  @override
  String get authLoginSubtitle => 'سجّل الدخول إلى حسابك للمتابعة';

  @override
  String get authSignupTitle => 'إنشاء حساب';

  @override
  String get authSignupSubtitle => 'ابدأ في أقل من دقيقة';

  @override
  String get authEmail => 'البريد الإلكتروني';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get authFirstName => 'الاسم';

  @override
  String get authLastName => 'اللقب';

  @override
  String get authPasswordHint => '8 أحرف على الأقل';

  @override
  String get authRemember => 'تذكرني';

  @override
  String get authLoginSubmit => 'تسجيل الدخول';

  @override
  String get authSignupSubmit => 'إنشاء الحساب';

  @override
  String get authForgot => 'نسيت كلمة المرور؟';

  @override
  String get authNoAccount => 'ليس لديك حساب؟';

  @override
  String get authSignupLink => 'ابدأ الآن';

  @override
  String get authHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get authSigninLink => 'تسجيل الدخول';

  @override
  String get authEmailPlaceholder => 'you@example.com';

  @override
  String get authFirstNamePlaceholder => 'أمينة';

  @override
  String get authLastNamePlaceholder => 'بن علي';

  @override
  String get authErrEmailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get authErrInvalidEmail => 'يرجى إدخال بريد إلكتروني صالح';

  @override
  String get authErrPasswordRequired => 'كلمة المرور مطلوبة';

  @override
  String get authErrPasswordTooShort =>
      'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل';

  @override
  String get authErrFirstNameRequired => 'الاسم مطلوب';

  @override
  String get authErrLastNameRequired => 'اللقب مطلوب';

  @override
  String get authForgotBack => 'العودة إلى تسجيل الدخول';

  @override
  String get authForgotTitle => 'نسيت كلمة المرور؟';

  @override
  String get authForgotSubtitle => 'أدخل بريدك لاستلام رابط إعادة التعيين';

  @override
  String get authForgotEmail => 'البريد الإلكتروني';

  @override
  String get authForgotEmailPlaceholder => 'you@company.com';

  @override
  String get authForgotSubmit => 'إرسال الرابط';

  @override
  String get authForgotSecure =>
      'رابط إعادة التعيين مشفر وتنتهي صلاحيته خلال ساعة';

  @override
  String get authForgotRemember => 'تتذكر كلمة المرور؟';

  @override
  String get authSentTitle => 'تحقق من بريدك';

  @override
  String get authSentMessage =>
      'إذا كان هناك حساب بهذا العنوان، فقد أُرسل إليه رابط إعادة التعيين للتو';

  @override
  String get authSentNoReceive => 'لم تستلم البريد؟';

  @override
  String get authSentTryAnother => 'جرّب عنوان بريد آخر';

  @override
  String get authSentResend => 'إعادة إرسال الرابط';

  @override
  String authSentResendIn(int seconds) {
    return 'إعادة إرسال الرابط بعد $seconds ث';
  }

  @override
  String get authSentResent => 'تم إرسال رابط جديد';

  @override
  String get authSentNextStep =>
      'افتح الرابط الوارد في البريد لاختيار كلمة مرور جديدة.';

  @override
  String get authResetTitle => 'كلمة مرور جديدة';

  @override
  String get authResetSubtitle => 'اختر كلمة مرور جديدة لحسابك';

  @override
  String get authResetDeadSubtitle =>
      'اطلب رابطًا جديدًا لإعادة تعيين كلمة المرور';

  @override
  String get authResetChecking => 'جارٍ التحقق من الرابط…';

  @override
  String get authResetPasswordLabel => 'كلمة المرور الجديدة';

  @override
  String get authResetConfirmLabel => 'تأكيد كلمة المرور';

  @override
  String get authErrPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get authResetSubmit => 'حفظ كلمة المرور';

  @override
  String get authResetDone => 'تم تحديث كلمة المرور';

  @override
  String get authResetRequestNew => 'طلب رابط جديد';

  @override
  String get menuOverview => 'نظرة عامة';

  @override
  String get menuInbox => 'البريد الوارد';

  @override
  String get menuSocial => 'وسائل التواصل';

  @override
  String get menuServices => 'الخدمات';

  @override
  String get menuProducts => 'المنتجات';

  @override
  String get menuAgents => 'الوكلاء';

  @override
  String get menuCommercial => 'الإعلانات';

  @override
  String get menuSoon => 'قريبا';

  @override
  String get menuNotifications => 'الإشعارات';

  @override
  String get menuAnalytics => 'تحليلات';

  @override
  String get menuReports => 'التقارير';

  @override
  String get menuSettings => 'الإعدادات';

  @override
  String get menuWebOnly => 'على الويب';

  @override
  String get tutorialStepAlreadyDone => 'تم مسبقًا — نكمل';

  @override
  String get exitHint => 'اضغط مرة أخرى للخروج';

  @override
  String get menuPages => 'الصفحات';

  @override
  String get menuPlan => 'خطتك';

  @override
  String get menuPlanUnknown => '—';

  @override
  String get menuSignOut => 'تسجيل الخروج';

  @override
  String get tutorialStepMode => 'اختر وضع المخزون';

  @override
  String get tutorialStepProduct => 'أنشئ منتجك الأول';

  @override
  String get tutorialStepAgent => 'أنشئ وكيل الذكاء الاصطناعي';

  @override
  String get tutorialStepPage => 'اربط صفحتك';

  @override
  String get tutorialWelcomeTitle => 'مرحبًا بك في Djaber.ai';

  @override
  String get tutorialWelcomeBody =>
      'نُشغّل متجرك معًا. أربع خطوات، ويبدأ وكيلك بالردّ على زبائنك.';

  @override
  String get tutorialStockTitle => 'أولًا، مخزونك';

  @override
  String get tutorialStockBody =>
      'تختار طريقة إدارة مخزونك، ثم تنشئ منتجك الأول — الاسم والسعر والكمية.';

  @override
  String get tutorialAgentTitle => 'ثم وكيلك';

  @override
  String get tutorialAgentBody =>
      'أنشئه بثلاثة حقول، اربط صفحتك على فيسبوك، ويردّ من أول سؤال.';

  @override
  String get commonContinue => 'متابعة';

  @override
  String get commonActive => 'نشط';

  @override
  String tutorialStepCounter(int step, int total) {
    return 'الخطوة $step من $total';
  }

  @override
  String get tutorialModeTitle => 'كيف تدير مخزونك ؟';

  @override
  String get tutorialModeSubtitle =>
      'هذا الاختيار يحدّد ما تراه في التطبيق. يمكنك تغييره في أي وقت من الإعدادات.';

  @override
  String get stockModeSimple => 'بسيط';

  @override
  String get stockModeAdvanced => 'متقدم';

  @override
  String get stockModeSimpleDesc =>
      'المنتجات والفئات والطلبات — أدر المخزون والطلبات دون تعقيد.';

  @override
  String get stockModeAdvancedDesc =>
      'مجموعة كاملة — الموردون والعملاء والمبيعات والمشتريات والصندوق والحركات والتوصيل والمزيد.';

  @override
  String get stockOverviewTitle => 'نظرة عامة على المخزون';

  @override
  String get stockOverviewSubtitle => 'ملخص المخزون والمبيعات والمشتريات';

  @override
  String get stockOverviewHintSimple =>
      'الوضع البسيط يعرض المنتجات والطلبات والعملاء. انتقل إلى المتقدم للمبيعات والمشتريات والموردين والصندوق والحركات.';

  @override
  String get stockOverviewHintAdvanced =>
      'الوضع المتقدم: نظام متكامل — المبيعات والمشتريات والموردون والصندوق وحركات المخزون مفعّلة.';

  @override
  String get stockTotalProducts => 'إجمالي المنتجات';

  @override
  String get stockLowStock => 'مخزون منخفض';

  @override
  String get stockValue => 'قيمة المخزون';

  @override
  String get stockRetailValue => 'قيمة البيع';

  @override
  String get stockCategories => 'الفئات';

  @override
  String get stockSuppliers => 'الموردون';

  @override
  String get stockTotalItems => 'إجمالي العناصر في المخزون';

  @override
  String get stockSalesMonth => 'مبيعات هذا الشهر';

  @override
  String get stockTotalSales => 'إجمالي المبيعات';

  @override
  String get stockRevenue => 'الإيرادات';

  @override
  String get stockPaid => 'مدفوع';

  @override
  String get stockPending => 'قيد الانتظار';

  @override
  String get stockPurchasesMonth => 'مشتريات هذا الشهر';

  @override
  String get stockTotalPurchases => 'إجمالي المشتريات';

  @override
  String get stockTotalSpent => 'إجمالي الإنفاق';

  @override
  String get stockReceived => 'مستلم';

  @override
  String get stockRecentMovements => 'الحركات الأخيرة';

  @override
  String get stockMovementsEmpty =>
      'لا توجد حركات مسجلة. ستظهر حركات المخزون هنا عند إضافة المنتجات أو بيعها أو تعديلها.';

  @override
  String get stockMoveIn => 'دخول';

  @override
  String get stockMoveOut => 'خروج';

  @override
  String get stockMoveAdjustment => 'تعديل';

  @override
  String get stockMoveReturn => 'إرجاع';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsSubtitle => 'أدر حسابك وإعدادات التطبيق';

  @override
  String get settingsStockMode => 'إدارة المخزون';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageFrench => 'الفرنسية';

  @override
  String get settingsLanguageEnglish => 'الإنجليزية';

  @override
  String get settingsLanguageArabic => 'العربية';

  @override
  String get settingsLanguageHelp =>
      'يبقى التطبيق باللغة التي تختارها، حتى لو تغيّرت لغة الهاتف.';

  @override
  String get planNameIndividual => 'فردي';

  @override
  String get planNamePro => 'احترافي';

  @override
  String get planNameTeams => 'فِرق';

  @override
  String get planDescIndividual =>
      'للبدء: اربط صفحتك ودع الذكاء الاصطناعي يرد على عملائك.';

  @override
  String get planDescPro =>
      'للبائعين النشطين: التعرّف على الصور، الرسائل الصوتية وحجم أكبر.';

  @override
  String get planDescTeams => 'للمتاجر الراسخة: أقصى حجم ودعم ذو أولوية.';

  @override
  String planFeaturePages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صفحة على فيسبوك / إنستغرام',
      few: '$count صفحات على فيسبوك / إنستغرام',
      two: 'صفحتان على فيسبوك / إنستغرام',
      one: 'صفحة واحدة على فيسبوك أو إنستغرام',
    );
    return '$_temp0';
  }

  @override
  String planFeatureCredits(String amount) {
    return '$amount رصيد ذكاء اصطناعي / شهريًا';
  }

  @override
  String planFeatureProducts(String amount) {
    return '$amount منتج';
  }

  @override
  String planFeatureDelivery(int count, String carriers) {
    return 'التوصيل إلى $count ولاية ($carriers)';
  }

  @override
  String get planFeatureAgentText => 'وكيل ذكاء اصطناعي 24/7 (نص)';

  @override
  String get planFeatureAgentFull => 'وكيل ذكاء اصطناعي 24/7 (نص + صور + صوت)';

  @override
  String get planFeatureStock => 'إدارة المخزون والطلبات';

  @override
  String get planFeatureCallConfirmation => 'تأكيد الطلبات بالاتصال الهاتفي';

  @override
  String get planFeatureVision => 'التعرّف على الصور (الرؤية)';

  @override
  String get planFeatureVoiceNotes => 'الرسائل الصوتية (تفريغ نصي)';

  @override
  String get planFeatureCrossSell =>
      'البيع المتقاطع والبيع الإضافي بالذكاء الاصطناعي';

  @override
  String get planFeatureUnlimitedProducts => 'منتجات غير محدودة';

  @override
  String get planFeatureUnlimitedConversations => 'محادثات غير محدودة';

  @override
  String get planFeatureEverythingPro => 'جميع ميزات الخطة الاحترافية';

  @override
  String get planFeaturePrioritySupport => 'دعم ذو أولوية';

  @override
  String get settingsAccount => 'معلومات الحساب';

  @override
  String get settingsBilling => 'الخطة والفوترة';

  @override
  String get settingsCurrentPlan => 'الخطة الحالية';

  @override
  String get settingsMonthly => 'شهري';

  @override
  String get settingsYearly => 'سنوي';

  @override
  String get settingsFree => 'مجاني';

  @override
  String settingsPerMonth(String currency) {
    return '$currency / شهر';
  }

  @override
  String settingsPerYear(String currency) {
    return '$currency / سنة';
  }

  @override
  String get settingsBadgeCurrent => 'الحالية';

  @override
  String get settingsBadgePopular => 'الأكثر شيوعا';

  @override
  String get settingsYourPlan => 'خطتك الحالية';

  @override
  String get settingsFreeNoPayment => 'مجاني — لا حاجة للدفع';

  @override
  String settingsSubscribe(String price) {
    return 'اشترك — $price';
  }

  @override
  String get settingsRedirecting => 'جارٍ التحويل…';

  @override
  String get settingsVerifying => 'جارٍ التحقق من الدفع…';

  @override
  String get settingsNoPlans => 'لا توجد خطط متاحة حاليًا.';

  @override
  String settingsCheckoutPaid(String plan) {
    return 'تم تأكيد الدفع — خطتك $plan مفعّلة.';
  }

  @override
  String get settingsCheckoutPending =>
      'لم يتم تأكيد الدفع بعد. إذا تمّ، ستُفعَّل خطتك قريبًا.';

  @override
  String get settingsCheckoutFailed => 'لم تتم عملية الدفع.';

  @override
  String get settingsFbTitle => 'صلاحيات واجهة فيسبوك';

  @override
  String get settingsFbActive => 'الصلاحيات المفعّلة حاليًا';

  @override
  String get settingsFbAvailable => 'الصلاحيات المتقدمة المتاحة';

  @override
  String get settingsFbReviewHint =>
      'تحتاج هذه الصلاحيات إلى موافقة مراجعة تطبيق فيسبوك.';

  @override
  String get settingsDangerTitle => 'منطقة الخطر';

  @override
  String get settingsDeleteAccount => 'حذف الحساب';

  @override
  String get settingsDeleteHelp =>
      'احذف حسابك وجميع البيانات المرتبطة به نهائيًا.';

  @override
  String get inboxTitle => 'البريد الوارد';

  @override
  String get inboxSubtitle => 'اقرأ ورد على رسائل عملائك.';

  @override
  String get inboxNoPagesTitle => 'لا توجد صفحات متصلة';

  @override
  String get inboxNoPagesBody =>
      'اربط صفحة فيسبوك أو إنستغرام لتبدأ في استقبال الرسائل هنا.';

  @override
  String get inboxConnectPage => 'ربط صفحة';

  @override
  String get inboxPlatformMessenger => 'ماسنجر';

  @override
  String get inboxPlatformInstagram => 'رسائل إنستغرام';

  @override
  String inboxSynced(String time) {
    return 'تمت المزامنة $time';
  }

  @override
  String get inboxSwitchPage => 'تبديل الصفحة';

  @override
  String get inboxConnectAnother => 'ربط صفحة أخرى';

  @override
  String get inboxSync => 'مزامنة';

  @override
  String get inboxSyncing => 'جاري المزامنة…';

  @override
  String get inboxTabAll => 'الكل';

  @override
  String get inboxTabActive => 'نشطة';

  @override
  String get inboxTabResolved => 'منتهية';

  @override
  String get inboxTabArchived => 'مؤرشفة';

  @override
  String get inboxSearchHint => 'ابحث بالاسم أو الرسالة…';

  @override
  String get inboxNoMatches => 'لا توجد نتائج';

  @override
  String get inboxNoConversations => 'لا توجد محادثات بعد';

  @override
  String get inboxNothingHere => 'لا شيء في هذا العرض';

  @override
  String get inboxPullFromFacebook => 'سحب من فيسبوك';

  @override
  String get inboxUpToDate => 'محدّث';

  @override
  String inboxSyncedCount(int n) {
    return 'تمت المزامنة — $n رسالة جديدة';
  }

  @override
  String get inboxAttachment => 'مرفق';

  @override
  String get inboxEmptyMessage => 'رسالة فارغة';

  @override
  String get inboxAiPaused => 'الذكاء الاصطناعي متوقف';

  @override
  String get inboxStatusActive => 'نشطة';

  @override
  String get inboxStatusResolved => 'منتهية';

  @override
  String get inboxStatusArchived => 'مؤرشفة';

  @override
  String get inboxTimeNow => 'الآن';

  @override
  String inboxTimeMinutes(int n) {
    return '$n د';
  }

  @override
  String inboxTimeHours(int n) {
    return '$n س';
  }

  @override
  String get conversationMarkResolved => 'وضع علامة منتهي';

  @override
  String get conversationArchive => 'أرشفة المحادثة';

  @override
  String get conversationReopen => 'إعادة فتح';

  @override
  String get conversationResumeAi => 'إعادة تشغيل الذكاء الاصطناعي';

  @override
  String get conversationPausedNotice =>
      'لم يعد الوكيل يرد على هذا العميل. رد عليه هنا.';

  @override
  String get conversationReplyHint => 'اكتب ردك…';

  @override
  String get conversationSend => 'إرسال';

  @override
  String get conversationSending => 'جاري الإرسال…';

  @override
  String get conversationReopenHint => 'أعد فتح هذه المحادثة للرد.';

  @override
  String get conversationEmpty => 'لا توجد رسائل بعد';

  @override
  String get conversationResolvedToast => 'تم وضع علامة منتهي';

  @override
  String get conversationArchivedToast => 'تمت الأرشفة';

  @override
  String get conversationReopenedToast => 'تمت إعادة فتح المحادثة';

  @override
  String get conversationAiResumedToast => 'عاد الذكاء الاصطناعي للرد';

  @override
  String get conversationAuthorAi => 'الوكيل';

  @override
  String get conversationAuthorYou => 'أنت';

  @override
  String get productVariantsTitle => 'المتغيرات';

  @override
  String productVariantsTotal(int count) {
    return 'إجمالي الكمية: $count';
  }

  @override
  String get productVariantAdd => 'إضافة متغير';

  @override
  String get productVariantsEmpty =>
      'لا توجد متغيرات. اضغط «إضافة متغير» لإنشاء واحد.';

  @override
  String get productVariantName => 'الاسم';

  @override
  String get productVariantNamePlaceholder => 'مثال: أحمر - L';

  @override
  String get productVariantSku => 'SKU';

  @override
  String get productVariantSkuPlaceholder => 'اختياري';

  @override
  String get productVariantCost => 'التكلفة';

  @override
  String get productVariantPrice => 'السعر';

  @override
  String get productVariantQuantity => 'الكمية';

  @override
  String get productVariantMinQuantity => 'الحد الأدنى';

  @override
  String get productVariantRemove => 'حذف المتغير';

  @override
  String get productVariantDuplicate => 'لا يمكن أن يكون لمتغيرين نفس الاسم';

  @override
  String get productVariantsRequired =>
      'أضف متغيرًا واحدًا على الأقل، أو ألغِ تحديد الخانة.';

  @override
  String get productVariantsRetryHint =>
      'تم إنشاء المنتج — سيتم إرسال المتغيرات المفقودة فقط.';

  @override
  String get productDetailEyebrow => 'تفاصيل المنتج';

  @override
  String get productDetailNoImages => 'لا توجد صور';

  @override
  String get productDetailCost => 'سعر التكلفة';

  @override
  String get productDetailSelling => 'سعر البيع';

  @override
  String get productDetailProfit => 'الربح / الهامش';

  @override
  String get productDetailInStock => 'في المخزون';

  @override
  String get productDetailStatus => 'الحالة';

  @override
  String get productDetailActive => 'نشط';

  @override
  String get productDetailInactive => 'غير نشط';

  @override
  String productDetailVariants(int count) {
    return 'المتغيرات ($count)';
  }

  @override
  String get tutorialProductTitle => 'منتجك الأول';

  @override
  String get tutorialProductSubtitle =>
      'هذا ما سيبيعه وكيلك. الوصف هو ما يقرأه للردّ على الزبائن.';

  @override
  String get tutorialProductSubmit => 'إنشاء المنتج';

  @override
  String get productName => 'الاسم';

  @override
  String get productNamePlaceholder => 'فستان ساتان — أسود';

  @override
  String get productSku => 'المرجع (SKU)';

  @override
  String get productSkuPlaceholder => 'PRD-001';

  @override
  String get productDescription => 'الوصف';

  @override
  String get productDescriptionPlaceholder =>
      'صف المنتج — يستعمله الوكيل لبيعه';

  @override
  String get productCostPrice => 'سعر الشراء (دج)';

  @override
  String get productSellingPrice => 'سعر البيع (دج)';

  @override
  String get productQuantity => 'الكمية الأولية';

  @override
  String get productErrRequired => 'هذا الحقل مطلوب';

  @override
  String get productErrNotANumber => 'أدخل رقمًا';

  @override
  String get productErrMustBePositive => 'يجب أن يكون أكبر من 0';

  @override
  String get productErrBelowCost => 'يجب أن يكون أكبر من أو يساوي سعر الشراء';

  @override
  String get productsEyebrow => 'الكتالوج';

  @override
  String get productsTitle => 'المنتجات';

  @override
  String productsSummary(int count, String value) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منتج',
      many: '$count منتجًا',
      few: '$count منتجات',
      two: 'منتجان',
      one: 'منتج واحد',
      zero: 'لا توجد منتجات',
    );
    return 'ما يبيعه وكيلك. $_temp0، $value قيمة المخزون.';
  }

  @override
  String get productsSearchLabel => 'البحث';

  @override
  String get productsSearchPlaceholder => 'ابحث عن منتج…';

  @override
  String get productsFilterAll => 'الكل';

  @override
  String get productsFilterLowStock => 'مخزون منخفض';

  @override
  String get productsSectionAll => 'كل المنتجات';

  @override
  String get productsSectionLowStock => 'مخزون منخفض';

  @override
  String get productsInStock => 'متوفر';

  @override
  String get productsOutOfStock => 'نفد';

  @override
  String productsThreshold(int count) {
    return 'الحد $count';
  }

  @override
  String productsVariantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count متغير',
      few: '$count متغيرات',
      two: 'متغيران',
      one: 'متغير واحد',
    );
    return '$_temp0';
  }

  @override
  String get productsEmptyTitle => 'لا توجد منتجات';

  @override
  String get productsEmptyBody =>
      'أضف منتجك الأول ليصبح وكيلك قادرًا على بيعه.';

  @override
  String get productsNoMatchTitle => 'لا نتائج';

  @override
  String get productsNoMatchBody => 'جرّب كلمة أخرى، أو أزل عامل التصفية.';

  @override
  String get productsAdd => 'إضافة منتج';

  @override
  String get productAddTitle => 'إضافة منتج';

  @override
  String get productAlertThreshold => 'حد التنبيه';

  @override
  String get productAlertThresholdHint => 'اتركه فارغًا لإلغاء التنبيه';

  @override
  String get productCategory => 'الفئة';

  @override
  String get productCategoryNone => 'بدون فئة';

  @override
  String get productUnit => 'الوحدة';

  @override
  String get productUnitNone => 'اختر وحدة';

  @override
  String get productPhotos => 'أضف صورًا';

  @override
  String get productPhotosHint => 'JPEG, PNG, WEBP · 5 ميغابايت كحد أقصى';

  @override
  String get productHasVariants => 'هذا المنتج له متغيرات';

  @override
  String get productHasVariantsHint =>
      'مقاسات أو ألوان — تُحدَّد الكمية لكل متغير';

  @override
  String get productAddSubmit => 'إضافة المنتج';

  @override
  String get productEditTitle => 'تعديل المنتج';

  @override
  String get productEditSubmit => 'تحديث المنتج';

  @override
  String get productEditVariantsHint =>
      'لتغيير كميات المتغيرات، استخدم «تعديل المخزون».';

  @override
  String get productEditLeaveBody => 'ستُفقد التعديلات.';

  @override
  String get productEditDeleteVariantsTitle => 'حذف المتغيرات؟';

  @override
  String productEditDeleteVariantsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سيُحذف $count متغير نهائيًا.',
      few: 'ستُحذف $count متغيرات نهائيًا.',
      two: 'سيُحذف متغيران نهائيًا.',
      one: 'سيُحذف متغير واحد نهائيًا.',
    );
    return '$_temp0';
  }

  @override
  String productEditDeleteVariantsStock(int count, int stock) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سيُحذف $count متغير نهائيًا، وستُخصم $stock وحدة من مخزونك.',
      few: 'ستُحذف $count متغيرات نهائيًا، وستُخصم $stock وحدة من مخزونك.',
      two: 'سيُحذف متغيران نهائيًا، وستُخصم $stock وحدة من مخزونك.',
      one: 'سيُحذف متغير واحد نهائيًا، وستُخصم $stock وحدة من مخزونك.',
    );
    return '$_temp0';
  }

  @override
  String get productEditDeleteVariantsConfirm => 'حذف وحفظ';

  @override
  String get productUnitAdd => 'إضافة وحدة';

  @override
  String get productUnitName => 'اسم الوحدة';

  @override
  String get productUnitNamePlaceholder => 'مثال: دزينة';

  @override
  String get productUnitAbbreviation => 'الاختصار';

  @override
  String get productUnitAbbreviationPlaceholder => 'مثال: دز';

  @override
  String get productUnitCreate => 'إضافة الوحدة';

  @override
  String get stockAdjustTitle => 'تعديل المخزون';

  @override
  String stockAdjustSubtitle(String product, String stock) {
    return '$product  ·  المخزون الحالي: $stock';
  }

  @override
  String get stockAdjustIn => 'إدخال (+)';

  @override
  String get stockAdjustOut => 'إخراج (−)';

  @override
  String get stockAdjustSet => 'تحديد';

  @override
  String get stockAdjustReason => 'السبب';

  @override
  String stockAdjustCurrent(int count) {
    return 'الكمية: $count';
  }

  @override
  String stockAdjustResult(int count) {
    return 'الكمية الجديدة: $count';
  }

  @override
  String stockAdjustInsufficient(int count) {
    return 'المتوفّر $count فقط';
  }

  @override
  String get stockAdjustNothing => 'أدخل كمية في سطر واحد على الأقل.';

  @override
  String get stockAdjustSubmit => 'تعديل المخزون';

  @override
  String get stockAdjustDone => 'تم تعديل المخزون';

  @override
  String get expensesTitle => 'مصاريف المنتج';

  @override
  String get expensesEyebrow => 'مصاريف المنتج';

  @override
  String get expensesMarginSummary => 'ملخّص الهامش';

  @override
  String get expensesTotal => 'إجمالي المصاريف';

  @override
  String get expensesPerUnit => 'المصروف / الوحدة';

  @override
  String get expensesTrueCost => 'التكلفة الحقيقية';

  @override
  String get expensesNetMargin => 'الهامش الصافي';

  @override
  String expensesSection(int count) {
    return 'المصاريف ($count)';
  }

  @override
  String get expensesEmpty =>
      'لا توجد مصاريف بعد. أضف واحدة أدناه وسيأخذها الهامش في الحسبان.';

  @override
  String get expensesAddSection => 'إضافة مصروف';

  @override
  String get expenseCategory => 'الفئة';

  @override
  String get expenseCategoryMarketing => 'تسويق';

  @override
  String get expenseCategoryShipping => 'توصيل';

  @override
  String get expenseCategoryPackaging => 'تغليف';

  @override
  String get expenseCategoryCustoms => 'جمارك';

  @override
  String get expenseCategoryStorage => 'تخزين';

  @override
  String get expenseCategoryOther => 'أخرى';

  @override
  String get expenseAmount => 'المبلغ (دج)';

  @override
  String get expenseAmountPlaceholder => 'المبلغ';

  @override
  String get expenseDescriptionPlaceholder => 'الوصف (اختياري)';

  @override
  String get expenseFixed => 'ثابت';

  @override
  String get expensePerUnit => 'لكل وحدة';

  @override
  String get expensePerUnitTag => '/ وحدة';

  @override
  String get expenseAdd => 'إضافة المصروف';

  @override
  String get expenseAdded => 'تمت إضافة المصروف';

  @override
  String get expenseDeleteTitle => 'حذف هذا المصروف؟';

  @override
  String expenseDeleteBody(String category, String amount) {
    return '$category — سيُحذف $amount، وسيُعاد حساب الهامش.';
  }

  @override
  String get expenseDeleted => 'تم حذف المصروف';

  @override
  String get productDeleteTitle => 'حذف المنتج';

  @override
  String productDeleteBody(String name) {
    return 'هل تريد فعلاً حذف $name؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get productDeleteDone => 'تم حذف المنتج';

  @override
  String get productDetailActions => 'إجراءات';

  @override
  String get productDetailAdjustMeta => 'إدخال أو إخراج أو كمية محدّدة';

  @override
  String get productDetailExpensesMeta => 'التكلفة الحقيقية والهامش الصافي';

  @override
  String get productDetailDeleteMeta => 'يزيله من كتالوجك';

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منتج',
      many: '$count منتجًا',
      few: '$count منتجات',
      two: 'منتجان',
      one: 'منتج واحد',
      zero: 'لا توجد منتجات',
    );
    return '$_temp0';
  }

  @override
  String get productPhotosSoon => 'تُضاف الصور من الويب في الوقت الحالي';

  @override
  String get productPhotosTooLarge =>
      'لم تُضف الصور التي يتجاوز حجمها 5 ميغابايت.';

  @override
  String get productPhotosWrongType =>
      'يمكن إضافة صور JPEG أو PNG أو WEBP أو GIF فقط.';

  @override
  String get productPhotosTooMany => '10 صور كحد أقصى لكل منتج.';

  @override
  String get productPhotosUploadFailed =>
      'تم إنشاء المنتج، لكن تعذّر رفع صوره.';

  @override
  String get productPhotosUploadFailedEdit =>
      'تم تحديث المنتج، لكن تعذّر رفع الصور الجديدة.';

  @override
  String get productPhotoRemove => 'إزالة الصورة';

  @override
  String get productPhotoCamera => 'التقاط صورة';

  @override
  String get productPhotoGallery => 'اختيار من المعرض';

  @override
  String get tutorialAgentSubtitle =>
      'يردّ على زبائنك بالاعتماد على كتالوجك وأسعارك. ثلاثة حقول تكفي — والباقي يُضبط لاحقًا.';

  @override
  String get tutorialAgentSubmit => 'إنشاء الوكيل';

  @override
  String get agentName => 'اسم الوكيل';

  @override
  String get agentNamePlaceholder => 'مثال: مساعد المبيعات';

  @override
  String get agentPersonality => 'الشخصية';

  @override
  String get agentToneProfessional => 'احترافي';

  @override
  String get agentToneProfessionalDesc => 'رسمي وموجّه للأعمال';

  @override
  String get agentToneFriendly => 'ودود';

  @override
  String get agentToneFriendlyDesc => 'دافئ وسهل التعامل';

  @override
  String get agentToneCasual => 'عفوي';

  @override
  String get agentToneCasualDesc => 'مرتاح وحواري';

  @override
  String get agentToneTechnical => 'تقني';

  @override
  String get agentToneTechnicalDesc => 'مفصّل ودقيق';

  @override
  String get agentInstructions => 'التعليمات';

  @override
  String get agentInstructionsPlaceholder =>
      'كيف يردّ، ومتى يحوّل المحادثة إليك';

  @override
  String get tutorialConnectTitle => 'اربط صفحتك';

  @override
  String get tutorialConnectSubtitle =>
      'هذه آخر خطوة. وكيلك يردّ في صندوق رسائل هذه الصفحة — وبمجرد ربطها يبدأ العمل.';

  @override
  String get connectPermissionsHeading => 'فيسبوك سيطلب منك';

  @override
  String get connectPermissionPages => 'الاطّلاع على قائمة صفحاتك';

  @override
  String get connectPermissionMessages => 'قراءة رسائل الصفحة وإرسالها';

  @override
  String get connectPermissionInfo => 'الوصول إلى معلومات الصفحة';

  @override
  String get connectFacebook => 'ربط فيسبوك';

  @override
  String get connectInstagram => 'ربط إنستغرام';

  @override
  String get oauthLoading => 'جارٍ تحميل فيسبوك…';

  @override
  String get oauthLoadingHint => 'تظهر هنا صفحة الإذن الخاصة بفيسبوك.';

  @override
  String get connectLater => 'اربطها لاحقًا';

  @override
  String get oauthDenied =>
      'تمّ إلغاء الإذن. يمكنك المحاولة مرّة أخرى وقتما تشاء.';

  @override
  String get connectFailed =>
      'تعذّر ربط صفحتك. أعد المحاولة، أو اربطها لاحقًا.';

  @override
  String get connectNothingNew =>
      'لم يتم ربط أي صفحة جديدة. تأكّد من اختيار صفحة عندما يُطلب منك ذلك، ثم أعد المحاولة.';

  @override
  String get connectLinkFailed =>
      'تم ربط الصفحة، لكنها لم تُربط بوكيلك بعد. يمكنك ربطها من إعدادات الوكيل.';

  @override
  String get tutorialReadyTitle => 'وكيلك متصل الآن';

  @override
  String get tutorialReadySubtitle =>
      'هو يردّ فعلًا على رسائل صفحتك، بالاعتماد على كتالوجك وأسعارك. أضف منتجات أخرى وقتما تشاء.';

  @override
  String get tutorialReadyTitlePending => 'أوشكت على الانتهاء';

  @override
  String get tutorialReadySubtitlePending =>
      'كتالوجك ووكيلك جاهزان. لم يبقَ سوى ربط صفحتك — سيبدأ وكيلك بالردّ فور ربطها.';

  @override
  String get tutorialReadySubmit => 'افتح التطبيق';

  @override
  String get tutorialReadyModeSimple => 'بسيط — المنتجات والفئات والطلبات';

  @override
  String get tutorialReadyModeAdvanced => 'متقدم — المجموعة الكاملة';

  @override
  String get homeGreetingMorning => 'صباح الخير';

  @override
  String get homeGreetingAfternoon => 'طاب يومك';

  @override
  String get homeGreetingEvening => 'مساء الخير';

  @override
  String get homeSnapshot => 'إليك لمحة سريعة';

  @override
  String get homeQueue => 'بانتظار تدخّلك';

  @override
  String get homeQueueStuck => 'توقّف الذكاء الاصطناعي';

  @override
  String get homeQueueEmpty =>
      'لا شيء في الانتظار. الوكيل يتولّى كل المحادثات.';

  @override
  String get homeQueueNoPage =>
      'لا توجد صفحة مربوطة، لذا لا يمكن لأي محادثة أن تصلك بعد.';

  @override
  String homeQueueMore(int count) {
    return '+ $count أخرى';
  }

  @override
  String homeAgeMinutes(int count) {
    return '$count دقيقة';
  }

  @override
  String homeAgeHours(int count) {
    return '$count ساعة';
  }

  @override
  String homeAgeDays(int count) {
    return '$count يوم';
  }

  @override
  String get homeNoPageTitle => 'لا توجد صفحة مربوطة';

  @override
  String get homeNoPageBody =>
      'ليس لوكيلك مكان يردّ فيه بعد. اربط صفحتك على فيسبوك أو إنستغرام ليبدأ العمل من أول رسالة.';

  @override
  String get homeOverview => 'لمحة';

  @override
  String get homeKpiPages => 'الصفحات المربوطة';

  @override
  String get homeKpiProducts => 'المنتجات';

  @override
  String homeKpiLowStock(int count) {
    return '$count مخزون منخفض';
  }

  @override
  String get homeKpiRevenue => 'رقم الأعمال (٣٠ يومًا)';

  @override
  String homeKpiSales(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مبيعة',
      many: '$count مبيعة',
      few: '$count مبيعات',
      two: 'بيعتان',
      one: 'بيعة واحدة',
      zero: 'لا مبيعات',
    );
    return '$_temp0';
  }

  @override
  String get homeKpiStockValue => 'قيمة المخزون';

  @override
  String get homeQuickActions => 'إجراءات سريعة';

  @override
  String get homeActionConnectTitle => 'اربط صفحة';

  @override
  String get homeActionConnectBody => 'اربط صفحتك على فيسبوك';

  @override
  String get homeActionProductsTitle => 'أضف منتجات';

  @override
  String get homeActionProductsBody => 'كوّن كتالوجك';

  @override
  String get homeActionAgentsTitle => 'وكلاء الذكاء الاصطناعي';

  @override
  String get homeActionAgentsBody => 'أدِر مساعديك';

  @override
  String get homeYourPages => 'صفحاتك';

  @override
  String get homeManageAll => 'إدارة الكل ←';

  @override
  String get homePagesEmpty => 'لا توجد صفحة مربوطة حتى الآن.';

  @override
  String get homePageActive => 'نشطة';

  @override
  String get homePageInactive => 'متوقفة';

  @override
  String homePageConnectedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'مربوطة في $dateString';
  }

  @override
  String get platformFacebook => 'فيسبوك';

  @override
  String get platformInstagram => 'إنستغرام';

  @override
  String get homeGetStarted => 'ابدأ';

  @override
  String get homeStepConnectTitle => 'اربط صفحة';

  @override
  String get homeStepConnectBody => 'اربط فيسبوك لتبدأ المحادثات';

  @override
  String get homeStepProductsTitle => 'أضف منتجات';

  @override
  String get homeStepProductsBody => 'كوّن كتالوجك';

  @override
  String get homeStepAgentTitle => 'اضبط وكيلك الذكي';

  @override
  String get homeStepAgentBody => 'خصّص النبرة والسلوك';

  @override
  String get homeStepSaleTitle => 'حقّق أول بيعة';

  @override
  String get homeStepSaleBody => 'شاهد الذكاء الاصطناعي يتولّى الطلبات';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navQueue => 'القائمة';

  @override
  String get navInbox => 'الرسائل';

  @override
  String get navStock => 'المخزون';

  @override
  String get navOrders => 'الطلبات';

  @override
  String get commonNotBuilt => 'غير متاح بعد';

  @override
  String get agentsTitle => 'وكلاء الذكاء الاصطناعي';

  @override
  String get agentsSubtitle =>
      'أنشئ وأدر وكلاء ذكيين يبيعون منتجاتك على الصفحات المرتبطة';

  @override
  String get agentsActive => 'الذكاء الاصطناعي نشط';

  @override
  String get agentsInactive => 'الذكاء الاصطناعي متوقف';

  @override
  String get agentsStatPages => 'الصفحات';

  @override
  String get agentsStatProducts => 'المنتجات';

  @override
  String get agentsStatModel => 'النموذج';

  @override
  String get agentsAllProducts => 'الكل';

  @override
  String get agentsNoPages => 'لا يرد على أي صفحة بعد';

  @override
  String get agentsPause => 'إيقاف الوكيل مؤقتًا';

  @override
  String get agentsResume => 'إعادة تشغيل الوكيل';

  @override
  String get agentsPausedToast => 'تم إيقاف الوكيل — لم يعد يرد';

  @override
  String get agentsResumedToast => 'الوكيل نشط — يرد من جديد';

  @override
  String get agentsEmptyTitle => 'لا يوجد وكيل';

  @override
  String get agentsEmptyBody =>
      'أنشئ وكيلا ذكيا للرد تلقائيا على الرسائل في صفحاتك وبيع منتجاتك.';

  @override
  String get agentsEmptyCta => 'أنشئ وكيلك';

  @override
  String get agentsActionInsights => 'مشاكل للمراجعة';

  @override
  String get agentsActionTest => 'اختبار الوكيل';

  @override
  String get agentsActionDetails => 'التفاصيل والإحصائيات';

  @override
  String get agentsActionDelete => 'حذف الوكيل';

  @override
  String get agentsDeleteTitle => 'حذف الوكيل؟';

  @override
  String agentsDeleteBody(String name) {
    return 'سيتم حذف $name ولن يرد بعد الآن على صفحاتك. يمكنك إنشاء وكيل جديد بعد ذلك.';
  }

  @override
  String get agentsDeleteConfirm => 'حذف';

  @override
  String get agentsDeletedToast => 'تم حذف الوكيل';

  @override
  String get agentsInsightsTitle => 'مشاكل معلّقة';

  @override
  String get agentsInsightsEmpty =>
      'لا توجد مشاكل معلّقة — وكيلك يتولى كل شيء.';

  @override
  String get agentsInsightsNone => 'لا يوجد شيء هنا.';

  @override
  String get agentsInsightUnclear => 'غير واضح';

  @override
  String get agentsInsightUnknown => 'موضوع غير معروف';

  @override
  String get agentsInsightHandoff => 'مُحوّل إليك';

  @override
  String get agentsInsightCustomer => 'العميل';

  @override
  String get agentsInsightAgent => 'رد الذكاء الاصطناعي';

  @override
  String get agentsInsightResolve => 'حل';

  @override
  String get agentsInsightDismiss => 'تجاهل';

  @override
  String get agentsInsightAddAndResolve => 'إضافة وحل';

  @override
  String get agentsInsightInstructionHint =>
      'أضف تعليمة ليتعامل الوكيل مع هذه الحالة بشكل أفضل في المرة القادمة…';

  @override
  String get agentsInsightResolved => 'تم الحل';

  @override
  String get agentsInsightDismissed => 'تم التجاهل';

  @override
  String get agentsInsightPending => 'معلّقة';

  @override
  String get agentsInsightFailed => 'تعذّر تحديث المشكلة.';

  @override
  String agentsTestTitle(String name) {
    return 'اختبار — $name';
  }

  @override
  String get agentsTestEmpty => 'أرسل رسالة للاختبار';

  @override
  String get agentsTestNote =>
      'تجربة فقط: لا يُستهلك أي رصيد ولا تُنشأ أي طلبات.';

  @override
  String get agentsTestPlaceholder => 'اكتب رسالة…';

  @override
  String get agentsTestSend => 'إرسال';

  @override
  String get agentsTestFailed => 'لا يوجد رد — أعد المحاولة.';

  @override
  String get agentsDetailsConversations => 'المحادثات';

  @override
  String agentsDetailsConversationsFoot(int received, int sent) {
    return '$received مستلمة · $sent مرسلة';
  }

  @override
  String get agentsDetailsMessages => 'الرسائل';

  @override
  String agentsDetailsLastActive(String date) {
    return 'آخر نشاط: $date';
  }

  @override
  String get agentsDetailsNoActivity => 'لا يوجد نشاط بعد';

  @override
  String get agentsDetailsOrders => 'الطلبات المُنشأة';

  @override
  String agentsDetailsResolvedFoot(int count) {
    return '$count تم حلها';
  }

  @override
  String get agentsDetailsInsights => 'ملاحظات الوكيل';

  @override
  String get agentsDetailsAll => 'الكل';

  @override
  String get agentsDetailsInstructions => 'تعليمات مخصصة';

  @override
  String get agentsDetailsNoInstructions => 'لا توجد تعليمات بعد.';

  @override
  String get agentsDetailsEdit => 'تعديل';

  @override
  String get agentsDetailsSave => 'حفظ';

  @override
  String get agentsDetailsSaved => 'تم حفظ التعليمات';

  @override
  String get agentsDetailsSavedMerged =>
      'تم حفظ التعليمات — مع الإبقاء على الأسطر المضافة من الويب';

  @override
  String get agentsDetailsConflictTitle => 'عُدّلت على الويب';

  @override
  String get agentsDetailsConflictBody =>
      'عُدّلت هذه التعليمات أثناء كتابتك. النسخة الحالية:';

  @override
  String get agentsDetailsUseLatest => 'اعتماد هذه النسخة';

  @override
  String get agentsDetailsKeepMine => 'استبدالها بنسختي';

  @override
  String get agentsNotFound => 'الوكيل غير موجود.';

  @override
  String agentsTestEmptyFor(String name) {
    return 'أرسل رسالة لاختبار $name';
  }

  @override
  String get agentsTestProduct => 'منتج';

  @override
  String agentsTestProductId(String id) {
    return 'المعرّف: $id…';
  }

  @override
  String get agentsPresetsTitle => 'ابدأ بوكيل جاهز';

  @override
  String get agentsPresetsBody =>
      'كل واحد مهيّأ للبيع في الجزائر — الدارجة والعربية والفرنسية، تسعير التوصيل وإدارة الطلبات. اختر واحدًا ثم عدّل ما تشاء.';

  @override
  String get agentsPresetVisionVoice => 'رؤية + صوت';

  @override
  String get agentsPresetVoice => 'صوت';

  @override
  String get agentsPresetCloserTagline => 'يحوّل المحادثات إلى طلبات مؤكدة';

  @override
  String get agentsPresetCloser1 => 'يرافق العميل من السؤال إلى الطلب المؤكد';

  @override
  String get agentsPresetCloser2 =>
      'يسعّر التوصيل حسب الولاية ويُغلق بالمبلغ الإجمالي';

  @override
  String get agentsPresetCloser3 => 'يفهم الصور والرسائل الصوتية';

  @override
  String get agentsPresetSupportTagline => 'يردّ بسرعة ويحوّل المشاكل إليك';

  @override
  String get agentsPresetSupport1 => 'يجيب بلطف عن أسئلة المنتجات والطلبات';

  @override
  String get agentsPresetSupport2 => 'يحوّل الشكاوى والاسترجاعات إلى إنسان';

  @override
  String get agentsPresetSupport3 => 'هادئ ودقيق ومباشر';

  @override
  String get agentsPresetAdvisorTagline =>
      'يساعد العميل على اختيار المنتج المناسب';

  @override
  String get agentsPresetAdvisor1 => 'يقارن الخيارات ويشرح الفروق';

  @override
  String get agentsPresetAdvisor2 => 'يجد المنتج انطلاقًا من صورة العميل';

  @override
  String get agentsPresetAdvisor3 =>
      'مثالي للكتالوجات ذات المتغيرات والمواصفات';

  @override
  String get agentsPresetExpressTagline => 'ردود فائقة السرعة للحجم الكبير';

  @override
  String get agentsPresetExpress1 => 'ردود قصيرة وسريعة للصفحات المزدحمة';

  @override
  String get agentsPresetExpress2 => 'أقل استهلاك للأرصدة — نص وصوت فقط';

  @override
  String get agentsPresetExpress3 => 'ينشئ الطلبات ويلغيها أيضًا';

  @override
  String get agentsPresetUse => 'استخدم هذا الوكيل  ←';

  @override
  String get agentsPresetOwn => 'تفضّل إنشاء وكيلك؟';

  @override
  String get agentsPresetScratch => 'ابدأ من الصفر';

  @override
  String get agentsCreatedToast => 'تم إنشاء الوكيل';

  @override
  String get agentFormSubtitle =>
      'اضبط وكيلًا يردّ على محادثاتك. الاسم وحده إلزامي — ولكل ما تبقّى قيمة افتراضية.';

  @override
  String get agentFormBasics => 'المعلومات الأساسية';

  @override
  String get agentFormDescription => 'الوصف';

  @override
  String get agentFormDescriptionPlaceholder =>
      'صف باختصار ما يقوم به هذا الوكيل…';

  @override
  String get agentFormInstructions => 'تعليمات مخصصة';

  @override
  String get agentFormInstructionsPlaceholder =>
      'كيف يردّ، ما الذي يتجنّبه، وكيف يتعامل مع حالات معيّنة…';

  @override
  String get agentFormInstructionsHint =>
      'توجّه هذه التعليمات سلوك الوكيل في المحادثات.';

  @override
  String get agentFormAdvanced => 'إعدادات متقدمة';

  @override
  String get agentFormAdvancedHint => 'اختياري — تُطبَّق قيم افتراضية.';

  @override
  String get agentFormBehavior => 'السلوك';

  @override
  String get agentFormBehaviorSummary => 'الختام · التحويل إلى إنسان';

  @override
  String get agentFormClosing => 'ختام المحادثة';

  @override
  String get agentFormClosingPlaceholder =>
      'أمثلة:\n• بعد الطلب: «شكرًا! طلبك في الطريق.»\n• الزبون يودّع: «شكرًا، نراك قريبًا!»\n• زبون غاضب: «عذرًا، سأحوّلك إلى الفريق.»';

  @override
  String get agentFormClosingHint =>
      'متى وكيف ينهي الوكيل المحادثة. إن تُرك فارغًا: يشكر بعد الطلب ويردّ على التوديع.';

  @override
  String get agentFormHandoff => 'قواعد التدخّل البشري';

  @override
  String get agentFormHandoffPlaceholder =>
      'أمثلة:\n• استرداد أو إرجاع ← أوقف الذكاء الاصطناعي ونبّهني\n• طلب تخفيض ← اتركه لي\n• شكوى ← حوّل المحادثة إليّ';

  @override
  String get agentFormHandoffHint =>
      'متى يتوقف الوكيل ويسلّمك المحادثة. التحيات (slm، cava، hi) يتولاها الذكاء الاصطناعي دائمًا.';

  @override
  String get agentFormDisplay => 'عرض المنتجات';

  @override
  String get agentFormDisplayDefault => 'النمط الافتراضي';

  @override
  String get agentFormDisplayCustom => 'مخصّص';

  @override
  String get agentFormDisplayHint =>
      'كيف يعرض الوكيل المنتج. المس وسمًا لإدراجه — ويملأ الوكيل البيانات الحقيقية.';

  @override
  String get agentFormTemplate => 'القالب';

  @override
  String get agentFormTemplatePlaceholder => 'المس الوسوم أعلاه أو اكتب هنا…';

  @override
  String get agentFormTagCard => 'بطاقة المنتج';

  @override
  String get agentFormTagName => 'الاسم';

  @override
  String get agentFormTagPrice => 'السعر (دج)';

  @override
  String get agentFormTagDescription => 'الوصف';

  @override
  String get agentFormTagStock => 'المخزون';

  @override
  String get agentFormTagNewLine => '↵ سطر جديد';

  @override
  String get agentFormPreview => 'معاينة';

  @override
  String get agentFormPreviewLive => 'معاينة مباشرة';

  @override
  String get agentFormPreviewCustomer => 'أرني منتجاتك';

  @override
  String get agentFormPreviewDefault =>
      'إليك ما لدينا!\n[PRODUCT_CARD]\nهل تريد الطلب؟';

  @override
  String get agentFormPreviewSampleName => 'منتج تجريبي';

  @override
  String get agentFormPreviewSampleDescription => 'منتج رائع';

  @override
  String get agentFormModel => 'نموذج الذكاء الاصطناعي';

  @override
  String agentFormModelSummary(String model, String temperature, int tokens) {
    return '$model · $temperature · $tokens رمزًا';
  }

  @override
  String get agentFormModelPicker => 'النموذج';

  @override
  String agentFormModelCost(String usd) {
    return '≈ $usd / 1000 رسالة';
  }

  @override
  String get agentFormModelsLoading => 'جارٍ تحميل النماذج المتاحة…';

  @override
  String get agentFormModelsUnavailable =>
      'نماذج الذكاء الاصطناعي غير متاحة مؤقتًا. أعد المحاولة لاحقًا.';

  @override
  String get agentFormTraitBestQuality => 'أفضل جودة';

  @override
  String get agentFormTraitFastAffordable => 'سريع وبسعر مناسب';

  @override
  String get agentFormTraitLongContext128k => 'سياق 128k';

  @override
  String get agentFormTraitLegacyFast => 'قديم، سريع';

  @override
  String get agentFormTraitBestBalanced => 'الأكثر توازنًا';

  @override
  String get agentFormTraitFastCheap => 'سريع واقتصادي';

  @override
  String get agentFormTraitMostCapable => 'الأقوى';

  @override
  String get agentFormTraitLatestFast => 'الأحدث، سريع';

  @override
  String get agentFormTraitLongContext1m => 'سياق 1M';

  @override
  String get agentFormTraitBestOpenSource => 'أفضل نموذج مفتوح المصدر';

  @override
  String get agentFormTraitUltraFast => 'فائق السرعة';

  @override
  String get agentFormTraitMixtureOfExperts => 'MoE، سياق 32k';

  @override
  String get agentFormTraitReasoning => 'نموذج استدلال';

  @override
  String get agentFormTemperature => 'درجة الإبداع';

  @override
  String get agentFormPrecise => 'دقيق';

  @override
  String get agentFormCreative => 'مبدع';

  @override
  String get agentFormMaxTokens => 'الحد الأقصى للرموز';

  @override
  String get agentFormMaxTokensHint => 'أقصى طول للرد · 100 – 4096';

  @override
  String get agentFormImages => 'التعرّف على الصور';

  @override
  String get agentFormImagesHint =>
      'يرى الذكاء الاصطناعي صور الزبائن ويقارنها بمنتجاتك. 5 أرصدة لكل صورة (1 للنص).';

  @override
  String get agentFormVoice => 'الرسائل الصوتية';

  @override
  String get agentFormVoiceHint =>
      'يستمع الذكاء الاصطناعي إلى الرسائل الصوتية ويكتبها (عربية، فرنسية، إنجليزية، دارجة). 3 أرصدة لكل رسالة. عند الإيقاف: يطلب الوكيل رسالة مكتوبة.';

  @override
  String get agentFormDelay => 'مهلة الرد';

  @override
  String agentFormDelayValue(int seconds) {
    return '$seconds ث';
  }

  @override
  String get agentFormDelayMax => '10 ث';

  @override
  String get agentFormDelayHint =>
      'ينتظر رسائل أخرى قبل الرد — كثيرًا ما يرسل الزبائن عدة رسائل قصيرة، فيجمعها الوكيل.';

  @override
  String get agentFormPages => 'الصفحات المتصلة';

  @override
  String get agentFormPagesHint =>
      'الصفحات التي يردّ عليها هذا الوكيل. لكل صفحة وكيل واحد فقط.';

  @override
  String agentFormPagesSummary(int selected, int total) {
    return '$selected من $total محددة';
  }

  @override
  String agentFormPagesCount(int selected, int total) {
    return '$selected من $total';
  }

  @override
  String get agentFormPagesNone => 'لا توجد صفحات متصلة';

  @override
  String get agentFormPagesEmpty =>
      'لا توجد صفحات متصلة بعد. اربط صفحة فيسبوك أو إنستغرام أولًا، ثم اربطها بهذا الوكيل.';

  @override
  String agentFormPageTaken(String agent) {
    return 'مرتبطة بـ $agent';
  }

  @override
  String get agentFormPageActive => 'نشطة';

  @override
  String get agentFormPageInactive => 'غير نشطة';

  @override
  String get agentFormSelectAll => 'تحديد الكل';

  @override
  String get agentFormClear => 'مسح';

  @override
  String get agentFormProducts => 'المنتجات';

  @override
  String get agentFormSellAll => 'بيع كل الكتالوج';

  @override
  String get agentFormSellAllHint =>
      'يعرف الوكيل كل منتجاتك. أوقف الخيار لتختار.';

  @override
  String get agentFormProductsAll => 'كل الكتالوج';

  @override
  String agentFormProductsChosen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منتجات مختارة',
      two: 'منتجان مختاران',
      one: 'منتج واحد مختار',
      zero: 'لم يُختر أي منتج',
    );
    return '$_temp0';
  }

  @override
  String get agentFormProductSearch => 'بحث';

  @override
  String get agentFormProductSearchPlaceholder => 'ابحث عن منتجات…';

  @override
  String get agentFormProductsNone => 'لا توجد منتجات متاحة';

  @override
  String get agentFormProductsNoMatch => 'لا توجد منتجات تطابق بحثك';

  @override
  String get agentFormEditTitle => 'تعديل الوكيل';

  @override
  String get agentFormEditSubtitle =>
      'حدّث إعدادات وكيل الذكاء الاصطناعي. تُطبَّق التغييرات على الرسائل القادمة.';

  @override
  String get agentFormEditAdvancedHint => 'المس قسمًا لتعديله.';

  @override
  String get agentFormActive => 'الوكيل نشط';

  @override
  String get agentFormActiveHint => 'يردّ على رسائل صفحاته ما دام نشطًا.';

  @override
  String get agentFormSave => 'حفظ التغييرات';

  @override
  String get agentFormSavedToast => 'تم تحديث الوكيل';

  @override
  String get agentFormSavedMergedToast =>
      'تم تحديث الوكيل — مع الإبقاء على التعليمات المضافة من الويب';

  @override
  String get agentFormLeaveTitle => 'المغادرة دون حفظ؟';

  @override
  String agentFormLeaveBody(String name) {
    return 'ستفقد تعديلاتك على $name.';
  }

  @override
  String get productFormLeaveBody => 'سيُفقد المنتج الذي بدأته.';

  @override
  String get conversationLeaveBody => 'سيُفقد ردك غير المرسل.';

  @override
  String get agentDetailsLeaveBody => 'ستُفقد تعديلاتك على التعليمات.';

  @override
  String get agentGenerateLeaveBody => 'سيتم تجاهل الوكيل المُنشأ.';

  @override
  String get tutorialAgentLeaveBody => 'سيُفقد الوكيل الذي بدأته.';

  @override
  String get checkoutLeaveTitle => 'مغادرة صفحة الدفع؟';

  @override
  String get checkoutLeaveBody => 'لم يكتمل الدفع بعد.';

  @override
  String get agentFormKeepEditing => 'مواصلة التعديل';

  @override
  String get agentFormLeave => 'المغادرة دون حفظ';

  @override
  String get agentsDetailsEditAgent => 'تعديل الوكيل';

  @override
  String get pagesEyebrow => 'القنوات المتصلة';

  @override
  String get pagesTitle => 'الصفحات والبريد الوارد';

  @override
  String get pagesSubtitle =>
      'لكل صفحة متصلة بريد وارد ومخزون ووكيل ذكاء اصطناعي خاص بها.';

  @override
  String get pagesStatTotal => 'إجمالي الصفحات';

  @override
  String get pagesStatPlanLimit => 'حد الخطة';

  @override
  String get pagesFilterAll => 'جميع المنصات';

  @override
  String get pagesEmptyTitle => 'لا توجد صفحة مربوطة';

  @override
  String get pagesEmptyBody => 'اربط صفحاتك لتبدأ إدارتها بالذكاء الاصطناعي.';

  @override
  String pagesEmptyPlatformTitle(String platform) {
    return 'لا توجد صفحات $platform';
  }

  @override
  String pagesEmptyPlatformBody(String platform) {
    return 'اربط صفحات $platform لتبدأ.';
  }

  @override
  String get pagesDisconnectTitle => 'فصل الصفحة؟';

  @override
  String pagesDisconnectBody(String name) {
    return 'لن تصلك رسائل $name بعد الآن وسيتوقف وكيل الذكاء الاصطناعي عن الرد فيها.';
  }

  @override
  String get pagesDisconnectConfirm => 'فصل';

  @override
  String get pagesDisconnectedToast => 'تم فصل الصفحة';

  @override
  String get pageCardAiOn => 'الذكاء الاصطناعي مفعّل';

  @override
  String get pageCardAiOff => 'الذكاء الاصطناعي معطّل';

  @override
  String get pageCardStatConvos => 'محادثات';

  @override
  String get pageCardStatMsgs7d => 'رسائل 7 أيام';

  @override
  String get pageCardStatUnread => 'غير مقروءة';

  @override
  String get pageCardStatStock => 'المخزون';

  @override
  String pageCardStatActive(int n) {
    return '$n نشطة';
  }

  @override
  String pageCardStatIn(int n) {
    return '$n واردة';
  }

  @override
  String get pageCardStatNeedsReply => 'بانتظار الرد';

  @override
  String get pageCardStatProducts => 'منتجات';

  @override
  String get pageCardAgentReady => 'وكيل الذكاء الاصطناعي جاهز';

  @override
  String get pageCardAgentTailored => 'مخصص لبريد هذه الصفحة.';

  @override
  String get pageCardAgentNotReady => 'لا يوجد وكيل مخصص بعد';

  @override
  String get pageCardAgentNotReadyHint =>
      'ولّد واحدًا من المحادثات الأخيرة لهذه الصفحة.';

  @override
  String get pageCardAgentGenerate => 'توليد';

  @override
  String get pageCardAgentRegenerate => 'إعادة توليد';

  @override
  String get pageCardActionInbox => 'البريد';

  @override
  String get pageCardActionStock => 'المخزون';

  @override
  String get pageCardActionConfigure => 'إعداد';

  @override
  String get pageCardActionDisconnect => 'فصل';

  @override
  String get pageCardNoActivity => 'لا نشاط بعد';

  @override
  String get pageCardNow => 'الآن';

  @override
  String pageCardMinutesAgo(int n) {
    return 'منذ $n د';
  }

  @override
  String pageCardHoursAgo(int n) {
    return 'منذ $n س';
  }

  @override
  String pageCardDaysAgo(int n) {
    return 'منذ $n ي';
  }

  @override
  String get agentGenTitle => 'توليد وكيل ذكاء اصطناعي من البريد الوارد';

  @override
  String agentGenSubtitle(String pageName) {
    return 'سنقرأ المحادثات الأخيرة على $pageName ونصمم وكيلًا مخصصًا.';
  }

  @override
  String get agentGenWhatTitle => 'ماذا يفعل هذا';

  @override
  String get agentGenWhat1 =>
      'يقرأ ما يصل إلى 25 محادثة حديثة (لا نخزن أي نسخ جديدة)';

  @override
  String get agentGenWhat2 =>
      'يكتشف ما تبيعه واللغات المستخدمة وأكثر الأسئلة شيوعًا';

  @override
  String get agentGenWhat3 =>
      'يصيغ شخصية ونبرة وطول الردود وتعليمات مخصصة لنشاطك';

  @override
  String get agentGenWhat4 =>
      'تعاين وتعدّل وتطبق — لا شيء يتغير حتى تضغط تطبيق';

  @override
  String get agentGenStart => 'قراءة البريد وتوليد';

  @override
  String get agentGenPhaseReading => 'قراءة المحادثات الأخيرة…';

  @override
  String get agentGenPhaseAnalyzing => 'فهم السياق — المنتجات واللغة والنبرة…';

  @override
  String get agentGenPhaseDrafting => 'صياغة وكيل الذكاء الاصطناعي المخصص لك…';

  @override
  String get agentGenPhaseSubhint => 'تستغرق هذه العملية عادة 10 إلى 30 ثانية.';

  @override
  String get agentGenStepRead => 'قراءة';

  @override
  String get agentGenStepAnalyze => 'تحليل';

  @override
  String get agentGenStepDraft => 'صياغة';

  @override
  String get agentGenSummary => 'ملخص النشاط';

  @override
  String agentGenSampled(int conversations, int messages) {
    return '$conversations محادثة · $messages رسالة';
  }

  @override
  String get agentGenLanguages => 'اللغات';

  @override
  String get agentGenTopQuestions => 'أهم الأسئلة';

  @override
  String get agentGenPersonality => 'الشخصية';

  @override
  String get agentGenTone => 'النبرة';

  @override
  String get agentGenLength => 'الطول';

  @override
  String get agentGenInstructions => 'التعليمات المخصصة';

  @override
  String get agentGenEditHint =>
      'عدّل قبل التطبيق. تُحفظ هذه التعليمات في إعدادات الذكاء الاصطناعي لهذه الصفحة.';

  @override
  String agentGenChars(int n) {
    return '$n حرفًا';
  }

  @override
  String get agentGenDiscard => 'تجاهل';

  @override
  String agentGenApply(String pageName) {
    return 'تطبيق على $pageName';
  }

  @override
  String get agentGenApplying => 'جاري تطبيق الإعدادات…';

  @override
  String agentGenCreated(String pageName) {
    return 'تم إنشاء وكيل الذكاء الاصطناعي وربطه بـ $pageName';
  }

  @override
  String agentGenUpdated(String pageName) {
    return 'تم تحديث وكيل الذكاء الاصطناعي لـ $pageName';
  }

  @override
  String get agentGenApplyFail => 'تعذر تطبيق الإعدادات';

  @override
  String get agentGenToneBalanced => 'متوازنة';

  @override
  String get agentGenToneFormal => 'رسمية';

  @override
  String get agentGenToneCasual => 'عفوية';

  @override
  String get agentGenToneEnthusiastic => 'متحمسة';

  @override
  String get agentGenLengthShort => 'قصيرة';

  @override
  String get agentGenLengthMedium => 'متوسطة';

  @override
  String get agentGenLengthDetailed => 'مفصّلة';

  @override
  String get agentsNewTitle => 'وكيل جديد';

  @override
  String get commonYes => 'نعم';

  @override
  String get commonNo => 'لا';

  @override
  String get menuCategories => 'الفئات';

  @override
  String get categoriesTitle => 'الفئات';

  @override
  String categoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فئة',
      few: '$count فئات',
      two: 'فئتان',
      one: 'فئة واحدة',
      zero: 'لا توجد فئات',
    );
    return '$_temp0';
  }

  @override
  String get categoriesSearchPlaceholder => 'ابحث في الفئات...';

  @override
  String get categoriesFilters => 'عوامل التصفية';

  @override
  String categoriesFiltersActive(int count) {
    return 'عوامل التصفية · $count';
  }

  @override
  String get categoriesSection => 'كل الفئات';

  @override
  String categoriesProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منتج',
      few: '$count منتجات',
      two: 'منتجان',
      one: 'منتج واحد',
      zero: '0 منتج',
    );
    return '$_temp0';
  }

  @override
  String get categoriesEmptyTitle => 'لا توجد فئات';

  @override
  String get categoriesEmptyBody => 'أنشئ فئات لتنظيم منتجاتك';

  @override
  String get categoriesNoMatchBody =>
      'لا توجد فئة تطابق البحث أو عوامل التصفية.';

  @override
  String get categoriesFilterMin => 'المنتجات · الحد الأدنى';

  @override
  String get categoriesFilterMax => 'المنتجات · الحد الأقصى';

  @override
  String get categoriesFilterRangeInvalid => 'يجب ألا يقل عن الحد الأدنى';

  @override
  String get categoriesFilterHasDescription => 'لها وصف';

  @override
  String categoriesFilterColorsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ألوان محددة',
      one: 'لون واحد محدد',
    );
    return '$_temp0';
  }

  @override
  String get categoriesFilterApply => 'تطبيق عوامل التصفية';

  @override
  String get categoriesFilterClear => 'مسح الكل';

  @override
  String get categoryAddTitle => 'إضافة فئة';

  @override
  String get categoryEditTitle => 'تعديل الفئة';

  @override
  String get categoryName => 'الاسم';

  @override
  String get categoryNamePlaceholder => 'مثال: إلكترونيات';

  @override
  String get categoryDescriptionPlaceholder => 'وصف اختياري';

  @override
  String get categoryColor => 'اللون';

  @override
  String get categoryColorCustom => 'لون مخصص';

  @override
  String get categoryColorHex => 'الرمز السداسي';

  @override
  String get categoryColorInvalid => 'ستة رموز سداسية، مثال EC4899';

  @override
  String get categoryColorApply => 'استخدام هذا اللون';

  @override
  String get categoryCreate => 'إضافة الفئة';

  @override
  String get categoryUpdate => 'تحديث الفئة';

  @override
  String get categoryNameTooShort => 'حرفان على الأقل';

  @override
  String get categoryNameTaken => 'لديك فئة بهذا الاسم مسبقًا';

  @override
  String get categoryAdded => 'تمت إضافة الفئة';

  @override
  String get categoryUpdated => 'تم تحديث الفئة';

  @override
  String get categoryDeleted => 'تم حذف الفئة';

  @override
  String get categoryDeleteTitle => 'حذف الفئة';

  @override
  String categoryDeleteBody(String name) {
    return 'هل تريد فعلاً حذف $name؟';
  }

  @override
  String categoryDeleteNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تحتوي هذه الفئة على $count منتج.',
      few: 'تحتوي هذه الفئة على $count منتجات.',
      two: 'تحتوي هذه الفئة على منتجين.',
      one: 'تحتوي هذه الفئة على منتج واحد.',
    );
    return '$_temp0';
  }

  @override
  String get categoryDeleteNoticeBody => 'ستصبح بلا فئة.';

  @override
  String get menuClients => 'العملاء';

  @override
  String get clientsEyebrow => 'المبيعات';

  @override
  String get clientsTitle => 'العملاء';

  @override
  String get clientsSubtitle =>
      'العملاء المحفوظون من محادثات الذكاء الاصطناعي والطلبات المؤكدة';

  @override
  String get clientsStatTotal => 'إجمالي العملاء';

  @override
  String get clientsStatActive => 'النشطون';

  @override
  String get clientsStatWithOrders => 'لديهم طلبات';

  @override
  String get clientsStatTotalSpent => 'إجمالي الإنفاق';

  @override
  String get clientsSearchName => 'ابحث بالاسم أو البريد الإلكتروني...';

  @override
  String get clientsSearchPhone => 'ابحث بالهاتف...';

  @override
  String get clientsSection => 'كل العملاء';

  @override
  String get clientsSourceAi => 'دردشة الذكاء';

  @override
  String get clientsSourceManual => 'يدوي';

  @override
  String clientsOrderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلب',
      few: '$count طلبات',
      two: 'طلبان',
      one: 'طلب واحد',
      zero: '0 طلب',
    );
    return '$_temp0';
  }

  @override
  String clientsConversationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count محادثة',
      few: '$count محادثات',
      two: 'محادثتان',
      one: 'محادثة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get clientsEmptyTitle => 'لا يوجد عملاء';

  @override
  String get clientsEmptyBody =>
      'يظهر العملاء هنا تلقائيًا عندما يؤكد روبوت الذكاء الاصطناعي طلبًا، أو أضفهم يدويًا.';

  @override
  String get clientsNoMatchBody => 'لا يوجد عميل يطابق البحث أو عوامل التصفية.';

  @override
  String get clientsFilterStatus => 'الحالة';

  @override
  String get clientsFilterActive => 'النشطون';

  @override
  String get clientsFilterInactive => 'غير النشطين';

  @override
  String get clientsFilterSource => 'المصدر';

  @override
  String get clientsFilterOrdersMin => 'الطلبات · الحد الأدنى';

  @override
  String get clientsFilterOrdersMax => 'الطلبات · الحد الأقصى';

  @override
  String get clientsFilterSpentMin => 'الإنفاق (دج) · الحد الأدنى';

  @override
  String get clientsFilterSpentMax => 'الإنفاق (دج) · الحد الأقصى';

  @override
  String get dateFrom => 'من تاريخ';

  @override
  String get dateTo => 'إلى تاريخ';

  @override
  String get dateClear => 'مسح التاريخ';

  @override
  String get datePickerToday => 'اليوم';

  @override
  String get clientAddTitle => 'إضافة عميل';

  @override
  String get clientEditTitle => 'تعديل العميل';

  @override
  String get clientCreate => 'إضافة العميل';

  @override
  String get clientUpdate => 'تحديث العميل';

  @override
  String get clientNamePlaceholder => 'اسم العميل';

  @override
  String get clientPhone => 'الهاتف';

  @override
  String get clientAddress => 'العنوان';

  @override
  String get clientAddressPlaceholder => 'عنوان العميل';

  @override
  String get clientNotes => 'ملاحظات';

  @override
  String get clientNotesPlaceholder => 'ملاحظات اختيارية';

  @override
  String get clientErrNoLetters => 'يجب أن يحتوي على حرف أو رقم واحد على الأقل';

  @override
  String get clientErrPhone =>
      'يجب أن يتكون الهاتف من 8 إلى 15 رقمًا (مثال 0555 12 34 56)';

  @override
  String clientErrPhoneTaken(String name) {
    return 'يوجد عميل بهذا الهاتف مسبقًا ($name)';
  }

  @override
  String get clientAdded => 'تمت إضافة العميل';

  @override
  String get clientUpdated => 'تم تحديث العميل';

  @override
  String get clientDeleted => 'تم حذف العميل';

  @override
  String get clientDeleteTitle => 'حذف العميل';

  @override
  String clientDeleteBody(String name) {
    return 'هل تريد فعلاً حذف $name؟';
  }

  @override
  String clientDeleteNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'لهذا العميل $count طلبًا مرتبطًا.',
      few: 'لهذا العميل $count طلبات مرتبطة.',
      two: 'لهذا العميل طلبان مرتبطان.',
      one: 'لهذا العميل طلب واحد مرتبط.',
    );
    return '$_temp0';
  }

  @override
  String get clientDetailEyebrow => 'تفاصيل العميل';

  @override
  String get clientDetailTotalOrders => 'إجمالي الطلبات';

  @override
  String get clientDetailLastOrder => 'آخر طلب';

  @override
  String get clientDetailMetrics => 'مقاييس محادثات الذكاء الاصطناعي';

  @override
  String get clientDetailConversations => 'المحادثات';

  @override
  String get clientDetailMessages => 'الرسائل';

  @override
  String get clientDetailAiResponses => 'ردود الذكاء الاصطناعي';

  @override
  String get clientDetailClientMessages => 'رسائل العميل';

  @override
  String get clientDetailLastMessage => 'آخر رسالة';

  @override
  String get clientDetailHistory => 'سجل المحادثات';

  @override
  String get clientDetailMsgs => 'رسائل';

  @override
  String get clientDetailFromAi => 'الذكاء:';

  @override
  String get clientDetailFromClient => 'العميل:';

  @override
  String get clientViewOrders => 'عرض الطلبات';

  @override
  String get clientOrdersSoon => 'الطلبات غير متاحة على الهاتف بعد';

  @override
  String get menuSuppliers => 'الموردون';

  @override
  String get suppliersEyebrow => 'المشتريات';

  @override
  String get suppliersTitle => 'الموردون';

  @override
  String suppliersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count موردًا',
      few: '$count موردين',
      two: 'موردان',
      one: 'مورد واحد',
      zero: 'لا يوجد موردون',
    );
    return '$_temp0';
  }

  @override
  String get suppliersStatTotal => 'إجمالي الموردين';

  @override
  String get suppliersStatWithPurchases => 'لديهم مشتريات';

  @override
  String get suppliersSearch => 'ابحث في الموردين...';

  @override
  String get suppliersSection => 'كل الموردين';

  @override
  String suppliersPurchaseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عملية شراء',
      few: '$count عمليات شراء',
      two: 'عمليتا شراء',
      one: 'عملية شراء واحدة',
      zero: '0 مشتريات',
    );
    return '$_temp0';
  }

  @override
  String get suppliersEmptyTitle => 'لا يوجد موردون';

  @override
  String get suppliersEmptyBody => 'أضف موردين لإدارة مشترياتك';

  @override
  String get suppliersNoMatchBody =>
      'لا يوجد مورد يطابق البحث أو عوامل التصفية.';

  @override
  String get suppliersFilterPurchasesMin => 'المشتريات · الحد الأدنى';

  @override
  String get suppliersFilterPurchasesMax => 'المشتريات · الحد الأقصى';

  @override
  String get supplierActive => 'نشط';

  @override
  String get supplierInactive => 'غير نشط';

  @override
  String get supplierAddTitle => 'إضافة مورد';

  @override
  String get supplierEditTitle => 'تعديل المورد';

  @override
  String get supplierCreate => 'إضافة المورد';

  @override
  String get supplierUpdate => 'تحديث المورد';

  @override
  String get supplierNamePlaceholder => 'اسم المورد';

  @override
  String get supplierAddressPlaceholder => 'عنوان المورد';

  @override
  String get supplierErrNameTaken => 'لديك مورد بهذا الاسم مسبقًا';

  @override
  String get supplierAdded => 'تمت إضافة المورد';

  @override
  String get supplierUpdated => 'تم تحديث المورد';

  @override
  String get supplierDeleted => 'تم حذف المورد';

  @override
  String get supplierDeleteTitle => 'حذف المورد';

  @override
  String supplierDeleteBody(String name) {
    return 'هل تريد فعلاً حذف $name؟';
  }

  @override
  String supplierDeleteNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'لهذا المورد $count عملية شراء مرتبطة.',
      few: 'لهذا المورد $count عمليات شراء مرتبطة.',
      two: 'لهذا المورد عمليتا شراء مرتبطتان.',
      one: 'لهذا المورد عملية شراء واحدة مرتبطة.',
    );
    return '$_temp0';
  }

  @override
  String get supplierDetailEyebrow => 'تفاصيل المورد';

  @override
  String get supplierDetailPurchases => 'المشتريات';

  @override
  String get supplierDetailMemberSince => 'عضو منذ';

  @override
  String get supplierViewPurchases => 'عرض المشتريات';

  @override
  String get supplierPurchasesSoon => 'المشتريات غير متاحة على الهاتف بعد';

  @override
  String get supplierNotFound => 'هذا المورد لم يعد موجودًا.';

  @override
  String get ordersEyebrow => 'المبيعات';

  @override
  String get ordersTitle => 'الطلبات';

  @override
  String ordersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلب',
      few: '$count طلبات',
      two: 'طلبان',
      one: 'طلب واحد',
      zero: 'لا توجد طلبات',
    );
    return '$_temp0';
  }

  @override
  String get ordersStatTotal => 'إجمالي الطلبات';

  @override
  String get ordersStatPending => 'قيد الانتظار';

  @override
  String get ordersStatDelivered => 'تم التسليم';

  @override
  String get ordersStatValue => 'القيمة الإجمالية';

  @override
  String get ordersSearch => 'ابحث برقم الطلب، العميل، الهاتف، المنتج...';

  @override
  String get ordersSection => 'كل الطلبات';

  @override
  String get ordersSelectAll => 'تحديد الكل';

  @override
  String get ordersNew => 'طلب جديد';

  @override
  String get ordersEmptyTitle => 'لا توجد طلبات بعد';

  @override
  String get ordersEmptyBody =>
      'تصل الطلبات من تأكيدات روبوت الدردشة الذكي، أو أنشئها يدويًا.';

  @override
  String get ordersNoMatchBody => 'لا توجد طلبات تطابق بحثك أو عوامل التصفية.';

  @override
  String get orderStatusAll => 'الكل';

  @override
  String get orderStatusPending => 'جديد';

  @override
  String get orderStatusConfirmed => 'مؤكدة';

  @override
  String get orderStatusPreparing => 'قيد التحضير';

  @override
  String get orderStatusShipped => 'مُرسلة';

  @override
  String get orderStatusDelivered => 'تم التسليم';

  @override
  String get orderStatusCancelled => 'ملغاة';

  @override
  String get orderStatusReturned => 'مرتجعة';

  @override
  String get orderConfirmNotCalled => 'لم يتم الاتصال';

  @override
  String get orderConfirmNoAnswer => 'لا يوجد رد';

  @override
  String get orderConfirmConfirmed => 'مؤكد';

  @override
  String get orderConfirmRejected => 'مرفوض';

  @override
  String orderConfirmWithCount(String label, int count) {
    return '$label ($count)';
  }

  @override
  String get orderSourceAi => 'ذكاء';

  @override
  String get orderSourceAiLong => 'روبوت الدردشة الذكي';

  @override
  String get orderSourceManual => 'يدوي';

  @override
  String get paymentStatusPaid => 'مدفوع';

  @override
  String get paymentStatusPending => 'قيد الانتظار';

  @override
  String get paymentStatusPartial => 'جزئي';

  @override
  String ordersRowItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عنصر',
      few: '$count عناصر',
      two: 'عنصران',
      one: 'عنصر واحد',
    );
    return '$_temp0';
  }

  @override
  String ordersRowMeta(String items, String paid, String remaining) {
    return '$items  ·  المدفوع $paid  ·  المتبقي $remaining';
  }

  @override
  String get ordersRowNoRemaining => '–';

  @override
  String get orderActionCallConfirm => 'اتصل وأكّد';

  @override
  String get orderActionRetry => 'أعد المحاولة';

  @override
  String get orderActionPrepare => 'ابدأ التحضير';

  @override
  String get orderActionMarkShipped => 'تحديد كمُرسلة';

  @override
  String get orderActionMarkDelivered => 'تحديد كمسلَّمة';

  @override
  String get orderActionOpen => 'فتح';

  @override
  String get orderActionMarkReturned => 'تحديد كمرتجع';

  @override
  String get orderActionDelete => 'حذف الطلب';

  @override
  String ordersSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلبًا محددًا',
      few: '$count طلبات محددة',
      two: 'طلبان محددان',
      one: 'طلب واحد محدد',
    );
    return '$_temp0';
  }

  @override
  String get ordersClearSelection => 'مسح';

  @override
  String get ordersBulkConfirm => 'تأكيد الكل';

  @override
  String get ordersBulkPrepare => 'تحضير الكل';

  @override
  String get ordersBulkShip => 'إرسال الكل';

  @override
  String get ordersBulkDeliver => 'تحديد الكل كمسلَّمة';

  @override
  String get ordersBulkReturn => 'تحديد الكل كمرتجع';

  @override
  String get ordersBulkCancel => 'إلغاء الكل';

  @override
  String get ordersBulkNone => 'لا يوجد إجراء جماعي متاح لهذا التحديد';

  @override
  String ordersBulkFailed(int failed, int total) {
    return 'تعذّر تحديث $failed من أصل $total طلبات';
  }

  @override
  String get ordersFilters => 'الفلاتر';

  @override
  String ordersFiltersActive(int count) {
    return 'الفلاتر · $count';
  }

  @override
  String get ordersFilterStatus => 'حالة الطلب';

  @override
  String get ordersFilterStatusAll => 'كل الحالات';

  @override
  String get ordersFilterConfirmation => 'التأكيد';

  @override
  String get ordersFilterPayment => 'حالة الدفع';

  @override
  String get ordersFilterAny => 'الكل';

  @override
  String get ordersFilterHasRemaining => 'يوجد رصيد متبقٍ';

  @override
  String get ordersFilterPaymentDisabled => 'معطّل — «الرصيد المتبقي» مفعّل';

  @override
  String get ordersFilterTotalMin => 'المبلغ الإجمالي (دج) · الأدنى';

  @override
  String get ordersFilterTotalMax => 'المبلغ الإجمالي (دج) · الأقصى';

  @override
  String get ordersFilterApply => 'تطبيق الفلاتر';

  @override
  String get ordersFilterClear => 'مسح الكل';

  @override
  String get orderEyebrow => 'الطلب';

  @override
  String get orderStepReview => 'المراجعة';

  @override
  String get orderStepCall => 'نتيجة الاتصال';

  @override
  String get orderStepResult => 'النتيجة';

  @override
  String orderCallsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اتصالًا',
      few: '$count اتصالات',
      two: 'اتصالان',
      one: 'اتصال واحد',
      zero: 'لا اتصالات',
    );
    return '$_temp0';
  }

  @override
  String get orderClientSection => 'العميل';

  @override
  String get orderEditContact => 'تعديل';

  @override
  String get orderEditContactDone => 'تم';

  @override
  String get orderFieldName => 'الاسم';

  @override
  String get orderFieldPhone => 'الهاتف';

  @override
  String get orderFieldAddress => 'العنوان';

  @override
  String get orderFieldRegion => 'المنطقة';

  @override
  String get orderNoPhone => 'بدون هاتف';

  @override
  String get orderNoAddress => 'بدون عنوان';

  @override
  String get orderPhoneHint => '0555 12 34 56';

  @override
  String get orderAddressHint => 'الولاية، البلدية، الشارع، المبنى...';

  @override
  String get orderContactSavedWithCall =>
      'تُحفظ التعديلات عند تسجيل نتيجة الاتصال.';

  @override
  String get orderStopdeskChip => 'ستوب ديسك (استلام من الوكالة)';

  @override
  String get orderItemsSection => 'العناصر';

  @override
  String orderUnitLine(int qty, String price) {
    return '×$qty · $price / وحدة';
  }

  @override
  String get orderTotalLabel => 'الإجمالي';

  @override
  String get orderPaidLabel => 'المدفوع';

  @override
  String get orderRemainingLabel => 'المتبقي';

  @override
  String get orderNotesSection => 'ملاحظات';

  @override
  String get orderAttemptsSection => 'المحاولات السابقة';

  @override
  String get orderCallHistorySection => 'سجل الاتصالات';

  @override
  String get orderLogCall => 'تسجيل نتيجة الاتصال';

  @override
  String get orderAlreadyConfirmed => 'مؤكدة بالفعل';

  @override
  String get orderClose => 'إغلاق';

  @override
  String orderReadOnlyNotice(String status) {
    return 'هذا الطلب $status — تسجيل الاتصالات معطّل.';
  }

  @override
  String get orderReadOnlyResell => 'أنشئ طلبًا جديدًا لإعادة البيع.';

  @override
  String get orderCallQuestion => 'كيف جرى الاتصال؟';

  @override
  String get orderCallSubtitle => 'سنسجّل المحاولة ونحدّث الطلب وفقًا لذلك.';

  @override
  String get orderOutcomeConfirmed => 'مؤكدة';

  @override
  String get orderOutcomeConfirmedHint =>
      'العميل يريد الطلب — سنجعله جاهزًا للإرسال.';

  @override
  String get orderOutcomeNoAnswer => 'لا يوجد رد';

  @override
  String get orderOutcomeNoAnswerHint =>
      'سُجّلت كمحاولة — يبقى في قائمة الانتظار.';

  @override
  String get orderOutcomeBusy => 'مشغول';

  @override
  String get orderOutcomeBusyHint =>
      'أعد المحاولة لاحقًا — يبقى في قائمة الانتظار.';

  @override
  String get orderOutcomeVoicemail => 'البريد الصوتي';

  @override
  String get orderOutcomeVoicemailHint =>
      'سُجّلت كمحاولة — يبقى في قائمة الانتظار.';

  @override
  String get orderOutcomeRejected => 'مرفوضة';

  @override
  String get orderOutcomeRejectedHint => 'العميل لا يريده — سيتم إلغاء الطلب.';

  @override
  String get orderCallNotesLabel => 'ملاحظات (اختياري، لسجلاتك)';

  @override
  String get orderCallNotesHintConfirmed =>
      'وقت التسليم المؤكد، التعليمات، الدفع…';

  @override
  String get orderCallNotesHintRejected => 'لماذا رفض العميل؟';

  @override
  String get orderCallNotesHintOther => 'ماذا حدث؟';

  @override
  String get orderSaveOutcome => 'حفظ النتيجة';

  @override
  String get orderBackToReview => 'رجوع';

  @override
  String get orderNoAddressWarning => 'لا يوجد عنوان تسليم لهذا الطلب بعد.';

  @override
  String get orderNoAddressBody =>
      'ارجع إلى «المراجعة» وعدّل بطاقة العميل قبل التأكيد.';

  @override
  String get orderResultConfirmedTitle => 'تم تأكيد الطلب';

  @override
  String get orderResultConfirmedBody => 'جاهز للإرسال إلى شركة التوصيل.';

  @override
  String get orderResultCancelledTitle => 'تم إلغاء الطلب';

  @override
  String get orderResultCancelledBody =>
      'تمت استعادة المخزون. وأُلغي الدفع المسجّل — أما الاسترداد الفعلي فيبقى عليك.';

  @override
  String get orderResultAttemptTitle => 'تم تسجيل المحاولة';

  @override
  String orderResultAttemptBody(int count) {
    return 'تم تسجيل المحاولة رقم $count. يبقى في قائمة الانتظار.';
  }

  @override
  String get orderNextSection => 'التالي: التحضير والإرسال';

  @override
  String get orderNextBody =>
      'أرسل هذا الطلب إلى شركة التوصيل، أو ضعه قيد التحضير بينما تجهّزه.';

  @override
  String get orderSendToDelivery => 'إرسال للتوصيل';

  @override
  String get orderSendToDeliverySoon => 'ياليدين / ZR — قريبًا';

  @override
  String get orderMarkPreparing => 'تحديد قيد التحضير';

  @override
  String get orderDone => 'تم';

  @override
  String get orderReturnTitle => 'تحديد كمرتجع';

  @override
  String orderReturnBody(String number) {
    return 'هل تريد فعلًا تحديد الطلب $number كمرتجع؟ ستتم استعادة المخزون وإلغاء الدفع.';
  }

  @override
  String get orderReturnNoticeTitle => 'الاسترداد ليس تلقائيًا';

  @override
  String get orderReturnNoticeBody =>
      'يجب إعادة المبلغ المحصّل إلى العميل وتسجيله كمصروف في الصندوق.';

  @override
  String get orderDeleteTitle => 'حذف الطلب';

  @override
  String orderDeleteBody(String number) {
    return 'هل تريد فعلًا حذف الطلب $number؟ ستتم استعادة المخزون.';
  }

  @override
  String get orderDeleteNoticeBody =>
      'يُحذف الطلب وسطوره وسجل اتصالاته نهائيًا.';

  @override
  String get newOrderTitle => 'طلب جديد';

  @override
  String get newOrderClientSection => 'العميل';

  @override
  String get newOrderSearchClient => 'ابحث عن عميل';

  @override
  String get newOrderSearchClientHint => 'ابحث عن عميل بالاسم أو الهاتف...';

  @override
  String get newOrderNoClients => 'لم يُعثر على عملاء';

  @override
  String get newOrderOrType => 'أو أدخل';

  @override
  String get newOrderClientName => 'اسم العميل';

  @override
  String get newOrderClientPhone => 'الهاتف';

  @override
  String get newOrderDeliveryAddress => 'عنوان التسليم';

  @override
  String get newOrderWilaya => 'الولاية';

  @override
  String get newOrderWilayaHint => 'اختر ولاية…';

  @override
  String get newOrderCommune => 'البلدية';

  @override
  String get newOrderCommuneHint => 'البلدية (اختياري)';

  @override
  String get newOrderStopdesk => 'ستوب ديسك (استلام من الوكالة — أرخص)';

  @override
  String get newOrderProductsSection => 'المنتجات';

  @override
  String get newOrderAddProducts => 'إضافة منتجات';

  @override
  String get newOrderProductHint => 'ابحث عن منتج بالاسم أو رمز SKU…';

  @override
  String get newOrderNoProducts => 'لم يُعثر على منتجات';

  @override
  String newOrderVariantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نوعًا',
      few: '$count أنواع',
      two: 'نوعان',
      one: 'نوع واحد',
    );
    return '$_temp0';
  }

  @override
  String newOrderInStock(int count) {
    return '$count في المخزون';
  }

  @override
  String get newOrderOutOfStock => 'نفد المخزون';

  @override
  String get newOrderQty => 'الكمية';

  @override
  String get newOrderUnitPrice => 'السعر (دج)';

  @override
  String get newOrderLineTotal => 'الإجمالي';

  @override
  String get newOrderNoLines => 'ابحث واختر المنتجات أعلاه لإضافتها';

  @override
  String get newOrderNotesSection => 'ملاحظة / ملاحظات';

  @override
  String get newOrderNotes => 'ملاحظات';

  @override
  String get newOrderNotesHint => 'أضف ملاحظة لهذا الطلب…';

  @override
  String get newOrderSummary => 'ملخص الطلب';

  @override
  String get newOrderSubtotal => 'المجموع الفرعي';

  @override
  String get newOrderDelivery => 'التوصيل';

  @override
  String get newOrderTotal => 'الإجمالي';

  @override
  String get newOrderPayInFull => 'مدفوع بالكامل';

  @override
  String get newOrderAmountPaid => 'المبلغ المدفوع (دج)';

  @override
  String get newOrderCodHint =>
      'اترك 0 للدفع عند الاستلام — يُسجَّل تلقائيًا عند التسليم.';

  @override
  String get newOrderRemainingDebt => 'المتبقي (دين)';

  @override
  String get newOrderFullyPaid => 'مدفوع بالكامل';

  @override
  String get newOrderPayment => 'الدفع';

  @override
  String get newOrderStatus => 'حالة الطلب';

  @override
  String get newOrderPaymentMethod => 'طريقة الدفع';

  @override
  String get paymentMethodCash => 'نقدًا';

  @override
  String get paymentMethodCard => 'بطاقة';

  @override
  String get paymentMethodTransfer => 'تحويل بنكي';

  @override
  String get paymentMethodCcp => 'CCP';

  @override
  String get newOrderSubmit => 'إنشاء الطلب';

  @override
  String get newOrderStockReserved =>
      'يُحجز المخزون فور إنشاء الطلب، حتى لو كان قيد الانتظار.';

  @override
  String get newOrderErrNoItems => 'أضف منتجًا واحدًا على الأقل';

  @override
  String get newOrderErrName => 'اسم العميل مطلوب';

  @override
  String get newOrderErrPhone => 'رقم الهاتف مطلوب للتواصل مع العميل';

  @override
  String get newOrderErrWilaya => 'ولاية التسليم مطلوبة';

  @override
  String get newOrderErrAddress =>
      'العنوان مطلوب للتوصيل إلى المنزل (أو اختر ستوب ديسك)';

  @override
  String newOrderErrStock(String name, int count) {
    return '$name — لم يتبقَّ سوى $count في المخزون';
  }

  @override
  String get orderCreatedToast => 'تم إنشاء الطلب';

  @override
  String get orderCallLoggedToast => 'تم حفظ نتيجة الاتصال';

  @override
  String get orderStatusChangedToast => 'تم تحديث الطلب';

  @override
  String get orderReturnedToast => 'تم تحديد الطلب كمرتجع';

  @override
  String get orderDeletedToast => 'تم حذف الطلب';

  @override
  String newOrderDraftLinesDropped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'تعذّر استرجاع $count أسطر من مسودتك: المنتجات لم تعد موجودة أو نفدت من المخزون.',
      one: 'تعذّر استرجاع سطر واحد من مسودتك: المنتج لم يعد موجودًا أو نفد من المخزون.',
    );
    return '$_temp0';
  }

  @override
  String get productsFilterPriceMin => 'سعر البيع (دج) · الحد الأدنى';

  @override
  String get productsFilterPriceMax => 'سعر البيع (دج) · الحد الأقصى';

  @override
  String get productsFilterCostMin => 'سعر التكلفة (دج) · الحد الأدنى';

  @override
  String get productsFilterCostMax => 'سعر التكلفة (دج) · الحد الأقصى';

  @override
  String get productsFilterQtyMin => 'الكمية · الحد الأدنى';

  @override
  String get productsFilterQtyMax => 'الكمية · الحد الأقصى';

  @override
  String get productsFilterProfitMin => 'الربح الصافي (دج) · الحد الأدنى';

  @override
  String get productsFilterProfitMax => 'الربح الصافي (دج) · الحد الأقصى';

  @override
  String get productsFilterMarginMin => 'الهامش (٪) · الحد الأدنى';

  @override
  String get productsFilterMarginMax => 'الهامش (٪) · الحد الأقصى';

  @override
  String get productsSectionInactive => 'المنتجات غير النشطة';

  @override
  String get menuDelivery => 'التوصيل';

  @override
  String get deliveryEyebrow => 'المبيعات';

  @override
  String get deliveryTitle => 'التوصيل';

  @override
  String get deliverySubtitle =>
      'أرسل الطلبات إلى شركات التوصيل وتتبّع الشحنات';

  @override
  String get deliveryFeesAction => 'الأسعار';

  @override
  String get deliveryProvidersAction => 'شركات التوصيل';

  @override
  String get deliveryRefresh => 'تحديث';

  @override
  String get deliveryStatReady => 'جاهزة للشحن';

  @override
  String get deliveryStatShipped => 'مُرسلة';

  @override
  String get deliveryStatInTransit => 'قيد النقل';

  @override
  String get deliveryStatDelivered => 'تم التسليم';

  @override
  String get deliverySearchLabel => 'البحث';

  @override
  String get deliverySearchPlaceholder => 'ابحث في الطلبات...';

  @override
  String get deliveryTabAll => 'الكل';

  @override
  String get deliveryTabReady => 'جاهز';

  @override
  String get deliveryTabSent => 'مُرسلة';

  @override
  String get deliveryTabInTransit => 'قيد النقل';

  @override
  String get deliveryTabDelivered => 'تم التسليم';

  @override
  String get deliveryOrdersSection => 'الطلبات';

  @override
  String get deliveryPillNotSent => 'لم تُرسل';

  @override
  String get deliveryPillSent => 'مُرسلة';

  @override
  String get deliveryPillInTransit => 'قيد النقل';

  @override
  String get deliveryPillDelivered => 'تم التسليم';

  @override
  String deliveryMetaLine(String provider, String tracking) {
    return 'شركة التوصيل $provider  ·  التتبع $tracking';
  }

  @override
  String get deliverySend => 'إرسال';

  @override
  String get deliveryTrack => 'تتبّع';

  @override
  String get deliveryLabel => 'الملصق';

  @override
  String get deliveryEmptyTitle => 'لا توجد طلبات';

  @override
  String get deliveryEmptyBody =>
      'تظهر الطلبات هنا، جاهزة للإرسال إلى شركة توصيل.';

  @override
  String get deliveryNoMatchTitle => 'لا نتائج';

  @override
  String get deliveryNoMatchBody => 'جرّب كلمة أخرى أو تبويبًا آخر.';

  @override
  String deliverySendTitle(String order) {
    return 'إرسال $order للتوصيل';
  }

  @override
  String get deliveryClient => 'العميل';

  @override
  String get deliveryPhone => 'الهاتف';

  @override
  String get deliveryAddress => 'العنوان';

  @override
  String get deliveryTotal => 'الإجمالي';

  @override
  String get deliveryProviderLabel => 'شركة التوصيل';

  @override
  String deliveryProviderDefault(String name) {
    return '$name (افتراضي)';
  }

  @override
  String get deliveryDestination => 'ولاية الوجهة';

  @override
  String get deliveryChooseWilaya => 'اختر ولاية';

  @override
  String get deliveryStopdesk => 'التوصيل إلى المكتب (ستوب ديسك)';

  @override
  String get deliveryNote => 'ملاحظة';

  @override
  String get deliveryNotePlaceholder => 'ملاحظة اختيارية لشركة التوصيل...';

  @override
  String get deliveryRates => 'الأسعار التقديرية';

  @override
  String get deliveryRateHome => 'التوصيل إلى المنزل';

  @override
  String get deliveryRateStopdesk => 'ستوب ديسك';

  @override
  String get deliveryConfirmSend => 'تأكيد وإرسال';

  @override
  String get deliveryNoProviders => 'لم تُضبط أي شركة توصيل';

  @override
  String get deliveryAddProvider => 'إضافة شركة توصيل';

  @override
  String deliverySentToast(String order, String provider) {
    return 'تم إرسال $order إلى $provider';
  }

  @override
  String deliveryTrackTitle(String order) {
    return 'التتبع — $order';
  }

  @override
  String deliveryCourierResponse(String provider) {
    return 'رد شركة التوصيل · $provider';
  }

  @override
  String get deliveryTrackEmpty => 'لم تُرجع شركة التوصيل أي معلومات.';

  @override
  String get deliveryLabelNotReady => 'لم تُصدر شركة التوصيل الملصق بعد.';

  @override
  String get deliveryLabelOpenFailed => 'تعذّر فتح الملصق على هذا الهاتف.';

  @override
  String get deliveryFeesEyebrow => 'التوصيل';

  @override
  String get deliveryFeesTitle => 'أسعار التوصيل';

  @override
  String get deliveryFeesSubtitle =>
      'حدّد سعر التوصيل لكل ولاية. يُستعمل تلقائيًا عند إنشاء الطلبات ومن طرف وكيل الذكاء الاصطناعي لعروض الأسعار على ماسنجر.';

  @override
  String get deliveryFeesFillMissing => 'إكمال الناقص';

  @override
  String get deliveryFeesResetAll => 'إعادة الكل للافتراضي';

  @override
  String get deliveryFeesSearch => 'ابحث عن ولاية…';

  @override
  String get deliveryFeesSection => 'الولايات';

  @override
  String get deliveryFeesDefault => 'افتراضي';

  @override
  String get deliveryFeesCustom => 'مخصص';

  @override
  String get deliveryFeesHome => 'المنزل (دج)';

  @override
  String get deliveryFeesStopdesk => 'المكتب (دج)';

  @override
  String get deliveryFeesReturn => 'الإرجاع (دج)';

  @override
  String get deliveryFeesReset => 'إعادة تعيين';

  @override
  String get deliveryFeesResetAllTitle => 'إعادة الكل إلى الافتراضي';

  @override
  String get deliveryFeesResetAllBody =>
      'استبدال كل أسعارك المخصصة بالقيم الافتراضية للنظام؟';

  @override
  String deliveryFeesSaved(String wilaya) {
    return 'تم حفظ أسعار $wilaya';
  }

  @override
  String deliveryFeesResetDone(String wilaya) {
    return 'عادت $wilaya إلى الأسعار الافتراضية';
  }

  @override
  String deliveryFeesFilled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم إكمال $count ولاية',
      one: 'تم إكمال ولاية واحدة',
      zero: 'لا شيء لإكماله: لكل ولاية أسعارها',
    );
    return '$_temp0';
  }

  @override
  String get deliveryFeesResetAllDone => 'عادت كل الأسعار إلى القيم الافتراضية';

  @override
  String get deliveryProvidersTitle => 'شركات التوصيل';

  @override
  String get deliveryProvidersSubtitle => 'اضبط شركات التوصيل لشحن الطلبات';

  @override
  String get deliveryProvidersSection => 'شركات التوصيل';

  @override
  String get deliveryDefaultBadge => 'افتراضي';

  @override
  String get deliveryCardProvider => 'الشركة:';

  @override
  String get deliveryCardSender => 'المرسِل:';

  @override
  String get deliveryCardPhone => 'الهاتف:';

  @override
  String get deliveryCardWilaya => 'الولاية:';

  @override
  String get deliveryEdit => 'تعديل';

  @override
  String get deliveryProvidersEmptyTitle => 'لم تُضبط أي شركة توصيل';

  @override
  String get deliveryProvidersEmptyBody => 'أضف شركة توصيل لبدء شحن الطلبات';

  @override
  String get deliveryDeleteTitle => 'حذف شركة التوصيل';

  @override
  String get deliveryDeleteBody =>
      'هل تريد فعلًا إزالة شركة التوصيل هذه؟ لا يمكن التراجع عن ذلك.';

  @override
  String deliveryProviderDeleted(String name) {
    return 'تم حذف $name';
  }

  @override
  String get deliveryFormAddTitle => 'إضافة شركة توصيل';

  @override
  String get deliveryFormEditTitle => 'تعديل شركة التوصيل';

  @override
  String get deliveryFormCourier => 'شركة التوصيل';

  @override
  String get deliveryFormChooseCourier => 'اختر شركة توصيل';

  @override
  String get deliveryFormDisplayName => 'الاسم المعروض';

  @override
  String get deliveryFormCredentials => 'بيانات اعتماد API';

  @override
  String get deliveryFormUnchanged => '(دون تغيير — أدخل للتحديث)';

  @override
  String get deliveryFormTest => 'اختبار بيانات الاعتماد';

  @override
  String deliveryFormTestOk(String name) {
    return 'بيانات الاعتماد صحيحة — تم الاتصال بـ $name.';
  }

  @override
  String deliveryFormTestFailed(String name, String reason) {
    return 'رفضت $name الاتصال: $reason';
  }

  @override
  String get deliveryFormSender => 'معلومات المرسِل';

  @override
  String get deliveryFormSenderName => 'اسم المرسِل';

  @override
  String get deliveryFormSenderPhone => 'هاتف المرسِل';

  @override
  String get deliveryFormSenderAddress => 'عنوان المرسِل';

  @override
  String get deliveryFormSenderWilaya => 'ولاية المرسِل';

  @override
  String get deliveryFormSetDefault => 'تعيين كشركة التوصيل الافتراضية';

  @override
  String get deliveryFormAdd => 'إضافة الشركة';

  @override
  String get deliveryFormUpdate => 'تحديث';

  @override
  String deliveryProviderAdded(String name) {
    return 'تمت إضافة $name';
  }

  @override
  String deliveryProviderUpdated(String name) {
    return 'تم تحديث $name';
  }

  @override
  String get deliveryFormAllTaken => 'كل شركات التوصيل المدعومة مضبوطة مسبقًا.';

  @override
  String get deliveryDeleteNoticeTitle => 'الطلبات المُرسلة مسبقًا';

  @override
  String deliveryDeleteNoticeBody(String name) {
    return 'ستحتفظ الطلبات المُرسلة عبر $name برقم التتبع، لكن لن يمكن تتبعها أو طباعة ملصقها بعد الآن.';
  }

  @override
  String get deliveryDeleteNoticeDefault =>
      'هذه شركة التوصيل الافتراضية لديك: اختر شركة أخرى بعد ذلك.';

  @override
  String deliveryProviderAlreadyGone(String name) {
    return 'كانت $name محذوفة مسبقًا';
  }

  @override
  String get menuSales => 'المبيعات';

  @override
  String get salesEyebrow => 'المبيعات';

  @override
  String get salesTitle => 'المبيعات';

  @override
  String salesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مبيعة',
    );
    return '$_temp0';
  }

  @override
  String get salesPeriodToday => 'اليوم';

  @override
  String get salesPeriodWeek => 'الأسبوع';

  @override
  String get salesPeriodMonth => 'الشهر';

  @override
  String get salesPeriodYear => 'السنة';

  @override
  String get salesStatTotal => 'إجمالي المبيعات';

  @override
  String get salesStatRevenue => 'الإيرادات';

  @override
  String get salesStatAverage => 'متوسط قيمة الطلب';

  @override
  String get salesStatPending => 'قيد الانتظار';

  @override
  String get salesSearch => 'ابحث في المبيعات…';

  @override
  String get salesQuickAll => 'الكل';

  @override
  String get salesQuickPaid => 'مدفوعة';

  @override
  String get salesQuickRemaining => 'متبقية';

  @override
  String get salesSection => 'كل المبيعات';

  @override
  String get salesView => 'عرض';

  @override
  String get salesNew => 'مبيعة جديدة';

  @override
  String get salesEmptyTitle => 'لا توجد مبيعات';

  @override
  String get salesEmptyBody => 'سجّل أول مبيعاتك لتتبع الإيرادات';

  @override
  String get salesNoMatchBody => 'لا توجد مبيعة تطابق هذه المعايير.';

  @override
  String get salesFilterMethodAny => 'كل الطرق';

  @override
  String get saleStatusPaid => 'مدفوعة';

  @override
  String get saleStatusPending => 'قيد الانتظار';

  @override
  String get saleStatusPartial => 'جزئية';

  @override
  String get saleDeleteTitle => 'حذف المبيعة';

  @override
  String saleDeleteBody(String number) {
    return 'هل تريد فعلًا حذف المبيعة $number؟';
  }

  @override
  String get saleDeleteNotice =>
      'لا يمكن التراجع عن هذا الإجراء. ستُستعاد كميات المخزون.';

  @override
  String saleDeletedToast(String number) {
    return 'تم حذف المبيعة $number';
  }

  @override
  String saleAlreadyGone(String number) {
    return 'كانت المبيعة $number محذوفة مسبقًا';
  }

  @override
  String get saleEyebrow => 'مبيعة';

  @override
  String get saleFieldCustomer => 'العميل';

  @override
  String get saleFieldPhone => 'الهاتف';

  @override
  String get saleFieldDate => 'التاريخ';

  @override
  String get saleFieldMethod => 'طريقة الدفع';

  @override
  String get saleFieldItems => 'المنتجات';

  @override
  String get saleWalkIn => 'عميل عابر';

  @override
  String get saleItemsSection => 'المنتجات';

  @override
  String saleLineMeta(int qty, String price) {
    return '×$qty  ·  $price';
  }

  @override
  String saleLineDiscount(String amount) {
    return 'خصم $amount';
  }

  @override
  String get saleSubtotal => 'المجموع الفرعي';

  @override
  String get saleDiscount => 'خصم';

  @override
  String get saleTax => 'الضريبة';

  @override
  String get saleTotal => 'الإجمالي';

  @override
  String get salePaymentStatus => 'حالة الدفع';

  @override
  String get saleMarkPaid => 'تحديد كمدفوعة';

  @override
  String get saleEdit => 'تعديل';

  @override
  String get saleMarkedPaidToast => 'تم تحديد المبيعة كمدفوعة';

  @override
  String saleEditTitle(String number) {
    return 'تعديل المبيعة $number';
  }

  @override
  String get saleEditSubtitle =>
      'عدّل الدفع والملاحظات. لا يمكن تغيير المنتجات والأسعار بعد تسجيل المبيعة.';

  @override
  String get saleMethodHint => 'اختر طريقة';

  @override
  String get saleEditPartialMissing => 'أدخل المبلغ المستلم';

  @override
  String saleEditPartialTooHigh(String total) {
    return 'يجب أن يكون أقل من الإجمالي ($total) — وإلا اختر «مدفوعة»';
  }

  @override
  String saleEditCaisse(String from, String to) {
    return 'سيتغير مبلغ الصندوق من $from إلى $to.';
  }

  @override
  String get saleEditSave => 'حفظ التعديلات';

  @override
  String get saleUpdatedToast => 'تم تحديث المبيعة';

  @override
  String get saleEditLeaveBody => 'ستفقد تعديلاتك.';

  @override
  String get newSaleNotesHint => 'أضف ملاحظة لهذه المبيعة…';

  @override
  String get newSaleSummary => 'ملخص الدفع';

  @override
  String get newSaleFullyPaid => 'مدفوعة بالكامل';

  @override
  String get newSaleStatus => 'الحالة';

  @override
  String get newSalePayInFull => 'دفع المبلغ كاملًا';

  @override
  String newSaleChangeDue(String amount) {
    return 'الباقي للعميل: $amount';
  }

  @override
  String get newSaleSubmit => 'إتمام البيع';

  @override
  String get newSaleStockNote => 'يُخصم المخزون فور تسجيل المبيعة.';

  @override
  String get newSaleErrPhone => 'رقم الهاتف غير مكتمل';

  @override
  String newSaleCreatedToast(String number) {
    return 'تم تسجيل المبيعة $number';
  }

  @override
  String get newSaleDateTitle => 'تاريخ المبيعة';

  @override
  String get newSaleLeaveBody => 'ستفقد المبيعة التي بدأتها.';

  @override
  String get menuPurchases => 'المشتريات';

  @override
  String get menuMovements => 'الحركات';

  @override
  String get purchasesEyebrow => 'المشتريات';

  @override
  String get purchasesTitle => 'المشتريات';

  @override
  String purchasesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عملية شراء',
    );
    return '$_temp0';
  }

  @override
  String get purchasesStatTotal => 'إجمالي المشتريات';

  @override
  String get purchasesStatSpent => 'إجمالي الإنفاق';

  @override
  String get purchasesStatToReceive => 'بانتظار الاستلام';

  @override
  String get purchasesStatReceived => 'مستلمة';

  @override
  String get purchasesSearch => 'ابحث في المشتريات…';

  @override
  String get purchasesQuickAll => 'الكل';

  @override
  String get purchasesQuickPaid => 'مدفوعة';

  @override
  String get purchasesQuickToPay => 'للدفع';

  @override
  String get purchasesSection => 'كل المشتريات';

  @override
  String purchasesRowMeta(String items, String paid, String remaining) {
    return '$items  ·  المدفوع $paid  ·  المتبقي للدفع $remaining';
  }

  @override
  String get purchasesReceive => 'استلام';

  @override
  String get purchasesNew => 'شراء جديد';

  @override
  String get purchasesEmptyTitle => 'لا توجد مشتريات';

  @override
  String get purchasesEmptyBody => 'سجّل أول عملية شراء من مورد';

  @override
  String get purchasesNoMatchBody => 'لا توجد عملية شراء تطابق هذه المعايير.';

  @override
  String get purchasesFilterStatus => 'حالة الاستلام';

  @override
  String get purchasesFilterSupplierAny => 'كل الموردين';

  @override
  String get purchasesFilterHasRemaining => 'مبلغ متبقٍّ للمورد';

  @override
  String get purchaseStatusPending => 'بانتظار الاستلام';

  @override
  String get purchaseStatusPartial => 'مستلم جزئيًا';

  @override
  String get purchaseStatusReceived => 'مستلم';

  @override
  String get purchaseStatusCancelled => 'ملغى';

  @override
  String get purchasePayPending => 'غير مدفوع';

  @override
  String get purchasePayPartial => 'مدفوع جزئيًا';

  @override
  String get purchasePayPaid => 'مدفوع';

  @override
  String get purchaseDeleteTitle => 'حذف الشراء';

  @override
  String purchaseDeleteBody(String number) {
    return 'هل تريد فعلًا حذف الشراء $number؟';
  }

  @override
  String get purchaseDeleteNotice => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String purchaseDeletedToast(String number) {
    return 'تم حذف الشراء $number';
  }

  @override
  String purchaseAlreadyGone(String number) {
    return 'كان الشراء $number محذوفًا مسبقًا';
  }

  @override
  String get purchaseEyebrow => 'شراء';

  @override
  String get purchaseFieldSupplier => 'المورد';

  @override
  String get purchaseFieldReceiving => 'الاستلام';

  @override
  String get purchaseFieldPayment => 'الدفع';

  @override
  String get purchaseFieldPaid => 'المبلغ المدفوع';

  @override
  String get purchaseFieldRemaining => 'المتبقي للدفع';

  @override
  String get purchaseFieldReceivedOn => 'تاريخ الاستلام';

  @override
  String get purchaseNoSupplier => 'بدون مورد';

  @override
  String purchaseLineMeta(int ordered, int received, String cost) {
    return 'المطلوب $ordered  ·  المستلم $received  ·  التكلفة $cost / وحدة';
  }

  @override
  String get purchaseMarkPaid => 'تحديد كمدفوع';

  @override
  String get purchaseMarkedPaidToast => 'تم تحديد الشراء كمدفوع';

  @override
  String get purchaseReceiveDelivery => 'استلام الشحنة';

  @override
  String get purchaseCancel => 'إلغاء الشراء';

  @override
  String get purchaseCancelKeep => 'الاحتفاظ بالشراء';

  @override
  String purchaseCancelBody(String number) {
    return 'سيتم إلغاء الشراء $number.';
  }

  @override
  String get purchaseCancelNoticeTitle => 'ما الذي سيحدث';

  @override
  String purchaseCancelStock(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ستُسحب $count وحدة مستلمة من المخزون.',
    );
    return '$_temp0';
  }

  @override
  String purchaseCancelMoney(String amount) {
    return 'سيُحذف الدفع البالغ $amount من الصندوق. سجّل استرداد المورد بنفسك.';
  }

  @override
  String get purchaseCancelFinal =>
      'لا يمكن استلام الشراء الملغى أو دفعه بعد ذلك.';

  @override
  String purchaseCancelledToast(String number) {
    return 'تم إلغاء الشراء $number';
  }

  @override
  String get receiveBody =>
      'أدخل الكمية التي سلّمها المورد لكل منتج. سيُحدَّث المخزون تلقائيًا.';

  @override
  String receiveLineMeta(int ordered, int received) {
    return 'المطلوب $ordered  ·  المستلم سابقًا $received';
  }

  @override
  String get receiveNowLabel => 'المستلم الآن';

  @override
  String receiveToCome(int count) {
    return '$count بانتظار الاستلام';
  }

  @override
  String get receiveComplete => 'مكتمل';

  @override
  String receiveOver(int count) {
    return '$count كحد أقصى';
  }

  @override
  String get receiveSubmit => 'تأكيد الاستلام';

  @override
  String get receiveNothing => 'أدخل كمية واحدة على الأقل';

  @override
  String get receivedToast => 'تم تسجيل الاستلام · تم تحديث المخزون';

  @override
  String get newPurchaseSearchSupplier => 'ابحث عن مورد';

  @override
  String get newPurchaseSearchSupplierHint => 'ابحث عن مورد بالاسم أو الهاتف…';

  @override
  String get newPurchaseNoSuppliers => 'لم يتم العثور على مورد';

  @override
  String get newPurchaseUnitCost => 'تكلفة الوحدة (دج)';

  @override
  String get newPurchaseNotesHint => 'أضف ملاحظة لهذا الشراء…';

  @override
  String get newPurchaseSummary => 'الدفع للمورد';

  @override
  String get newPurchaseAmountPaid => 'المبلغ المدفوع للمورد (دج)';

  @override
  String get newPurchaseFullyPaid => 'مدفوع بالكامل';

  @override
  String get newPurchasePayInFull => 'دفع المبلغ كاملًا';

  @override
  String newPurchaseOverpaid(String total) {
    return 'أكثر من الإجمالي: سيُسجَّل $total فقط.';
  }

  @override
  String get newPurchaseStockNote => 'يُضاف المخزون عند استلام الشحنة.';

  @override
  String get newPurchaseSubmit => 'تسجيل الشراء';

  @override
  String newPurchaseCreatedToast(String number) {
    return 'تم تسجيل الشراء $number';
  }

  @override
  String get newPurchaseDateTitle => 'تاريخ الشراء';

  @override
  String get newPurchaseLeaveBody => 'ستفقد عملية الشراء التي بدأتها.';

  @override
  String get movementsEyebrow => 'المخزون';

  @override
  String get movementsTitle => 'حركات المخزون';

  @override
  String get movementsSubtitle => 'سجل جميع تغييرات المخزون';

  @override
  String get movementsSection => 'الحركات';

  @override
  String get movementsEmptyTitle => 'لا توجد حركات';

  @override
  String get movementsEmptyBody =>
      'ستظهر حركات المخزون هنا عند إضافة المنتجات أو بيعها أو تعديلها';

  @override
  String get movementsNoMatchBody => 'لا توجد حركة تطابق هذه المعايير.';

  @override
  String get movementsFilterType => 'نوع الحركة';

  @override
  String get movementsFilterTypeAny => 'كل الأنواع';

  @override
  String get movementsFilterProduct => 'المنتج';

  @override
  String get movementsFilterProductAny => 'كل المنتجات';

  @override
  String movementReasonSale(String number) {
    return 'بيع $number';
  }

  @override
  String movementReasonSaleDeleted(String number) {
    return 'حذف البيع $number';
  }

  @override
  String movementReasonPurchase(String number) {
    return 'استلام شراء $number';
  }

  @override
  String movementReasonPurchaseCancelled(String number) {
    return 'إلغاء الشراء $number';
  }

  @override
  String movementReasonOrder(String number) {
    return 'طلب $number';
  }

  @override
  String movementReasonOrderCancelled(String number) {
    return 'طلب ملغى $number';
  }

  @override
  String movementReasonOrderReturned(String number) {
    return 'طلب مرتجع $number';
  }

  @override
  String movementReasonOrderDeleted(String number) {
    return 'طلب محذوف $number';
  }

  @override
  String get movementReasonInitial => 'المخزون الأولي';

  @override
  String get movementReasonVariantDeleted => 'حذف متغير';

  @override
  String saleDeleteMoney(String amount) {
    return 'سيُحذف المبلغ المستلم $amount من الصندوق.';
  }

  @override
  String get menuCaisse => 'الصندوق';

  @override
  String get caisseEyebrow => 'المالية';

  @override
  String get caisseTitle => 'الصندوق';

  @override
  String get caisseSubtitle => 'صندوق النقد وإدارة الخزينة';

  @override
  String get caissePeriodToday => 'اليوم';

  @override
  String get caissePeriodWeek => 'هذا الأسبوع';

  @override
  String get caissePeriodMonth => 'هذا الشهر';

  @override
  String get caissePeriodYear => 'هذه السنة';

  @override
  String get caisseStatBalance => 'الرصيد';

  @override
  String get caisseStatIncome => 'إجمالي الإيرادات';

  @override
  String get caisseStatExpense => 'إجمالي المصاريف';

  @override
  String get caisseStatCount => 'المعاملات';

  @override
  String get caisseSearch => 'ابحث بالمرجع أو الوصف…';

  @override
  String get caisseSection => 'المعاملات';

  @override
  String get caisseEmptyTitle => 'لم يتم العثور على معاملات';

  @override
  String get caisseEmptyBody =>
      'تظهر المبيعات والطلبات والمشتريات المدفوعة هنا تلقائيًا. أضف باقي مداخيلك ومصاريفك.';

  @override
  String get caisseNoMatchBody => 'لا توجد معاملة تطابق هذه المعايير.';

  @override
  String get caisseTypeIncome => 'إيراد';

  @override
  String get caisseTypeExpense => 'مصروف';

  @override
  String get caisseCatSale => 'بيع';

  @override
  String get caisseCatOrder => 'طلب';

  @override
  String get caisseCatPurchase => 'شراء';

  @override
  String get caisseCatRent => 'إيجار';

  @override
  String get caisseCatSalary => 'راتب';

  @override
  String get caisseCatUtilities => 'فواتير';

  @override
  String get caisseCatMarketing => 'تسويق';

  @override
  String get caisseCatShipping => 'شحن';

  @override
  String get caisseCatOther => 'أخرى';

  @override
  String caisseRef(String reference) {
    return 'المرجع $reference';
  }

  @override
  String get caisseAuto => 'تلقائي';

  @override
  String get caisseManual => 'يدوي';

  @override
  String caisseAutoSale(String number) {
    return 'بيع $number';
  }

  @override
  String caisseAutoOrder(String number) {
    return 'طلب $number';
  }

  @override
  String caisseAutoPurchase(String number) {
    return 'شراء $number';
  }

  @override
  String get caisseFilterType => 'النوع';

  @override
  String get caisseFilterCategory => 'الفئة';

  @override
  String get caisseFilterCategoryAny => 'كل الفئات';

  @override
  String get caisseAddTitle => 'إضافة معاملة';

  @override
  String get caisseEditTitle => 'تعديل المعاملة';

  @override
  String get caisseFieldAmount => 'المبلغ (دج)';

  @override
  String get caisseFieldReference => 'المرجع';

  @override
  String get caisseReferenceHint => 'مثال: فاتورة رقم 123';

  @override
  String get caisseFieldDescription => 'الوصف';

  @override
  String get caisseDescriptionHint => 'تفاصيل هذه المعاملة';

  @override
  String get caisseFieldDate => 'التاريخ';

  @override
  String get caisseAdd => 'إضافة';

  @override
  String get caisseUpdate => 'تحديث';

  @override
  String get caisseErrAmount => 'أدخل مبلغًا';

  @override
  String get caisseErrAmountPositive => 'يجب أن يكون المبلغ أكبر من 0';

  @override
  String get caisseAddedToast => 'تمت إضافة المعاملة';

  @override
  String get caisseUpdatedToast => 'تم تحديث المعاملة';

  @override
  String get caisseDeletedToast => 'تم حذف المعاملة';

  @override
  String get caisseAlreadyGone => 'كانت هذه المعاملة محذوفة مسبقًا';

  @override
  String get caisseDeleteTitle => 'حذف المعاملة';

  @override
  String get caisseDeleteBody => 'هل تريد فعلًا حذف هذه المعاملة؟';
}
