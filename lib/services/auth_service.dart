import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/error/error_mapper.dart';
import '../core/error/failures.dart';
import '../core/error/guarded_call.dart';

class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  // google_sign_in 7 requires initialize() exactly once per process.
  static Future<void>? _googleInit;

  Future<void> _ensureGoogleInitialized() =>
      _googleInit ??= _googleSignIn.initialize().catchError((Object error) {
        _googleInit = null;
        throw error;
      });

  User? get currentUser => _auth.currentUser;

  User requireCurrentUser() {
    final user = currentUser;
    if (user == null) {
      throw const AuthenticationFailure(
        code: 'no-current-user',
        message: 'Please sign in again to continue.',
      );
    }
    return user;
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges().transform(
        StreamTransformer<User?, User?>.fromHandlers(
          handleError: (error, stackTrace, sink) {
            sink.addError(mapToFailure(error, stackTrace), stackTrace);
          },
        ),
      );

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) =>
      guardedCall(
        () =>
            _auth.signInWithEmailAndPassword(email: email, password: password),
      );

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) =>
      guardedCall(
        () => _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ),
      );

  Future<UserCredential> signInWithGoogle() => guardedCall(() async {
        await _ensureGoogleInitialized();
        final GoogleSignInAccount googleUser;
        try {
          googleUser = await _googleSignIn.authenticate();
        } on GoogleSignInException catch (error) {
          if (error.code == GoogleSignInExceptionCode.canceled ||
              error.code == GoogleSignInExceptionCode.interrupted) {
            throw const AuthActionCancelledException();
          }
          rethrow;
        }

        final credential = GoogleAuthProvider.credential(
          idToken: googleUser.authentication.idToken,
        );
        return _auth.signInWithCredential(credential);
      });

  Future<void> reloadCurrentUser(User user) => guardedCall(user.reload);

  Future<void> sendEmailVerification(User user) =>
      guardedCall(user.sendEmailVerification);

  Future<void> sendPasswordReset(String email) =>
      guardedCall(() => _auth.sendPasswordResetEmail(email: email));

  Future<void> signOutGoogle() => guardedCall(() async {
        await _ensureGoogleInitialized();
        await _googleSignIn.signOut();
      });

  Future<void> signOut() => guardedCall(_auth.signOut);

  Future<void> deleteCurrentUser(User user) => guardedCall(user.delete);
}
