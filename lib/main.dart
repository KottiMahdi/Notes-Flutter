import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'utils/app_error_messages.dart';
import 'views/auth/forgot_password_view.dart';
import 'views/auth/login_view.dart';
import 'views/auth/register_view.dart';
import 'views/categories/add_category_view.dart';
import 'views/home/home_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> Function()? firebaseInitializer;
  final FirebaseAuth? auth;

  const MyApp({
    super.key,
    this.firebaseInitializer,
    this.auth,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[50],
          titleTextStyle: const TextStyle(
            color: Colors.orange,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Colors.orange),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: _AppBootstrap(
        firebaseInitializer: firebaseInitializer,
        auth: auth,
      ),
      routes: {
        'homepage': (context) => const HomeView(),
        'addCategory': (context) => const AddCategoryView(),
        'registre': (context) => const RegisterView(),
        'login': (context) => const LoginView(),
        'forgotPWD': (context) => const ForgotPasswordView(),
      },
    );
  }
}

class _AppBootstrap extends StatefulWidget {
  final Future<FirebaseApp> Function()? firebaseInitializer;
  final FirebaseAuth? auth;

  const _AppBootstrap({
    this.firebaseInitializer,
    this.auth,
  });

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  late Future<FirebaseApp> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initializeFirebase();
  }

  Future<FirebaseApp> _initializeFirebase() {
    final initializer = widget.firebaseInitializer;
    if (initializer != null) {
      return initializer();
    }

    return Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  void _retry() {
    setState(() {
      _initialization = _initializeFirebase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingScaffold(message: 'Starting app...');
        }

        if (snapshot.hasError) {
          return _ErrorScaffold(
            title: 'App failed to start',
            message: AppErrorMessages.fromException(
              snapshot.error,
              fallback:
                  'Could not start the app. Check your connection and try again.',
            ),
            onRetry: _retry,
          );
        }

        return _AuthGate(auth: widget.auth ?? FirebaseAuth.instance);
      },
    );
  }
}

class _AuthGate extends StatelessWidget {
  final FirebaseAuth auth;

  const _AuthGate({required this.auth});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScaffold(message: 'Checking session...');
        }

        if (snapshot.hasError) {
          return _ErrorScaffold(
            title: 'Session error',
            message: AppErrorMessages.fromException(
              snapshot.error,
              fallback: 'Could not check your session. Please restart the app.',
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginView();
        }

        return _VerifiedSession(auth: auth, user: user);
      },
    );
  }
}

class _VerifiedSession extends StatefulWidget {
  final FirebaseAuth auth;
  final User user;

  const _VerifiedSession({
    required this.auth,
    required this.user,
  });

  @override
  State<_VerifiedSession> createState() => _VerifiedSessionState();
}

class _VerifiedSessionState extends State<_VerifiedSession> {
  late Future<bool> _sessionCheck;

  @override
  void initState() {
    super.initState();
    _sessionCheck = _checkSession();
  }

  @override
  void didUpdateWidget(covariant _VerifiedSession oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.uid != widget.user.uid) {
      _sessionCheck = _checkSession();
    }
  }

  Future<bool> _checkSession() async {
    await widget.user.reload();
    final currentUser = widget.auth.currentUser;
    if (currentUser == null) {
      return false;
    }

    if (!currentUser.emailVerified) {
      await widget.auth.signOut();
      return false;
    }

    return true;
  }

  void _retry() {
    setState(() {
      _sessionCheck = _checkSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _sessionCheck,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingScaffold(message: 'Restoring session...');
        }

        if (snapshot.hasError) {
          return _ErrorScaffold(
            title: 'Session error',
            message: AppErrorMessages.fromException(
              snapshot.error,
              fallback:
                  'Could not restore your session. Check your connection and try again.',
            ),
            onRetry: _retry,
          );
        }

        return snapshot.data == true ? const HomeView() : const LoginView();
      },
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  final String message;

  const _LoadingScaffold({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const _ErrorScaffold({
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700, size: 48),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
