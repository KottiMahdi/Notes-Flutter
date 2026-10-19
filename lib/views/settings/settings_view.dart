import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../core/utils/app_error_messages.dart';
import '../../core/widgets/retry_snack_bar.dart';
import '../../core/widgets/scrollable_dialog_content.dart';
import '../../core/widgets/theme_mode_scope.dart';
import '../widgets/app_bottom_nav.dart';

class SettingsView extends StatefulWidget {
  final AuthController? authController;
  final void Function(BuildContext, AppNavTab) onTabSelected;

  const SettingsView({
    super.key,
    this.authController,
    required this.onTabSelected,
  });

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late final AuthController _authController =
      widget.authController ?? AuthController();
  bool _isSigningOut = false;
  bool _isDeletingAccount = false;

  Future<void> _signOut() async {
    if (_isSigningOut || _isDeletingAccount) return;

    final confirmed = await _showAccountConfirmation(
      icon: Icons.logout_rounded,
      accentColor: const Color(0xFF954A00),
      title: 'Sign out?',
      message: 'You will need to sign in again to access your notes.',
      confirmLabel: 'Sign out',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSigningOut = true);
    try {
      await _authController.signOut();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('login', (route) => false);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSigningOut = false);
      showRetrySnackBar(
        context,
        message: AppErrorMessages.fromException(
          error,
          fallback: 'Could not sign out. Please try again.',
        ),
        onRetry: _signOut,
      );
    }
  }

  Future<void> _deleteAccount() async {
    if (_isDeletingAccount || _isSigningOut) return;

    final confirmed = await _showAccountConfirmation(
      icon: Icons.delete_outline,
      accentColor: const Color(0xFFD92D20),
      title: 'Delete account?',
      message:
          'This permanently deletes your profile, categories, and notes. This can\'t be undone.',
      confirmLabel: 'Delete account',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeletingAccount = true);
    try {
      await _authController.deleteAccount();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('login', (route) => false);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isDeletingAccount = false);
      showRetrySnackBar(
        context,
        message: AppErrorMessages.fromException(
          error,
          fallback: 'Could not delete your account. Please try again.',
        ),
        onRetry: _deleteAccount,
      );
    }
  }

  Future<bool?> _showAccountConfirmation({
    required IconData icon,
    required Color accentColor,
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final secondary = isDark ? Colors.white60 : const Color(0xFF6B7280);

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ScrollableDialogContent(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(message, style: TextStyle(color: secondary, height: 1.4)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side:
                            BorderSide(color: secondary.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color:
                              isDark ? Colors.white : const Color(0xFF17202A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        confirmLabel,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background =
        isDark ? const Color(0xFF121212) : const Color(0xFFFFFCF7);
    final surface = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final muted = isDark ? Colors.white60 : const Color(0xFF6B7280);
    final busy = _isSigningOut || _isDeletingAccount;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.sticky_note_2_outlined,
                color: Color(0xFF17202A),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Settings',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        actions: const [
          ThemeModeToggle(),
          SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text(
              'Account',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: muted.withValues(alpha: isDark ? 0.12 : 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _AccountOptionTile(
                    icon: Icons.logout_rounded,
                    color: const Color(0xFF954A00),
                    title: 'Sign out',
                    subtitle: 'Return to the login screen',
                    isBusy: _isSigningOut,
                    muted: muted,
                    onTap: busy ? null : _signOut,
                  ),
                  Divider(height: 1, color: muted.withValues(alpha: 0.14)),
                  _AccountOptionTile(
                    icon: Icons.delete_outline,
                    color: const Color(0xFFD92D20),
                    title: 'Delete account',
                    subtitle: 'Permanently remove your private data',
                    isBusy: _isDeletingAccount,
                    muted: muted,
                    onTap: busy ? null : _deleteAccount,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        isDark: isDark,
        selectedTab: AppNavTab.settings,
        onTabSelected: (tab) => widget.onTabSelected(context, tab),
      ),
    );
  }
}

class _AccountOptionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool isBusy;
  final Color muted;
  final VoidCallback? onTap;

  const _AccountOptionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.isBusy,
    required this.muted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      leading: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(subtitle, style: TextStyle(color: muted)),
      trailing: isBusy
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            )
          : Icon(Icons.chevron_right_rounded, color: muted),
      onTap: onTap,
    );
  }
}
