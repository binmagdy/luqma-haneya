import 'package:flutter/material.dart';
import 'package:luqma_haneya/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../di/providers.dart';
import '../../../domain/entities/recipe_entity.dart';
import '../../../domain/value_objects/recipe_moderation.dart';

class MySubmittedRecipesScreen extends ConsumerWidget {
  const MySubmittedRecipesScreen({super.key});

  String _statusLabel(AppLocalizations l10n, RecipeEntity r) {
    switch (r.moderationStatus) {
      case RecipeModerationStatus.pending:
        return l10n.recipeStatusPending;
      case RecipeModerationStatus.rejected:
        return l10n.recipeStatusRejected;
      case RecipeModerationStatus.approved:
      default:
        return l10n.recipeStatusApproved;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(mySubmittedRecipesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.mySubmittedTitle)),
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
              final r = list[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(
                    r.title.isEmpty ? '—' : r.title,
                    textDirection: TextDirection.rtl,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(_statusLabel(l10n, r)),
                        visualDensity: VisualDensity.compact,
                      ),
                      if (r.moderationStatus ==
                              RecipeModerationStatus.rejected &&
                          r.rejectedReason != null &&
                          r.rejectedReason!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            l10n.recipeRejectedReason(r.rejectedReason!),
                            textDirection: TextDirection.rtl,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                  onTap: () => context.push('/recipe/${r.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
