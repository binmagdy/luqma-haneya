import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/week_calendar.dart';
import '../../../core/widgets/lh_primary_button.dart';
import '../../../di/providers.dart';
import '../../../domain/entities/recipe_entity.dart';
import '../../../domain/entities/user_preferences_entity.dart';
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
  String _busyMessage = '';

  @override
  void dispose() {
    _pantryCtrl.dispose();
    super.dispose();
  }

  void _setBusy(String message) {
    if (!mounted) return;
    setState(() {
      _busy = true;
      _busyMessage = message;
    });
  }

  Future<void> _generate() async {
    if (_busy) return;
    _setBusy('جارِ تجهيز خطتك...');
    final sw = Stopwatch()..start();
    try {
      final results = await Future.wait([
        ref.read(preferencesRepositoryProvider).loadPreferences(),
        ref.read(recipeRepositoryProvider).getAllRecipes(),
        ref.read(favoritesRepositoryProvider).getFavorites(),
        ref.read(ratingRepositoryProvider).allMyRatings(),
        ref.read(viewedRecipesLocalDsProvider).loadOrdered(),
      ]);

      if (!mounted) return;
      setState(() => _busyMessage = 'بنختار أفضل الوصفات ليك...');

      final prefs = results[0] as UserPreferencesEntity;
      final catalog = results[1] as List<RecipeEntity>;
      final favs = results[2] as Set<String>;
      final ratings = results[3] as Map<String, int>;
      final viewed = results[4] as List<String>;

      if (kDebugMode) {
        debugPrint(
          'SmartMealPlanScreen: data loaded recipes=${catalog.length} '
          'favs=${favs.length} ratings=${ratings.length} viewed=${viewed.length} '
          '${sw.elapsedMilliseconds}ms',
        );
      }

      final catalogById = {for (final r in catalog) r.id: r};
      final favRecipes = <RecipeEntity>[];
      for (final id in favs) {
        final r = catalogById[id];
        if (r != null) favRecipes.add(r);
      }
      final highRated = <RecipeEntity>[];
      for (final r in catalog) {
        final v = ratings[r.id];
        if (v != null && v >= 4) highRated.add(r);
      }
      final recent = <RecipeEntity>[];
      for (final id in viewed.take(10)) {
        final r = catalogById[id];
        if (r != null) recent.add(r);
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
      final wk = weekKeyFor(startMonday);

      if (!mounted) return;
      setState(() => _busyMessage = 'بنولّد الخطة...');

      final planResult = SmartMealPlanGenerator.generate(
        settings: settings,
        catalog: catalog,
        prefs: prefs,
        favoriteIds: favs,
        myRatings: ratings,
        suggestionContext: ctx,
        startMonday: startMonday,
      );

      if (planResult.assignments.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'ما فيش وصفات متاحة بعد تطبيق تفضيلاتك. عدّلي الإعدادات أو المخزن وحاولي مرة تانية.',
            ),
          ),
        );
        return;
      }

      if (!mounted) return;
      setState(() => _busyMessage = 'بنحفظ خطتك...');

      await ref
          .read(mealPlanRepositoryProvider)
          .applySmartAssignments(wk, planResult.assignments);
      ref.invalidate(mealPlanWeekAssignmentsProvider(wk));

      if (kDebugMode) {
        debugPrint(
          'SmartMealPlanScreen: saved week=$wk slots=${planResult.assignments.length} '
          'relaxed=${planResult.relaxedFiltersUsed} reused=${planResult.reusedRecipes} '
          'totalMs=${sw.elapsedMilliseconds}',
        );
      }

      if (!mounted) return;

      if (planResult.shouldShowRelaxedHint) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(SmartPlanGenerationResult.relaxedMessageAr),
            duration: Duration(seconds: 5),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم توليد الخطة وحفظها')),
        );
      }

      if (kDebugMode) {
        debugPrint('SmartMealPlanScreen: navigating to /meal-plan week=$wk');
      }
      context.go('/meal-plan');
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('SmartMealPlanScreen: generate failed $e\n$st');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذّر توليد الخطة. حاولي تاني.\n$e'),
          action: SnackBarAction(
            label: 'إعادة المحاولة',
            onPressed: _generate,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _busyMessage = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('خطة أسبوعية ذكية')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          if (_busy) ...[
            LinearProgressIndicator(
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 8),
            Text(
              _busyMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
          const Text('مدة الخطة'),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('٣ أيام'),
                selected: _dur == SmartPlanDuration.three,
                onSelected: _busy
                    ? null
                    : (_) => setState(() => _dur = SmartPlanDuration.three),
              ),
              ChoiceChip(
                label: const Text('أسبوع'),
                selected: _dur == SmartPlanDuration.seven,
                onSelected: _busy
                    ? null
                    : (_) => setState(() => _dur = SmartPlanDuration.seven),
              ),
              ChoiceChip(
                label: const Text('أسبوعين'),
                selected: _dur == SmartPlanDuration.fourteen,
                onSelected: _busy
                    ? null
                    : (_) => setState(() => _dur = SmartPlanDuration.fourteen),
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
                onSelected: _busy
                    ? null
                    : (_) =>
                        setState(() => _meals = SmartPlanMealsPerDay.lunchOnly),
              ),
              ChoiceChip(
                label: const Text('غداء + عشاء'),
                selected: _meals == SmartPlanMealsPerDay.lunchDinner,
                onSelected: _busy
                    ? null
                    : (_) => setState(
                          () => _meals = SmartPlanMealsPerDay.lunchDinner,
                        ),
              ),
              ChoiceChip(
                label: const Text('فطار + غداء + عشاء'),
                selected: _meals == SmartPlanMealsPerDay.allThree,
                onSelected: _busy
                    ? null
                    : (_) =>
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
                  onChanged:
                      _busy ? null : (v) => setState(() => _people = v.round()),
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
                onSelected: _busy
                    ? null
                    : (_) =>
                        setState(() => _budget = SmartPlanBudget.economical),
              ),
              ChoiceChip(
                label: const Text('متوسط'),
                selected: _budget == SmartPlanBudget.balanced,
                onSelected: _busy
                    ? null
                    : (_) => setState(() => _budget = SmartPlanBudget.balanced),
              ),
              ChoiceChip(
                label: const Text('مرن'),
                selected: _budget == SmartPlanBudget.flexible,
                onSelected: _busy
                    ? null
                    : (_) => setState(() => _budget = SmartPlanBudget.flexible),
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
                onSelected: _busy
                    ? null
                    : (_) => setState(
                          () => _pace = SmartPlanCookingPace.quickWeekdays,
                        ),
              ),
              ChoiceChip(
                label: const Text('بدون تفضيل'),
                selected: _pace == SmartPlanCookingPace.any,
                onSelected: _busy
                    ? null
                    : (_) => setState(() => _pace = SmartPlanCookingPace.any),
              ),
            ],
          ),
          SwitchListTile(
            title: const Text('استخدام مكونات المخزن'),
            value: _usePantry,
            onChanged: _busy ? null : (v) => setState(() => _usePantry = v),
          ),
          if (_usePantry)
            TextField(
              controller: _pantryCtrl,
              enabled: !_busy,
              maxLines: 3,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                hintText: 'مثال: طماطم، أرز، فول…',
              ),
            ),
          SwitchListTile(
            title: const Text('تضمين المفضلة'),
            value: _includeFav,
            onChanged: _busy ? null : (v) => setState(() => _includeFav = v),
          ),
          SwitchListTile(
            title: const Text('تجربة وصفات جديدة'),
            value: _tryNew,
            onChanged: _busy ? null : (v) => setState(() => _tryNew = v),
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
