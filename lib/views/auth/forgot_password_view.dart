import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../core/utils/app_error_messages.dart';
import '../../core/widgets/retry_error_dialog.dart';
import '../../core/widgets/theme_mode_scope.dart';

class ForgotPasswordView extends StatefulWidget {
  final AuthController? authController;

  const ForgotPasswordView({super.key, this.authController});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailCtrl;
  late final AuthController _authController =
      widget.authController ?? AuthController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _authController.sendPasswordReset(_emailCtrl.text);
      if (!mounted) return;
      setState(() => _isLoading = false);
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Done',
        desc: 'Password reset link sent. Check your email.',
        btnOkOnPress: () {},
      ).show();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      await showRetryErrorDialog(
        context,
        message: AppErrorMessages.fromException(
          error,
          fallback:
              'Could not send the reset email. Check the address and try again.',
        ),
        onRetry: _sendReset,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight > 40
                      ? constraints.maxHeight - 40
                      : 0,
                  maxWidth: 520,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const ThemeModeToggle(),
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight < 600 ? 24 : 94),
                    Icon(
                      Icons.lock_reset_rounded,
                      size: 56,
                      color: colors.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Reset Password',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.onSurface,
                              ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Enter your email and we will send you a password reset link',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                            height: 1.45,
                          ),
                    ),
                    const SizedBox(height: 30),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Email',
                            style: TextStyle(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            enabled: !_isLoading,
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailCtrl,
                            style: TextStyle(color: colors.onSurface),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email address';
                              }
                              if (!value.contains('@') ||
                                  !value.contains('.')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Enter your email',
                              prefixIcon:
                                  const Icon(Icons.mail_outline, size: 20),
                              hintStyle: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 14,
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              filled: true,
                              fillColor: colors.surfaceContainerLowest,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    BorderSide(color: colors.outlineVariant),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    BorderSide(color: colors.outlineVariant),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    BorderSide(color: colors.primary, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor: colors.primaryContainer,
                                foregroundColor: colors.onPrimaryContainer,
                                elevation: 0,
                              ),
                              onPressed: _isLoading ? null : _sendReset,
                              child: _isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colors.onPrimaryContainer,
                                      ),
                                    )
                                  : const Text('RESET PASSWORD'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context)
                              .pushReplacementNamed('login'),
                      child: Text.rich(
                        TextSpan(
                          text: 'Remember your password? ',
                          style: TextStyle(color: colors.onSurfaceVariant),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
