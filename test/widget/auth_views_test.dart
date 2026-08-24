import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notes_management_mobile_application/controllers/auth_controller.dart';
import 'package:notes_management_mobile_application/views/auth/forgot_password_view.dart';
import 'package:notes_management_mobile_application/views/auth/login_view.dart';
import 'package:notes_management_mobile_application/views/auth/register_view.dart';

class _NoopAuthController extends AuthController {
  _NoopAuthController()
      : super(
          auth: MockFirebaseAuth(),
          firestore: FakeFirebaseFirestore(),
        );
}

class _SuccessfulLoginAuthController extends AuthController {
  _SuccessfulLoginAuthController()
      : super(
          auth: MockFirebaseAuth(
            mockUser: MockUser(
              uid: 'verified-user',
              email: 'john@example.com',
              isEmailVerified: true,
            ),
            signedIn: true,
          ),
          firestore: FakeFirebaseFirestore(),
        );
}

Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    routes: {
      'homepage': (_) => const Scaffold(body: Text('Home')),
      'login': (_) => const Scaffold(body: Text('Login')),
      'registre': (_) => const Scaffold(body: Text('Register')),
      'forgotPWD': (_) => const Scaffold(body: Text('Forgot Password')),
    },
    home: Scaffold(body: child),
  );
}

void main() {
  group('Auth UI views', () {
    testWidgets('login view renders title and login button', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          LoginView(authController: _NoopAuthController()),
        ),
      );

      expect(find.text('Login'), findsWidgets);
      expect(find.text('Login To Continue Using The App'), findsOneWidget);
      expect(find.textContaining('Login with Google'), findsOneWidget);
    });

    testWidgets('register view renders sign-up content', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          RegisterView(authController: _NoopAuthController()),
        ),
      );

      expect(find.text('Sign Up'), findsWidgets);
      expect(find.text('Create An Account To Login'), findsOneWidget);
      expect(find.text('Login'), findsWidgets);
    });

    testWidgets('forgot password view renders reset form', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          ForgotPasswordView(authController: _NoopAuthController()),
        ),
      );

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('RESET PASSWORD'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('login view Google button uses injected controller',
        (tester) async {
      final google = GoogleSignIn();
      final auth = _SuccessfulLoginAuthController();
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            'homepage': (_) => const Scaffold(body: Text('Home')),
          },
          home: LoginView(authController: auth, googleSignIn: google),
        ),
      );

      expect(find.byType(MaterialButton), findsWidgets);
      expect(find.textContaining('Login with Google'), findsOneWidget);
    });
  });
}
