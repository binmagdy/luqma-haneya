import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/week_calendar.dart';
import '../../../di/providers.dart';
import '../../../domain/entities/recipe_entity.dart';

final _allRecipesProvider = FutureProvider<List<RecipeEntity>>((ref) {
  return ref.watch(recipeRepositoryProvider).getAllRecipes();
});

final _assignmentsProvider =
    FutureProvider.autoDispose.family<Map<String, String>, String>(
  (ref, weekKey) => ref.watch(mealPlanRepositoryProvider).loadWeek(weekKey),
);

Future<void> pickMealPlanDay(
  BuildContext context,
  WidgetRef ref, {
  required String weekKey,
  required String dayKey,
}) async {
  final recipes = await ref.read(_allRecipesProvider.future);
  if (!context.mounted) return;
  final chosen = await showModalBottomSheet<RecipeEntity>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      return SafeArea(
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'اختار وصفة',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
            for (final r in recipes)
              ListTile(
                title: Text(r.title),
                subtitle: Text('${r.minutes} د • ${r.servings} أشخاص'),
                onTap: () => Navigator.pop(ctx, r),
              ),
          ],
        ),
      );
    },
  );
  if (chosen == null) return;
  await ref.read(mealPlanRepositoryProvider).saveDayAssignment(
        weekKey,
        dayKey,
        chosen.id,
        chosen.title,
      );
  ref.invalidate(_assignmentsProvider(weekKey));
}

class MealPlanScreen extends ConsumerWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekKey = weekKeyFor(DateTime.now());
    final days = currentWeekDays();
    final async = ref.watch(_assignmentsProvider(weekKey));

    return Scaffold(
      appBar: AppBar(
        title: const Text('خطة الأسبوع'),
      ),
      body: async.when(
        data: (map) {
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            itemCount: days.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'خطط لوجبة رئيسية كل يوم. هنحفظ خطتك على الجهاز، ولو Firebase شغال هنتزامن مع السحابة.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.inkMuted,
                          height: 1.45,
                        ),
                  ),
                );
              }
              final d = days[i - 1];
              final raw = map[d.key];
              String? title;
              if (raw != null) {
                final i = raw.indexOf('|');
                if (i > 0 && i < raw.length - 1) {
                  title = raw.substring(i + 1);
                }
              }

              return Card(
                child: ListTile(
                  title: Text(
                    d.labelAr,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    title ?? 'اضغط لاختيار وصفة',
                    style: TextStyle(
                      color: title == null ? AppColors.inkMuted : AppColors.ink,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () => pickMealPlanDay(
                    context,
                    ref,
                    weekKey: weekKey,
                    dayKey: d.key,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }
}
