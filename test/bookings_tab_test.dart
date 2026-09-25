import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shaadi_hub/features/shell/main_shell.dart';

void main() {
  testWidgets('Bookings tab renders and can filter vendors without crashing',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: MainShell(initialIndex: 3),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header and KPI strip
    expect(find.text('My Bookings'), findsOneWidget);
    expect(find.text('EVENT BUDGET & BOOKINGS'), findsOneWidget);
    expect(find.text('7 Vendors Hired 🎉'), findsOneWidget);

    // Verify filter chips exist
    expect(find.text('All (7)'), findsOneWidget);
    expect(find.text('Office Parties (2)'), findsOneWidget);
    expect(find.text('Birthdays & Parties (2)'), findsOneWidget);
    expect(find.text('Weddings & Galas (3)'), findsOneWidget);

    // Verify vendor cards are visible
    expect(find.text('Grand Stage Crafters & AV Tech'), findsOneWidget);

    // Tap on 'Office Parties (2)' filter chip
    await tester.tap(find.text('Office Parties (2)'));
    await tester.pumpAndSettle();

    // Verify office party vendors are shown
    expect(find.text('TechCorp Office Gala'), findsWidgets);

    // Tap back on 'All (7)'
    await tester.tap(find.text('All (7)'));
    await tester.pumpAndSettle();

    expect(find.text('Grand Stage Crafters & AV Tech'), findsOneWidget);
  });
}
