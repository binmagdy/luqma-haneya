import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class LhFavoriteButton extends StatelessWidget {
  const LhFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
    this.size = 22,
  });

  final bool isFavorite;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
      onPressed: onPressed,
      icon: Icon(
        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: isFavorite ? AppColors.terracotta : AppColors.inkMuted,
        size: size,
      ),
    );
  }
}
