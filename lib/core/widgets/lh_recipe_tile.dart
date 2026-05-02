import 'package:flutter/material.dart';

import '../recipe_labels_ar.dart';
import '../theme/app_colors.dart';
import '../../domain/entities/recipe_entity.dart';

class LhRecipeTile extends StatelessWidget {
  const LhRecipeTile({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  final RecipeEntity recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                AppColors.cream.withValues(alpha: 0.9),
                Colors.white,
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.terracotta.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  recipe.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.inkMuted,
                      ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  alignment: WrapAlignment.end,
                  textDirection: TextDirection.rtl,
                  children: [
                    _TinyMeta(
                      icon: Icons.schedule_rounded,
                      text: '${recipe.minutes} د',
                    ),
                    _TinyMeta(
                      icon: Icons.wb_sunny_outlined,
                      text: RecipeLabelsAr.mealType(recipe.mealType),
                    ),
                    _TinyMeta(
                      icon: Icons.payments_outlined,
                      text: RecipeLabelsAr.budget(recipe.budget),
                    ),
                    _TinyMeta(
                      icon: Icons.trending_flat_rounded,
                      text: RecipeLabelsAr.difficulty(recipe.difficulty),
                    ),
                    if (recipe.spicy)
                      const _TinyMeta(
                        icon: Icons.local_fire_department_rounded,
                        text: 'حار',
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    const Icon(Icons.people_alt_rounded,
                        size: 18, color: AppColors.olive),
                    const SizedBox(width: 4),
                    Text('${recipe.servings} أشخاص'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TinyMeta extends StatelessWidget {
  const _TinyMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.rtl,
      children: [
        Icon(icon, size: 14, color: AppColors.olive),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.inkMuted,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
