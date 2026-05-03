import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/recipe_entity.dart';
import '../../domain/value_objects/recipe_schema.dart';
import '../../domain/value_objects/recipe_source.dart';

class RecipeModel extends RecipeEntity {
  const RecipeModel({
    required super.id,
    required super.title,
    required super.description,
    required super.minutes,
    required super.servings,
    required super.steps,
    required super.tags,
    required super.mealType,
    required super.difficulty,
    required super.budget,
    required super.spicy,
    required super.cuisine,
    required super.mainIngredients,
    required super.optionalIngredients,
    super.source = RecipeSource.asset,
    super.createdByUserId,
    super.createdAt,
    super.isApproved = true,
    super.averageRating,
    super.ratingCount,
  });

  factory RecipeModel.fromEntity(RecipeEntity e) {
    if (e is RecipeModel) return e;
    return RecipeModel(
      id: e.id,
      title: e.title,
      description: e.description,
      minutes: e.minutes,
      servings: e.servings,
      steps: e.steps,
      tags: e.tags,
      mealType: e.mealType,
      difficulty: e.difficulty,
      budget: e.budget,
      spicy: e.spicy,
      cuisine: e.cuisine,
      mainIngredients: e.mainIngredients,
      optionalIngredients: e.optionalIngredients,
      source: e.source,
      createdByUserId: e.createdByUserId,
      createdAt: e.createdAt,
      isApproved: e.isApproved,
      averageRating: e.averageRating,
      ratingCount: e.ratingCount,
    );
  }

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    final tags = List<String>.from(json['tags'] as List<dynamic>? ?? const []);
    final main = List<String>.from(
      json['mainIngredients'] as List<dynamic>? ??
          json['ingredients'] as List<dynamic>? ??
          const [],
    );
    final optional = List<String>.from(
      json['optionalIngredients'] as List<dynamic>? ?? const [],
    );
    final minutes = (json['minutes'] as num).toInt();

    return RecipeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      minutes: minutes,
      servings: (json['servings'] as num).toInt(),
      steps: List<String>.from(json['steps'] as List<dynamic>),
      tags: tags,
      mealType: json['mealType'] as String? ?? _inferMealType(tags),
      difficulty: json['difficulty'] as String? ?? _inferDifficulty(minutes),
      budget: json['budget'] as String? ?? _inferBudget(tags),
      spicy: json['spicy'] as bool? ?? _inferSpicy(tags, main, optional),
      cuisine: json['cuisine'] as String? ?? _inferCuisine(tags),
      mainIngredients: main,
      optionalIngredients: optional,
      source: json['source'] as String? ?? RecipeSource.asset,
      createdByUserId: json['createdByUserId'] as String?,
      createdAt: _parseDate(json['createdAt']),
      isApproved: json['isApproved'] as bool? ?? true,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      ratingCount: (json['ratingCount'] as num?)?.toInt(),
    );
  }

  factory RecipeModel.fromFirestore(String id, Map<String, dynamic> data) {
    final tags = List<String>.from(data['tags'] as List? ?? const []);
    final main = List<String>.from(
      data['mainIngredients'] as List? ??
          data['ingredients'] as List? ??
          const [],
    );
    final optional =
        List<String>.from(data['optionalIngredients'] as List? ?? const []);
    final minutes = (data['minutes'] as num?)?.toInt() ?? 30;

    return RecipeModel(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      minutes: minutes,
      servings: (data['servings'] as num?)?.toInt() ?? 4,
      steps: List<String>.from(data['steps'] as List? ?? const []),
      tags: tags,
      mealType: data['mealType'] as String? ?? _inferMealType(tags),
      difficulty: data['difficulty'] as String? ?? _inferDifficulty(minutes),
      budget: data['budget'] as String? ?? _inferBudget(tags),
      spicy: data['spicy'] as bool? ?? _inferSpicy(tags, main, optional),
      cuisine: data['cuisine'] as String? ?? _inferCuisine(tags),
      mainIngredients: main,
      optionalIngredients: optional,
      source: data['source'] as String? ?? RecipeSource.remote,
      createdByUserId: data['createdByUserId'] as String?,
      createdAt: _parseFirestoreDate(data['createdAt']),
      isApproved: data['isApproved'] as bool? ?? true,
      averageRating: (data['averageRating'] as num?)?.toDouble(),
      ratingCount: (data['ratingCount'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'minutes': minutes,
      'servings': servings,
      'steps': steps,
      'tags': tags,
      'mealType': mealType,
      'difficulty': difficulty,
      'budget': budget,
      'spicy': spicy,
      'cuisine': cuisine,
      'mainIngredients': mainIngredients,
      'optionalIngredients': optionalIngredients,
      'source': source,
      if (createdByUserId != null) 'createdByUserId': createdByUserId,
      if (createdAt != null) 'createdAt': createdAt,
      'isApproved': isApproved,
      if (averageRating != null) 'averageRating': averageRating,
      if (ratingCount != null) 'ratingCount': ratingCount,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'minutes': minutes,
      'servings': servings,
      'steps': steps,
      'tags': tags,
      'mealType': mealType,
      'difficulty': difficulty,
      'budget': budget,
      'spicy': spicy,
      'cuisine': cuisine,
      'mainIngredients': mainIngredients,
      'optionalIngredients': optionalIngredients,
      'source': source,
      if (createdByUserId != null) 'createdByUserId': createdByUserId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      'isApproved': isApproved,
      if (averageRating != null) 'averageRating': averageRating,
      if (ratingCount != null) 'ratingCount': ratingCount,
    };
  }

  static DateTime? _parseDate(dynamic v) {
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  static DateTime? _parseFirestoreDate(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  static String _inferMealType(List<String> tags) {
    final raw = tags.join();
    if (raw.contains('فطار')) return RecipeMealType.breakfast;
    if (raw.contains('حلو') || raw.contains('مشروبات')) {
      return RecipeMealType.snack;
    }
    if (raw.contains('شوربة')) return RecipeMealType.lunch;
    if (raw.contains('غداء')) return RecipeMealType.lunch;
    if (raw.contains('عشاء')) return RecipeMealType.dinner;
    return RecipeMealType.any;
  }

  static String _inferDifficulty(int minutes) {
    if (minutes >= 90) return RecipeDifficulty.hard;
    if (minutes >= 50) return RecipeDifficulty.medium;
    return RecipeDifficulty.easy;
  }

  static String _inferBudget(List<String> tags) {
    final raw = tags.join();
    if (raw.contains('اقتصادي')) return RecipeBudget.low;
    return RecipeBudget.medium;
  }

  static bool _inferSpicy(
    List<String> tags,
    List<String> main,
    List<String> optional,
  ) {
    final blob = [...tags, ...main, ...optional].join().toLowerCase();
    return blob.contains('حار') ||
        blob.contains('شطة') ||
        blob.contains('هريسة') ||
        blob.contains('فلفل حار');
  }

  static String _inferCuisine(List<String> tags) {
    final raw = tags.join();
    if (raw.contains('مصري')) return 'egyptian';
    return 'mixed';
  }
}
