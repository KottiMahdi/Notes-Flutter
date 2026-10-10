import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';
import '../../utils/app_error_messages.dart';

class RegisterForm extends StatefulWidget {
  final AuthController? authController;

  const RegisterForm({super.key, this.authController});

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
  bool _isLoading = false;

  late final AuthController _authController;

  @override
  void initState() {
    _usernameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    _confirmPasswordCtrl = TextEditingController();
    _authController = widget.authController ?? AuthController();
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

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    final colors = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(_iconForHint(hint), size: 20),
      hintStyle: TextStyle(
        fontSize: 14,
        color: colors.onSurfaceVariant,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      filled: true,
      fillColor: colors.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
    );
  }

  IconData _iconForHint(String hint) {
    if (hint.contains('Username')) return Icons.person_outline;
    if (hint.contains('Email')) return Icons.mail_outline;
    return Icons.lock_outline;
  }

  Future<void> _register() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _authController.signUp(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      await _authController.saveUserDetails(
        UserModel(
          username: _usernameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
        ),
      );
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
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error',
        desc: AppErrorMessages.fromException(
          error,
          fallback:
              'Registration failed. Please check your details and try again.',
        ),
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
          const Text(
            'Username',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 10),
          TextFormField(
            enabled: !_isLoading,
            controller: _usernameCtrl,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please choose a username';
              } else if (value.length < 4) {
                return 'Username must be 4 or more characters';
              }
              return null;
            },
            decoration: _inputDecoration(context, 'Enter Your Username'),
          ),
          const SizedBox(height: 20),
          const Text(
            'Email',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 10),
          TextFormField(
            enabled: !_isLoading,
            keyboardType: TextInputType.emailAddress,
            controller: _emailCtrl,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email address';
              } else if (!value.contains('@') || !value.contains('.')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            decoration: _inputDecoration(context, 'Enter Your Email'),
          ),
          const SizedBox(height: 20),
          const Text(
            'Password',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 10),
          TextFormField(
            enabled: !_isLoading,
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
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration:
                _inputDecoration(context, 'Enter Your Password').copyWith(
              suffixIcon: IconButton(
                onPressed: _isLoading
                    ? null
                    : () => setState(() => _isObscured = !_isObscured),
                tooltip: _isObscured ? 'Show password' : 'Hide password',
                icon: Icon(
                  _isObscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Confirm Password',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 10),
          TextFormField(
            enabled: !_isLoading,
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
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration:
                _inputDecoration(context, 'Confirm Your Password').copyWith(
              suffixIcon: IconButton(
                onPressed: _isLoading
                    ? null
                    : () => setState(() => _isObscured = !_isObscured),
                tooltip: _isObscured ? 'Show password' : 'Hide password',
                icon: Icon(
                  _isObscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        )
                      : Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
