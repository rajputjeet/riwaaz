import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shaadi_hub/features/shell/main_shell.dart';

void main() {
  testWidgets(
      'Profile tab renders legal policies, bottom logout and delete account options',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: MainShell(initialIndex: 4),
      ),
    );
    await tester.pumpAndSettle();

    // Verify user profile header
    expect(find.text('Simran & Rahul 💍'), findsOneWidget);

    // Verify section headers
    expect(find.text('EVENT PLANNING TOOLS'), findsOneWidget);
    expect(find.text('LEGAL & POLICIES'), findsOneWidget);

    // Verify Privacy Policy & Terms & Conditions options
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Terms & Conditions'), findsOneWidget);

    // Verify Logout button exists at bottom
    expect(find.text('Logout'), findsOneWidget);

    // Verify Delete Account option exists
    expect(find.text('Delete Account'), findsOneWidget);

    // 1. Test Privacy Policy
    await tester.ensureVisible(find.text('Privacy Policy'));
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.text('1. Commitment to User Privacy'), findsOneWidget);
    expect(find.text('3. In-Person Payments & No Banking Data Collection'),
        findsOneWidget);

    // Close Privacy Policy sheet
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // 2. Test Terms & Conditions
    await tester.ensureVisible(find.text('Terms & Conditions'));
    await tester.tap(find.text('Terms & Conditions'));
    await tester.pumpAndSettle();
    expect(find.text('1. Acceptance of Terms'), findsOneWidget);
    expect(find.text('3. In-Person Payments & Direct Contracts'), findsOneWidget);

    // Close Terms sheet
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // 3. Test Logout dialog
    await tester.ensureVisible(find.text('Logout'));
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(find.text('Log Out'), findsWidgets);
    expect(find.text('Cancel'), findsOneWidget);

    // Dismiss dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // 4. Test Delete Account dialog
    await tester.ensureVisible(find.text('Delete Account'));
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();
    expect(find.text('Keep Account'), findsOneWidget);
    expect(find.text('Delete Permanently'), findsOneWidget);

    // Dismiss dialog
    await tester.tap(find.text('Keep Account'));
    await tester.pumpAndSettle();
  });
}
