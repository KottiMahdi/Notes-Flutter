import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        reverse: true,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sign Up',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Create An Account To Login',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              // ── Register form ──────────────────────────────────────────────
              RegisterForm(authController: authController),
              const SizedBox(height: 10),
              // ── Login link ─────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Have an account?',
                      style: TextStyle(color: Colors.black, fontSize: 16)),
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
