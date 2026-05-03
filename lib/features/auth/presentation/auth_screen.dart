import 'package:flutter/material.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('الحساب')),
      body: session.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (s) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                Text(
                  s.isGuest
                      ? 'أنتِ ضيفة على الجهاز — التقييمات العامة والمزامنة المتقدمة تحتاج تسجيل دخول اختياري.'
                      : 'مسجّلة دخول: ${s.resolvedDisplayName ?? s.firestoreSyncId}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'معرّف المزامنة: ${s.firestoreSyncId}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.inkMuted,
                      ),
                ),
                const SizedBox(height: 32),
                if (s.isGuest) ...[
                  LhPrimaryButton(
                    label: 'تسجيل دخول مجهول (سريع)',
                    expanded: true,
                    icon: Icons.person_outline_rounded,
                    onPressed: () async {
                      try {
                        await ref
                            .read(authRepositoryProvider)
                            .signInAnonymously();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم تسجيل الدخول')),
                          );
                          context.pop();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('تعذر: $e')),
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
                    child: const Text('متابعة كضيفة'),
                  ),
                ] else ...[
                  LhPrimaryButton(
                    label: 'تسجيل الخروج',
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
