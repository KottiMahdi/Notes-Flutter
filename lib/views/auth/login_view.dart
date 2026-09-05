import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../controllers/auth_controller.dart';
import '../../utils/app_error_messages.dart';
import '../../utils/theme_mode_scope.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppErrorMessages.fromException(
              error,
              fallback: 'Google sign-in failed. Please try again.',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = widget.authController ??
        AuthController(googleSignIn: widget.googleSignIn);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(actions: const [ThemeModeToggle()]),
      body: SingleChildScrollView(
        reverse: true,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomLogo(),
              const SizedBox(height: 20),
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Login To Continue Using The App',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              LoginForm(authController: authController),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'OR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              MaterialButton(
                height: 45,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                disabledColor: Theme.of(context).colorScheme.surfaceContainer,
                textColor: Theme.of(context).colorScheme.onSurface,
                onPressed:
                    _isGoogleLoading ? null : () => _signInWithGoogle(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isGoogleLoading) ...[
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      const Text('Signing in...'),
                    ] else ...[
                      Image.asset(
                        'assets/img/google-color-svgrepo-com.png',
                        width: 26,
                      ),
                      const Text(' Login with Google'),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _isGoogleLoading
                    ? null
                    : () {
                        Navigator.of(context).pushReplacementNamed('registre');
                      },
                child: const Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: "Don't Have An Account ? "),
                        TextSpan(
                          text: 'Register',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
