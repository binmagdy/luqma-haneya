import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/recipe_rating_resolve.dart';
import '../../../core/utils/week_calendar.dart';
import '../../../core/widgets/lh_recipe_tile.dart';
import '../../../di/providers.dart';

class TrendingScreen extends ConsumerWidget {
  const TrendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(trendingRecipesProvider);
    final sums = ref.watch(ratingSummariesProvider);
    final favs = ref.watch(favoriteIdsProvider);
    final wk = isoWeekKey(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('تريندي الأسبوع')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (list) {
          return sums.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('خطأ: $e')),
            data: (sumMap) {
              return favs.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('خطأ: $e')),
                data: (favSet) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    children: [
                      Text(
                        'أسبوع $wk — مرتبة حسب التقييمات العامة عند توفرها، مع بدائل محلية.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      for (final r in list)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: LhRecipeTile(
                            recipe: r,
                            ratingSummary: resolveRatingDisplay(r, sumMap),
                            isFavorite: favSet.contains(r.id),
                            onFavoriteTap: () async {
                              await ref
                                  .read(favoritesRepositoryProvider)
                                  .setFavorite(
                                    r.id,
                                    !favSet.contains(r.id),
                                  );
                              ref.invalidate(favoriteIdsProvider);
                            },
                            onTap: () => context.push('/recipe/${r.id}'),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
