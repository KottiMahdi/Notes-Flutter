import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_management_mobile_application/controllers/auth_controller.dart';
import 'package:notes_management_mobile_application/views/auth/login_form.dart';
import 'package:notes_management_mobile_application/views/auth/register_form.dart';

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
      'forgotPWD': (_) => const Scaffold(body: Text('Forgot Password')),
      'login': (_) => const Scaffold(body: Text('Login')),
    },
    home: Scaffold(body: child),
  );
}

void main() {
  group('Auth form widgets', () {
    testWidgets('login form validates empty email and password',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          LoginForm(authController: _NoopAuthController()),
        ),
      );

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email address'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('login form navigates to homepage on successful auth',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          LoginForm(authController: _SuccessfulLoginAuthController()),
        ),
      );

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Enter Your Email'),
          'john@example.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Enter Your Password'), '12345');

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('register form validates password mismatch',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          RegisterForm(authController: _NoopAuthController()),
        ),
      );

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Enter Your Username'), 'john');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Enter Your Email'),
          'john@example.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Enter Your Password'), '12345');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirm Your Password'), '99999');

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });
}
