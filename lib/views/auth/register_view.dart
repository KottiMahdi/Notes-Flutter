import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../core/widgets/theme_mode_scope.dart';
import 'register_form.dart';

class RegisterView extends StatelessWidget {
  final AuthController? authController;

  const RegisterView({
    super.key,
    this.authController,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 40,
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
                  const SizedBox(height: 24),
                  Text(
                    'Sign Up',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create An Account To Login',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 30),
                  RegisterForm(authController: authController),
                  const SizedBox(height: 22),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed('login'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Have an account? ',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                        Text(
                          'Login',
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
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
