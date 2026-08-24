import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_management_mobile_application/controllers/auth_controller.dart';
import 'package:notes_management_mobile_application/views/auth/forgot_password_view.dart';

class _ResetAuthController extends AuthController {
  _ResetAuthController()
      : super(
          auth: MockFirebaseAuth(
            mockUser: MockUser(
              uid: 'reset-user',
              email: 'reset@example.com',
              isEmailVerified: true,
            ),
            signedIn: true,
          ),
          firestore: FakeFirebaseFirestore(),
        );
}

void main() {
  group('Forgot password view flow', () {
    testWidgets('reset password view renders email field and reset action',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ForgotPasswordView(authController: _ResetAuthController()),
        ),
      );

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('RESET PASSWORD'), findsOneWidget);
    });
  });
}
