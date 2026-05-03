import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/week_calendar.dart';
import '../../../core/widgets/lh_primary_button.dart';
import '../../../di/providers.dart';
import '../../../domain/entities/recipe_entity.dart';
import '../../../domain/services/recipe_scoring_service.dart';
import '../../../domain/services/smart_meal_plan_generator.dart';
import '../../../domain/value_objects/smart_plan_settings.dart';

class SmartMealPlanScreen extends ConsumerStatefulWidget {
  const SmartMealPlanScreen({super.key});

  @override
  ConsumerState<SmartMealPlanScreen> createState() =>
      _SmartMealPlanScreenState();
}

class _SmartMealPlanScreenState extends ConsumerState<SmartMealPlanScreen> {
  SmartPlanDuration _dur = SmartPlanDuration.seven;
  SmartPlanMealsPerDay _meals = SmartPlanMealsPerDay.lunchDinner;
  SmartPlanBudget _budget = SmartPlanBudget.balanced;
  SmartPlanCookingPace _pace = SmartPlanCookingPace.quickWeekdays;
  var _people = 4;
  var _usePantry = false;
  final _pantryCtrl = TextEditingController();
  var _includeFav = true;
  var _tryNew = true;
  var _busy = false;

  @override
  void dispose() {
    _pantryCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    setState(() => _busy = true);
    try {
      final prefs =
          await ref.read(preferencesRepositoryProvider).loadPreferences();
      final catalog = await ref.read(recipeRepositoryProvider).getAllRecipes();
      final favs = await ref.read(favoritesRepositoryProvider).getFavorites();
      final ratings = await ref.read(ratingRepositoryProvider).allMyRatings();
      final viewed = await ref.read(viewedRecipesLocalDsProvider).loadOrdered();
      final favRecipes = <RecipeEntity>[];
      for (final r in catalog) {
        if (favs.contains(r.id)) favRecipes.add(r);
      }
      final highRated = <RecipeEntity>[];
      for (final r in catalog) {
        final v = ratings[r.id];
        if (v != null && v >= 4) highRated.add(r);
      }
      final recent = <RecipeEntity>[];
      for (final id in viewed.take(10)) {
        for (final r in catalog) {
          if (r.id == id) {
            recent.add(r);
            break;
          }
        }
      }
      final ctx = RecipeSuggestionContext(
        favoriteRecipeIds: favs,
        favoriteRecipes: favRecipes,
        highRatedRecipes: highRated,
        recentlyViewedRecipes: recent,
      );

      final settings = SmartPlanSettings(
        duration: _dur,
        mealsPerDay: _meals,
        people: _people,
        budget: _budget,
        cookingPace: _pace,
        usePantry: _usePantry,
        pantryIngredients: _pantryCtrl.text
            .split(RegExp(r'[,،\n]+'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        includeFavorites: _includeFav,
        tryNewRecipes: _tryNew,
      );

      final startMonday = SmartMealPlanGenerator.mondayOf(DateTime.now());
      final plan = SmartMealPlanGenerator.generate(
        settings: settings,
        catalog: catalog,
        prefs: prefs,
        favoriteIds: favs,
        myRatings: ratings,
        suggestionContext: ctx,
        startMonday: startMonday,
      );

      final wk = weekKeyFor(startMonday);
      await ref
          .read(mealPlanRepositoryProvider)
          .applySmartAssignments(wk, plan);
      ref.invalidate(mealPlanWeekAssignmentsProvider(wk));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم توليد الخطة وحفظها')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('خطة أسبوعية ذكية')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          const Text('مدة الخطة'),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('٣ أيام'),
                selected: _dur == SmartPlanDuration.three,
                onSelected: (_) =>
                    setState(() => _dur = SmartPlanDuration.three),
              ),
              ChoiceChip(
                label: const Text('أسبوع'),
                selected: _dur == SmartPlanDuration.seven,
                onSelected: (_) =>
                    setState(() => _dur = SmartPlanDuration.seven),
              ),
              ChoiceChip(
                label: const Text('أسبوعين'),
                selected: _dur == SmartPlanDuration.fourteen,
                onSelected: (_) =>
                    setState(() => _dur = SmartPlanDuration.fourteen),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('الوجبات يوميًا'),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('غداء فقط'),
                selected: _meals == SmartPlanMealsPerDay.lunchOnly,
                onSelected: (_) =>
                    setState(() => _meals = SmartPlanMealsPerDay.lunchOnly),
              ),
              ChoiceChip(
                label: const Text('غداء + عشاء'),
                selected: _meals == SmartPlanMealsPerDay.lunchDinner,
                onSelected: (_) =>
                    setState(() => _meals = SmartPlanMealsPerDay.lunchDinner),
              ),
              ChoiceChip(
                label: const Text('فطار + غداء + عشاء'),
                selected: _meals == SmartPlanMealsPerDay.allThree,
                onSelected: (_) =>
                    setState(() => _meals = SmartPlanMealsPerDay.allThree),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('عدد الأشخاص'),
              Expanded(
                child: Slider(
                  value: _people.toDouble(),
                  min: 1,
                  max: 12,
                  divisions: 11,
                  label: '$_people',
                  onChanged: (v) => setState(() => _people = v.round()),
                ),
              ),
            ],
          ),
          const Text('الميزانية'),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('اقتصادي'),
                selected: _budget == SmartPlanBudget.economical,
                onSelected: (_) =>
                    setState(() => _budget = SmartPlanBudget.economical),
              ),
              ChoiceChip(
                label: const Text('متوسط'),
                selected: _budget == SmartPlanBudget.balanced,
                onSelected: (_) =>
                    setState(() => _budget = SmartPlanBudget.balanced),
              ),
              ChoiceChip(
                label: const Text('مرن'),
                selected: _budget == SmartPlanBudget.flexible,
                onSelected: (_) =>
                    setState(() => _budget = SmartPlanBudget.flexible),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('وقت الطهي'),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('أيام الأسبوع السريعة'),
                selected: _pace == SmartPlanCookingPace.quickWeekdays,
                onSelected: (_) =>
                    setState(() => _pace = SmartPlanCookingPace.quickWeekdays),
              ),
              ChoiceChip(
                label: const Text('بدون تفضيل'),
                selected: _pace == SmartPlanCookingPace.any,
                onSelected: (_) =>
                    setState(() => _pace = SmartPlanCookingPace.any),
              ),
            ],
          ),
          SwitchListTile(
            title: const Text('استخدام مكونات المخزن'),
            value: _usePantry,
            onChanged: (v) => setState(() => _usePantry = v),
          ),
          if (_usePantry)
            TextField(
              controller: _pantryCtrl,
              maxLines: 3,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                hintText: 'مثال: طماطم، أرز، فول…',
              ),
            ),
          SwitchListTile(
            title: const Text('تضمين المفضلة'),
            value: _includeFav,
            onChanged: (v) => setState(() => _includeFav = v),
          ),
          SwitchListTile(
            title: const Text('تجربة وصفات جديدة'),
            value: _tryNew,
            onChanged: (v) => setState(() => _tryNew = v),
          ),
          const SizedBox(height: 20),
          LhPrimaryButton(
            label: _busy ? 'جاري التوليد…' : 'ولّدي الخطة',
            expanded: true,
            onPressed: _busy ? null : _generate,
          ),
        ],
      ),
    );
  }
}
