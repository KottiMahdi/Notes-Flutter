import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_management_mobile_application/views/settings/about_view.dart';
import 'package:notes_management_mobile_application/views/settings/settings_view.dart';

void main() {
  testWidgets('About NoteNest shows the privacy policy and contact email',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AboutView()),
    );

    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Last updated: October 22, 2026'), findsOneWidget);
    expect(find.text('1. Information We Collect'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('9. Contact Us'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('9. Contact Us'), findsOneWidget);
    expect(find.text('mkotti72@gmail.com'), findsOneWidget);
  });

  testWidgets('Settings opens the About NoteNest page', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsView(onTabSelected: (_, __) {}),
      ),
    );

    final aboutTile = find.text('About NoteNest');
    await tester.scrollUntilVisible(
      aboutTile,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(aboutTile);
    await tester.pumpAndSettle();

    expect(find.text('Privacy Policy'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('9. Contact Us'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('9. Contact Us'), findsOneWidget);
  });
}
