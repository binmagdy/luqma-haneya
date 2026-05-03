import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/bootstrap.dart';
import '../../core/utils/week_calendar.dart';

/// Client-side aggregation for weekly trending. TODO: move to Cloud Function for scale.
class TrendingRemoteDataSource {
  TrendingRemoteDataSource(this._firestore);

  final FirebaseFirestore? _firestore;

  bool get isAvailable => firebaseAppReady && _firestore != null;

  /// Returns recipe ids sorted by weekly score (avg desc, count desc).
  Future<List<String>> recipeIdsTrendingThisWeek(
      {int minWeeklyCount = 3}) async {
    if (!isAvailable) return const [];
    final wk = isoWeekKey(DateTime.now());
    try {
      final snap = await _firestore!
          .collectionGroup('ratings')
          .where('weekKey', isEqualTo: wk)
          .limit(500)
          .get();

      final byRecipe = <String, List<int>>{};
      for (final d in snap.docs) {
        final rid = d.reference.parent.parent?.id;
        if (rid == null || rid.isEmpty) continue;
        final r = (d.data()['rating'] as num?)?.toInt();
        if (r == null || r < 1 || r > 5) continue;
        byRecipe.putIfAbsent(rid, () => []).add(r);
      }
      final scored = <MapEntry<String, double>>[];
      for (final e in byRecipe.entries) {
        final n = e.value.length;
        if (n < minWeeklyCount) continue;
        final avg = e.value.reduce((a, b) => a + b) / n;
        scored.add(MapEntry(e.key, avg * 1000 + n));
      }
      scored.sort((a, b) => b.value.compareTo(a.value));
      return scored.map((e) => e.key).toList();
    } catch (e) {
      // Missing composite index or offline — caller falls back.
      return const [];
    }
  }

  /// All-time from denormalized recipe docs (best-effort).
  Future<List<String>> recipeIdsByAllTimeRating({int limit = 30}) async {
    if (!isAvailable) return const [];
    try {
      final snap = await _firestore!
          .collection('recipes')
          .orderBy('averageRating', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map((d) => d.id).toList();
    } catch (_) {
      return const [];
    }
  }
}
