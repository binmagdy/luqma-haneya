import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/recipe_rating_resolve.dart';
import '../../../core/widgets/lh_recipe_tile.dart';
import '../../../core/widgets/lh_section_header.dart';
import '../../../di/providers.dart';
import '../../../domain/entities/recipe_entity.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cat = ref.watch(allRecipesCatalogProvider);
    final favs = ref.watch(favoriteIdsProvider);
    final sums = ref.watch(ratingSummariesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('المفضلة')),
      body: cat.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (all) {
          return favs.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('خطأ: $e')),
            data: (favSet) {
              return sums.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('خطأ: $e')),
                data: (sumMap) {
                  final favRecipes = <RecipeEntity>[];
                  for (final r in all) {
                    if (favSet.contains(r.id)) favRecipes.add(r);
                  }
                  if (favRecipes.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'مفيش وصفات في المفضلة — اضغطي القلب على أي وصفة.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: favRecipes.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: LhSectionHeader(
                            title: 'وصفاتك المفضلة',
                            subtitle: 'متاحة بدون إنترنت بعد أول تحميل.',
                          ),
                        );
                      }
                      final r = favRecipes[i - 1];
                      return LhRecipeTile(
                        recipe: r,
                        ratingSummary: resolveRatingDisplay(r, sumMap),
                        isFavorite: true,
                        onFavoriteTap: () async {
                          await ref
                              .read(favoritesRepositoryProvider)
                              .setFavorite(r.id, false);
                          ref.invalidate(favoriteIdsProvider);
                        },
                        onTap: () => context.push('/recipe/${r.id}'),
                      );
                    },
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
