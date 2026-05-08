import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'لقمة هنية'**
  String get appTitle;

  /// No description provided for @homeWeekPlanTooltip.
  ///
  /// In ar, this message translates to:
  /// **'خطة الأسبوع'**
  String get homeWeekPlanTooltip;

  /// No description provided for @homeSettingsTooltip.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get homeSettingsTooltip;

  /// No description provided for @homeHeadline.
  ///
  /// In ar, this message translates to:
  /// **'يوم سعيد ونفسك في لقمة حلوة؟'**
  String get homeHeadline;

  /// No description provided for @homeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تصفحي كل الوصفات، خذي اقتراحات ذكية، دوري بالمكونات، خطّطي الأسبوع، أو ضيفي وصفتك.'**
  String get homeSubtitle;

  /// No description provided for @homeFirebaseBanner.
  ///
  /// In ar, this message translates to:
  /// **'وضع تجريبي: شغّل Firebase (flutterfire configure) عشان تتزامن خطط الوجبات والمفضلة والتقييمات مع السحابة.'**
  String get homeFirebaseBanner;

  /// No description provided for @homeAllRecipes.
  ///
  /// In ar, this message translates to:
  /// **'كل الوصفات'**
  String get homeAllRecipes;

  /// No description provided for @homeSuggestions.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات لك'**
  String get homeSuggestions;

  /// No description provided for @homePantrySearch.
  ///
  /// In ar, this message translates to:
  /// **'بحث بالمكونات'**
  String get homePantrySearch;

  /// No description provided for @homeSmartMealPlan.
  ///
  /// In ar, this message translates to:
  /// **'الخطة الأسبوعية الذكية'**
  String get homeSmartMealPlan;

  /// No description provided for @homeManualMealPlan.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الخطة يدوياً'**
  String get homeManualMealPlan;

  /// No description provided for @homeFavorites.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get homeFavorites;

  /// No description provided for @homeAddRecipe.
  ///
  /// In ar, this message translates to:
  /// **'إضافة وصفة'**
  String get homeAddRecipe;

  /// No description provided for @homeFooterTagline.
  ///
  /// In ar, this message translates to:
  /// **'وصفات مصرية بلمسة دافية'**
  String get homeFooterTagline;

  /// No description provided for @homeGuestAccount.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول اختياري — أنتِ ضيفة على الجهاز'**
  String get homeGuestAccount;

  /// No description provided for @homeLogin.
  ///
  /// In ar, this message translates to:
  /// **'دخول'**
  String get homeLogin;

  /// No description provided for @homeSignOut.
  ///
  /// In ar, this message translates to:
  /// **'خروج'**
  String get homeSignOut;

  /// No description provided for @homeTrendingTitle.
  ///
  /// In ar, this message translates to:
  /// **'الوصفات الرائجة هذا الأسبوع'**
  String get homeTrendingTitle;

  /// No description provided for @homeTrendingSeeAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get homeTrendingSeeAll;

  /// No description provided for @homeTrendingEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد تريندي من السحابة حاليًا.'**
  String get homeTrendingEmpty;

  /// No description provided for @homeTrendingError.
  ///
  /// In ar, this message translates to:
  /// **'تريندي: {error}'**
  String homeTrendingError(String error);

  /// No description provided for @homePopularPrefsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأكلات المفضلة عند الناس'**
  String get homePopularPrefsTitle;

  /// No description provided for @homePopularPrefsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لما يتوفر اتصال ويشارك المستخدمون تفضيلاتهم، هتظهر هنا إحصائيات عامة فقط (بدون بيانات شخصية).'**
  String get homePopularPrefsEmpty;

  /// No description provided for @homeCloudPlansHint.
  ///
  /// In ar, this message translates to:
  /// **'خططك الأسبوعية تتزامن مع السحابة عند تسجيل الدخول.'**
  String get homeCloudPlansHint;

  /// No description provided for @homeAccountEntry.
  ///
  /// In ar, this message translates to:
  /// **'الحساب والمزامنة'**
  String get homeAccountEntry;

  /// No description provided for @mealPlanSyncLocalOnly.
  ///
  /// In ar, this message translates to:
  /// **'الخطة محفوظة على جهازك. سجّلي دخولًا اختياريًا للمزامنة مع السحابة.'**
  String get mealPlanSyncLocalOnly;

  /// No description provided for @mealPlanSyncCloud.
  ///
  /// In ar, this message translates to:
  /// **'مزامنة سحابية: تُحفظ الخطة على جهازك وتُرفع تلقائيًا عند توفر الشبكة.'**
  String get mealPlanSyncCloud;

  /// No description provided for @authEmailLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد'**
  String get authEmailLabel;

  /// No description provided for @authEmailNone.
  ///
  /// In ar, this message translates to:
  /// **'غير مرتبط'**
  String get authEmailNone;

  /// No description provided for @authSyncStatusGuest.
  ///
  /// In ar, this message translates to:
  /// **'وضع ضيف: المفضلة والخطط محليًا على الجهاز.'**
  String get authSyncStatusGuest;

  /// No description provided for @authSyncStatusCloud.
  ///
  /// In ar, this message translates to:
  /// **'متصل بالسحابة: المفضلة والخطط والتقييمات العامة تتزامن عند توفر الشبكة.'**
  String get authSyncStatusCloud;

  /// No description provided for @authGoogleTodo.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول بجوجل قريبًا'**
  String get authGoogleTodo;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In ar, this message translates to:
  /// **'لغة التطبيق'**
  String get settingsLanguageSection;

  /// No description provided for @settingsLanguageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get settingsLanguageArabic;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageHint.
  ///
  /// In ar, this message translates to:
  /// **'يتم حفظ اختيارك على الجهاز.'**
  String get settingsLanguageHint;

  /// No description provided for @settingsOpenFromAccount.
  ///
  /// In ar, this message translates to:
  /// **'العودة للحساب'**
  String get settingsOpenFromAccount;

  /// No description provided for @authTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get authTitle;

  /// No description provided for @authOpenSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات واللغة'**
  String get authOpenSettings;

  /// No description provided for @authError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ: {error}'**
  String authError(String error);

  /// No description provided for @authGuestIntro.
  ///
  /// In ar, this message translates to:
  /// **'أنتِ ضيفة على الجهاز — التقييمات العامة والمزامنة المتقدمة تحتاج تسجيل دخول اختياري.'**
  String get authGuestIntro;

  /// No description provided for @authSignedInIntro.
  ///
  /// In ar, this message translates to:
  /// **'مسجّلة دخول: {name}'**
  String authSignedInIntro(String name);

  /// No description provided for @authSyncId.
  ///
  /// In ar, this message translates to:
  /// **'معرّف المزامنة: {id}'**
  String authSyncId(String id);

  /// No description provided for @authAnonymousSignIn.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل دخول مجهول (سريع)'**
  String get authAnonymousSignIn;

  /// No description provided for @authContinueGuest.
  ///
  /// In ar, this message translates to:
  /// **'متابعة كضيفة'**
  String get authContinueGuest;

  /// No description provided for @authSignOut.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get authSignOut;

  /// No description provided for @authSignedInSnackbar.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الدخول'**
  String get authSignedInSnackbar;

  /// No description provided for @authSignInFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر: {error}'**
  String authSignInFailed(String error);

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navRecipes.
  ///
  /// In ar, this message translates to:
  /// **'الوصفات'**
  String get navRecipes;

  /// No description provided for @navAccount.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get navAccount;

  /// No description provided for @navSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get navSettings;

  /// No description provided for @recipeDetailTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الوصفة'**
  String get recipeDetailTitle;

  /// No description provided for @recipeNotAvailable.
  ///
  /// In ar, this message translates to:
  /// **'الوصفة مش متاحة'**
  String get recipeNotAvailable;

  /// No description provided for @recipeContentLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل بيانات الوصفة'**
  String get recipeContentLoadFailed;

  /// No description provided for @recipeError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ: {error}'**
  String recipeError(String error);

  /// No description provided for @ratingPublicTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقييم عام'**
  String get ratingPublicTitle;

  /// No description provided for @ratingPublicMessage.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك عشان تقييمك يظهر للناس.'**
  String get ratingPublicMessage;

  /// No description provided for @ratingCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get ratingCancel;

  /// No description provided for @ratingLocalOnly.
  ///
  /// In ar, this message translates to:
  /// **'حفظ محلي فقط'**
  String get ratingLocalOnly;

  /// No description provided for @ratingLogin.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get ratingLogin;

  /// No description provided for @ratingSavedSnackbar.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التقييم'**
  String get ratingSavedSnackbar;

  /// No description provided for @ratingSaveFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر الحفظ: {error}'**
  String ratingSaveFailed(String error);

  /// No description provided for @recipeAverageRating.
  ///
  /// In ar, this message translates to:
  /// **'متوسط التقييم: '**
  String get recipeAverageRating;

  /// No description provided for @recipeYourRating.
  ///
  /// In ar, this message translates to:
  /// **'تقييمك'**
  String get recipeYourRating;

  /// No description provided for @recipeSavingRating.
  ///
  /// In ar, this message translates to:
  /// **'جاري الحفظ…'**
  String get recipeSavingRating;

  /// No description provided for @recipeSaveRating.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التقييم'**
  String get recipeSaveRating;

  /// No description provided for @recipeSpicy.
  ///
  /// In ar, this message translates to:
  /// **'حار'**
  String get recipeSpicy;

  /// No description provided for @recipeMainIngredients.
  ///
  /// In ar, this message translates to:
  /// **'المكونات الأساسية'**
  String get recipeMainIngredients;

  /// No description provided for @recipeOptionalIngredients.
  ///
  /// In ar, this message translates to:
  /// **'مكونات اختيارية'**
  String get recipeOptionalIngredients;

  /// No description provided for @recipeSteps.
  ///
  /// In ar, this message translates to:
  /// **'الخطوات'**
  String get recipeSteps;

  /// No description provided for @recipeBack.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get recipeBack;

  /// No description provided for @recipeMinutesChip.
  ///
  /// In ar, this message translates to:
  /// **'{minutes} دقيقة'**
  String recipeMinutesChip(int minutes);

  /// No description provided for @recipeServingsChip.
  ///
  /// In ar, this message translates to:
  /// **'{count} أشخاص'**
  String recipeServingsChip(int count);

  /// No description provided for @loginTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginTitle;

  /// No description provided for @registerTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get registerTitle;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In ar, this message translates to:
  /// **'استعادة كلمة المرور'**
  String get forgotPasswordTitle;

  /// No description provided for @accountTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get accountTitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get loginPasswordLabel;

  /// No description provided for @registerNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get registerNameLabel;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get registerConfirmPassword;

  /// No description provided for @loginSubmit.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginSubmit;

  /// No description provided for @loginGoogle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول بجوجل'**
  String get loginGoogle;

  /// No description provided for @loginRegisterCta.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get loginRegisterCta;

  /// No description provided for @loginForgotCta.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get loginForgotCta;

  /// No description provided for @loginGuestCta.
  ///
  /// In ar, this message translates to:
  /// **'متابعة كضيف'**
  String get loginGuestCta;

  /// No description provided for @forgotSubmit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الرابط'**
  String get forgotSubmit;

  /// No description provided for @registerSubmit.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الحساب'**
  String get registerSubmit;

  /// No description provided for @accountSignInCta.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get accountSignInCta;

  /// No description provided for @accountRegisterCta.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get accountRegisterCta;

  /// No description provided for @accountSignOut.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get accountSignOut;

  /// No description provided for @accountGuestTitle.
  ///
  /// In ar, this message translates to:
  /// **'أنت ضيف'**
  String get accountGuestTitle;

  /// No description provided for @accountGuestBody.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ حسابًا لمزامنة المفضلة والخطط عبر الأجهزة، ونشر الوصفات والتقييمات.'**
  String get accountGuestBody;

  /// No description provided for @accountProviderLabel.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدخول'**
  String get accountProviderLabel;

  /// No description provided for @accountEmailSection.
  ///
  /// In ar, this message translates to:
  /// **'البريد'**
  String get accountEmailSection;

  /// No description provided for @forgotPasswordSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رابط استعادة كلمة المرور'**
  String get forgotPasswordSuccess;

  /// No description provided for @registerSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الحساب'**
  String get registerSuccess;

  /// No description provided for @authValEmailRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل البريد الإلكتروني'**
  String get authValEmailRequired;

  /// No description provided for @authValEmailInvalid.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني غير صالح'**
  String get authValEmailInvalid;

  /// No description provided for @authValPasswordMin.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور 6 أحرف على الأقل'**
  String get authValPasswordMin;

  /// No description provided for @authValNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'الاسم مطلوب'**
  String get authValNameRequired;

  /// No description provided for @authValPasswordMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get authValPasswordMismatch;

  /// No description provided for @authErrorWrongPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور غير صحيحة'**
  String get authErrorWrongPassword;

  /// No description provided for @authErrorUserNotFound.
  ///
  /// In ar, this message translates to:
  /// **'الحساب غير موجود'**
  String get authErrorUserNotFound;

  /// No description provided for @authErrorNetwork.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من اتصال الإنترنت'**
  String get authErrorNetwork;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In ar, this message translates to:
  /// **'البريد مستخدم بالفعل'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور ضعيفة'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorInvalidCredential.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الدخول غير صحيحة'**
  String get authErrorInvalidCredential;

  /// No description provided for @authErrorGeneric.
  ///
  /// In ar, this message translates to:
  /// **'{message}'**
  String authErrorGeneric(String message);

  /// No description provided for @homeRecommendedForYou.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات لك'**
  String get homeRecommendedForYou;

  /// No description provided for @homeRecommendedSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'حسب تفضيلاتك ومشاهداتك والرائج'**
  String get homeRecommendedSubtitle;

  /// No description provided for @addRecipeAuthRequired.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول لإضافة وصفة للمجتمع'**
  String get addRecipeAuthRequired;

  /// No description provided for @addRecipeImageUrl.
  ///
  /// In ar, this message translates to:
  /// **'رابط صورة (اختياري)'**
  String get addRecipeImageUrl;

  /// No description provided for @addRecipeIngredientsMin2.
  ///
  /// In ar, this message translates to:
  /// **'أضف مكونتين على الأقل في الأساسي'**
  String get addRecipeIngredientsMin2;

  /// No description provided for @addRecipeTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة وصفة'**
  String get addRecipeTitle;

  /// No description provided for @addRecipeEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل وصفة'**
  String get addRecipeEditTitle;

  /// No description provided for @addRecipeSubmittedPending.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الوصفة للمراجعة'**
  String get addRecipeSubmittedPending;

  /// No description provided for @addRecipeUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الوصفة'**
  String get addRecipeUpdated;

  /// No description provided for @accountAdminPanel.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get accountAdminPanel;

  /// No description provided for @accountMySubmissions.
  ///
  /// In ar, this message translates to:
  /// **'وصفاتي المرسلة'**
  String get accountMySubmissions;

  /// No description provided for @adminDashboardTitle.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get adminDashboardTitle;

  /// No description provided for @adminSectionPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get adminSectionPending;

  /// No description provided for @adminSectionApproved.
  ///
  /// In ar, this message translates to:
  /// **'مقبولة'**
  String get adminSectionApproved;

  /// No description provided for @adminSectionRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوضة'**
  String get adminSectionRejected;

  /// No description provided for @adminSectionStats.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات التطبيق'**
  String get adminSectionStats;

  /// No description provided for @adminReview.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة'**
  String get adminReview;

  /// No description provided for @adminApprove.
  ///
  /// In ar, this message translates to:
  /// **'قبول'**
  String get adminApprove;

  /// No description provided for @adminReject.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get adminReject;

  /// No description provided for @adminEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get adminEdit;

  /// No description provided for @adminDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get adminDelete;

  /// No description provided for @adminHide.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء عن العامة'**
  String get adminHide;

  /// No description provided for @adminRejectTitle.
  ///
  /// In ar, this message translates to:
  /// **'سبب الرفض'**
  String get adminRejectTitle;

  /// No description provided for @adminRejectHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتبي سبب الرفض للمستخدمة'**
  String get adminRejectHint;

  /// No description provided for @adminStatsTitle.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات'**
  String get adminStatsTitle;

  /// No description provided for @adminStatsUsers.
  ///
  /// In ar, this message translates to:
  /// **'المستخدمون'**
  String get adminStatsUsers;

  /// No description provided for @adminStatsRecipes.
  ///
  /// In ar, this message translates to:
  /// **'الوصفات'**
  String get adminStatsRecipes;

  /// No description provided for @adminStatsPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get adminStatsPending;

  /// No description provided for @adminStatsApproved.
  ///
  /// In ar, this message translates to:
  /// **'مقبولة'**
  String get adminStatsApproved;

  /// No description provided for @adminStatsRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوضة'**
  String get adminStatsRejected;

  /// No description provided for @adminStatsRatingsNote.
  ///
  /// In ar, this message translates to:
  /// **'عدد التقييمات التفصيلي يحتاج فهرسة إضافية (TODO).'**
  String get adminStatsRatingsNote;

  /// No description provided for @adminStatsTopRatedTodo.
  ///
  /// In ar, this message translates to:
  /// **'أعلى التقييم: TODO — تجميع سحابي'**
  String get adminStatsTopRatedTodo;

  /// No description provided for @adminStatsFavoritesTodo.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر مفضلة: TODO — تجميع من users.favoriteRecipeIds'**
  String get adminStatsFavoritesTodo;

  /// No description provided for @mySubmittedTitle.
  ///
  /// In ar, this message translates to:
  /// **'وصفاتي المرسلة'**
  String get mySubmittedTitle;

  /// No description provided for @recipeStatusPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get recipeStatusPending;

  /// No description provided for @recipeStatusApproved.
  ///
  /// In ar, this message translates to:
  /// **'مقبولة'**
  String get recipeStatusApproved;

  /// No description provided for @recipeStatusRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوضة'**
  String get recipeStatusRejected;

  /// No description provided for @recipeRejectedReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب الرفض: {reason}'**
  String recipeRejectedReason(String reason);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
