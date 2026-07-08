import 'package:flutter/material.dart';
import 'package:luqma_haneya/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/recipe_rating_resolve.dart';
import '../../../core/widgets/lh_recipe_tile.dart';
import '../../../core/widgets/lh_section_header.dart';
import '../../../di/providers.dart';
import '../../../domain/repositories/recipe_repository.dart';
import '../../../domain/value_objects/recipe_category.dart';

class RecipeSuggestionScreen extends ConsumerStatefulWidget {
  const RecipeSuggestionScreen({super.key, this.initialMode});

  final String? initialMode;

  @override
  ConsumerState<RecipeSuggestionScreen> createState() =>
      _RecipeSuggestionScreenState();
}

class _RecipeSuggestionScreenState
    extends ConsumerState<RecipeSuggestionScreen> {
  late String _mode;

  @override
  void initState() {
    super.initState();
    _mode = RecipeCategory.normalize(widget.initialMode);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(suggestionBundleProvider(_mode));
    final l10n = AppLocalizations.of(context)!;
    final isDiet = _mode == RecipeCategory.diet;

    return Scaffold(
      appBar: AppBar(
        title: Text(isDiet ? 'اقتراحات دايت' : l10n.homeSuggestions),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: RecipeCategory.normal,
                  label: Text('وصفات البيت'),
                ),
                ButtonSegment(
                  value: RecipeCategory.diet,
                  label: Text('دايت'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() => _mode = s.first),
            ),
          ),
          Expanded(
            child: async.when(
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
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: LhSectionHeader(
                          title: isDiet
                              ? 'اقتراحات دايت لك'
                              : l10n.homeRecommendedForYou,
                          subtitle:
                              '${l10n.homeRecommendedSubtitle} — $kDailySuggestionDisplayLimit',
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
                        ref.invalidate(suggestionBundleProvider(_mode));
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
          ),
        ],
      ),
    );
  }
}
