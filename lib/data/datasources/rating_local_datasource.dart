import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/recipe_rating_summary.dart';

/// Local persistence for this device's star ratings and cached aggregates.
class RatingLocalDataSource {
  static const _kMyRatings = 'recipe_my_ratings_json_v1';
  static const _kSummaries = 'recipe_rating_summaries_json_v1';

  Future<Map<String, Map<String, dynamic>>> loadMyRatings() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kMyRatings);
    if (raw == null || raw.isEmpty) return {};
    final map = json.decode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)));
  }

  Future<void> saveMyRatings(Map<String, Map<String, dynamic>> data) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kMyRatings, json.encode(data));
  }

  Future<Map<String, RecipeRatingSummary>> loadSummaries() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kSummaries);
    if (raw == null || raw.isEmpty) return {};
    final map = json.decode(raw) as Map<String, dynamic>;
    final out = <String, RecipeRatingSummary>{};
    for (final e in map.entries) {
      final m = e.value as Map<String, dynamic>;
      final avg = (m['average'] as num?)?.toDouble() ?? 0;
      final count = (m['count'] as num?)?.toInt() ?? 0;
      out[e.key] = RecipeRatingSummary(average: avg, count: count);
    }
    return out;
  }

  Future<void> saveSummaries(Map<String, RecipeRatingSummary> data) async {
    final sp = await SharedPreferences.getInstance();
    final encoded = data.map(
      (k, v) => MapEntry(k, {'average': v.average, 'count': v.count}),
    );
    await sp.setString(_kSummaries, json.encode(encoded));
  }

  Future<void> mergeSummary(
      String recipeId, RecipeRatingSummary summary) async {
    final all = await loadSummaries();
    all[recipeId] = summary;
    await saveSummaries(all);
  }
}
