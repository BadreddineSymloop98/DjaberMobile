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
  String get errorNotFound => 'غير موجود.';

  @override
  String get errorServer => 'حدث خطأ من جانبنا.';

  @override
  String get errorUnknown => 'حدث خطأ ما.';

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
  String get obEsc2Body => '2 400 دج · أنشأه الوكيل';

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
  String get authErrInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get authErrUserExists => 'يوجد حساب بهذا البريد الإلكتروني بالفعل';

  @override
  String get authErrNetwork => 'لا يمكن الوصول إلى الخادم. تحقق من اتصالك.';

  @override
  String get authErrUnknown => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

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
}
