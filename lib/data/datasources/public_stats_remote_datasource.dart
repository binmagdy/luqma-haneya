import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/bootstrap.dart';

/// Aggregated public preference counters — no per-user PII.
///
/// TODO: Restrict writes to Cloud Functions / validated increments for production.
class PublicStatsRemoteDataSource {
  PublicStatsRemoteDataSource(this._firestore);

  final FirebaseFirestore? _firestore;

  bool get isAvailable => firebaseAppReady && _firestore != null;

  String _docIdForTag(String normalizedTag) {
    final s = normalizedTag.replaceAll(RegExp(r'[^\w\u0600-\u06FF]'), '_');
    final t = s.length > 80 ? s.substring(0, 80) : s;
    return 'tag_$t';
  }

  /// Increments counter for a preference tag (best-effort, MVP).
  Future<void> incrementTagCount({
    required String normalizedKey,
    required String labelAr,
  }) async {
    if (!isAvailable || normalizedKey.length < 2) return;
    final id = _docIdForTag(normalizedKey);
    final ref = _firestore!
        .collection('public_stats')
        .doc('preferences')
        .collection('items')
        .doc(id);
    await ref.set({
      'key': normalizedKey,
      'label': labelAr,
      'count': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Top tags by count (readable by all clients per rules).
  Future<List<({String key, String label, int count})>> fetchTopTags({
    int limit = 12,
  }) async {
    if (!isAvailable) return const [];
    try {
      final snap = await _firestore!
          .collection('public_stats')
          .doc('preferences')
          .collection('items')
          .orderBy('count', descending: true)
          .limit(limit)
          .get();
      final out = <({String key, String label, int count})>[];
      for (final d in snap.docs) {
        final m = d.data();
        final k = (m['key'] as String?) ?? d.id;
        final label = (m['label'] as String?) ?? k;
        final c = (m['count'] as num?)?.toInt() ?? 0;
        if (c > 0) out.add((key: k, label: label, count: c));
      }
      return out;
    } catch (_) {
      return const [];
    }
  }
}
