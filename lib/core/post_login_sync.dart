import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/providers.dart';

/// Merges local favorites, meal plans, and preferences into Firestore after sign-in.
Future<void> syncLocalUserDataToCloud(WidgetRef ref) async {
  final session = await ref.read(authRepositoryProvider).readSession();
  final uid = session.firebaseUid;
  if (uid == null) return;

  final remote = ref.read(userProfileRemoteDsProvider);
  if (remote.isAvailable) {
    try {
      final prefs =
          await ref.read(preferencesRepositoryProvider).loadPreferences();
      await remote.mergePreferencesFromLocal(uid, prefs);
    } catch (_) {
      /* offline */
    }
  }

  try {
    await ref.read(favoritesRepositoryProvider).pushLocalFavoritesToCloud();
  } catch (_) {
    /* offline */
  }

  if (remote.isAvailable) {
    try {
      final favs =
          await ref.read(favoritesRepositoryProvider).favoriteRecipeIds();
      await remote.mergeFavoriteRecipeIds(uid, favs);
    } catch (_) {
      /* offline */
    }
  }

  try {
    await ref.read(mealPlanRepositoryProvider).pushAllLocalWeeksToCloud();
  } catch (_) {
    /* offline */
  }

  ref.invalidate(favoriteIdsProvider);
}
