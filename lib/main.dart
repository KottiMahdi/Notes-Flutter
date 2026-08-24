import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/auth/login_view.dart';
import 'views/auth/register_view.dart';
import 'views/auth/forgot_password_view.dart';
import 'views/home/home_view.dart';
import 'views/categories/add_category_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
                  fontWeight: FontWeight.bold),
              iconTheme: const IconThemeData(color: Colors.orange))),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final user = snapshot.data;
          if (user == null || !user.emailVerified) {
            return const LoginView();
          }

          return const HomeView();
        },
      ),
      routes: {
        "homepage": (context) => const HomeView(),
        "addCategory": (context) => const AddCategoryView(),
        "registre": (context) => const RegisterView(),
        "login": (context) => const LoginView(),
        "forgotPWD": (context) => const ForgotPasswordView(),
      },
    );
  }
}
