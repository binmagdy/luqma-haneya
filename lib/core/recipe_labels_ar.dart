import '../domain/value_objects/recipe_schema.dart';

/// Arabic labels for recipe catalog fields (RTL UI).
abstract class RecipeLabelsAr {
  static String mealType(String code) {
    switch (code) {
      case RecipeMealType.breakfast:
        return 'فطار';
      case RecipeMealType.lunch:
        return 'غداء';
      case RecipeMealType.dinner:
        return 'عشاء';
      case RecipeMealType.snack:
        return 'وجبة خفيفة';
      case RecipeMealType.any:
      default:
        return 'أي وقت';
    }
  }

  static String difficulty(String code) {
    switch (code) {
      case RecipeDifficulty.easy:
        return 'سهل';
      case RecipeDifficulty.medium:
        return 'متوسط';
      case RecipeDifficulty.hard:
        return 'صعب';
      default:
        return code;
    }
  }

  static String budget(String code) {
    switch (code) {
      case RecipeBudget.low:
        return 'اقتصادي';
      case RecipeBudget.medium:
        return 'تكلفة متوسطة';
      case RecipeBudget.high:
        return 'أعلى تكلفة';
      default:
        return code;
    }
  }

  static String cuisine(String code) {
    switch (code) {
      case 'egyptian':
        return 'مصري';
      case 'levantine':
        return 'شامي';
      case 'mixed':
      default:
        return 'متنوع';
    }
  }
}
