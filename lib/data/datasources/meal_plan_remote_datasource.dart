import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../core/bootstrap.dart';

class MealPlanRemoteDataSource {
  MealPlanRemoteDataSource(this._firestore);

  final FirebaseFirestore? _firestore;

  bool get isAvailable => firebaseAppReady && _firestore != null;

  static const Duration _networkTimeout = Duration(seconds: 12);

  DocumentReference<Map<String, dynamic>>? _mealWeekDoc(
    String? userId,
    String weekKey,
  ) {
    if (!isAvailable || userId == null) return null;
    return _firestore!
        .collection('users')
        .doc(userId)
        .collection('meal_weeks')
        .doc(weekKey);
  }

  static String mealPlanV2DocId(String weekKey) =>
      'plan_${weekKey.replaceAll(RegExp(r'[^0-9\-]'), '_')}';

  DocumentReference<Map<String, dynamic>>? _mealPlanV2Doc(
    String? userId,
    String weekKey,
  ) {
    if (!isAvailable || userId == null) return null;
    return _firestore!
        .collection('users')
        .doc(userId)
        .collection('meal_plans')
        .doc(mealPlanV2DocId(weekKey));
  }

  Future<Map<String, String>?> tryLoad(String? userId, String weekKey) async {
    final doc = _mealWeekDoc(userId, weekKey);
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
    String? userId,
    String weekKey,
    Map<String, String> assignments,
  ) async {
    final doc = _mealWeekDoc(userId, weekKey);
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

  Future<Map<String, String>?> tryLoadMealPlanV2(
    String? userId,
    String weekKey,
  ) async {
    final doc = _mealPlanV2Doc(userId, weekKey);
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
        debugPrint('MealPlanRemoteDataSource.tryLoadMealPlanV2 timeout $e');
      }
      return null;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('MealPlanRemoteDataSource.tryLoadMealPlanV2 $e\n$st');
      }
      return null;
    }
  }

  Future<void> upsertMealPlanV2({
    required String? userId,
    required String weekKey,
    required Map<String, String> assignments,
    int durationDays = 7,
    String mealsPerDay = 'lunch_dinner',
    int servings = 4,
    Map<String, dynamic>? settings,
  }) async {
    final doc = _mealPlanV2Doc(userId, weekKey);
    if (doc == null) return;
    final planId = mealPlanV2DocId(weekKey);
    try {
      final snap = await doc.get().timeout(_networkTimeout);
      final exists = snap.exists;
      await doc.set({
        'planId': planId,
        'title': 'خطة الأسبوع',
        'weekKey': weekKey,
        'durationDays': durationDays,
        'mealsPerDay': mealsPerDay,
        'servings': servings,
        'settings': settings ?? const <String, dynamic>{},
        'assignments': assignments,
        'updatedAt': FieldValue.serverTimestamp(),
        if (!exists) 'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).timeout(_networkTimeout);
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('MealPlanRemoteDataSource.upsertMealPlanV2 timeout $e');
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('MealPlanRemoteDataSource.upsertMealPlanV2 $e\n$st');
      }
    }
  }
}
