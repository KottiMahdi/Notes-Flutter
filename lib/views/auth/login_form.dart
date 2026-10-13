import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../core/utils/app_error_messages.dart';

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
  bool _isLoading = false;

  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    _authController = widget.authController ?? AuthController();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _authController.signIn(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('homepage');
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
          fallback: 'Login failed. Please check your details and try again.',
        ),
        btnOkOnPress: () {},
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    InputDecoration decoration({
      required String hintText,
      required IconData icon,
      Widget? suffixIcon,
    }) {
      return InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffixIcon,
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

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Email',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
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
              } else if (!value.contains('@') || !value.contains('.')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            decoration: decoration(
              hintText: 'Enter Your Email',
              icon: Icons.mail_outline,
            ),
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
            style: TextStyle(color: colors.onSurface),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              } else if (value.length < 5) {
                return 'Password must be 5 or more characters';
              }
              return null;
            },
            decoration: decoration(
              hintText: 'Enter Your Password',
              icon: Icons.lock_outline,
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
          Container(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () => Navigator.of(context).pushNamed('forgotPWD'),
              child: Text(
                'Forgot Password ?',
                style: TextStyle(fontSize: 13, color: colors.primary),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: colors.primaryContainer,
                    foregroundColor: colors.onPrimaryContainer,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.onPrimaryContainer,
                          ),
                        )
                      : Text(
                          'Login',
                          style: TextStyle(
                            color: colors.onPrimaryContainer,
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
