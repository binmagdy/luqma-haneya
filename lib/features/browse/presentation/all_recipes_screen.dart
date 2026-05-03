import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/recipe_labels_ar.dart';
import '../../../core/recipe_rating_resolve.dart';
import '../../../core/widgets/lh_recipe_tile.dart';
import '../../../core/widgets/lh_section_header.dart';
import '../../../di/providers.dart';
import '../../../domain/entities/recipe_entity.dart';
import '../../../domain/entities/recipe_rating_summary.dart';
import '../../../domain/services/recipe_scoring_service.dart';
import '../../../domain/value_objects/recipe_schema.dart';

enum _RecipeSort { def, newest, highestRated, fastest }

enum _SpicyFilter { any, spicy, mild }

class AllRecipesScreen extends ConsumerStatefulWidget {
  const AllRecipesScreen({super.key});

  @override
  ConsumerState<AllRecipesScreen> createState() => _AllRecipesScreenState();
}

class _AllRecipesScreenState extends ConsumerState<AllRecipesScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _meal;
  String? _difficulty;
  String? _budget;
  String? _cuisine;
  _SpicyFilter _spicy = _SpicyFilter.any;
  _RecipeSort _sort = _RecipeSort.def;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _matchesQuery(RecipeEntity r, String q) {
    if (q.isEmpty) return true;
    final nq = RecipeScoringService.normalize(q);
    if (nq.length < 2) return true;
    final blob = RecipeScoringService.normalize([
      r.title,
      r.description,
      ...r.tags,
      ...r.mainIngredients,
      ...r.optionalIngredients,
    ].join(' '));
    return blob.contains(nq);
  }

  bool _passesFilters(RecipeEntity r) {
    if (_meal != null &&
        r.mealType != _meal &&
        r.mealType != RecipeMealType.any) {
      return false;
    }
    if (_difficulty != null && r.difficulty != _difficulty) return false;
    if (_budget != null && r.budget != _budget) return false;
    if (_cuisine != null && r.cuisine != _cuisine) return false;
    switch (_spicy) {
      case _SpicyFilter.spicy:
        if (!r.spicy) return false;
        break;
      case _SpicyFilter.mild:
        if (r.spicy) return false;
        break;
      case _SpicyFilter.any:
        break;
    }
    return _matchesQuery(r, _query);
  }

  List<RecipeEntity> _applySort(
    List<RecipeEntity> list,
    Map<String, RecipeRatingSummary> sums,
  ) {
    final out = [...list];
    switch (_sort) {
      case _RecipeSort.def:
        out.sort((a, b) => a.title.compareTo(b.title));
        break;
      case _RecipeSort.newest:
        out.sort((a, b) {
          final da = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final db = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return db.compareTo(da);
        });
        break;
      case _RecipeSort.highestRated:
        double score(RecipeEntity r) {
          final s = resolveRatingDisplay(r, sums);
          return s?.average ?? -1;
        }
        out.sort((a, b) => score(b).compareTo(score(a)));
        break;
      case _RecipeSort.fastest:
        out.sort((a, b) => a.minutes.compareTo(b.minutes));
        break;
    }
    return out;
  }

  Future<void> _toggleFavorite(String id, bool cur) async {
    await ref.read(favoritesRepositoryProvider).setFavorite(id, !cur);
    ref.invalidate(favoriteIdsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final cat = ref.watch(allRecipesCatalogProvider);
    final sums = ref.watch(ratingSummariesProvider);
    final favs = ref.watch(favoriteIdsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('كل الوصفات')),
      body: cat.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (all) {
          return sums.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('خطأ: $e')),
            data: (sumMap) {
              return favs.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('خطأ: $e')),
                data: (favSet) {
                  final cuisines = all.map((r) => r.cuisine).toSet().toList()
                    ..sort();
                  final filtered =
                      all.where(_passesFilters).toList(growable: false);
                  final sorted = _applySort(filtered, sumMap);
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: TextField(
                          controller: _searchCtrl,
                          textDirection: TextDirection.rtl,
                          decoration: const InputDecoration(
                            hintText: 'بحث بالاسم، المكون، أو الوسم',
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                          onChanged: (v) => setState(() => _query = v.trim()),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            FilterChip(
                              label: const Text('وجبة: فطار'),
                              selected: _meal == RecipeMealType.breakfast,
                              onSelected: (v) => setState(
                                () =>
                                    _meal = v ? RecipeMealType.breakfast : null,
                              ),
                            ),
                            FilterChip(
                              label: const Text('غداء'),
                              selected: _meal == RecipeMealType.lunch,
                              onSelected: (v) => setState(
                                () => _meal = v ? RecipeMealType.lunch : null,
                              ),
                            ),
                            FilterChip(
                              label: const Text('عشاء'),
                              selected: _meal == RecipeMealType.dinner,
                              onSelected: (v) => setState(
                                () => _meal = v ? RecipeMealType.dinner : null,
                              ),
                            ),
                            FilterChip(
                              label: const Text('سهل'),
                              selected: _difficulty == RecipeDifficulty.easy,
                              onSelected: (v) => setState(
                                () => _difficulty =
                                    v ? RecipeDifficulty.easy : null,
                              ),
                            ),
                            FilterChip(
                              label: const Text('متوسط'),
                              selected: _difficulty == RecipeDifficulty.medium,
                              onSelected: (v) => setState(
                                () => _difficulty =
                                    v ? RecipeDifficulty.medium : null,
                              ),
                            ),
                            FilterChip(
                              label: const Text('صعب'),
                              selected: _difficulty == RecipeDifficulty.hard,
                              onSelected: (v) => setState(
                                () => _difficulty =
                                    v ? RecipeDifficulty.hard : null,
                              ),
                            ),
                            FilterChip(
                              label: const Text('اقتصادي'),
                              selected: _budget == RecipeBudget.low,
                              onSelected: (v) => setState(
                                () => _budget = v ? RecipeBudget.low : null,
                              ),
                            ),
                            FilterChip(
                              label: const Text('تكلفة متوسطة'),
                              selected: _budget == RecipeBudget.medium,
                              onSelected: (v) => setState(
                                () => _budget = v ? RecipeBudget.medium : null,
                              ),
                            ),
                            FilterChip(
                              label: const Text('حار'),
                              selected: _spicy == _SpicyFilter.spicy,
                              onSelected: (v) => setState(
                                () => _spicy =
                                    v ? _SpicyFilter.spicy : _SpicyFilter.any,
                              ),
                            ),
                            FilterChip(
                              label: const Text('غير حار'),
                              selected: _spicy == _SpicyFilter.mild,
                              onSelected: (v) => setState(
                                () => _spicy =
                                    v ? _SpicyFilter.mild : _SpicyFilter.any,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            const Text('المطبخ:'),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButton<String?>(
                                isExpanded: true,
                                value: _cuisine,
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('الكل'),
                                  ),
                                  ...cuisines.map(
                                    (c) => DropdownMenuItem<String?>(
                                      value: c,
                                      child: Text(RecipeLabelsAr.cuisine(c)),
                                    ),
                                  ),
                                ],
                                onChanged: (v) => setState(() => _cuisine = v),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('ترتيب:'),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButton<_RecipeSort>(
                                isExpanded: true,
                                value: _sort,
                                items: const [
                                  DropdownMenuItem(
                                    value: _RecipeSort.def,
                                    child: Text('افتراضي'),
                                  ),
                                  DropdownMenuItem(
                                    value: _RecipeSort.newest,
                                    child: Text('الأحدث'),
                                  ),
                                  DropdownMenuItem(
                                    value: _RecipeSort.highestRated,
                                    child: Text('الأعلى تقييمًا'),
                                  ),
                                  DropdownMenuItem(
                                    value: _RecipeSort.fastest,
                                    child: Text('الأسرع'),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v != null) setState(() => _sort = v);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          _meal = null;
                          _difficulty = null;
                          _budget = null;
                          _cuisine = null;
                          _spicy = _SpicyFilter.any;
                          _sort = _RecipeSort.def;
                          _query = '';
                          _searchCtrl.clear();
                        }),
                        child: const Text('مسح الفلاتر'),
                      ),
                      Expanded(
                        child: sorted.isEmpty
                            ? const Center(child: Text('مفيش نتائج'))
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  8,
                                  20,
                                  24,
                                ),
                                itemCount: sorted.length + 1,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, i) {
                                  if (i == 0) {
                                    return LhSectionHeader(
                                      title: 'كل الوصفات المتاحة',
                                      subtitle:
                                          'عدد النتائج: ${sorted.length} من أصل ${all.length}',
                                    );
                                  }
                                  final r = sorted[i - 1];
                                  return LhRecipeTile(
                                    recipe: r,
                                    ratingSummary:
                                        resolveRatingDisplay(r, sumMap),
                                    isFavorite: favSet.contains(r.id),
                                    onFavoriteTap: () => _toggleFavorite(
                                      r.id,
                                      favSet.contains(r.id),
                                    ),
                                    onTap: () =>
                                        context.push('/recipe/${r.id}'),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
