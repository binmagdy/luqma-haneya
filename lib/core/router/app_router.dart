import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/add_recipe/presentation/add_recipe_screen.dart';
import '../../features/browse/presentation/all_recipes_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/meal_plan/presentation/meal_plan_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/pantry/presentation/pantry_screen.dart';
import '../../features/recipe_detail/presentation/recipe_detail_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/suggestion/presentation/recipe_suggestion_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
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
        builder: (context, state) => const AddRecipeScreen(),
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
    ],
  );
});
