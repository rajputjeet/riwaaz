import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shaadi_hub/features/vendor_panel/vendor_notifications_screen.dart';
import 'package:shaadi_hub/features/notifications/customer_notifications_screen.dart';
import 'package:shaadi_hub/features/vendor_panel/vendor_edit_profile_screen.dart';
import 'package:shaadi_hub/features/profile/customer_edit_profile_screen.dart';
import 'package:shaadi_hub/features/vendor_panel/vendor_verification_screen.dart';
import 'package:shaadi_hub/core/services/booking_service.dart';

void main() {
  setUp(() {
    AppBookingService.instance.resetForTesting();
  });

  testWidgets('VendorNotificationsScreen renders and filters items',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: VendorNotificationsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Partner Notifications'), findsOneWidget);

    // Switch to Updates filter
    await tester.ensureVisible(find.textContaining('Updates'));
    await tester.tap(find.textContaining('Updates'));
    await tester.pumpAndSettle();
    expect(find.text('Gold Partner Badge Active'), findsOneWidget);
    expect(find.text('Direct Settlement Reminder'), findsOneWidget);
  });

  testWidgets('CustomerNotificationsScreen renders and filters items',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: CustomerNotificationsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);

    // Switch to Planning filter
    await tester.ensureVisible(find.textContaining('Planning'));
    await tester.tap(find.textContaining('Planning'));
    await tester.pumpAndSettle();
    expect(find.text('Wedding Checklist Milestone'), findsOneWidget);
    expect(find.text('Pay In Person Reminder'), findsOneWidget);
  });

  testWidgets('VendorEditProfileScreen renders form and saves changes',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: VendorEditProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Business Profile'), findsOneWidget);
    expect(find.text('Royal Click Studio'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);

    await tester.ensureVisible(find.text('Save Changes'));
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
  });

  testWidgets('CustomerEditProfileScreen renders form and saves changes',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: CustomerEditProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Simran Kaur'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);

    await tester.ensureVisible(find.text('Save Changes'));
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
  });

  testWidgets('VendorVerificationScreen renders credentials and perks',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: VendorVerificationScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Verification Status'), findsOneWidget);
    expect(find.text('100% Verified Partner'), findsOneWidget);
    expect(find.text('Government Identity Proof'), findsOneWidget);
    expect(find.text('Business Registration & Tax'), findsOneWidget);
    expect(find.text('Direct Settlement Agreement'), findsOneWidget);
  });
}
