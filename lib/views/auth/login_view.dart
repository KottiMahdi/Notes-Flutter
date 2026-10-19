import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../controllers/auth_controller.dart';
import '../../core/utils/app_error_messages.dart';
import '../../core/widgets/retry_snack_bar.dart';
import '../../core/widgets/theme_mode_scope.dart';
import '../widgets/custom_logo.dart';
import 'login_form.dart';

class LoginView extends StatefulWidget {
  final AuthController? authController;
  final GoogleSignIn? googleSignIn;

  const LoginView({
    super.key,
    this.authController,
    this.googleSignIn,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _isGoogleLoading = false;

  Future<void> _signInWithGoogle(BuildContext context) async {
    if (_isGoogleLoading) return;

    final authController = widget.authController ??
        AuthController(googleSignIn: widget.googleSignIn);

    setState(() => _isGoogleLoading = true);
    try {
      await authController.signInWithGoogle();
      if (!context.mounted) return;
      Navigator.of(context)
          .pushNamedAndRemoveUntil('homepage', (route) => false);
    } catch (error) {
      if (!context.mounted) return;
      setState(() => _isGoogleLoading = false);
      showRetrySnackBar(
        context,
        message: AppErrorMessages.fromException(
          error,
          fallback: 'Google sign-in failed. Please try again.',
        ),
        onRetry: () => _signInWithGoogle(context),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = widget.authController ??
        AuthController(googleSignIn: widget.googleSignIn);
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
                    const Align(
                      alignment: Alignment.topRight,
                      child: ThemeModeToggle(),
                    ),
                    const SizedBox(height: 24),
                    const CustomLogo(),
                    const SizedBox(height: 26),
                    Text(
                      'Login',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.onSurface,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Login To Continue Using The App',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 30),
                    LoginForm(authController: authController),
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        Expanded(child: Divider(color: colors.outlineVariant)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                          ),
                        ),
                        Expanded(child: Divider(color: colors.outlineVariant)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 54,
                      child: MaterialButton(
                        height: 54,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: colors.surfaceContainerLowest,
                        disabledColor: colors.surfaceContainer,
                        textColor: colors.onSurface,
                        padding: EdgeInsets.zero,
                        onPressed: _isGoogleLoading
                            ? null
                            : () => _signInWithGoogle(context),
                        child: _isGoogleLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/img/google-color-svgrepo-com.png',
                                    width: 22,
                                    height: 22,
                                    cacheWidth: (22 *
                                            MediaQuery.devicePixelRatioOf(
                                              context,
                                            ))
                                        .round(),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Login with Google'),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: _isGoogleLoading
                          ? null
                          : () => Navigator.of(context)
                              .pushReplacementNamed('registre'),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text.rich(
                          TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(color: colors.onSurfaceVariant),
                            children: [
                              TextSpan(
                                text: 'Register',
                                style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
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
