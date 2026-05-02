import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/bootstrap.dart';

class MealPlanRemoteDataSource {
  MealPlanRemoteDataSource(this._firestore);

  final FirebaseFirestore? _firestore;

  bool get isAvailable => firebaseAppReady && _firestore != null;

  DocumentReference<Map<String, dynamic>>? _doc(
      String deviceId, String weekKey) {
    if (!isAvailable) return null;
    return _firestore!
        .collection('users')
        .doc(deviceId)
        .collection('meal_weeks')
        .doc(weekKey);
  }

  Future<Map<String, String>?> tryLoad(String deviceId, String weekKey) async {
    final doc = _doc(deviceId, weekKey);
    if (doc == null) return null;
    final snap = await doc.get();
    if (!snap.exists) return null;
    final data = snap.data();
    if (data == null) return null;
    final raw = data['assignments'];
    if (raw is! Map) return null;
    return raw.map((k, v) => MapEntry(k.toString(), v.toString()));
  }

  Future<void> upsert(
    String deviceId,
    String weekKey,
    Map<String, String> assignments,
  ) async {
    final doc = _doc(deviceId, weekKey);
    if (doc == null) return;
    await doc.set({
      'assignments': assignments,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
