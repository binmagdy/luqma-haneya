import 'package:flutter/material.dart';
import 'package:luqma_haneya/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/lh_primary_button.dart';
import '../../../core/widgets/lh_section_header.dart';
import '../../../data/models/recipe_model.dart';
import '../../../di/providers.dart';
import '../../../domain/value_objects/recipe_schema.dart';
import '../../../domain/value_objects/recipe_source.dart';

/// User-submitted recipe form. Persists locally and optionally syncs to Firestore.
///
/// **Production note:** submitted recipes should use `isApproved: false` until a
/// moderation step publishes them. MVP keeps `isApproved: true` so testers see
/// entries immediately in browse/search.
class AddRecipeScreen extends ConsumerStatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  ConsumerState<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends ConsumerState<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _minutes = TextEditingController();
  final _servings = TextEditingController();
  final _mainIng = TextEditingController();
  final _optIng = TextEditingController();
  final _steps = TextEditingController();
  final _tags = TextEditingController();
  final _cuisine = TextEditingController(text: 'egyptian');
  final _imageUrl = TextEditingController();

  String _meal = RecipeMealType.any;
  String _difficulty = RecipeDifficulty.easy;
  String _budget = RecipeBudget.medium;
  bool _spicy = false;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _minutes.dispose();
    _servings.dispose();
    _mainIng.dispose();
    _optIng.dispose();
    _steps.dispose();
    _tags.dispose();
    _cuisine.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  List<String> _lines(String raw) {
    return raw
        .split(RegExp(r'[\n،,]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final session = await ref.read(authSessionProvider.future);
    if (!mounted) return;
    if (session.isGuest || !session.canPublishPublicRatings) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addRecipeAuthRequired)),
      );
      context.push('/login');
      return;
    }

    setState(() => _saving = true);
    try {
      final id = const Uuid().v4();
      final uid = session.firebaseUid!;
      final now = DateTime.now();
      final main = _lines(_mainIng.text);
      final opt = _lines(_optIng.text);
      final steps = _lines(_steps.text);
      final tags = _lines(_tags.text);
      final img = _imageUrl.text.trim();

      final recipe = RecipeModel(
        id: id,
        title: _title.text.trim(),
        description: _desc.text.trim(),
        minutes: int.parse(_minutes.text.trim()),
        servings: int.parse(_servings.text.trim()),
        steps: steps,
        tags: tags,
        mealType: _meal,
        difficulty: _difficulty,
        budget: _budget,
        spicy: _spicy,
        cuisine: _cuisine.text.trim().isEmpty ? 'mixed' : _cuisine.text.trim(),
        mainIngredients: main,
        optionalIngredients: opt,
        source: RecipeSource.user,
        createdByUserId: uid,
        createdAt: now,
        isApproved: true,
        imageUrl: img.isEmpty ? null : img,
        creatorName: session.resolvedDisplayName ?? session.email,
      );

      await ref.read(userRecipeRepositoryProvider).submit(recipe);
      ref.invalidate(allRecipesCatalogProvider);
      ref.invalidate(suggestionBundleProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الوصفة')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر الحفظ: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة وصفة')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const LhSectionHeader(
              title: 'وصفة جديدة',
              subtitle:
                  'البيانات تتسجل على الجهاز أولًا، وتتزامن مع السحابة لو Firebase شغال.',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _title,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(labelText: 'العنوان *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
            ),
            TextFormField(
              controller: _desc,
              textDirection: TextDirection.rtl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'الوصف *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minutes,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'الدقائق *'),
                    validator: (v) {
                      final n = int.tryParse(v?.trim() ?? '');
                      if (n == null || n <= 0) return 'رقم صحيح';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _servings,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'عدد الأشخاص *'),
                    validator: (v) {
                      final n = int.tryParse(v?.trim() ?? '');
                      if (n == null || n <= 0) return 'رقم صحيح';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('نوع الوجبة'),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('أي وقت'),
                  selected: _meal == RecipeMealType.any,
                  onSelected: (_) => setState(() => _meal = RecipeMealType.any),
                ),
                ChoiceChip(
                  label: const Text('فطار'),
                  selected: _meal == RecipeMealType.breakfast,
                  onSelected: (_) =>
                      setState(() => _meal = RecipeMealType.breakfast),
                ),
                ChoiceChip(
                  label: const Text('غداء'),
                  selected: _meal == RecipeMealType.lunch,
                  onSelected: (_) =>
                      setState(() => _meal = RecipeMealType.lunch),
                ),
                ChoiceChip(
                  label: const Text('عشاء'),
                  selected: _meal == RecipeMealType.dinner,
                  onSelected: (_) =>
                      setState(() => _meal = RecipeMealType.dinner),
                ),
                ChoiceChip(
                  label: const Text('خفيف'),
                  selected: _meal == RecipeMealType.snack,
                  onSelected: (_) =>
                      setState(() => _meal = RecipeMealType.snack),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('الصعوبة'),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('سهل'),
                  selected: _difficulty == RecipeDifficulty.easy,
                  onSelected: (_) =>
                      setState(() => _difficulty = RecipeDifficulty.easy),
                ),
                ChoiceChip(
                  label: const Text('متوسط'),
                  selected: _difficulty == RecipeDifficulty.medium,
                  onSelected: (_) =>
                      setState(() => _difficulty = RecipeDifficulty.medium),
                ),
                ChoiceChip(
                  label: const Text('صعب'),
                  selected: _difficulty == RecipeDifficulty.hard,
                  onSelected: (_) =>
                      setState(() => _difficulty = RecipeDifficulty.hard),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('الميزانية'),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('اقتصادي'),
                  selected: _budget == RecipeBudget.low,
                  onSelected: (_) => setState(() => _budget = RecipeBudget.low),
                ),
                ChoiceChip(
                  label: const Text('متوسط'),
                  selected: _budget == RecipeBudget.medium,
                  onSelected: (_) =>
                      setState(() => _budget = RecipeBudget.medium),
                ),
                ChoiceChip(
                  label: const Text('مرتفع'),
                  selected: _budget == RecipeBudget.high,
                  onSelected: (_) =>
                      setState(() => _budget = RecipeBudget.high),
                ),
              ],
            ),
            SwitchListTile(
              title: const Text('حار'),
              value: _spicy,
              activeThumbColor: AppColors.terracotta,
              onChanged: (v) => setState(() => _spicy = v),
            ),
            TextFormField(
              controller: _cuisine,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(
                labelText: 'المطبخ (رمز، مثل egyptian)',
              ),
            ),
            TextFormField(
              controller: _mainIng,
              textDirection: TextDirection.rtl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'المكونات الأساسية * (سطر لكل مكونة)',
              ),
              validator: (v) {
                final lines = _lines(v ?? '');
                if (lines.length < 2) return l10n.addRecipeIngredientsMin2;
                return null;
              },
            ),
            TextFormField(
              controller: _optIng,
              textDirection: TextDirection.rtl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'مكونات اختيارية (سطر لكل مكونة)',
              ),
            ),
            TextFormField(
              controller: _steps,
              textDirection: TextDirection.rtl,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'الخطوات * (سطر لكل خطوة)',
              ),
              validator: (v) {
                final lines = _lines(v ?? '');
                return lines.isEmpty ? 'أضيفي خطوة واحدة على الأقل' : null;
              },
            ),
            TextFormField(
              controller: _tags,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                labelText: 'وسوم (اختياري، مفصولة بفاصلة)',
              ),
            ),
            TextFormField(
              controller: _imageUrl,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(labelText: l10n.addRecipeImageUrl),
            ),
            const SizedBox(height: 20),
            LhPrimaryButton(
              label: _saving ? 'جاري الحفظ…' : 'حفظ الوصفة',
              expanded: true,
              onPressed: _saving ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
