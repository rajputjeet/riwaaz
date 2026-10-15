import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shaadi_hub/controllers/category_controller.dart';
import 'package:shaadi_hub/core/constants/service_categories.dart';
import 'package:shaadi_hub/data/models/category_model.dart';
import 'package:shaadi_hub/features/dashboard/dashboard_screen.dart';

void main() {
  setUp(() {
    Get.reset();
    Get.put(CategoryController());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('DashboardBody renders real categories and no dummy fallback vendors',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final catCtrl = CategoryController.to;

    // Inject 3 real server categories
    catCtrl.serviceCategories.assignAll([
      ServiceCategoryItem.fromCategoryModel(
        CategoryModel(id: 'cat_1', name: 'Real Luxury Mandaps', desc: 'Real mandap services'),
        index: 0,
      ),
      ServiceCategoryItem.fromCategoryModel(
        CategoryModel(id: 'cat_2', name: 'Real Cinematic Films', desc: 'Real film services'),
        index: 1,
      ),
      ServiceCategoryItem.fromCategoryModel(
        CategoryModel(id: 'cat_3', name: 'Real Royal Catering', desc: 'Real catering services'),
        index: 2,
      ),
    ]);
    catCtrl.isLoaded.value = true;
    catCtrl.isLoading.value = false;

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: DashboardBody(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // 1. Verify real categories appear
    expect(find.text('Real Luxury Mandaps'), findsOneWidget);
    expect(find.text('Real Cinematic Films'), findsOneWidget);
    expect(find.text('Real Royal Catering'), findsOneWidget);

    // 2. Verify previous hardcoded dummy categories do NOT appear
    expect(find.text('Photographers'), findsNothing);
    expect(find.text('Makeup Artists'), findsNothing);
    expect(find.text('Decorators'), findsNothing);

    // 3. Verify top promo banner cards remain present (as requested: "except top cards")
    expect(find.textContaining('Dream Wedding'), findsOneWidget);

    // 4. Verify dummy vendors like 'Royal Photography' do NOT appear
    expect(find.text('Royal Photography'), findsNothing);
    expect(find.text('The Grand Venue'), findsNothing);
    expect(find.text('Elegance Bridal Studio'), findsNothing);
    expect(find.text('Grand Stage Crafters'), findsNothing);
    expect(find.text('Royal Feast Catering'), findsNothing);
  });
}
