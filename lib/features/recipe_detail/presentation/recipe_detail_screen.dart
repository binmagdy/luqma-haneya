import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/recipe_labels_ar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/lh_primary_button.dart';
import '../../../core/widgets/lh_section_header.dart';
import '../../../di/providers.dart';
import '../../../domain/entities/recipe_entity.dart';

final _recipeProvider = FutureProvider.family<RecipeEntity?, String>((ref, id) {
  return ref.watch(recipeRepositoryProvider).getRecipeById(id);
});

class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({super.key, required this.recipeId});

  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_recipeProvider(recipeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الوصفة'),
      ),
      body: async.when(
        data: (recipe) {
          if (recipe == null) {
            return const Center(child: Text('الوصفة مش متاحة'));
          }
          return _RecipeBody(recipe: recipe);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }
}

class _RecipeBody extends StatelessWidget {
  const _RecipeBody({required this.recipe});

  final RecipeEntity recipe;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(
          recipe.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          recipe.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.inkMuted,
                height: 1.5,
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          textDirection: TextDirection.rtl,
          children: [
            _MetaChip(
                icon: Icons.schedule_rounded, label: '${recipe.minutes} دقيقة'),
            _MetaChip(
                icon: Icons.people_alt_rounded,
                label: '${recipe.servings} أشخاص'),
            _MetaChip(
              icon: Icons.wb_sunny_outlined,
              label: RecipeLabelsAr.mealType(recipe.mealType),
            ),
            _MetaChip(
              icon: Icons.trending_flat_rounded,
              label: RecipeLabelsAr.difficulty(recipe.difficulty),
            ),
            _MetaChip(
              icon: Icons.payments_outlined,
              label: RecipeLabelsAr.budget(recipe.budget),
            ),
            _MetaChip(
              icon: Icons.public_rounded,
              label: RecipeLabelsAr.cuisine(recipe.cuisine),
            ),
            if (recipe.spicy)
              const Chip(
                avatar: Icon(Icons.local_fire_department_rounded, size: 18),
                label: Text('حار'),
              ),
            ...recipe.tags.map(
              (t) => Chip(
                label: Text(t),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const LhSectionHeader(title: 'المكونات الأساسية'),
        const SizedBox(height: 10),
        ...recipe.mainIngredients.map(
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
        if (recipe.optionalIngredients.isNotEmpty) ...[
          const SizedBox(height: 12),
          const LhSectionHeader(title: 'مكونات اختيارية'),
          const SizedBox(height: 10),
          ...recipe.optionalIngredients.map(
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
        const LhSectionHeader(title: 'الخطوات'),
        const SizedBox(height: 10),
        ...List.generate(recipe.steps.length, (i) {
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
                    recipe.steps[i],
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        LhPrimaryButton(
          label: 'رجوع للاقتراحات',
          expanded: true,
          onPressed: () => Navigator.of(context).maybePop(),
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
