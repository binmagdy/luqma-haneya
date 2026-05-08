import 'package:flutter/material.dart';
import 'package:luqma_haneya/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/lh_primary_button.dart';
import '../../../di/providers.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  String _providerLabel(AppLocalizations l10n, String? id) {
    switch (id) {
      case 'google.com':
        return 'Google';
      case 'password':
        return l10n.accountEmailSection;
      default:
        return id ?? '—';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountTitle),
        actions: [
          TextButton(
            onPressed: () => context.push('/settings'),
            child: Text(l10n.authOpenSettings),
          ),
        ],
      ),
      body: session.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.authError(e.toString()))),
        data: (s) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.oliveLight.withValues(alpha: 0.35),
                child: Icon(
                  s.isGuest
                      ? Icons.person_outline_rounded
                      : Icons.person_rounded,
                  size: 44,
                  color: AppColors.olive,
                ),
              ),
              const SizedBox(height: 16),
              if (s.isGuest) ...[
                Text(
                  l10n.accountGuestTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.accountGuestBody,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.inkMuted,
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: 24),
                LhPrimaryButton(
                  label: l10n.accountSignInCta,
                  expanded: true,
                  icon: Icons.login_rounded,
                  onPressed: () => context.push('/login'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.push('/register'),
                  child: Text(l10n.accountRegisterCta),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.loginGuestCta,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.inkMuted,
                      ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    await ref.read(authRepositoryProvider).continueAsGuest();
                    if (context.mounted) context.go('/home');
                  },
                  child: Text(l10n.loginGuestCta),
                ),
              ] else ...[
                Text(
                  s.resolvedDisplayName ?? '',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.accountEmailSection}: ${s.email ?? l10n.authEmailNone}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.accountProviderLabel}: ${_providerLabel(l10n, s.primaryProviderId)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.inkMuted,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.authSyncStatusCloud,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.45,
                      ),
                ),
                if (!s.firebaseIsAnonymous) ...[
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.outbox_rounded),
                    title: Text(l10n.accountMySubmissions),
                    onTap: () => context.push('/my-recipes'),
                  ),
                  ref.watch(appUserContextProvider).when(
                        data: (c) {
                          if (!c.isAdmin) {
                            return const SizedBox.shrink();
                          }
                          return ListTile(
                            leading:
                                const Icon(Icons.admin_panel_settings_rounded),
                            title: Text(l10n.accountAdminPanel),
                            onTap: () => context.push('/admin'),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                ],
                const SizedBox(height: 28),
                LhPrimaryButton(
                  label: l10n.accountSignOut,
                  expanded: true,
                  icon: Icons.logout_rounded,
                  onPressed: () async {
                    await ref.read(authRepositoryProvider).signOut();
                    ref.invalidate(favoriteIdsProvider);
                    if (context.mounted) context.go('/home');
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
