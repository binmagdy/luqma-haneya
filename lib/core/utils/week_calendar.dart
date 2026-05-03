class WeekDayDef {
  const WeekDayDef(this.key, this.labelAr);

  final String key;
  final String labelAr;
}

List<WeekDayDef> currentWeekDays() {
  const keys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  const labels = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];
  return List.generate(7, (i) => WeekDayDef(keys[i], labels[i]));
}

DateTime mondayOfWeekContaining(DateTime d) => _mondayOf(d);

String weekKeyFor(DateTime d) {
  final m = _mondayOf(d);
  final y = m.year.toString().padLeft(4, '0');
  final mo = m.month.toString().padLeft(2, '0');
  final day = m.day.toString().padLeft(2, '0');
  return '$y-$mo-$day';
}

DateTime _mondayOf(DateTime d) {
  final day = DateTime(d.year, d.month, d.day);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

/// ISO week-year key, e.g. `2026-W18` for trending / public ratings.
String isoWeekKey(DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  final thursday = d.add(Duration(days: DateTime.thursday - d.weekday));
  final y = thursday.year;
  final firstWeekMonday = _mondayOf(DateTime(y, 1, 4));
  final week = 1 + thursday.difference(firstWeekMonday).inDays ~/ 7;
  return '$y-W${week.toString().padLeft(2, '0')}';
}
