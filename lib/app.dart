import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/locale/app_locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

class LuqmaHaneyaApp extends ConsumerWidget {
  const LuqmaHaneyaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final locale =
        ref.watch(appLocaleProvider).valueOrNull ?? const Locale('ar');

    return MaterialApp.router(
      key: ValueKey(locale.languageCode),
      title: 'لقمة هنية',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}
