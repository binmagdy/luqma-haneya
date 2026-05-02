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
