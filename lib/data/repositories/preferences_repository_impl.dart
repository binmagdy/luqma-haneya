import 'dart:async';

import '../../core/arabic_text_normalize.dart';
import '../../domain/entities/user_preferences_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../datasources/preferences_local_datasource.dart';
import '../datasources/public_stats_remote_datasource.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  PreferencesRepositoryImpl(
    this._local, {
    PublicStatsRemoteDataSource? publicStats,
    AuthRepository? auth,
  })  : _publicStats = publicStats,
        _auth = auth;

  final PreferencesLocalDataSource _local;
  final PublicStatsRemoteDataSource? _publicStats;
  final AuthRepository? _auth;

  @override
  Future<bool> isOnboardingComplete() => _local.isOnboardingComplete();

  @override
  Future<void> setOnboardingComplete(bool value) =>
      _local.setOnboardingComplete(value);

  @override
  Future<UserPreferencesEntity> loadPreferences() => _local.loadPreferences();

  @override
  Future<void> savePreferences(UserPreferencesEntity prefs) async {
    await _local.savePreferences(prefs);
    unawaited(_bumpPublicTagStats(prefs));
  }

  Future<void> _bumpPublicTagStats(UserPreferencesEntity prefs) async {
    final stats = _publicStats;
    final auth = _auth;
    if (stats == null || !stats.isAvailable || auth == null) return;
    try {
      final session = await auth.readSession();
      if (session.isGuest) return;
      for (final t in prefs.favoriteTags) {
        final n = ArabicTextNormalize.forMatch(t);
        if (n.length < 2) continue;
        await stats.incrementTagCount(normalizedKey: n, labelAr: t);
      }
    } catch (_) {
      /* MVP: never block preference save */
    }
  }
}
