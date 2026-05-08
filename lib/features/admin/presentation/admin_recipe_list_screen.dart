import 'package:flutter/material.dart';
import 'package:luqma_haneya/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/recipe_model.dart';
import '../../../di/providers.dart';
import '../../../domain/entities/recipe_entity.dart';
import '../../../domain/value_objects/recipe_moderation.dart';

class AdminRecipeListScreen extends ConsumerWidget {
  const AdminRecipeListScreen({super.key, required this.status});

  /// One of [RecipeModerationStatus] values.
  final String status;

  String _title(AppLocalizations l10n) {
    switch (status) {
      case RecipeModerationStatus.pending:
        return l10n.adminSectionPending;
      case RecipeModerationStatus.approved:
        return l10n.adminSectionApproved;
      case RecipeModerationStatus.rejected:
        return l10n.adminSectionRejected;
      default:
        return l10n.adminDashboardTitle;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(adminRecipesByStatusProvider(status));
    return Scaffold(
      appBar: AppBar(title: Text(_title(l10n))),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.authError(e.toString()))),
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Text(l10n.homeTrendingEmpty));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, i) {
              return _RecipeModerationCard(recipe: list[i], status: status);
            },
          );
        },
      ),
    );
  }
}

class _RecipeModerationCard extends ConsumerWidget {
  const _RecipeModerationCard({required this.recipe, required this.status});

  final RecipeEntity recipe;
  final String status;

  Future<void> _quickReject(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adminRejectTitle),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: InputDecoration(hintText: l10n.adminRejectHint),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.ratingCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(l10n.adminReject),
          ),
        ],
      ),
    );
    if (reason == null || reason.isEmpty) return;
    final uid = ref.read(authRepositoryProvider).currentSession?.firebaseUid;
    if (uid == null || !context.mounted) return;
    await ref.read(adminModerationRepositoryProvider).rejectRecipe(
          recipeId: recipe.id,
          adminUid: uid,
          reason: reason,
        );
    ref.invalidate(adminRecipesByStatusProvider(status));
    ref.invalidate(allRecipesCatalogProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminReject)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final m = recipe;
    final model = m is RecipeModel ? m : RecipeModel.fromEntity(m);
    final preview = m.mainIngredients.take(3).join('، ');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              m.title.isEmpty ? '—' : m.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (model.creatorName != null && model.creatorName!.isNotEmpty)
              Text(
                model.creatorName!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (m.createdAt != null)
              Text(
                m.createdAt.toString(),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            if (preview.isNotEmpty)
              Text(
                preview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
              ),
            if (m.tags.isNotEmpty)
              Wrap(
                spacing: 6,
                children: m.tags
                    .take(6)
                    .map(
                      (t) => Chip(
                        label: Text(t, style: const TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 6,
              children: [
                OutlinedButton(
                  onPressed: () => context.push('/admin/review/${m.id}'),
                  child: Text(l10n.adminReview),
                ),
                if (status == RecipeModerationStatus.pending) ...[
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
                      ref.invalidate(adminRecipesByStatusProvider(status));
                      ref.invalidate(allRecipesCatalogProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.adminApprove)),
                        );
                      }
                    },
                    child: Text(l10n.adminApprove),
                  ),
                  FilledButton.tonal(
                    onPressed: () => _quickReject(context, ref),
                    child: Text(l10n.adminReject),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
