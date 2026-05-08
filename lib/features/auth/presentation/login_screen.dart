import 'package:flutter/material.dart';
import 'package:luqma_haneya/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/post_login_sync.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/lh_primary_button.dart';
import '../../../di/providers.dart';
import '../../../domain/auth/auth_exceptions.dart';
import 'auth_error_localizer.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _busy = false;

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    final l10n = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).signInWithEmailAndPassword(
            email: _email.text.trim(),
            password: _password.text,
          );
      await syncLocalUserDataToCloud(ref);
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      final msg = localizedAuthError(l10n, e);
      if (msg.isNotEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _doGoogle() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      await syncLocalUserDataToCloud(ref);
      if (!mounted) return;
      context.go('/home');
    } on AuthUserCancelledException {
      /* silent */
    } catch (e) {
      if (!mounted) return;
      final msg = localizedAuthError(l10n, e);
      if (msg.isNotEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _guest() async {
    await ref.read(authRepositoryProvider).continueAsGuest();
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginTitle)),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _busy,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    decoration:
                        InputDecoration(labelText: l10n.loginEmailLabel),
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return l10n.authValEmailRequired;
                      if (!_emailRe.hasMatch(t)) {
                        return l10n.authValEmailInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    textDirection: TextDirection.ltr,
                    decoration:
                        InputDecoration(labelText: l10n.loginPasswordLabel),
                    validator: (v) {
                      final t = v ?? '';
                      if (t.length < 6) return l10n.authValPasswordMin;
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  LhPrimaryButton(
                    label: l10n.loginSubmit,
                    expanded: true,
                    icon: Icons.login_rounded,
                    onPressed: _busy ? null : _doLogin,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _doGoogle,
                    icon: const Icon(Icons.g_mobiledata_rounded),
                    label: Text(l10n.loginGoogle),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _busy ? null : () => context.push('/register'),
                    child: Text(l10n.loginRegisterCta),
                  ),
                  TextButton(
                    onPressed:
                        _busy ? null : () => context.push('/forgot-password'),
                    child: Text(l10n.loginForgotCta),
                  ),
                  const Divider(height: 32),
                  Text(
                    l10n.loginGuestCta,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.inkMuted,
                        ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _busy ? null : _guest,
                    child: Text(l10n.loginGuestCta),
                  ),
                  if (_busy)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
