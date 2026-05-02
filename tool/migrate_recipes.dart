import 'dart:convert';
import 'dart:io';

/// One-off migration: split `ingredients` into main/optional and add catalog fields.
void main() {
  final root = Directory.current.path;
  final path = '$root/assets/recipes.json';
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('Missing $path (run from project root)');
    exitCode = 1;
    return;
  }

  final list = json.decode(file.readAsStringSync()) as List<dynamic>;
  for (final raw in list) {
    final m = Map<String, dynamic>.from(raw as Map);
    final tags = List<String>.from(m['tags'] as List? ?? const []);
    final legacy = List<String>.from(m['ingredients'] as List? ?? const []);

    if (m['mainIngredients'] == null && legacy.isNotEmpty) {
      final main = <String>[];
      final opt = <String>[];
      for (final line in legacy) {
        if (RegExp(r'اختياري|optional', caseSensitive: false).hasMatch(line)) {
          opt.add(line);
        } else {
          main.add(line);
        }
      }
      m['mainIngredients'] = main;
      m['optionalIngredients'] = opt;
    }

    final minutes = (m['minutes'] as num?)?.toInt() ?? 30;
    m.putIfAbsent('mealType', () => _inferMealType(tags));
    m.putIfAbsent('difficulty', () => _inferDifficulty(minutes));
    m.putIfAbsent('budget', () => _inferBudget(tags));
    m.putIfAbsent('spicy', () => _inferSpicy(tags, legacy));
    m.putIfAbsent('cuisine', () => _inferCuisine(tags));

    if (m.containsKey('ingredients')) {
      m.remove('ingredients');
    }
  }

  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(list));
  stdout.writeln('Updated ${list.length} recipes.');
}

String _inferMealType(List<String> tags) {
  final raw = tags.join();
  if (raw.contains('فطار')) return 'breakfast';
  if (raw.contains('حلو') || raw.contains('مشروبات')) return 'snack';
  if (raw.contains('شوربة')) return 'lunch';
  if (raw.contains('غداء')) return 'lunch';
  if (raw.contains('عشاء')) return 'dinner';
  return 'any';
}

String _inferDifficulty(int minutes) {
  if (minutes >= 90) return 'hard';
  if (minutes >= 50) return 'medium';
  return 'easy';
}

String _inferBudget(List<String> tags) {
  final raw = tags.join();
  if (raw.contains('اقتصادي')) return 'low';
  return 'medium';
}

bool _inferSpicy(List<String> tags, List<String> lines) {
  final blob = [...tags, ...lines].join().toLowerCase();
  return blob.contains('حار') ||
      blob.contains('شطة') ||
      blob.contains('هريسة') ||
      blob.contains('فلفل حار');
}

String _inferCuisine(List<String> tags) {
  final raw = tags.join();
  if (raw.contains('مصري')) return 'egyptian';
  return 'mixed';
}
