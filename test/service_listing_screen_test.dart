import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shaadi_hub/controllers/category_controller.dart';
import 'package:shaadi_hub/features/service_listing/service_listing_screen.dart';
import 'package:shaadi_hub/features/vendor_detail/vendor_detail_screen.dart';

void main() {
  setUp(() {
    Get.reset();
    Get.put(CategoryController());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('ServiceListingScreen renders and has no dummy vendors',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const GetMaterialApp(
        home: ServiceListingScreen(category: 'Photographers & Videographers'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // Verify header exists
    expect(find.byType(ServiceListingScreen), findsOneWidget);
    expect(find.text('Photographers & Videographers'), findsOneWidget);

    // Verify static dummy vendors are NOT present
    expect(find.text('Royal Mandap & Floral Decor'), findsNothing);
    expect(find.text('Flora Magic Events'), findsNothing);
    expect(find.text('Grand Stage Crafters'), findsNothing);
    expect(find.text('Flavours of Punjab Caterers'), findsNothing);
  });

  testWidgets('VendorDetailScreen renders dynamically',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const GetMaterialApp(
        home: VendorDetailScreen(
          vendorName: 'Apex Studio Events',
          location: 'Mohali',
          startingPrice: 30000,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('Apex Studio Events'), findsWidgets);
    expect(find.text('Mohali'), findsOneWidget);
  });
}
