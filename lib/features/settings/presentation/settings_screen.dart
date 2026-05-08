import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luqma_haneya/l10n/app_localizations.dart';

import '../../../core/locale/app_locale_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale =
        ref.watch(appLocaleProvider).valueOrNull ?? const Locale('ar');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Text(
            l10n.settingsLanguageSection,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.settingsLanguageHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: Text(l10n.settingsLanguageArabic),
            trailing: locale.languageCode == 'ar'
                ? Icon(Icons.check,
                    color: Theme.of(context).colorScheme.primary)
                : null,
            onTap: () => ref
                .read(appLocaleProvider.notifier)
                .setLocale(const Locale('ar')),
          ),
          ListTile(
            title: Text(l10n.settingsLanguageEnglish),
            trailing: locale.languageCode == 'en'
                ? Icon(Icons.check,
                    color: Theme.of(context).colorScheme.primary)
                : null,
            onTap: () => ref
                .read(appLocaleProvider.notifier)
                .setLocale(const Locale('en')),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.person_outline_rounded),
            title: Text(l10n.settingsOpenFromAccount),
            onTap: () => context.push('/account'),
          ),
        ],
      ),
    );
  }
}
