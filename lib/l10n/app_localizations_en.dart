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
  String get homeTrendingTitle => 'Trending recipes this week';

  @override
  String get homeTrendingSeeAll => 'See all';

  @override
  String get homeTrendingEmpty => 'No cloud trending data right now.';

  @override
  String homeTrendingError(String error) {
    return 'Trending: $error';
  }

  @override
  String get homePopularPrefsTitle => 'Popular tastes (community)';

  @override
  String get homePopularPrefsEmpty =>
      'When online, anonymous counts of favorite tags may appear here. No personal data is shown.';

  @override
  String get homeCloudPlansHint =>
      'Weekly plans sync to the cloud after you sign in.';

  @override
  String get homeAccountEntry => 'Account & sync';

  @override
  String get mealPlanSyncLocalOnly =>
      'Plan is saved on this device only. Optional sign-in enables cloud sync.';

  @override
  String get mealPlanSyncCloud =>
      'Cloud sync: your plan is saved locally and uploaded when the network is available.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailNone => 'Not linked';

  @override
  String get authSyncStatusGuest =>
      'Guest mode: favorites and meal plans stay on this device.';

  @override
  String get authSyncStatusCloud =>
      'Cloud: favorites, meal plans, and public ratings sync when online.';

  @override
  String get authGoogleTodo => 'Google sign-in coming later';

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
  String get recipeContentLoadFailed => 'Could not load recipe details';

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

  @override
  String get loginTitle => 'Sign in';

  @override
  String get registerTitle => 'Create account';

  @override
  String get forgotPasswordTitle => 'Reset password';

  @override
  String get accountTitle => 'Account';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get registerNameLabel => 'Name';

  @override
  String get registerConfirmPassword => 'Confirm password';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginGoogle => 'Sign in with Google';

  @override
  String get loginRegisterCta => 'Create new account';

  @override
  String get loginForgotCta => 'Forgot password?';

  @override
  String get loginGuestCta => 'Continue as guest';

  @override
  String get forgotSubmit => 'Send reset link';

  @override
  String get registerSubmit => 'Create account';

  @override
  String get accountSignInCta => 'Sign in';

  @override
  String get accountRegisterCta => 'Create account';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get accountGuestTitle => 'Guest mode';

  @override
  String get accountGuestBody =>
      'Create an account to sync favorites and plans, publish recipes, and post public ratings.';

  @override
  String get accountProviderLabel => 'Sign-in method';

  @override
  String get accountEmailSection => 'Email';

  @override
  String get forgotPasswordSuccess => 'Password reset link sent';

  @override
  String get registerSuccess => 'Account created';

  @override
  String get authValEmailRequired => 'Email is required';

  @override
  String get authValEmailInvalid => 'Invalid email address';

  @override
  String get authValPasswordMin => 'Password must be at least 6 characters';

  @override
  String get authValNameRequired => 'Name is required';

  @override
  String get authValPasswordMismatch => 'Passwords do not match';

  @override
  String get authErrorWrongPassword => 'Incorrect password';

  @override
  String get authErrorUserNotFound => 'Account not found';

  @override
  String get authErrorNetwork => 'Check your internet connection';

  @override
  String get authErrorEmailInUse => 'Email is already in use';

  @override
  String get authErrorWeakPassword => 'Password is too weak';

  @override
  String get authErrorInvalidCredential => 'Invalid sign-in credentials';

  @override
  String authErrorGeneric(String message) {
    return '$message';
  }

  @override
  String get homeRecommendedForYou => 'Suggestions for you';

  @override
  String get homeRecommendedSubtitle =>
      'Based on your tastes, history, and what is trending';

  @override
  String get addRecipeAuthRequired => 'Sign in to publish a recipe';

  @override
  String get addRecipeImageUrl => 'Image URL (optional)';

  @override
  String get addRecipeIngredientsMin2 => 'Add at least two main ingredients';

  @override
  String get addRecipeTitle => 'Add recipe';

  @override
  String get addRecipeEditTitle => 'Edit recipe';

  @override
  String get addRecipeSubmittedPending => 'Recipe submitted for review';

  @override
  String get addRecipeUpdated => 'Recipe updated';

  @override
  String get accountAdminPanel => 'Admin dashboard';

  @override
  String get accountMySubmissions => 'My submitted recipes';

  @override
  String get adminDashboardTitle => 'Admin dashboard';

  @override
  String get adminSectionPending => 'Pending';

  @override
  String get adminSectionApproved => 'Approved';

  @override
  String get adminSectionRejected => 'Rejected';

  @override
  String get adminSectionStats => 'App statistics';

  @override
  String get adminReview => 'Review';

  @override
  String get adminApprove => 'Approve';

  @override
  String get adminReject => 'Reject';

  @override
  String get adminEdit => 'Edit';

  @override
  String get adminDelete => 'Delete';

  @override
  String get adminHide => 'Hide from public';

  @override
  String get adminRejectTitle => 'Rejection reason';

  @override
  String get adminRejectHint => 'Enter a reason for the submitter';

  @override
  String get adminStatsTitle => 'Statistics';

  @override
  String get adminStatsUsers => 'Users';

  @override
  String get adminStatsRecipes => 'Recipes';

  @override
  String get adminStatsPending => 'Pending';

  @override
  String get adminStatsApproved => 'Approved';

  @override
  String get adminStatsRejected => 'Rejected';

  @override
  String get adminStatsRatingsNote =>
      'Detailed rating counts need extra indexing (TODO).';

  @override
  String get adminStatsTopRatedTodo => 'Top rated: TODO — cloud aggregation';

  @override
  String get adminStatsFavoritesTodo =>
      'Most favorited: TODO — aggregate users.favoriteRecipeIds';

  @override
  String get mySubmittedTitle => 'My submitted recipes';

  @override
  String get recipeStatusPending => 'Under review';

  @override
  String get recipeStatusApproved => 'Approved';

  @override
  String get recipeStatusRejected => 'Rejected';

  @override
  String recipeRejectedReason(String reason) {
    return 'Rejection reason: $reason';
  }
}
