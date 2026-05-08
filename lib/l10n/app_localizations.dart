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
  /// **'اقتراحات لي'**
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
  /// **'وصفات تريندي هذا الأسبوع ({weekKey})'**
  String homeTrendingTitle(String weekKey);

  /// No description provided for @homeTrendingSeeAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get homeTrendingSeeAll;

  /// No description provided for @homeTrendingError.
  ///
  /// In ar, this message translates to:
  /// **'تريندي: {error}'**
  String homeTrendingError(String error);

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
