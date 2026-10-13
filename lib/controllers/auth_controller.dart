import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../core/utils/screen_cache.dart';

class AuthController {
  final AuthService _authService;
  final UserService _userService;

  AuthController({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
    AuthService? authService,
    UserService? userService,
  })  : _authService =
            authService ?? AuthService(auth: auth, googleSignIn: googleSignIn),
        _userService = userService ?? UserService(firestore: firestore);

  Future<void> _signOutGoogleSession() async {
    try {
      await _authService.signOutGoogle();
    } catch (_) {
      debugPrint('Google sign-out did not complete; continuing sign-out.');
    }
  }

  Future<void> _ensureEmailIsVerified(UserCredential credential) async {
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'Authentication succeeded but no user was returned.',
      );
    }

    await _authService.reloadCurrentUser(user);
    final refreshedUser = _authService.currentUser;
    if (refreshedUser == null || !refreshedUser.emailVerified) {
      await _authService.signOut();
      await _signOutGoogleSession();
      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: 'Please verify your email before continuing.',
      );
    }
  }

  Future<bool> restoreVerifiedSession(User user) async {
    await _authService.reloadCurrentUser(user);
    final currentUser = _authService.currentUser;
    if (currentUser == null) return false;

    if (!currentUser.emailVerified) {
      await _authService.signOut();
      return false;
    }

    return true;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.signIn(
      email: email.trim(),
      password: password,
    );

    await _ensureEmailIsVerified(credential);
    return credential;
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return _authService.signUp(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> saveUserDetails(UserModel user) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user available to save profile data.',
      );
    }

    await _userService.saveUserDetails(uid, user);
  }

  Future<void> sendEmailVerification() async {
    final user = _authService.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No user is currently signed in.',
      );
    }

    await _authService.sendEmailVerification(user);
  }

  Future<UserCredential> signInWithGoogle() async {
    final userCredential = await _authService.signInWithGoogle();
    await _ensureEmailIsVerified(userCredential);
    return userCredential;
  }

  Future<void> sendPasswordReset(String email) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      throw ArgumentError.value(email, 'email', 'Enter your email address.');
    }

    await _authService.sendPasswordReset(trimmedEmail);
  }

  Future<void> signOut() async {
    ScreenCache.clear();
    await _signOutGoogleSession();
    await _authService.signOut();
  }

  Future<void> deleteAccount() async {
    ScreenCache.clear();
    final user = _authService.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user available to delete.',
      );
    }

    await _userService.deleteUserData(user.uid);
    await _authService.deleteCurrentUser(user);
    await _authService.signOut();
    await _signOutGoogleSession();
  }

  User? get currentUser => _authService.currentUser;

  Stream<User?> authStateChanges() => _authService.authStateChanges();
}
