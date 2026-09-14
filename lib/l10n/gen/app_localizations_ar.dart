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
  String get authSentMessage => 'أرسلنا رابط إعادة التعيين إلى';

  @override
  String get authSentNoReceive => 'لم تستلم البريد؟';

  @override
  String get authSentTryAnother => 'جرّب عنوان بريد آخر';

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
}
