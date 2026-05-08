import 'package:flutter/material.dart';
import 'package:luqma_haneya/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/lh_primary_button.dart';
import '../../../di/providers.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.authTitle),
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
          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                Text(
                  s.isGuest
                      ? l10n.authGuestIntro
                      : l10n.authSignedInIntro(
                          s.resolvedDisplayName ?? s.firestoreSyncId,
                        ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.authSyncId(s.firestoreSyncId),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.inkMuted,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.authEmailLabel}: ${s.email?.isNotEmpty == true ? s.email! : l10n.authEmailNone}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  s.isGuest
                      ? l10n.authSyncStatusGuest
                      : l10n.authSyncStatusCloud,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.inkMuted,
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.authGoogleTodo,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.inkMuted,
                      ),
                ),
                const SizedBox(height: 32),
                if (s.isGuest) ...[
                  LhPrimaryButton(
                    label: l10n.authAnonymousSignIn,
                    expanded: true,
                    icon: Icons.person_outline_rounded,
                    onPressed: () async {
                      try {
                        await ref
                            .read(authRepositoryProvider)
                            .signInAnonymously();
                        final session = await ref
                            .read(authRepositoryProvider)
                            .readSession();
                        final uid = session.firebaseUid;
                        if (uid != null) {
                          final remote = ref.read(userProfileRemoteDsProvider);
                          if (remote.isAvailable) {
                            final prefs = await ref
                                .read(preferencesRepositoryProvider)
                                .loadPreferences();
                            await remote.mergePreferencesFromLocal(uid, prefs);
                          }
                          await ref
                              .read(favoritesRepositoryProvider)
                              .pushLocalFavoritesToCloud();
                          ref.invalidate(favoriteIdsProvider);
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.authSignedInSnackbar)),
                          );
                          context.pop();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.authSignInFailed('$e')),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () async {
                      await ref.read(authRepositoryProvider).continueAsGuest();
                      if (context.mounted) context.pop();
                    },
                    child: Text(l10n.authContinueGuest),
                  ),
                ] else ...[
                  LhPrimaryButton(
                    label: l10n.authSignOut,
                    expanded: true,
                    icon: Icons.logout_rounded,
                    onPressed: () async {
                      await ref.read(authRepositoryProvider).signOut();
                      if (context.mounted) context.pop();
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
