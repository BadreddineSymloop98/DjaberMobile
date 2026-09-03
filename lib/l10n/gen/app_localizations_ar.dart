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
      'عندما لا يعود الوكيل قادراً على متابعة المحادثة، يرنّ هاتفك. تتولّى المحادثة وتردّ، ثم تعيدها إليه.';

  @override
  String get onboardingStockTitle => 'مخزونك في جيبك';

  @override
  String get onboardingStockBody =>
      'تحقّق من التوفّر، صحّح كمية، استلم توصيلة — دون العودة إلى المكتب.';

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
}
