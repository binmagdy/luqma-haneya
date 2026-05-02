import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/lh_recipe_tile.dart';
import '../../../core/widgets/lh_section_header.dart';
import '../../../di/providers.dart';
import '../../../domain/entities/recipe_entity.dart';

final _suggestionsProvider = FutureProvider<List<RecipeEntity>>((ref) async {
  final prefs =
      await ref.watch(preferencesRepositoryProvider).loadPreferences();
  return ref.watch(recipeRepositoryProvider).suggestForToday(prefs);
});

class RecipeSuggestionScreen extends ConsumerWidget {
  const RecipeSuggestionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_suggestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('اقتراحات النهاردة'),
      ),
      body: async.when(
        data: (list) {
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
                        'مرتبة من الأنسب لتفضيلاتك — كل ما تضغطي على وصفة هتشوفي المكونات والخطوات.',
                  ),
                );
              }
              final r = list[i - 1];
              return LhRecipeTile(
                recipe: r,
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
