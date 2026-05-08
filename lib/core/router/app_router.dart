import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/recipe_model.dart';
import '../../di/providers.dart';
import '../../domain/value_objects/recipe_moderation.dart';
import '../../features/add_recipe/presentation/add_recipe_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/admin/presentation/admin_recipe_list_screen.dart';
import '../../features/admin/presentation/admin_recipe_review_screen.dart';
import '../../features/admin/presentation/admin_stats_screen.dart';
import '../../features/auth/presentation/account_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/browse/presentation/all_recipes_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/meal_plan/presentation/meal_plan_screen.dart';
import '../../features/smart_meal_plan/presentation/smart_meal_plan_screen.dart';
import '../../features/trending/presentation/trending_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/pantry/presentation/pantry_screen.dart';
import '../../features/recipe_detail/presentation/recipe_detail_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/suggestion/presentation/recipe_suggestion_screen.dart';
import '../../features/user_recipes/presentation/my_submitted_recipes_screen.dart';
import '../bootstrap.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(goRouterAuthRefreshProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      if (!firebaseAppReady) return null;
      final loc = state.matchedLocation;
      if (loc == '/auth') return '/account';
      final onLoginFlow =
          loc == '/login' || loc == '/register' || loc == '/forgot-password';
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && onLoginFlow) {
        return '/home';
      }
      if (loc.startsWith('/admin')) {
        final av = ref.read(appUserContextProvider);
        if (av.isLoading) return null;
        final admin = av.hasValue && av.requireValue.isAdmin;
        if (!admin) return '/account';
      }
      if (loc == '/my-recipes') {
        final s = ref.read(authSessionProvider);
        if (s.isLoading) return null;
        final v = s.valueOrNull;
        if (v == null ||
            !v.isLoggedIn ||
            v.firebaseIsAnonymous) {
          return '/login';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/recipes',
        builder: (context, state) => const AllRecipesScreen(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/add-recipe',
        builder: (context, state) {
          final extra = state.extra;
          final initial = extra is RecipeModel ? extra : null;
          return AddRecipeScreen(initialRecipe: initial);
        },
      ),
      GoRoute(
        path: '/suggest',
        builder: (context, state) => const RecipeSuggestionScreen(),
      ),
      GoRoute(
        path: '/recipe/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return RecipeDetailScreen(recipeId: id);
        },
      ),
      GoRoute(
        path: '/pantry',
        builder: (context, state) => const PantryScreen(),
      ),
      GoRoute(
        path: '/meal-plan',
        builder: (context, state) => const MealPlanScreen(),
      ),
      GoRoute(
        path: '/smart-meal-plan',
        builder: (context, state) => const SmartMealPlanScreen(),
      ),
      GoRoute(
        path: '/trending',
        builder: (context, state) => const TrendingScreen(),
      ),
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/pending',
        builder: (context, state) => const AdminRecipeListScreen(
          status: RecipeModerationStatus.pending,
        ),
      ),
      GoRoute(
        path: '/admin/approved',
        builder: (context, state) => const AdminRecipeListScreen(
          status: RecipeModerationStatus.approved,
        ),
      ),
      GoRoute(
        path: '/admin/rejected',
        builder: (context, state) => const AdminRecipeListScreen(
          status: RecipeModerationStatus.rejected,
        ),
      ),
      GoRoute(
        path: '/admin/review/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AdminRecipeReviewScreen(recipeId: id);
        },
      ),
      GoRoute(
        path: '/admin/stats',
        builder: (context, state) => const AdminStatsScreen(),
      ),
      GoRoute(
        path: '/my-recipes',
        builder: (context, state) => const MySubmittedRecipesScreen(),
      ),
    ],
  );
});
