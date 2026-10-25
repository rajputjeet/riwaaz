import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shaadi_hub/data/models/razorpay_payment_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shaadi_hub/data/api_provider/vendor_api_provider.dart';
import 'package:shaadi_hub/data/models/vendor_coupon_model.dart';
import 'package:shaadi_hub/data/shared/data_response.dart';
import 'package:shaadi_hub/features/vendor_registration/vendor_subscription_checkout_flow.dart';

class _CouponApi implements VendorApiProvider {
  bool empty = false;
  bool reject = false;
  bool rejectVerification = false;
  int verificationCalls = 0;
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
  Future<DataResponse<RazorpayOrderModel>> createRazorpayOrder({
    required String type,
    required String planId,
    String? couponCode,
  }) async => DataResponse(
    isSuccess: true,
    data: RazorpayOrderModel.fromJson({
      'isFree': couponCode == 'FREE100',
      'orderId': 'order_test',
      'keyId': 'rzp_test_example',
      'amount': couponCode == 'FREE100' ? 0 : 999,
      'amountInPaise': couponCode == 'FREE100' ? 0 : 99900,
      'couponCode': couponCode,
    }),
  );

  @override
  Future<DataResponse<RazorpayVerificationModel>> verifyRazorpayPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    verificationCalls++;
    return DataResponse(
      isSuccess: !rejectVerification,
      message: rejectVerification ? 'Payment verification failed.' : null,
      data: RazorpayVerificationModel(
        verified: !rejectVerification,
        orderId: orderId,
        paymentId: paymentId,
        transactionId: 'transaction_test',
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
        onPay: onPay ?? (_, _, _) async => false,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('razorpay_flutter'), (
          call,
        ) async {
          if (call.method == 'open') {
            return {
              'type': 0,
              'data': {
                'razorpay_payment_id': 'pay_test',
                'razorpay_order_id': 'order_test',
                'razorpay_signature': 'signature_test',
              },
            };
          }
          return null;
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('razorpay_flutter'),
          null,
        );
  });

  test('an incomplete order cannot silently activate a free plan', () {
    for (final data in <Map<String, dynamic>>[
      {},
      {'isFree': true},
      {'amount': 0},
      {'isFree': true, 'amount': 999, 'amountInPaise': 99900},
      {'isFree': false, 'amount': 999, 'amountInPaise': 999},
    ]) {
      expect(() => RazorpayOrderModel.fromJson(data), throwsFormatException);
    }
  });

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
      final api = _CouponApi()..empty = true;
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
                          api: api,
                          onPay: (_, _, transactionId) async {
                            expect(api.verificationCalls, 1);
                            expect(transactionId, 'transaction_test');
                            return true;
                          },
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

  testWidgets('unverified payment never assigns a plan and allows retry', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var requests = 0;
    final api = _CouponApi()..rejectVerification = true;
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
          api: api,
          onPay: (method, code, _) async {
            requests++;
            expect(method, 'Razorpay');
            expect(code, isNull);
            throw Exception('offline');
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pay ₹999 securely'), findsOneWidget);
    await tester.tap(find.text('Pay ₹999 securely'));
    await tester.pumpAndSettle();
    expect(requests, 0);
    expect(api.verificationCalls, 1);
    expect(find.text('Payment verification failed.'), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
  });

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
        onPay: (m, c, _) async {
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
      expect(method, 'Coupon');
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
