import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/bootstrap.dart';
import '../data/datasources/meal_plan_local_datasource.dart';
import '../data/datasources/meal_plan_remote_datasource.dart';
import '../data/datasources/preferences_local_datasource.dart';
import '../data/datasources/recipe_local_datasource.dart';
import '../data/datasources/recipe_remote_datasource.dart';
import '../data/datasources/user_identity_local_datasource.dart';
import '../data/repositories/meal_plan_repository_impl.dart';
import '../data/repositories/preferences_repository_impl.dart';
import '../data/repositories/recipe_repository_impl.dart';
import '../domain/repositories/meal_plan_repository.dart';
import '../domain/repositories/preferences_repository.dart';
import '../domain/repositories/recipe_repository.dart';

final preferencesLocalDsProvider = Provider<PreferencesLocalDataSource>(
  (ref) => PreferencesLocalDataSource(),
);

final preferencesRepositoryProvider = Provider<PreferencesRepository>(
  (ref) => PreferencesRepositoryImpl(ref.watch(preferencesLocalDsProvider)),
);

final recipeLocalDsProvider = Provider<RecipeLocalDataSource>(
  (ref) => RecipeLocalDataSource(),
);

final recipeRemoteDsProvider = Provider<RecipeRemoteDataSource>(
  (ref) => RecipeRemoteDataSource(
    firebaseAppReady ? FirebaseFirestore.instance : null,
  ),
);

final recipeRepositoryProvider = Provider<RecipeRepository>(
  (ref) => RecipeRepositoryImpl(
    local: ref.watch(recipeLocalDsProvider),
    remote: ref.watch(recipeRemoteDsProvider),
  ),
);

final mealPlanLocalDsProvider = Provider<MealPlanLocalDataSource>(
  (ref) => MealPlanLocalDataSource(),
);

final mealPlanRemoteDsProvider = Provider<MealPlanRemoteDataSource>(
  (ref) => MealPlanRemoteDataSource(
    firebaseAppReady ? FirebaseFirestore.instance : null,
  ),
);

final userIdentityDsProvider = Provider<UserIdentityLocalDataSource>(
  (ref) => UserIdentityLocalDataSource(),
);

final mealPlanRepositoryProvider = Provider<MealPlanRepository>(
  (ref) => MealPlanRepositoryImpl(
    local: ref.watch(mealPlanLocalDsProvider),
    remote: ref.watch(mealPlanRemoteDsProvider),
    identity: ref.watch(userIdentityDsProvider),
  ),
);

final firebaseReadyProvider = Provider<bool>((ref) => firebaseAppReady);
