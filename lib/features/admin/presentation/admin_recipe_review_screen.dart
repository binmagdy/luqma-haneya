import 'package:flutter/material.dart';
import 'package:luqma_haneya/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/recipe_model.dart';
import '../../../di/providers.dart';
import '../../../domain/entities/recipe_entity.dart';
import '../../../domain/value_objects/recipe_moderation.dart';

final _adminReviewRecipeProvider =
    FutureProvider.family<RecipeEntity?, String>((ref, id) {
  return ref.read(recipeRepositoryProvider).getRecipeById(id);
});

class AdminRecipeReviewScreen extends ConsumerWidget {
  const AdminRecipeReviewScreen({super.key, required this.recipeId});

  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(_adminReviewRecipeProvider(recipeId));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminReview)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.authError(e.toString()))),
        data: (recipe) {
          if (recipe == null) {
            return Center(child: Text(l10n.recipeNotAvailable));
          }
          final m =
              recipe is RecipeModel ? recipe : RecipeModel.fromEntity(recipe);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(m.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(m.description, textDirection: TextDirection.rtl),
              const SizedBox(height: 16),
              Text(l10n.recipeMainIngredients,
                  style: Theme.of(context).textTheme.titleSmall),
              ...m.mainIngredients
                  .map((e) => Text('• $e', textDirection: TextDirection.rtl)),
              const SizedBox(height: 12),
              Text(l10n.recipeOptionalIngredients,
                  style: Theme.of(context).textTheme.titleSmall),
              ...m.optionalIngredients
                  .map((e) => Text('• $e', textDirection: TextDirection.rtl)),
              const SizedBox(height: 12),
              Text(l10n.recipeSteps,
                  style: Theme.of(context).textTheme.titleSmall),
              ...m.steps.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '${e.key + 1}. ${e.value}',
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (m.moderationStatus == RecipeModerationStatus.pending) ...[
                    FilledButton(
                      onPressed: () async {
                        final uid = ref
                            .read(authRepositoryProvider)
                            .currentSession
                            ?.firebaseUid;
                        if (uid == null) return;
                        await ref
                            .read(adminModerationRepositoryProvider)
                            .approveRecipe(recipeId: m.id, adminUid: uid);
                        ref.invalidate(_adminReviewRecipeProvider(m.id));
                        ref.invalidate(adminRecipesByStatusProvider(
                            RecipeModerationStatus.pending));
                        ref.invalidate(allRecipesCatalogProvider);
                        if (context.mounted) context.pop();
                      },
                      child: Text(l10n.adminApprove),
                    ),
                    FilledButton.tonal(
                      onPressed: () async {
                        final ctrl = TextEditingController();
                        final reason = await showDialog<String>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(l10n.adminRejectTitle),
                            content: TextField(
                              controller: ctrl,
                              maxLines: 3,
                              decoration: InputDecoration(
                                  hintText: l10n.adminRejectHint),
                              textDirection: TextDirection.rtl,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(l10n.ratingCancel),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, ctrl.text.trim()),
                                child: Text(l10n.adminReject),
                              ),
                            ],
                          ),
                        );
                        if (reason == null || reason.isEmpty) return;
                        final uid = ref
                            .read(authRepositoryProvider)
                            .currentSession
                            ?.firebaseUid;
                        if (uid == null || !context.mounted) return;
                        await ref
                            .read(adminModerationRepositoryProvider)
                            .rejectRecipe(
                              recipeId: m.id,
                              adminUid: uid,
                              reason: reason,
                            );
                        ref.invalidate(_adminReviewRecipeProvider(m.id));
                        ref.invalidate(adminRecipesByStatusProvider(
                            RecipeModerationStatus.pending));
                        if (context.mounted) context.pop();
                      },
                      child: Text(l10n.adminReject),
                    ),
                  ],
                  OutlinedButton(
                    onPressed: () => context.push('/add-recipe', extra: m),
                    child: Text(l10n.adminEdit),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.adminHide),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(l10n.ratingCancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(l10n.adminHide),
                            ),
                          ],
                        ),
                      );
                      if (ok != true) return;
                      await ref
                          .read(adminModerationRepositoryProvider)
                          .setVisibility(
                            recipeId: m.id,
                            visibility: RecipeVisibility.hidden,
                          );
                      ref.invalidate(_adminReviewRecipeProvider(m.id));
                      ref.invalidate(allRecipesCatalogProvider);
                      if (context.mounted) context.pop();
                    },
                    child: Text(l10n.adminHide),
                  ),
                  TextButton(
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.adminDelete),
                          content: Text(l10n.adminDelete),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(l10n.ratingCancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(l10n.adminDelete),
                            ),
                          ],
                        ),
                      );
                      if (ok != true) return;
                      await ref
                          .read(adminModerationRepositoryProvider)
                          .deleteRecipe(m.id);
                      ref.invalidate(allRecipesCatalogProvider);
                      if (context.mounted) context.pop();
                    },
                    child: Text(l10n.adminDelete,
                        style: const TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
