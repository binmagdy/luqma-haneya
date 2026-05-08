import 'package:flutter/material.dart';
import 'package:luqma_haneya/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/recipe_labels_ar.dart';
import '../../../core/recipe_rating_resolve.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/lh_favorite_button.dart';
import '../../../core/widgets/lh_primary_button.dart';
import '../../../core/widgets/lh_rating_stars.dart';
import '../../../core/widgets/lh_section_header.dart';
import '../../../di/providers.dart';
import '../../../domain/entities/recipe_entity.dart';
import '../../../domain/entities/recipe_rating_summary.dart';

final _recipeProvider = FutureProvider.family<RecipeEntity?, String>((ref, id) {
  return ref.watch(recipeRepositoryProvider).getRecipeById(id);
});

class RecipeDetailScreen extends ConsumerStatefulWidget {
  const RecipeDetailScreen({super.key, required this.recipeId});

  final String recipeId;

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  var _loggedView = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loggedView) return;
    _loggedView = true;
    ref.read(viewedRecipesLocalDsProvider).recordView(widget.recipeId);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_recipeProvider(widget.recipeId));
    final sums = ref.watch(ratingSummariesProvider);
    final favs = ref.watch(favoriteIdsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recipeDetailTitle),
        actions: [
          favs.when(
            data: (set) {
              final on = set.contains(widget.recipeId);
              return LhFavoriteButton(
                isFavorite: on,
                onPressed: () async {
                  await ref
                      .read(favoritesRepositoryProvider)
                      .setFavorite(widget.recipeId, !on);
                  ref.invalidate(favoriteIdsProvider);
                  ref.invalidate(suggestionBundleProvider);
                },
                size: 26,
              );
            },
            loading: () => const SizedBox(width: 48),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: async.when(
        data: (recipe) {
          if (recipe == null) {
            return Center(child: Text(l10n.recipeNotAvailable));
          }
          return sums.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text(l10n.recipeError(e.toString()))),
            data: (sumMap) {
              return _RecipeBody(
                recipe: recipe,
                recipeId: widget.recipeId,
                ratingSummary: resolveRatingDisplay(recipe, sumMap),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.recipeError(e.toString()))),
      ),
    );
  }
}

class _RecipeBody extends ConsumerStatefulWidget {
  const _RecipeBody({
    required this.recipe,
    required this.recipeId,
    required this.ratingSummary,
  });

  final RecipeEntity recipe;
  final String recipeId;
  final RecipeRatingSummary? ratingSummary;

  @override
  ConsumerState<_RecipeBody> createState() => _RecipeBodyState();
}

enum _GuestRatingChoice { cancel, localOnly, login }

class _RecipeBodyState extends ConsumerState<_RecipeBody> {
  int? _draftStars;
  var _saving = false;

  Future<void> _saveRating(int stars) async {
    final session = await ref.read(authSessionProvider.future);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    var publishPublic = session.canPublishPublicRatings;

    if (!session.canPublishPublicRatings) {
      if (!mounted) return;
      final choice = await showDialog<_GuestRatingChoice>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.ratingPublicTitle),
          content: Text(l10n.ratingPublicMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, _GuestRatingChoice.cancel),
              child: Text(l10n.ratingCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, _GuestRatingChoice.localOnly),
              child: Text(l10n.ratingLocalOnly),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, _GuestRatingChoice.login),
              child: Text(l10n.ratingLogin),
            ),
          ],
        ),
      );
      if (!mounted) return;
      switch (choice) {
        case _GuestRatingChoice.login:
          context.push('/auth');
          return;
        case _GuestRatingChoice.localOnly:
          publishPublic = false;
          break;
        case _GuestRatingChoice.cancel:
        case null:
          return;
      }
    }

    setState(() => _saving = true);
    try {
      await ref.read(ratingRepositoryProvider).setMyRating(
            widget.recipeId,
            stars,
            publishPublic: publishPublic,
          );
      ref.invalidate(myRatingProvider(widget.recipeId));
      ref.invalidate(ratingSummariesProvider);
      ref.invalidate(allRecipesCatalogProvider);
      ref.invalidate(suggestionBundleProvider);
      if (!mounted) return;
      setState(() => _draftStars = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.ratingSavedSnackbar)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.ratingSaveFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final my = ref.watch(myRatingProvider(widget.recipeId));
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(
          widget.recipe.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.recipe.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.inkMuted,
                height: 1.5,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Text(l10n.recipeAverageRating),
            LhRatingSummaryRow(
              summary: widget.ratingSummary,
              compact: false,
            ),
          ],
        ),
        const SizedBox(height: 16),
        LhSectionHeader(title: l10n.recipeYourRating),
        const SizedBox(height: 6),
        my.when(
          data: (v) {
            final effective = _draftStars ?? v;
            return Column(
              children: [
                LhRatingPicker(
                  value: effective,
                  onChanged: (s) => setState(() => _draftStars = s),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _saving || effective == null
                      ? null
                      : () => _saveRating(effective),
                  child: Text(
                    _saving ? l10n.recipeSavingRating : l10n.recipeSaveRating,
                  ),
                ),
              ],
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text(l10n.recipeError(e.toString())),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          textDirection: TextDirection.rtl,
          children: [
            _MetaChip(
                icon: Icons.schedule_rounded,
                label: l10n.recipeMinutesChip(widget.recipe.minutes)),
            _MetaChip(
              icon: Icons.people_alt_rounded,
              label: l10n.recipeServingsChip(widget.recipe.servings),
            ),
            _MetaChip(
              icon: Icons.wb_sunny_outlined,
              label: RecipeLabelsAr.mealType(widget.recipe.mealType),
            ),
            _MetaChip(
              icon: Icons.trending_flat_rounded,
              label: RecipeLabelsAr.difficulty(widget.recipe.difficulty),
            ),
            _MetaChip(
              icon: Icons.payments_outlined,
              label: RecipeLabelsAr.budget(widget.recipe.budget),
            ),
            _MetaChip(
              icon: Icons.public_rounded,
              label: RecipeLabelsAr.cuisine(widget.recipe.cuisine),
            ),
            if (widget.recipe.spicy)
              Chip(
                avatar:
                    const Icon(Icons.local_fire_department_rounded, size: 18),
                label: Text(l10n.recipeSpicy),
              ),
            ...widget.recipe.tags.map(
              (t) => Chip(
                label: Text(t),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        LhSectionHeader(title: l10n.recipeMainIngredients),
        const SizedBox(height: 10),
        ...widget.recipe.mainIngredients.map(
          (line) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                const Text('•  '),
                Expanded(child: Text(line, textAlign: TextAlign.right)),
              ],
            ),
          ),
        ),
        if (widget.recipe.optionalIngredients.isNotEmpty) ...[
          const SizedBox(height: 12),
          LhSectionHeader(title: l10n.recipeOptionalIngredients),
          const SizedBox(height: 10),
          ...widget.recipe.optionalIngredients.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  const Text('•  '),
                  Expanded(child: Text(line, textAlign: TextAlign.right)),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        LhSectionHeader(title: l10n.recipeSteps),
        const SizedBox(height: 10),
        ...List.generate(widget.recipe.steps.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.terracotta.withValues(alpha: 0.2),
                  foregroundColor: AppColors.terracottaDark,
                  child: Text('${i + 1}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.recipe.steps[i],
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        LhPrimaryButton(
          label: l10n.recipeBack,
          expanded: true,
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: AppColors.olive),
      label: Text(label),
    );
  }
}
