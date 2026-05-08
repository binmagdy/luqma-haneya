// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'لقمة هنية';

  @override
  String get homeWeekPlanTooltip => 'خطة الأسبوع';

  @override
  String get homeSettingsTooltip => 'الإعدادات';

  @override
  String get homeHeadline => 'يوم سعيد ونفسك في لقمة حلوة؟';

  @override
  String get homeSubtitle =>
      'تصفحي كل الوصفات، خذي اقتراحات ذكية، دوري بالمكونات، خطّطي الأسبوع، أو ضيفي وصفتك.';

  @override
  String get homeFirebaseBanner =>
      'وضع تجريبي: شغّل Firebase (flutterfire configure) عشان تتزامن خطط الوجبات والمفضلة والتقييمات مع السحابة.';

  @override
  String get homeAllRecipes => 'كل الوصفات';

  @override
  String get homeSuggestions => 'اقتراحات لي';

  @override
  String get homePantrySearch => 'بحث بالمكونات';

  @override
  String get homeSmartMealPlan => 'الخطة الأسبوعية الذكية';

  @override
  String get homeManualMealPlan => 'تعديل الخطة يدوياً';

  @override
  String get homeFavorites => 'المفضلة';

  @override
  String get homeAddRecipe => 'إضافة وصفة';

  @override
  String get homeFooterTagline => 'وصفات مصرية بلمسة دافية';

  @override
  String get homeGuestAccount => 'تسجيل الدخول اختياري — أنتِ ضيفة على الجهاز';

  @override
  String get homeLogin => 'دخول';

  @override
  String get homeSignOut => 'خروج';

  @override
  String homeTrendingTitle(String weekKey) {
    return 'وصفات تريندي هذا الأسبوع ($weekKey)';
  }

  @override
  String get homeTrendingSeeAll => 'عرض الكل';

  @override
  String get homeTrendingEmpty => 'لا يوجد تريندي من السحابة حاليًا.';

  @override
  String homeTrendingError(String error) {
    return 'تريندي: $error';
  }

  @override
  String get homePopularPrefsTitle => 'الأكلات المفضلة عند الناس';

  @override
  String get homePopularPrefsEmpty =>
      'لما يتوفر اتصال ويشارك المستخدمون تفضيلاتهم، هتظهر هنا إحصائيات عامة فقط (بدون بيانات شخصية).';

  @override
  String get homeCloudPlansHint =>
      'خططك الأسبوعية تتزامن مع السحابة عند تسجيل الدخول.';

  @override
  String get homeAccountEntry => 'الحساب والمزامنة';

  @override
  String get mealPlanSyncLocalOnly =>
      'الخطة محفوظة على جهازك. سجّلي دخولًا اختياريًا للمزامنة مع السحابة.';

  @override
  String get mealPlanSyncCloud =>
      'مزامنة سحابية: تُحفظ الخطة على جهازك وتُرفع تلقائيًا عند توفر الشبكة.';

  @override
  String get authEmailLabel => 'البريد';

  @override
  String get authEmailNone => 'غير مرتبط';

  @override
  String get authSyncStatusGuest =>
      'وضع ضيف: المفضلة والخطط محليًا على الجهاز.';

  @override
  String get authSyncStatusCloud =>
      'متصل بالسحابة: المفضلة والخطط والتقييمات العامة تتزامن عند توفر الشبكة.';

  @override
  String get authGoogleTodo => 'تسجيل الدخول بجوجل قريبًا';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsLanguageSection => 'لغة التطبيق';

  @override
  String get settingsLanguageArabic => 'العربية';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageHint => 'يتم حفظ اختيارك على الجهاز.';

  @override
  String get settingsOpenFromAccount => 'العودة للحساب';

  @override
  String get authTitle => 'الحساب';

  @override
  String get authOpenSettings => 'الإعدادات واللغة';

  @override
  String authError(String error) {
    return 'خطأ: $error';
  }

  @override
  String get authGuestIntro =>
      'أنتِ ضيفة على الجهاز — التقييمات العامة والمزامنة المتقدمة تحتاج تسجيل دخول اختياري.';

  @override
  String authSignedInIntro(String name) {
    return 'مسجّلة دخول: $name';
  }

  @override
  String authSyncId(String id) {
    return 'معرّف المزامنة: $id';
  }

  @override
  String get authAnonymousSignIn => 'تسجيل دخول مجهول (سريع)';

  @override
  String get authContinueGuest => 'متابعة كضيفة';

  @override
  String get authSignOut => 'تسجيل الخروج';

  @override
  String get authSignedInSnackbar => 'تم تسجيل الدخول';

  @override
  String authSignInFailed(String error) {
    return 'تعذر: $error';
  }

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navRecipes => 'الوصفات';

  @override
  String get navAccount => 'الحساب';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get recipeDetailTitle => 'تفاصيل الوصفة';

  @override
  String get recipeNotAvailable => 'الوصفة مش متاحة';

  @override
  String recipeError(String error) {
    return 'خطأ: $error';
  }

  @override
  String get ratingPublicTitle => 'تقييم عام';

  @override
  String get ratingPublicMessage => 'سجّل دخولك عشان تقييمك يظهر للناس.';

  @override
  String get ratingCancel => 'إلغاء';

  @override
  String get ratingLocalOnly => 'حفظ محلي فقط';

  @override
  String get ratingLogin => 'تسجيل الدخول';

  @override
  String get ratingSavedSnackbar => 'تم حفظ التقييم';

  @override
  String ratingSaveFailed(String error) {
    return 'تعذر الحفظ: $error';
  }

  @override
  String get recipeAverageRating => 'متوسط التقييم: ';

  @override
  String get recipeYourRating => 'تقييمك';

  @override
  String get recipeSavingRating => 'جاري الحفظ…';

  @override
  String get recipeSaveRating => 'حفظ التقييم';

  @override
  String get recipeSpicy => 'حار';

  @override
  String get recipeMainIngredients => 'المكونات الأساسية';

  @override
  String get recipeOptionalIngredients => 'مكونات اختيارية';

  @override
  String get recipeSteps => 'الخطوات';

  @override
  String get recipeBack => 'رجوع';

  @override
  String recipeMinutesChip(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String recipeServingsChip(int count) {
    return '$count أشخاص';
  }
}
