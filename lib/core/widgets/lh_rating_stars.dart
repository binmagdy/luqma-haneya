import 'package:flutter/material.dart';

import '../../domain/entities/recipe_rating_summary.dart';
import '../theme/app_colors.dart';

/// Read-only average + count (RTL-friendly).
class LhRatingSummaryRow extends StatelessWidget {
  const LhRatingSummaryRow({
    super.key,
    required this.summary,
    this.compact = true,
  });

  final RecipeRatingSummary? summary;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = summary;
    if (s == null || !s.hasRatings) {
      return Text(
        'لا تقييمات بعد',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.inkMuted,
            ),
      );
    }
    final iconSize = compact ? 14.0 : 18.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.rtl,
      children: [
        Text(
          s.average.toStringAsFixed(1),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.olive,
              ),
        ),
        const SizedBox(width: 4),
        Icon(Icons.star_rounded, size: iconSize, color: AppColors.accentGold),
        const SizedBox(width: 2),
        Text(
          '(${s.count})',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.inkMuted,
              ),
        ),
      ],
    );
  }
}

/// Interactive 1–5 stars (RTL).
class LhRatingPicker extends StatelessWidget {
  const LhRatingPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int? value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      textDirection: TextDirection.rtl,
      children: List.generate(5, (i) {
        final star = 5 - i;
        final filled = value != null && value! >= star;
        return IconButton(
          tooltip: '$star',
          onPressed: () => onChanged(star),
          icon: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: filled ? AppColors.accentGold : AppColors.inkMuted,
            size: 36,
          ),
        );
      }),
    );
  }
}
