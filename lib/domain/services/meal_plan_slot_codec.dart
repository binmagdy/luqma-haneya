/// Encodes a meal slot value for local/Firestore maps.
/// Legacy: `recipeId|title`
/// Extended: `recipeId|title|servings|locked|generatedAtIso`
class MealPlanSlotCodec {
  MealPlanSlotCodec._();

  static String encode({
    required String recipeId,
    required String recipeTitle,
    int servings = 4,
    bool locked = false,
    DateTime? generatedAt,
  }) {
    final g = generatedAt?.toIso8601String() ?? '';
    return '$recipeId|$recipeTitle|$servings|${locked ? 1 : 0}|$g';
  }

  static MealPlanSlotParsed? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final p = raw.split('|');
    if (p.length < 2) return null;
    return MealPlanSlotParsed(
      recipeId: p[0],
      recipeTitle: p[1],
      servings: p.length > 2 ? int.tryParse(p[2]) ?? 4 : 4,
      locked: p.length > 3 && p[3] == '1',
      generatedAt:
          p.length > 4 && p[4].isNotEmpty ? DateTime.tryParse(p[4]) : null,
    );
  }

  static bool isLocked(String raw) => decode(raw)?.locked ?? false;
}

class MealPlanSlotParsed {
  const MealPlanSlotParsed({
    required this.recipeId,
    required this.recipeTitle,
    required this.servings,
    required this.locked,
    this.generatedAt,
  });

  final String recipeId;
  final String recipeTitle;
  final int servings;
  final bool locked;
  final DateTime? generatedAt;

  String encode() => MealPlanSlotCodec.encode(
        recipeId: recipeId,
        recipeTitle: recipeTitle,
        servings: servings,
        locked: locked,
        generatedAt: generatedAt,
      );
}
