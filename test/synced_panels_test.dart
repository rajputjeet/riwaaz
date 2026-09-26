import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shaadi_hub/core/services/booking_service.dart';
import 'package:shaadi_hub/features/shell/main_shell.dart';
import 'package:shaadi_hub/features/vendor_panel/vendor_shell.dart';

void main() {
  setUp(() {
    AppBookingService.instance.resetForTesting();
  });

  testWidgets(
      'Synchronized Panels Process: Customer booking -> Vendor Pending -> Vendor Accepts -> Contact Unlocked',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final service = AppBookingService.instance;
    final initialTotal = service.customerBookingsCount;
    final initialPending = service.pendingCount;

    // 1. Customer creates a new booking (as done by VendorDetailScreen)
    final newBooking = service.createBooking(
      vendorName: 'Royal Luxury Mandap Designers',
      category: 'Decoration & Themes',
      package: 'Imperial Crystal Floral Canopy',
      total: '₹80,000',
      price: 80000,
      clientName: 'Simran & Rahul 💍',
      clientPhone: '+91 98765 99001',
      vendorPhone: '+91 98722 44332',
      date: '28 Dec 2026',
      time: 'Evening Ceremony',
      venue: 'The Oberoi Sukhvilas Lawn',
      eventName: 'Grand Royal Vivah',
      eventType: 'Wedding',
    );

    // Verify service reacted
    expect(service.customerBookingsCount, equals(initialTotal + 1));
    expect(service.pendingCount, equals(initialPending + 1));
    expect(newBooking.isPending, isTrue);
    expect(newBooking.isAccepted, isFalse);

    // 2. Open Customer Bookings Tab
    await tester.pumpWidget(
      const MaterialApp(
        home: MainShell(initialIndex: 3),
      ),
    );
    await tester.pumpAndSettle();

    // Verify new booking is visible on customer panel
    expect(find.text('Royal Luxury Mandap Designers'), findsOneWidget);

    // Verify contact is locked for this new pending booking
    expect(find.text('Call & WhatsApp unlock upon acceptance'), findsWidgets);

    // 3. Open Vendor Panel
    await tester.pumpWidget(
      const MaterialApp(
        home: VendorShell(initialIndex: 1),
      ),
    );
    await tester.pumpAndSettle();

    // Verify vendor bookings tab has Pending selected by default and shows the new request
    expect(find.textContaining('Pending (${service.pendingCount})'), findsOneWidget);
    expect(find.text('Royal Luxury Mandap Designers'), findsWidgets);
    expect(find.text('Accept Booking'), findsWidgets);
    expect(find.text('Decline'), findsWidgets);

    // 4. Vendor accepts the booking
    await tester.tap(find.text('Accept Booking').first);
    await tester.pumpAndSettle();

    // Verify service state updated to Confirmed
    expect(service.pendingCount, equals(initialPending));
    expect(service.confirmedCount, greaterThan(0));

    // 5. Open Customer Bookings Tab again to verify Call & WhatsApp are unlocked
    await tester.pumpWidget(
      const MaterialApp(
        home: MainShell(initialIndex: 3),
      ),
    );
    await tester.pumpAndSettle();

    // Now Call and WhatsApp buttons are available for the accepted booking
    expect(find.text('Call'), findsWidgets);
    expect(find.text('WhatsApp'), findsWidgets);

    // Verify in-person payment terms are present
    expect(find.text('Pay In-Person'), findsWidgets);

    // Verify no Chat button exists
    expect(find.text('Chat'), findsNothing);
  });
}
