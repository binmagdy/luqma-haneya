import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/recipe_rating_resolve.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/lh_primary_button.dart';
import '../../../core/widgets/lh_recipe_tile.dart';
import '../../../core/widgets/lh_section_header.dart';
import '../../../di/providers.dart';
import '../../../domain/entities/recipe_entity.dart';

class PantryScreen extends ConsumerStatefulWidget {
  const PantryScreen({super.key});

  @override
  ConsumerState<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends ConsumerState<PantryScreen> {
  final _controller = TextEditingController();
  final List<String> _items = [];
  AsyncValue<List<RecipeEntity>> _results = const AsyncData([]);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final t = _controller.text.trim();
    if (t.isEmpty) return;
    setState(() {
      if (!_items.contains(t)) _items.add(t);
      _controller.clear();
    });
  }

  Future<void> _search() async {
    setState(() => _results = const AsyncLoading());
    try {
      final prefs =
          await ref.read(preferencesRepositoryProvider).loadPreferences();
      final list =
          await ref.read(recipeRepositoryProvider).findByPantryIngredients(
                _items,
                prefs,
              );
      setState(() => _results = AsyncData(list));
    } catch (e, st) {
      setState(() => _results = AsyncError(e, st));
    }
  }

  @override
  Widget build(BuildContext context) {
    final favs = ref.watch(favoriteIdsProvider);
    final sums = ref.watch(ratingSummariesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مكونات عندك في البيت'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const LhSectionHeader(
              title: 'اكتب اللي موجود',
              subtitle: 'مثال: طماطم، أرز، فول، سمك…',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _add(),
                    decoration: const InputDecoration(
                      hintText: 'ضيف مكونة',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _add,
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _items
                  .map(
                    (s) => InputChip(
                      label: Text(s),
                      onDeleted: () => setState(() => _items.remove(s)),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            LhPrimaryButton(
              label: 'دورلي على وصفة',
              icon: Icons.search_rounded,
              expanded: true,
              onPressed: _items.isEmpty ? null : _search,
            ),
            const SizedBox(height: 24),
            const LhSectionHeader(
              title: 'نتائج قريبة من مطبخك',
              subtitle:
                  'الأعلى في القائمة أقرب لمكوناتك الأساسية في الوصفة (بعد استبعاد الحساسية).',
            ),
            const SizedBox(height: 12),
            _results.when(
              data: (list) {
                if (_items.isEmpty) {
                  return Text(
                    'ابدأ بإضافة مكونات عشان نطابقها مع الوصفات.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.inkMuted,
                        ),
                  );
                }
                if (list.isEmpty) {
                  return Text(
                    'مفيش تطابق قوي — جرّب تضيف مكونات أكتر.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.inkMuted,
                        ),
                  );
                }
                return favs.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('خطأ: $e'),
                  data: (favSet) {
                    return sums.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('خطأ: $e'),
                      data: (sumMap) {
                        return Column(
                          children: list
                              .map(
                                (r) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: LhRecipeTile(
                                    recipe: r,
                                    ratingSummary:
                                        resolveRatingDisplay(r, sumMap),
                                    isFavorite: favSet.contains(r.id),
                                    onFavoriteTap: () async {
                                      await ref
                                          .read(favoritesRepositoryProvider)
                                          .setFavorite(
                                            r.id,
                                            !favSet.contains(r.id),
                                          );
                                      ref.invalidate(favoriteIdsProvider);
                                    },
                                    onTap: () =>
                                        context.push('/recipe/${r.id}'),
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Text('خطأ: $e'),
            ),
          ],
        ),
      ),
    );
  }
}
