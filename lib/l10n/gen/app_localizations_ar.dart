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
}
