import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';

class LoginForm extends StatefulWidget {
  final AuthController? authController;

  const LoginForm({super.key, this.authController});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailCtrl;
  late TextEditingController _passwordCtrl;
  bool _isObscured = true;

  late final AuthController _authController;

  @override
  void initState() {
    _emailCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    _authController = widget.authController ?? AuthController();
    super.initState();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final credential = await _authController.signIn(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      if (credential.user!.emailVerified) {
        Navigator.of(context).pushReplacementNamed('homepage');
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.info,
          animType: AnimType.rightSlide,
          title: 'Error',
          desc: 'Please verify your email first',
          btnOkOnPress: () {},
        ).show();
      }
    } on Exception catch (e) {
      if (!mounted) return;
      final msg = e.toString().contains('user-not-found')
          ? 'No user found for that email.'
          : e.toString().contains('wrong-password')
              ? 'Wrong password provided for that user.'
              : 'Login failed. Please try again.';
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error',
        desc: msg,
        btnOkOnPress: () {},
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Email ──────────────────────────────────────────────────────────
          const Text('Email',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            controller: _emailCtrl,
            style: const TextStyle(color: Colors.black),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email address';
              } else if (!value.contains('@') || !value.contains('.')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Enter Your Email',
              hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: Colors.grey)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: Colors.grey)),
            ),
          ),
          const SizedBox(height: 20),
          // ── Password ───────────────────────────────────────────────────────
          const Text('Password',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordCtrl,
            obscureText: _isObscured,
            style: const TextStyle(color: Colors.black),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              } else if (value.length < 5) {
                return "Password must be 5 or more characters";
              }
              return null;
            },
            decoration: InputDecoration(
              suffixIcon: TextButton(
                onPressed: () => setState(() => _isObscured = !_isObscured),
                child: Text(
                  _isObscured ? 'SHOW' : 'HIDE',
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ),
              hintText: 'Enter Your Password',
              hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: Colors.grey)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: Colors.grey)),
            ),
          ),
          // ── Forgot password ────────────────────────────────────────────────
          Container(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pushNamed('forgotPWD'),
              child: const Text('Forgot Password ?',
                  style: TextStyle(fontSize: 14, color: Colors.black)),
            ),
          ),
          // ── Login button ───────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  onPressed: _login,
                  child: const Text('Login',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
