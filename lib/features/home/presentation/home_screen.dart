import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/lh_primary_button.dart';
import '../../../di/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseOn = ref.watch(firebaseReadyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لقمة هنية'),
        actions: [
          IconButton(
            tooltip: 'خطة الأسبوع',
            onPressed: () => context.push('/meal-plan'),
            icon: const Icon(Icons.calendar_month_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              const SizedBox(height: 12),
              Text(
                'يوم سعيد ونفسك في لقمة حلوة؟',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'تصفحي كل الوصفات، خذي اقتراحات ذكية، دوري بالمكونات، خطّطي الأسبوع، أو ضيفي وصفتك.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkMuted,
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: 24),
              if (!firebaseOn)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'وضع تجريبي: شغّل Firebase (flutterfire configure) عشان تتزامن خطط الوجبات والمفضلة والتقييمات مع السحابة.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
              LhPrimaryButton(
                label: 'كل الوصفات',
                icon: Icons.menu_book_rounded,
                expanded: true,
                onPressed: () => context.push('/recipes'),
              ),
              const SizedBox(height: 12),
              LhPrimaryButton(
                label: 'اقتراحات لي',
                icon: Icons.auto_awesome_rounded,
                expanded: true,
                onPressed: () => context.push('/suggest'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push('/pantry'),
                icon: const Icon(Icons.kitchen_rounded),
                label: const Text('بحث بالمكونات'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.olive,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.oliveLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push('/meal-plan'),
                icon: const Icon(Icons.edit_calendar_rounded),
                label: const Text('الخطة الأسبوعية'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.olive,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.oliveLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push('/favorites'),
                icon: const Icon(Icons.favorite_rounded),
                label: const Text('المفضلة'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.olive,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.oliveLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push('/add-recipe'),
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text('إضافة وصفة'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.olive,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.oliveLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'وصفات مصرية بلمسة دافية',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.inkMuted,
                    ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
