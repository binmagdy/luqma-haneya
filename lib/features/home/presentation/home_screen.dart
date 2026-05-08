import 'package:flutter/material.dart';
import 'package:luqma_haneya/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/recipe_rating_resolve.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/week_calendar.dart';
import '../../../core/widgets/lh_primary_button.dart';
import '../../../core/widgets/lh_recipe_tile.dart';
import '../../../di/providers.dart';
import '../../../domain/entities/recipe_entity.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseOn = ref.watch(firebaseReadyProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.homeWeekPlanTooltip,
            onPressed: () => context.push('/meal-plan'),
            icon: const Icon(Icons.calendar_month_rounded),
          ),
          IconButton(
            tooltip: l10n.homeSettingsTooltip,
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              const SizedBox(height: 8),
              const _HomeAccountStrip(),
              const SizedBox(height: 12),
              Text(
                l10n.homeHeadline,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.homeSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkMuted,
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: 20),
              const _HomeTrendingSection(),
              const SizedBox(height: 24),
              if (!firebaseOn)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        l10n.homeFirebaseBanner,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
              LhPrimaryButton(
                label: l10n.homeAllRecipes,
                icon: Icons.menu_book_rounded,
                expanded: true,
                onPressed: () => context.push('/recipes'),
              ),
              const SizedBox(height: 12),
              LhPrimaryButton(
                label: l10n.homeSuggestions,
                icon: Icons.auto_awesome_rounded,
                expanded: true,
                onPressed: () => context.push('/suggest'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push('/pantry'),
                icon: const Icon(Icons.kitchen_rounded),
                label: Text(l10n.homePantrySearch),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.olive,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.oliveLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push('/smart-meal-plan'),
                icon: const Icon(Icons.auto_graph_rounded),
                label: Text(l10n.homeSmartMealPlan),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.olive,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.oliveLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push('/meal-plan'),
                icon: const Icon(Icons.edit_calendar_rounded),
                label: Text(l10n.homeManualMealPlan),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.olive,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.oliveLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push('/favorites'),
                icon: const Icon(Icons.favorite_rounded),
                label: Text(l10n.homeFavorites),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.olive,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.oliveLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push('/add-recipe'),
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: Text(l10n.homeAddRecipe),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.olive,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.oliveLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                l10n.homeFooterTagline,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.inkMuted,
                    ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeAccountStrip extends ConsumerWidget {
  const _HomeAccountStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final l10n = AppLocalizations.of(context)!;

    return session.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (s) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => context.push('/auth'),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.cream.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.oliveLight.withValues(alpha: 0.4),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(
                      s.isGuest
                          ? Icons.person_off_outlined
                          : Icons.person_rounded,
                      color: AppColors.olive,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.isGuest
                            ? l10n.homeGuestAccount
                            : (s.resolvedDisplayName ?? s.firestoreSyncId),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    if (s.isGuest)
                      TextButton(
                        onPressed: () => context.push('/auth'),
                        child: Text(l10n.homeLogin),
                      )
                    else
                      TextButton(
                        onPressed: () =>
                            ref.read(authRepositoryProvider).signOut(),
                        child: Text(l10n.homeSignOut),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HomeTrendingSection extends ConsumerWidget {
  const _HomeTrendingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trending = ref.watch(trendingRecipesProvider);
    final sums = ref.watch(ratingSummariesProvider);
    final favs = ref.watch(favoriteIdsProvider);
    final l10n = AppLocalizations.of(context)!;

    return trending.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Text(l10n.homeTrendingError(e.toString()),
          textAlign: TextAlign.center),
      data: (list) {
        return sums.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (sumMap) {
            return favs.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (favSet) {
                if (list.isEmpty) {
                  return const SizedBox.shrink();
                }
                final slice = list.length > 12 ? list.sublist(0, 12) : list;
                final wk = isoWeekKey(DateTime.now());
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Expanded(
                          child: Text(
                            l10n.homeTrendingTitle(wk),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/trending'),
                          child: Text(l10n.homeTrendingSeeAll),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: slice.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final RecipeEntity r = slice[i];
                          return SizedBox(
                            width: 280,
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
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
