import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../utils/theme_mode_scope.dart';
import 'register_form.dart';

class RegisterView extends StatelessWidget {
  final AuthController? authController;

  const RegisterView({
    super.key,
    this.authController,
  });

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 70),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sign Up',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text('Create An Account To Login',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
              const SizedBox(height: 10),
              // ── Register form ──────────────────────────────────────────────
              RegisterForm(authController: authController),
              const SizedBox(height: 10),
              // ── Login link ─────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Have an account?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                      )),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed('login'),
                    child: const Text('Login',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom)),
            ],
          ),
        ),
      ),
    );
  }
}
