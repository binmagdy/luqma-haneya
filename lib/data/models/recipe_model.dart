import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/recipe_entity.dart';
import '../../domain/value_objects/recipe_moderation.dart';
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
    super.moderationStatus = RecipeModerationStatus.approved,
    super.visibility = RecipeVisibility.public,
    super.rejectedReason,
    super.updatedAt,
    super.approvedBy,
    super.approvedAt,
    super.rejectedBy,
    super.rejectedAt,
    super.averageRating,
    super.ratingCount,
    super.imageUrl,
    this.creatorName,
  });

  /// Display name for `creatorName` in Firestore (user-submitted recipes).
  final String? creatorName;

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
      moderationStatus: e.moderationStatus,
      visibility: e.visibility,
      rejectedReason: e.rejectedReason,
      updatedAt: e.updatedAt,
      approvedBy: e.approvedBy,
      approvedAt: e.approvedAt,
      rejectedBy: e.rejectedBy,
      rejectedAt: e.rejectedAt,
      averageRating: e.averageRating,
      ratingCount: e.ratingCount,
      imageUrl: e.imageUrl,
      creatorName: e is RecipeModel ? e.creatorName : null,
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
      createdByUserId:
          json['createdByUserId'] as String? ?? json['createdBy'] as String?,
      createdAt: _parseDate(json['createdAt']),
      isApproved:
          json['isApproved'] as bool? ?? json['approved'] as bool? ?? true,
      moderationStatus: json['moderationStatus'] as String? ??
          json['status'] as String? ??
          RecipeModerationStatus.approved,
      visibility: json['visibility'] as String? ?? RecipeVisibility.public,
      rejectedReason: json['rejectedReason'] as String?,
      updatedAt: _parseDate(json['updatedAt']),
      approvedBy: json['approvedBy'] as String?,
      approvedAt: _parseDate(json['approvedAt']),
      rejectedBy: json['rejectedBy'] as String?,
      rejectedAt: _parseDate(json['rejectedAt']),
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      ratingCount: (json['ratingCount'] as num?)?.toInt() ??
          (json['ratingsCount'] as num?)?.toInt(),
      imageUrl: json['imageUrl'] as String?,
      creatorName: json['creatorName'] as String?,
    );
  }

  static List<String> _firestoreStringList(dynamic value) {
    if (value == null) {
      return const [];
    }
    if (value is List) {
      return value
          .map((e) => e == null ? '' : e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static String _firestoreString(dynamic value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }
    if (value is String) {
      return value.trim();
    }
    return value.toString().trim();
  }

  factory RecipeModel.fromFirestore(String id, Map<String, dynamic> data) {
    final tags = _firestoreStringList(data['tags']);
    final main = _firestoreStringList(
      data['mainIngredients'] ?? data['ingredients'],
    );
    final optional = _firestoreStringList(data['optionalIngredients']);
    final steps = _firestoreStringList(data['steps']);
    final minutes = (data['minutes'] as num?)?.toInt() ?? 30;
    final title = _firestoreString(data['title']);
    final description = _firestoreString(data['description']);
    final moderationStatus = _moderationStatusFromFirestore(data);
    final visibility = _visibilityFromFirestore(data);
    final approvedFlag = data['approved'] ?? data['isApproved'];
    final isApproved = _isApprovedFromModeration(
      moderationStatus,
      approvedFlag,
    );

    return RecipeModel(
      id: id,
      title: title,
      description: description,
      minutes: minutes,
      servings: (data['servings'] as num?)?.toInt() ?? 4,
      steps: steps,
      tags: tags,
      mealType: data['mealType'] as String? ?? _inferMealType(tags),
      difficulty: data['difficulty'] as String? ?? _inferDifficulty(minutes),
      budget: data['budget'] as String? ?? _inferBudget(tags),
      spicy: data['spicy'] as bool? ?? _inferSpicy(tags, main, optional),
      cuisine: data['cuisine'] as String? ?? _inferCuisine(tags),
      mainIngredients: main,
      optionalIngredients: optional,
      source: data['source'] as String? ?? RecipeSource.remote,
      createdByUserId:
          data['createdByUserId'] as String? ?? data['createdBy'] as String?,
      createdAt: _parseFirestoreDate(data['createdAt']),
      isApproved: isApproved,
      moderationStatus: moderationStatus,
      visibility: visibility,
      rejectedReason: _firestoreStringOrNull(data['rejectedReason']),
      updatedAt: _parseFirestoreDate(data['updatedAt']),
      approvedBy: _firestoreStringOrNull(data['approvedBy']),
      approvedAt: _parseFirestoreDate(data['approvedAt']),
      rejectedBy: _firestoreStringOrNull(data['rejectedBy']),
      rejectedAt: _parseFirestoreDate(data['rejectedAt']),
      averageRating: (data['averageRating'] as num?)?.toDouble(),
      ratingCount: (data['ratingCount'] as num?)?.toInt() ??
          (data['ratingsCount'] as num?)?.toInt(),
      imageUrl: data['imageUrl'] as String?,
      creatorName: data['creatorName'] as String?,
    );
  }

  static String? _firestoreStringOrNull(dynamic value) {
    final s = _firestoreString(value);
    return s.isEmpty ? null : s;
  }

  static String _moderationStatusFromFirestore(Map<String, dynamic> data) {
    final s = data['status'] as String?;
    if (s == RecipeModerationStatus.pending ||
        s == RecipeModerationStatus.rejected ||
        s == RecipeModerationStatus.approved) {
      return s!;
    }
    final ap = data['approved'] ?? data['isApproved'];
    if (ap is bool && ap == false) {
      return RecipeModerationStatus.pending;
    }
    return RecipeModerationStatus.approved;
  }

  static String _visibilityFromFirestore(Map<String, dynamic> data) {
    final v = data['visibility'] as String?;
    if (v == RecipeVisibility.hidden) {
      return RecipeVisibility.hidden;
    }
    return RecipeVisibility.public;
  }

  static bool _isApprovedFromModeration(
    String moderationStatus,
    dynamic approvedFlag,
  ) {
    if (moderationStatus == RecipeModerationStatus.pending ||
        moderationStatus == RecipeModerationStatus.rejected) {
      return false;
    }
    if (approvedFlag is bool) {
      return approvedFlag;
    }
    return true;
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
      'status': moderationStatus,
      'visibility': visibility,
      if (createdByUserId != null) 'createdByUserId': createdByUserId,
      if (createdByUserId != null) 'createdBy': createdByUserId,
      if (creatorName != null) 'creatorName': creatorName,
      if (createdAt != null) 'createdAt': createdAt,
      'isApproved': isApproved,
      'approved': isApproved,
      if (rejectedReason != null && rejectedReason!.isNotEmpty)
        'rejectedReason': rejectedReason,
      if (approvedBy != null) 'approvedBy': approvedBy,
      if (approvedAt != null) 'approvedAt': approvedAt,
      if (rejectedBy != null) 'rejectedBy': rejectedBy,
      if (rejectedAt != null) 'rejectedAt': rejectedAt,
      if (averageRating != null) 'averageRating': averageRating,
      if (ratingCount != null) 'ratingCount': ratingCount,
      if (ratingCount != null) 'ratingsCount': ratingCount,
      if (imageUrl != null && imageUrl!.isNotEmpty) 'imageUrl': imageUrl,
    };
  }

  RecipeModel copyWith({
    String? id,
    String? title,
    String? description,
    int? minutes,
    int? servings,
    List<String>? steps,
    List<String>? tags,
    String? mealType,
    String? difficulty,
    String? budget,
    bool? spicy,
    String? cuisine,
    List<String>? mainIngredients,
    List<String>? optionalIngredients,
    String? source,
    String? createdByUserId,
    DateTime? createdAt,
    bool? isApproved,
    String? moderationStatus,
    String? visibility,
    String? rejectedReason,
    DateTime? updatedAt,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectedBy,
    DateTime? rejectedAt,
    double? averageRating,
    int? ratingCount,
    String? imageUrl,
    String? creatorName,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      minutes: minutes ?? this.minutes,
      servings: servings ?? this.servings,
      steps: steps ?? this.steps,
      tags: tags ?? this.tags,
      mealType: mealType ?? this.mealType,
      difficulty: difficulty ?? this.difficulty,
      budget: budget ?? this.budget,
      spicy: spicy ?? this.spicy,
      cuisine: cuisine ?? this.cuisine,
      mainIngredients: mainIngredients ?? this.mainIngredients,
      optionalIngredients: optionalIngredients ?? this.optionalIngredients,
      source: source ?? this.source,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      isApproved: isApproved ?? this.isApproved,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      visibility: visibility ?? this.visibility,
      rejectedReason: rejectedReason ?? this.rejectedReason,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedBy: rejectedBy ?? this.rejectedBy,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      imageUrl: imageUrl ?? this.imageUrl,
      creatorName: creatorName ?? this.creatorName,
    );
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
      'moderationStatus': moderationStatus,
      'visibility': visibility,
      if (rejectedReason != null) 'rejectedReason': rejectedReason,
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (approvedBy != null) 'approvedBy': approvedBy,
      if (approvedAt != null) 'approvedAt': approvedAt!.toIso8601String(),
      if (rejectedBy != null) 'rejectedBy': rejectedBy,
      if (rejectedAt != null) 'rejectedAt': rejectedAt!.toIso8601String(),
      if (averageRating != null) 'averageRating': averageRating,
      if (ratingCount != null) 'ratingCount': ratingCount,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (creatorName != null) 'creatorName': creatorName,
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
