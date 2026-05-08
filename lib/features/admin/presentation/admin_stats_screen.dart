import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:luqma_haneya/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/bootstrap.dart';
import '../../../domain/value_objects/recipe_moderation.dart';

/// MVP counts via Firestore aggregate `count()`.
/// TODO: top-rated / most-favorited need rollups or Cloud Functions at scale.
Future<_AdminStats> _loadAdminStats() async {
  if (!firebaseAppReady) {
    return const _AdminStats();
  }
  final fs = FirebaseFirestore.instance;
  final users = (await fs.collection('users').count().get()).count ?? 0;
  final recipes = (await fs.collection('recipes').count().get()).count ?? 0;
  final pending = (await fs
              .collection('recipes')
              .where('status', isEqualTo: RecipeModerationStatus.pending)
              .count()
              .get())
          .count ??
      0;
  final approved = (await fs
              .collection('recipes')
              .where('status', isEqualTo: RecipeModerationStatus.approved)
              .count()
              .get())
          .count ??
      0;
  final rejected = (await fs
              .collection('recipes')
              .where('status', isEqualTo: RecipeModerationStatus.rejected)
              .count()
              .get())
          .count ??
      0;
  return _AdminStats(
    users: users,
    recipes: recipes,
    pending: pending,
    approved: approved,
    rejected: rejected,
  );
}

final adminStatsProvider =
    FutureProvider<_AdminStats>((ref) => _loadAdminStats());

class _AdminStats {
  const _AdminStats({
    this.users = 0,
    this.recipes = 0,
    this.pending = 0,
    this.approved = 0,
    this.rejected = 0,
  });

  final int users;
  final int recipes;
  final int pending;
  final int approved;
  final int rejected;
}

class AdminStatsScreen extends ConsumerWidget {
  const AdminStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(adminStatsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminStatsTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.authError(e.toString()))),
        data: (s) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StatTile(label: l10n.adminStatsUsers, value: s.users),
            _StatTile(label: l10n.adminStatsRecipes, value: s.recipes),
            _StatTile(label: l10n.adminStatsPending, value: s.pending),
            _StatTile(label: l10n.adminStatsApproved, value: s.approved),
            _StatTile(label: l10n.adminStatsRejected, value: s.rejected),
            const SizedBox(height: 16),
            Text(
              l10n.adminStatsRatingsNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              l10n.adminStatsTopRatedTodo,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              l10n.adminStatsFavoritesTodo,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(label),
        trailing: Text(
          '$value',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
