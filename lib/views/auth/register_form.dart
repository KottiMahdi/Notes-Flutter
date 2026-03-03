// ignore_for_file: avoid_print

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _passwordCtrl;
  late TextEditingController _confirmPasswordCtrl;
  bool _isObscured = true;

  final AuthController _authController = AuthController();

  @override
  void initState() {
    _usernameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    _confirmPasswordCtrl = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
      filled: true,
      fillColor: Colors.grey.shade200,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.grey)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.grey)),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      if (_passwordCtrl.text == _confirmPasswordCtrl.text) {
        await _authController.signUp(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
        await _authController.saveUserDetails(UserModel(
          username: _usernameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
        ));
      }
      await _authController.sendEmailVerification();
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Done',
        desc: 'Email verification sent. Please check your email.',
        btnOkOnPress: () {
          Navigator.of(context).pushReplacementNamed('login');
        },
      ).show();
    } on Exception catch (e) {
      if (!mounted) return;
      final msg = e.toString().contains('weak-password')
          ? 'The password provided is too weak.'
          : e.toString().contains('email-already-in-use')
              ? 'The account already exists for that email.'
              : 'Registration failed. Please try again.';
      print(e);
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
          // ── Username ───────────────────────────────────────────────────────
          const Text('Username',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          TextFormField(
            controller: _usernameCtrl,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please choose a username';
              } else if (value.length < 4) {
                return 'Username must be 4 or more characters';
              }
              return null;
            },
            decoration: _inputDecoration('Enter Your Username'),
          ),
          const SizedBox(height: 20),
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
            decoration: _inputDecoration('Enter Your Email'),
          ),
          const SizedBox(height: 20),
          // ── Password ───────────────────────────────────────────────────────
          const Text('Password',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordCtrl,
            obscureText: _isObscured,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 5) {
                return 'Password must be 5 or more characters';
              }
              return null;
            },
            style: const TextStyle(color: Colors.black),
            decoration: _inputDecoration('Enter Your Password').copyWith(
              suffixIcon: TextButton(
                onPressed: () => setState(() => _isObscured = !_isObscured),
                child: Text(_isObscured ? 'SHOW' : 'HIDE',
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // ── Confirm Password ───────────────────────────────────────────────
          const Text('Confirm Password',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          TextFormField(
            obscureText: _isObscured,
            controller: _confirmPasswordCtrl,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please re-enter your password';
              }
              if (value.length < 5) {
                return 'Password must be 5 or more characters';
              }
              if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            style: const TextStyle(color: Colors.black),
            decoration: _inputDecoration('Confirm Your Password').copyWith(
              suffixIcon: TextButton(
                onPressed: () => setState(() => _isObscured = !_isObscured),
                child: Text(_isObscured ? 'SHOW' : 'HIDE',
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // ── Sign-up button ─────────────────────────────────────────────────
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
                  onPressed: _register,
                  child: const Text('Sign Up',
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
