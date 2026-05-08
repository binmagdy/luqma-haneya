import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleCode = 'app_locale_code';

final appLocaleProvider =
    AsyncNotifierProvider<AppLocaleNotifier, Locale>(AppLocaleNotifier.new);

class AppLocaleNotifier extends AsyncNotifier<Locale> {
  @override
  Future<Locale> build() async {
    final prefs = await SharedPreferences.getInstance();
    return _localeFromCode(prefs.getString(_kLocaleCode));
  }

  Locale _localeFromCode(String? code) {
    if (code == 'en') return const Locale('en');
    return const Locale('ar');
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleCode, locale.languageCode);
    state = AsyncData(locale);
  }
}
