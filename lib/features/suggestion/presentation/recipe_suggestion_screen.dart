import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/recipe_rating_resolve.dart';
import '../../../core/widgets/lh_recipe_tile.dart';
import '../../../core/widgets/lh_section_header.dart';
import '../../../di/providers.dart';
import '../../../domain/repositories/recipe_repository.dart';

class RecipeSuggestionScreen extends ConsumerWidget {
  const RecipeSuggestionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(suggestionBundleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('اقتراحات لي'),
      ),
      body: async.when(
        data: (bundle) {
          final list = bundle.suggestions;
          if (list.isEmpty) {
            return const Center(child: Text('مفيش اقتراحات حالياً'));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            itemCount: list.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              if (i == 0) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: LhSectionHeader(
                    title: 'اختاروا أكلة تناسب المود',
                    subtitle:
                        'مرتبة من الأنسب لتفضيلاتك ومفضلاتك وتقييماتك — حتى $kDailySuggestionDisplayLimit وصفات في الشاشة دي فقط (مش كل الكتالوج).',
                  ),
                );
              }
              final r = list[i - 1];
              return LhRecipeTile(
                recipe: r,
                ratingSummary: resolveRatingDisplay(r, bundle.summaries),
                isFavorite: bundle.favorites.contains(r.id),
                onFavoriteTap: () async {
                  await ref.read(favoritesRepositoryProvider).setFavorite(
                        r.id,
                        !bundle.favorites.contains(r.id),
                      );
                  ref.invalidate(suggestionBundleProvider);
                  ref.invalidate(favoriteIdsProvider);
                },
                onTap: () => context.push('/recipe/${r.id}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('حصل خطأ: $e', textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
