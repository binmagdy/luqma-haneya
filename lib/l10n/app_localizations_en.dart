// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Luqma Haneya';

  @override
  String get homeWeekPlanTooltip => 'Week plan';

  @override
  String get homeSettingsTooltip => 'Settings';

  @override
  String get homeHeadline => 'Hungry for something good today?';

  @override
  String get homeSubtitle =>
      'Browse recipes, get smart suggestions, search by ingredients, plan your week, or add your own recipe.';

  @override
  String get homeFirebaseBanner =>
      'Demo mode: run flutterfire configure so meal plans, favorites, and ratings sync to the cloud.';

  @override
  String get homeAllRecipes => 'All recipes';

  @override
  String get homeSuggestions => 'Suggestions for me';

  @override
  String get homePantrySearch => 'Search by ingredients';

  @override
  String get homeSmartMealPlan => 'Smart weekly plan';

  @override
  String get homeManualMealPlan => 'Edit plan manually';

  @override
  String get homeFavorites => 'Favorites';

  @override
  String get homeAddRecipe => 'Add recipe';

  @override
  String get homeFooterTagline => 'Egyptian home cooking, warmly';

  @override
  String get homeGuestAccount =>
      'Sign-in is optional — you are browsing as a guest';

  @override
  String get homeLogin => 'Sign in';

  @override
  String get homeSignOut => 'Sign out';

  @override
  String homeTrendingTitle(String weekKey) {
    return 'Trending recipes this week ($weekKey)';
  }

  @override
  String get homeTrendingSeeAll => 'See all';

  @override
  String homeTrendingError(String error) {
    return 'Trending: $error';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageSection => 'App language';

  @override
  String get settingsLanguageArabic => 'Arabic';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageHint => 'Your choice is saved on this device.';

  @override
  String get settingsOpenFromAccount => 'Back to account';

  @override
  String get authTitle => 'Account';

  @override
  String get authOpenSettings => 'Settings & language';

  @override
  String authError(String error) {
    return 'Error: $error';
  }

  @override
  String get authGuestIntro =>
      'You are a guest on this device — public ratings and advanced sync need optional sign-in.';

  @override
  String authSignedInIntro(String name) {
    return 'Signed in: $name';
  }

  @override
  String authSyncId(String id) {
    return 'Sync ID: $id';
  }

  @override
  String get authAnonymousSignIn => 'Anonymous sign-in (quick)';

  @override
  String get authContinueGuest => 'Continue as guest';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get authSignedInSnackbar => 'Signed in';

  @override
  String authSignInFailed(String error) {
    return 'Could not sign in: $error';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navRecipes => 'Recipes';

  @override
  String get navAccount => 'Account';

  @override
  String get navSettings => 'Settings';

  @override
  String get recipeDetailTitle => 'Recipe details';

  @override
  String get recipeNotAvailable => 'Recipe not available';

  @override
  String recipeError(String error) {
    return 'Error: $error';
  }

  @override
  String get ratingPublicTitle => 'Public rating';

  @override
  String get ratingPublicMessage =>
      'Sign in so your rating can appear to others.';

  @override
  String get ratingCancel => 'Cancel';

  @override
  String get ratingLocalOnly => 'Save locally only';

  @override
  String get ratingLogin => 'Sign in';

  @override
  String get ratingSavedSnackbar => 'Rating saved';

  @override
  String ratingSaveFailed(String error) {
    return 'Could not save: $error';
  }

  @override
  String get recipeAverageRating => 'Average rating: ';

  @override
  String get recipeYourRating => 'Your rating';

  @override
  String get recipeSavingRating => 'Saving…';

  @override
  String get recipeSaveRating => 'Save rating';

  @override
  String get recipeSpicy => 'Spicy';

  @override
  String get recipeMainIngredients => 'Main ingredients';

  @override
  String get recipeOptionalIngredients => 'Optional ingredients';

  @override
  String get recipeSteps => 'Steps';

  @override
  String get recipeBack => 'Back';

  @override
  String recipeMinutesChip(int minutes) {
    return '$minutes min';
  }

  @override
  String recipeServingsChip(int count) {
    return '$count servings';
  }
}
