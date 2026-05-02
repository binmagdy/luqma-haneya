import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserIdentityLocalDataSource {
  static const _kDeviceId = 'device_id';

  Future<String> getOrCreateDeviceId() async {
    final sp = await SharedPreferences.getInstance();
    var id = sp.getString(_kDeviceId);
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      await sp.setString(_kDeviceId, id);
    }
    return id;
  }
}
