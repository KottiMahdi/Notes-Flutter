import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/custom_logo.dart';
import 'login_form.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    final AuthController authController = AuthController();
    try {
      await authController.signInWithGoogle();
      if (!context.mounted) return;
      Navigator.of(context)
          .pushNamedAndRemoveUntil('homepage', (route) => false);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

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
              const SizedBox(height: 50),
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
              const Text(
                'Login To Continue Using The App',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              // ── Login Form ────────────────────────────────────────────────
              const LoginForm(),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'OR',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
              // ── Google Login Button ───────────────────────────────────────
              MaterialButton(
                  height: 45,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  color: Colors.grey.shade100,
                  textColor: Colors.black,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/img/google-color-svgrepo-com.png',
                          width: 26),
                      const Text(' Login with Google'),
                    ],
                  ),
                  onPressed: () => _signInWithGoogle(context)),
              const SizedBox(height: 20),
              // ── Register Link ─────────────────────────────────────────────
              InkWell(
                onTap: () {
                  Navigator.of(context).pushReplacementNamed("registre");
                },
                child: const Center(
                  child: Text.rich(TextSpan(children: [
                    TextSpan(text: "Don't Have An Account ? "),
                    TextSpan(
                        text: "Register",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ))
                  ])),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom))
            ],
          ),
        ),
      ),
    );
  }
}
