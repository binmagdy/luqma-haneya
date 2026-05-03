import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  static const _kGuestOnly = 'auth_guest_only_v1';

  Future<bool> preferGuestOnly() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kGuestOnly) ?? true;
  }

  Future<void> setPreferGuestOnly(bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kGuestOnly, value);
  }
}
