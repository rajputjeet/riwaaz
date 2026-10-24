import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shaadi_hub/data/api_provider/vendor_api_provider.dart';
import 'package:shaadi_hub/data/models/vendor_coupon_model.dart';
import 'package:shaadi_hub/data/shared/data_response.dart';
import 'package:shaadi_hub/features/vendor_registration/vendor_subscription_checkout_flow.dart';

class _CouponApi implements VendorApiProvider {
  bool empty = false;
  bool reject = false;
  String? requestedPlan;

  @override
  Future<DataResponse<List<VendorCouponModel>>> getVendorCoupons({
    String? search,
  }) async => DataResponse(
    isSuccess: true,
    data: empty
        ? []
        : [
            VendorCouponModel(
              couponCode: 'FREE100',
              title: 'Free subscription',
              discountType: 'free',
              validUntil: DateTime(2027, 1, 1),
            ),
          ],
  );

  @override
  Future<DataResponse<ApplyCouponResultModel>> applyVendorCoupon({
    required String couponCode,
    required String subscriptionPlanId,
  }) async {
    requestedPlan = subscriptionPlanId;
    return reject
        ? DataResponse(isSuccess: false, message: 'Coupon has expired.')
        : DataResponse(
            isSuccess: true,
            data: ApplyCouponResultModel(
              couponCode: couponCode,
              originalPrice: 999,
              discountAmount: 999,
              finalPrice: 0,
              savings: 999,
              isFree: true,
            ),
          );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _open(
  WidgetTester tester,
  _CouponApi api, {
  VendorPlanPurchase? onPay,
}) async {
  tester.view.physicalSize = const Size(360, 720);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetViewInsets);
  await tester.pumpWidget(
    MaterialApp(
      // Reproduce the production theme's full-width minimum, including in Rows.
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
      ),
      home: VendorSubscriptionCouponScreen(
        plan: const {
          'id': 'plan-123',
          'name': 'Starter Partner',
          'duration': '1 Month',
          'price': 999,
        },
        api: api,
        onPay: onPay ?? (_, _) async => false,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('pull to refresh reloads even an empty coupon list', (
    tester,
  ) async {
    final api = _CouponApi()..empty = true;
    await _open(tester, api);
    expect(find.text('No coupons for now'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'MYCODE');
    api.empty = false;
    await tester.drag(find.byType(ListView).first, const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(find.text('Free subscription'), findsOneWidget);
    expect(find.text('No coupons for now'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'MYCODE',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'successful checkout returns through both routes to plan selection',
    (tester) async {
      bool? completed;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () async {
                    completed = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => VendorSubscriptionCouponScreen(
                          plan: const {
                            'id': 'plan-123',
                            'name': 'Starter',
                            'price': 999,
                          },
                          api: _CouponApi()..empty = true,
                          onPay: (_, _) async => true,
                        ),
                      ),
                    );
                  },
                  child: const Text('Choose plan'),
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Choose plan'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Continue to checkout'));
      await tester.tap(find.text('Continue to checkout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pay ₹999 securely'));
      await tester.pumpAndSettle();
      expect(completed, isTrue);
      expect(find.text('Choose plan'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test('missing coupon price cannot silently become a free plan', () {
    expect(
      () => ApplyCouponResultModel.fromJson({'isFree': true}),
      throwsFormatException,
    );
    final coupon = ApplyCouponResultModel.fromJson({
      'isFree': true,
      'finalPrice': 974,
    });
    expect(coupon.isFree, isFalse);
  });

  testWidgets(
    'paid checkout displays amount and recovers from a failed request',
    (tester) async {
      tester.view.physicalSize = const Size(360, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var requests = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ),
          home: VendorSecureCheckoutScreen(
            plan: const {
              'id': 'plan-123',
              'name': 'Starter Partner',
              'price': 999,
            },
            coupon: null,
            onPay: (method, code) async {
              requests++;
              expect(method, 'UPI');
              expect(code, isNull);
              throw Exception('offline');
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Select payment mode'), findsOneWidget);
      await tester.tap(find.text('Pay ₹999 securely'));
      await tester.pumpAndSettle();
      expect(requests, 1);
      expect(
        find.text('Could not complete checkout. Please try again.'),
        findsOneWidget,
      );
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'empty offers and inline Apply fit the themed screen with keyboard',
    (tester) async {
      await _open(tester, _CouponApi()..empty = true);
      expect(find.text('No coupons for now'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'FREE100');
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Apply'));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'listed coupon validates the selected plan and free checkout passes its code',
    (tester) async {
      final api = _CouponApi();
      String? method;
      String? code;
      await _open(
        tester,
        api,
        onPay: (m, c) async {
          method = m;
          code = c;
          return false;
        },
      );
      await tester.tap(find.widgetWithText(TextButton, 'Apply'));
      await tester.pumpAndSettle();
      expect(api.requestedPlan, 'plan-123');
      final continueButton = find.widgetWithText(
        ElevatedButton,
        'Continue · Free',
      );
      await tester.ensureVisible(continueButton);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();
      expect(find.text('Select payment mode'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Activate plan for free'));
      await tester.pumpAndSettle();
      expect(method, 'Free');
      expect(code, 'FREE100');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'rejected manual coupon shows the backend error and does not open checkout',
    (tester) async {
      await _open(tester, _CouponApi()..reject = true);
      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'EXPIRED');
      final apply = find.widgetWithText(ElevatedButton, 'Apply');
      await tester.ensureVisible(apply);
      await tester.tap(apply);
      await tester.pumpAndSettle();
      expect(find.text('Coupon has expired.'), findsOneWidget);
      final next = find.widgetWithText(ElevatedButton, 'Continue to checkout');
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(
        find.text('Apply the coupon code before checkout.'),
        findsOneWidget,
      );
      expect(find.byType(VendorSecureCheckoutScreen), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
