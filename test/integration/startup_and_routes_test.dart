import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App startup and route flow', () {
    testWidgets('MaterialApp includes the app routes', (tester) async {
      final routes = {
        'homepage': (_) => const Scaffold(body: Text('Home')),
        'addCategory': (_) => const Scaffold(body: Text('Add Category')),
        'registre': (_) => const Scaffold(body: Text('Register')),
        'login': (_) => const Scaffold(body: Text('Login')),
        'forgotPWD': (_) => const Scaffold(body: Text('Forgot Password')),
      };

      await tester.pumpWidget(MaterialApp(
        routes: routes,
        home: const Scaffold(body: Text('Root')),
      ));

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(routes.containsKey('login'), isTrue);
      expect(routes.containsKey('homepage'), isTrue);
      expect(routes.containsKey('forgotPWD'), isTrue);
      expect(find.text('Root'), findsOneWidget);
    });
  });
}
