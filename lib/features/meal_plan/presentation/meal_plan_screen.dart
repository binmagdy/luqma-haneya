import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/week_calendar.dart';
import '../../../di/providers.dart';
import '../../../domain/entities/recipe_entity.dart';
import '../../../domain/services/meal_plan_slot_codec.dart';

final _allRecipesProvider = FutureProvider<List<RecipeEntity>>((ref) {
  return ref.watch(recipeRepositoryProvider).getAllRecipes();
});

final _slotKeyRe = RegExp(r'^(\d{4}-\d{2}-\d{2})__(breakfast|lunch|dinner)$');

bool _isStructuredPlan(Map<String, String> map) =>
    map.keys.any((k) => _slotKeyRe.hasMatch(k));

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
  ref.invalidate(mealPlanWeekAssignmentsProvider(weekKey));
}

Future<void> pickMealPlanSlot(
  BuildContext context,
  WidgetRef ref, {
  required String weekKey,
  required String slotKey,
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
                'استبدال الوجبة',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
            for (final r in recipes)
              ListTile(
                title: Text(r.title),
                onTap: () => Navigator.pop(ctx, r),
              ),
          ],
        ),
      );
    },
  );
  if (chosen == null) return;
  await ref.read(mealPlanRepositoryProvider).replaceSlot(
        weekKey,
        slotKey,
        chosen.id,
        chosen.title,
      );
  ref.invalidate(mealPlanWeekAssignmentsProvider(weekKey));
}

class MealPlanScreen extends ConsumerWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekKey = weekKeyFor(DateTime.now());
    final days = currentWeekDays();
    final async = ref.watch(mealPlanWeekAssignmentsProvider(weekKey));

    return Scaffold(
      appBar: AppBar(
        title: const Text('خطة الأسبوع'),
        actions: [
          TextButton(
            onPressed: () => context.push('/smart-meal-plan'),
            child: const Text('خطة ذكية'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/smart-meal-plan'),
        icon: const Icon(Icons.auto_fix_high_rounded),
        label: const Text('توليد ذكي'),
      ),
      body: async.when(
        data: (map) {
          if (_isStructuredPlan(map)) {
            final keys = map.keys.where((k) => _slotKeyRe.hasMatch(k)).toList()
              ..sort();
            if (keys.isEmpty) {
              return _legacyBody(context, ref, weekKey, days, map);
            }
            final byDate = <String, List<String>>{};
            for (final k in keys) {
              final m = _slotKeyRe.firstMatch(k)!;
              final date = m.group(1)!;
              byDate.putIfAbsent(date, () => []).add(k);
            }
            final dateList = byDate.keys.toList()..sort();
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 88),
              itemCount: dateList.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'خطة ذكية متعددة الوجبات. اضغطي للاستبدال، القفل يمنع التغيير عند إعادة التوليد.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.inkMuted,
                            height: 1.45,
                          ),
                    ),
                  );
                }
                final date = dateList[i - 1];
                final slotKeys = byDate[date]!..sort();
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 8),
                        for (final sk in slotKeys)
                          _StructuredSlotRow(
                            slotKey: sk,
                            raw: map[sk]!,
                            onPick: () => pickMealPlanSlot(
                              context,
                              ref,
                              weekKey: weekKey,
                              slotKey: sk,
                            ),
                            onToggleLock: () async {
                              final p = MealPlanSlotCodec.decode(map[sk]!);
                              if (p == null) return;
                              await ref
                                  .read(mealPlanRepositoryProvider)
                                  .setSlotLocked(weekKey, sk, !p.locked);
                              ref.invalidate(
                                  mealPlanWeekAssignmentsProvider(weekKey));
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return _legacyBody(context, ref, weekKey, days, map);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }
}

Widget _legacyBody(
  BuildContext context,
  WidgetRef ref,
  String weekKey,
  List<WeekDayDef> days,
  Map<String, String> map,
) {
  return ListView.separated(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 88),
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
        final idx = raw.indexOf('|');
        if (idx > 0 && idx < raw.length - 1) {
          title = raw.substring(idx + 1);
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
}

class _StructuredSlotRow extends StatelessWidget {
  const _StructuredSlotRow({
    required this.slotKey,
    required this.raw,
    required this.onPick,
    required this.onToggleLock,
  });

  final String slotKey;
  final String raw;
  final VoidCallback onPick;
  final VoidCallback onToggleLock;

  @override
  Widget build(BuildContext context) {
    final p = MealPlanSlotCodec.decode(raw);
    final slot = slotKey.split('__').last;
    final title = p?.recipeTitle ?? raw;
    final locked = p?.locked ?? false;
    return ListTile(
      title: Text(
        '$slot — $title',
        textAlign: TextAlign.right,
      ),
      subtitle: Text(
        'حصص: ${p?.servings ?? '-'}',
        textAlign: TextAlign.right,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: locked ? 'إلغاء القفل' : 'قفل الوجبة',
            onPressed: onToggleLock,
            icon: Icon(
              locked ? Icons.lock_rounded : Icons.lock_open_rounded,
              color: locked ? AppColors.terracotta : AppColors.inkMuted,
            ),
          ),
          IconButton(
            tooltip: 'استبدال',
            onPressed: onPick,
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
    );
  }
}
