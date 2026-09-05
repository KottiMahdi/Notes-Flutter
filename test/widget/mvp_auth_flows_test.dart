import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_management_mobile_application/controllers/auth_controller.dart';
import 'package:notes_management_mobile_application/models/user_model.dart';
import 'package:notes_management_mobile_application/views/auth/login_form.dart';

class _RecordingAuthController extends AuthController {
  final Object? signInFailure;
  bool signUpCalled = false;
  bool profileSaved = false;
  bool verificationSent = false;
  String? resetEmail;

  _RecordingAuthController({this.signInFailure})
      : super(
          auth: MockFirebaseAuth(),
          firestore: FakeFirebaseFirestore(),
        );

  @override
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    if (signInFailure != null) throw signInFailure!;
    return super.signIn(email: email, password: password);
  }

  @override
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    signUpCalled = true;
    return super.signUp(email: email, password: password);
  }

  @override
  Future<void> saveUserDetails(UserModel user) async {
    profileSaved = true;
    await super.saveUserDetails(user);
  }

  @override
  Future<void> sendEmailVerification() async {
    verificationSent = true;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    resetEmail = email.trim();
  }
}

Widget _formApp(Widget child) {
  return MaterialApp(
    routes: {
      'homepage': (_) => const Scaffold(body: Text('Home')),
      'login': (_) => const Scaffold(body: Text('Login')),
    },
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('login screen renders its core controls', (tester) async {
    await tester.pumpWidget(_formApp(LoginForm(
      authController: _RecordingAuthController(),
    )));

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Forgot Password ?'), findsOneWidget);
  });

  test('registration creates the account workflow and sends verification',
      () async {
    final controller = _RecordingAuthController();
    await controller.signUp(email: 'jane@example.com', password: 'secret');
    await controller.saveUserDetails(
      UserModel(username: 'jane', email: 'jane@example.com'),
    );
    await controller.sendEmailVerification();

    expect(controller.signUpCalled, isTrue);
    expect(controller.profileSaved, isTrue);
    expect(controller.verificationSent, isTrue);
    expect(controller.currentUser?.email, 'jane@example.com');
  });

  test('password reset sends the entered email', () async {
    final controller = _RecordingAuthController();
    await controller.sendPasswordReset(' reset@example.com ');

    expect(controller.resetEmail, 'reset@example.com');
  });

  test('authentication failure is surfaced by the auth controller', () async {
    final controller = _RecordingAuthController(
      signInFailure: FirebaseAuthException(code: 'wrong-password'),
    );

    expect(
      () => controller.signIn(
        email: 'user@example.com',
        password: 'secret',
      ),
      throwsA(
        isA<FirebaseAuthException>().having(
          (error) => error.code,
          'code',
          'wrong-password',
        ),
      ),
    );
  });

  test('restored authenticated session is exposed by auth state changes',
      () async {
    final auth = MockFirebaseAuth(
      mockUser: MockUser(
        uid: 'restored-user',
        email: 'restored@example.com',
        isEmailVerified: true,
      ),
      signedIn: true,
    );
    final controller = AuthController(
      auth: auth,
      firestore: FakeFirebaseFirestore(),
    );

    expect(await controller.authStateChanges().first, same(auth.currentUser));
  });
}
