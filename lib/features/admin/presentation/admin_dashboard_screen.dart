import 'package:flutter/material.dart';
import 'package:luqma_haneya/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminDashboardTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            leading: const Icon(Icons.hourglass_top_rounded),
            title: Text(l10n.adminSectionPending),
            onTap: () => context.push('/admin/pending'),
          ),
          ListTile(
            leading: const Icon(Icons.check_circle_outline_rounded),
            title: Text(l10n.adminSectionApproved),
            onTap: () => context.push('/admin/approved'),
          ),
          ListTile(
            leading: const Icon(Icons.cancel_outlined),
            title: Text(l10n.adminSectionRejected),
            onTap: () => context.push('/admin/rejected'),
          ),
          ListTile(
            leading: const Icon(Icons.insights_rounded),
            title: Text(l10n.adminSectionStats),
            onTap: () => context.push('/admin/stats'),
          ),
        ],
      ),
    );
  }
}
