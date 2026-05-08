import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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

  static const Duration _networkTimeout = Duration(seconds: 12);

  Future<Map<String, String>?> tryLoad(String deviceId, String weekKey) async {
    final doc = _doc(deviceId, weekKey);
    if (doc == null) return null;
    try {
      final snap = await doc.get().timeout(_networkTimeout);
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;
      final raw = data['assignments'];
      if (raw is! Map) return null;
      return raw.map((k, v) => MapEntry(k.toString(), v.toString()));
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('MealPlanRemoteDataSource.tryLoad timeout week=$weekKey $e');
      }
      return null;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint(
            'MealPlanRemoteDataSource.tryLoad failed week=$weekKey $e\n$st');
      }
      return null;
    }
  }

  Future<void> upsert(
    String deviceId,
    String weekKey,
    Map<String, String> assignments,
  ) async {
    final doc = _doc(deviceId, weekKey);
    if (doc == null) return;
    try {
      await doc.set({
        'assignments': assignments,
        'weekKey': weekKey,
        'updatedAt': FieldValue.serverTimestamp(),
        'generatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).timeout(_networkTimeout);
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('MealPlanRemoteDataSource.upsert timeout week=$weekKey $e');
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint(
            'MealPlanRemoteDataSource.upsert failed week=$weekKey $e\n$st');
      }
    }
  }
}
