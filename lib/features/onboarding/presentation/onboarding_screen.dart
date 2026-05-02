import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/lh_primary_button.dart';
import '../../../di/providers.dart';
import '../../../domain/entities/user_preferences_entity.dart';
import '../../../domain/value_objects/recipe_schema.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _allergiesCtl = TextEditingController();
  final _dislikesCtl = TextEditingController();
  final _favoriteFoodsCtl = TextEditingController();
  int _index = 0;

  bool _vegetarian = false;
  bool _quick = false;
  bool _avoidSpicy = true;
  bool _economical = false;
  String? _preferredMealType;
  final Set<String> _favorites = {};

  static const _chips = ['مصري', 'بحري', 'عائلي', 'فطار', 'مناسبات'];

  @override
  void dispose() {
    _pageController.dispose();
    _allergiesCtl.dispose();
    _dislikesCtl.dispose();
    _favoriteFoodsCtl.dispose();
    super.dispose();
  }

  List<String> _splitList(String raw) {
    return raw
        .split(RegExp(r'[,،\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _finish() async {
    final prefsRepo = ref.read(preferencesRepositoryProvider);
    final entity = UserPreferencesEntity(
      vegetarian: _vegetarian,
      quickMealsPreferred: _quick,
      avoidSpicy: _avoidSpicy,
      economicalMealsPreferred: _economical,
      preferredMealType: _preferredMealType,
      favoriteTags: _favorites.toList(),
      favoriteIngredients: _splitList(_favoriteFoodsCtl.text),
      allergies: _splitList(_allergiesCtl.text),
      dislikedIngredients: _splitList(_dislikesCtl.text),
    );
    await prefsRepo.savePreferences(entity);
    await prefsRepo.setOnboardingComplete(true);
    if (!mounted) return;
    context.go('/home');
  }

  void _next() {
    if (_index < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('لقمة هنية'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: active ? 28 : 8,
                    decoration: BoxDecoration(
                      color: active ? AppColors.terracotta : AppColors.cream,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  const _PageWelcome(),
                  _PageDiet(
                    vegetarian: _vegetarian,
                    quick: _quick,
                    avoidSpicy: _avoidSpicy,
                    economical: _economical,
                    preferredMealType: _preferredMealType,
                    allergiesController: _allergiesCtl,
                    dislikesController: _dislikesCtl,
                    favoriteFoodsController: _favoriteFoodsCtl,
                    onVegetarian: (v) => setState(() => _vegetarian = v),
                    onQuick: (v) => setState(() => _quick = v),
                    onAvoidSpicy: (v) => setState(() => _avoidSpicy = v),
                    onEconomical: (v) => setState(() => _economical = v),
                    onPreferredMealType: (v) =>
                        setState(() => _preferredMealType = v),
                  ),
                  _PageFavorites(
                    chips: _chips,
                    selected: _favorites,
                    onToggle: (t) {
                      setState(() {
                        if (_favorites.contains(t)) {
                          _favorites.remove(t);
                        } else {
                          _favorites.add(t);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: LhPrimaryButton(
                label: _index == 2 ? 'يلا نبدأ' : 'التالي',
                expanded: true,
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageWelcome extends StatelessWidget {
  const _PageWelcome();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أهلاً بيك في لقمة هنية',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'هنساعدك تخطط أكلك الأسبوع وتلاقي وصفات مصرية دافية تناسب ذوقك.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkMuted,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cream.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.restaurant_menu_rounded,
                  size: 40,
                  color: AppColors.terracotta,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'هنخصص الاقتراحات حسب تفضيلاتك في خطوات بسيطة.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageDiet extends StatelessWidget {
  const _PageDiet({
    required this.vegetarian,
    required this.quick,
    required this.avoidSpicy,
    required this.economical,
    required this.preferredMealType,
    required this.allergiesController,
    required this.dislikesController,
    required this.favoriteFoodsController,
    required this.onVegetarian,
    required this.onQuick,
    required this.onAvoidSpicy,
    required this.onEconomical,
    required this.onPreferredMealType,
  });

  final bool vegetarian;
  final bool quick;
  final bool avoidSpicy;
  final bool economical;
  final String? preferredMealType;
  final TextEditingController allergiesController;
  final TextEditingController dislikesController;
  final TextEditingController favoriteFoodsController;
  final ValueChanged<bool> onVegetarian;
  final ValueChanged<bool> onQuick;
  final ValueChanged<bool> onAvoidSpicy;
  final ValueChanged<bool> onEconomical;
  final ValueChanged<String?> onPreferredMealType;

  InputDecoration _fieldDec(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'تفضيلات الأكل',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'اختار اللي يناسب بيتكم — دايمًا تقدر تغيّره من الإعدادات لاحقاً.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.inkMuted,
              ),
        ),
        const SizedBox(height: 20),
        SwitchListTile(
          value: vegetarian,
          onChanged: onVegetarian,
          title: const Text('أفضل وصفات نباتية'),
          tileColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          value: quick,
          onChanged: onQuick,
          title: const Text('عندي وقت قليل — وجبات أسرع'),
          tileColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          value: economical,
          onChanged: onEconomical,
          title: const Text('بحب الأكلات الاقتصادية'),
          tileColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          value: avoidSpicy,
          onChanged: onAvoidSpicy,
          title: const Text('مش بحب الأكل الحار'),
          tileColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        const SizedBox(height: 20),
        Text(
          'وقت الأكلة اللي بتخططوا له أكتر؟ (اختياري)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'بيساعدنا نرتب اقتراحات النهاردة — تقدري تسيبيه على «أي وقت».',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.inkMuted,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          textDirection: TextDirection.rtl,
          children: [
            FilterChip(
              label: const Text('أي وقت'),
              selected: preferredMealType == null,
              onSelected: (_) => onPreferredMealType(null),
            ),
            FilterChip(
              label: const Text('فطار'),
              selected: preferredMealType == RecipeMealType.breakfast,
              onSelected: (v) {
                if (v) onPreferredMealType(RecipeMealType.breakfast);
              },
            ),
            FilterChip(
              label: const Text('غداء'),
              selected: preferredMealType == RecipeMealType.lunch,
              onSelected: (v) {
                if (v) onPreferredMealType(RecipeMealType.lunch);
              },
            ),
            FilterChip(
              label: const Text('عشاء'),
              selected: preferredMealType == RecipeMealType.dinner,
              onSelected: (v) {
                if (v) onPreferredMealType(RecipeMealType.dinner);
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        TextField(
          controller: allergiesController,
          maxLines: 2,
          textAlign: TextAlign.right,
          decoration: _fieldDec(
            'حساسية من (افصلي بفاصلة)',
            'مثال: لبن، مكسرات، سمك',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: dislikesController,
          maxLines: 2,
          textAlign: TextAlign.right,
          decoration: _fieldDec(
            'مكونات مش بتحبّوها (افصلي بفاصلة)',
            'مثال: بصل، باذنجان',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: favoriteFoodsController,
          maxLines: 2,
          textAlign: TextAlign.right,
          decoration: _fieldDec(
            'أكلات أو مكونات بتحبّوها (افصلي بفاصلة)',
            'مثال: فول، أرز، فراخ',
          ),
        ),
      ],
    );
  }
}

class _PageFavorites extends StatelessWidget {
  const _PageFavorites({
    required this.chips,
    required this.selected,
    required this.onToggle,
  });

  final List<String> chips;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'إيه نوع الأكلات اللي بتحبوها؟',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'اختار أكتر من خيار عشان الاقتراحات تبقى أقرب لذوقكم.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.inkMuted,
              ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: chips.map((c) {
            final on = selected.contains(c);
            return FilterChip(
              label: Text(c),
              selected: on,
              onSelected: (_) => onToggle(c),
            );
          }).toList(),
        ),
      ],
    );
  }
}
