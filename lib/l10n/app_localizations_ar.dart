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
  String get homeSuggestions => 'اقتراحات لك';

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
  String get homeTrendingTitle => 'الوصفات الرائجة هذا الأسبوع';

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
  String get recipeContentLoadFailed => 'تعذر تحميل بيانات الوصفة';

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

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get registerTitle => 'إنشاء حساب';

  @override
  String get forgotPasswordTitle => 'استعادة كلمة المرور';

  @override
  String get accountTitle => 'الحساب';

  @override
  String get loginEmailLabel => 'البريد الإلكتروني';

  @override
  String get loginPasswordLabel => 'كلمة المرور';

  @override
  String get registerNameLabel => 'الاسم';

  @override
  String get registerConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get loginSubmit => 'تسجيل الدخول';

  @override
  String get loginGoogle => 'تسجيل الدخول بجوجل';

  @override
  String get loginRegisterCta => 'إنشاء حساب جديد';

  @override
  String get loginForgotCta => 'نسيت كلمة المرور؟';

  @override
  String get loginGuestCta => 'متابعة كضيف';

  @override
  String get forgotSubmit => 'إرسال الرابط';

  @override
  String get registerSubmit => 'إنشاء الحساب';

  @override
  String get accountSignInCta => 'تسجيل الدخول';

  @override
  String get accountRegisterCta => 'إنشاء حساب';

  @override
  String get accountSignOut => 'تسجيل الخروج';

  @override
  String get accountGuestTitle => 'أنت ضيف';

  @override
  String get accountGuestBody =>
      'أنشئ حسابًا لمزامنة المفضلة والخطط عبر الأجهزة، ونشر الوصفات والتقييمات.';

  @override
  String get accountProviderLabel => 'طريقة الدخول';

  @override
  String get accountEmailSection => 'البريد';

  @override
  String get forgotPasswordSuccess => 'تم إرسال رابط استعادة كلمة المرور';

  @override
  String get registerSuccess => 'تم إنشاء الحساب';

  @override
  String get authValEmailRequired => 'أدخل البريد الإلكتروني';

  @override
  String get authValEmailInvalid => 'البريد الإلكتروني غير صالح';

  @override
  String get authValPasswordMin => 'كلمة المرور 6 أحرف على الأقل';

  @override
  String get authValNameRequired => 'الاسم مطلوب';

  @override
  String get authValPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get authErrorWrongPassword => 'كلمة المرور غير صحيحة';

  @override
  String get authErrorUserNotFound => 'الحساب غير موجود';

  @override
  String get authErrorNetwork => 'تحقق من اتصال الإنترنت';

  @override
  String get authErrorEmailInUse => 'البريد مستخدم بالفعل';

  @override
  String get authErrorWeakPassword => 'كلمة المرور ضعيفة';

  @override
  String get authErrorInvalidCredential => 'بيانات الدخول غير صحيحة';

  @override
  String authErrorGeneric(String message) {
    return '$message';
  }

  @override
  String get homeRecommendedForYou => 'اقتراحات لك';

  @override
  String get homeRecommendedSubtitle => 'حسب تفضيلاتك ومشاهداتك والرائج';

  @override
  String get addRecipeAuthRequired => 'سجّل الدخول لإضافة وصفة للمجتمع';

  @override
  String get addRecipeImageUrl => 'رابط صورة (اختياري)';

  @override
  String get addRecipeIngredientsMin2 => 'أضف مكونتين على الأقل في الأساسي';

  @override
  String get addRecipeTitle => 'إضافة وصفة';

  @override
  String get addRecipeEditTitle => 'تعديل وصفة';

  @override
  String get addRecipeSubmittedPending => 'تم إرسال الوصفة للمراجعة';

  @override
  String get addRecipeUpdated => 'تم تحديث الوصفة';

  @override
  String get accountAdminPanel => 'لوحة التحكم';

  @override
  String get accountMySubmissions => 'وصفاتي المرسلة';

  @override
  String get adminDashboardTitle => 'لوحة التحكم';

  @override
  String get adminSectionPending => 'قيد المراجعة';

  @override
  String get adminSectionApproved => 'مقبولة';

  @override
  String get adminSectionRejected => 'مرفوضة';

  @override
  String get adminSectionStats => 'إحصائيات التطبيق';

  @override
  String get adminReview => 'مراجعة';

  @override
  String get adminApprove => 'قبول';

  @override
  String get adminReject => 'رفض';

  @override
  String get adminEdit => 'تعديل';

  @override
  String get adminDelete => 'حذف';

  @override
  String get adminHide => 'إخفاء عن العامة';

  @override
  String get adminRejectTitle => 'سبب الرفض';

  @override
  String get adminRejectHint => 'اكتبي سبب الرفض للمستخدمة';

  @override
  String get adminStatsTitle => 'إحصائيات';

  @override
  String get adminStatsUsers => 'المستخدمون';

  @override
  String get adminStatsRecipes => 'الوصفات';

  @override
  String get adminStatsPending => 'قيد المراجعة';

  @override
  String get adminStatsApproved => 'مقبولة';

  @override
  String get adminStatsRejected => 'مرفوضة';

  @override
  String get adminStatsRatingsNote =>
      'عدد التقييمات التفصيلي يحتاج فهرسة إضافية (TODO).';

  @override
  String get adminStatsTopRatedTodo => 'أعلى التقييم: TODO — تجميع سحابي';

  @override
  String get adminStatsFavoritesTodo =>
      'الأكثر مفضلة: TODO — تجميع من users.favoriteRecipeIds';

  @override
  String get mySubmittedTitle => 'وصفاتي المرسلة';

  @override
  String get recipeStatusPending => 'قيد المراجعة';

  @override
  String get recipeStatusApproved => 'مقبولة';

  @override
  String get recipeStatusRejected => 'مرفوضة';

  @override
  String recipeRejectedReason(String reason) {
    return 'سبب الرفض: $reason';
  }
}
