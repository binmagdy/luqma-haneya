/// Normalizes Arabic (and mixed) text for fuzzy matching of ingredients and prefs.
abstract class ArabicTextNormalize {
  ArabicTextNormalize._();

  static const Map<String, String> _digitMap = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
  };

  /// Lowercase, trim, collapse spaces, strip diacritics, unify common letter variants,
  /// map Eastern digits to Western (for ingredient lines like "٢ كوب").
  static String forMatch(String raw) {
    var s = raw.trim().toLowerCase();
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    s = s.replaceAll('\u0640', ''); // tatweel
    s = s.replaceAll(
      RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]'),
      '',
    );
    s = s.replaceAll(RegExp(r'[أإآٱ]'), 'ا');
    s = s.replaceAll('ة', 'ه');
    s = s.replaceAll('ى', 'ي');
    s = s.replaceAllMapped(
      RegExp(r'[٠-٩]'),
      (m) => _digitMap[m.group(0)] ?? m.group(0)!,
    );
    return s.trim();
  }

  static bool _isArabicLetter(String ch) {
    if (ch.isEmpty) return false;
    final c = ch.codeUnitAt(0);
    return (c >= 0x0600 && c <= 0x06FF) || (c >= 0x0750 && c <= 0x077F);
  }

  /// True if [needle] appears in [haystack] as a meaningful substring (avoids
  /// short needles like "زيت" matching inside "زيتون" when possible).
  static bool fuzzyContains(String haystack, String needle) {
    final h = forMatch(haystack);
    final n = forMatch(needle);
    if (n.length < 2) return false;
    if (n.length >= 4) return h.contains(n);
    final idx = h.indexOf(n);
    if (idx < 0) return false;
    final beforeOk = idx == 0 || !_isArabicLetter(h[idx - 1]);
    final end = idx + n.length;
    final afterOk = end >= h.length || !_isArabicLetter(h[end]);
    return beforeOk && afterOk;
  }

  /// Pantry term vs one ingredient line (both strings should already be [forMatch] output).
  static bool ingredientLineMatchesPantry(String pantryNorm, String lineNorm) {
    if (pantryNorm.length < 2 || lineNorm.length < 2) return false;
    if (lineNorm.contains(pantryNorm)) {
      if (pantryNorm.length >= 4) return true;
      return fuzzyContains(lineNorm, pantryNorm);
    }
    if (pantryNorm.contains(lineNorm)) {
      if (lineNorm.length >= 4) return true;
      return fuzzyContains(pantryNorm, lineNorm);
    }
    return false;
  }
}
