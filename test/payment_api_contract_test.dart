import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shaadi_hub/data/api_provider/ad_api_provider.dart';
import 'package:shaadi_hub/data/api_provider/vendor_api_provider.dart';
import 'package:shaadi_hub/data/injector.dart';
import 'package:shaadi_hub/data/models/payment_price_fields.dart';
import 'package:shaadi_hub/data/models/razorpay_payment_models.dart';
import 'package:shaadi_hub/data/models/vendor_coupon_model.dart';
import 'package:shaadi_hub/models/subscription_coupon_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all documented payable aliases preserve rupees and paise', () {
    for (final key in PaymentPriceFields.payableKeys) {
      final data = <String, dynamic>{
        'isFree': false,
        key: '799.50',
        'amountInPaise': 79950,
        'originalSubscriptionPrice': 999,
        'savings': 199.50,
      };
      final order = RazorpayOrderModel.fromJson(data);
      expect(order.finalAmount, 799.50, reason: key);
      expect(order.amountInPaise, 79950, reason: key);
      expect(order.originalPrice, 999, reason: key);
      expect(order.discountAmount, 199.50, reason: key);
      expect(ApplyCouponResultModel.fromJson(data).finalPrice, 799.50);
      expect(CouponValidationResult.fromJson(data).finalPrice, 799.50);
    }
  });

  test('base price aliases are distinct from the payable price', () {
    for (final key in PaymentPriceFields.originalKeys) {
      final order = RazorpayOrderModel.fromJson({
        'isFree': false,
        'finalAmount': 799,
        key: 999,
        'savings': 200,
      });
      expect(order.originalPrice, 999);
      expect(order.discountAmount, 200);
      expect(order.finalAmount, 799);
    }
  });

  test(
    'documented free order needs no Razorpay ID or explicit paise field',
    () {
      final order = RazorpayOrderModel.fromJson({
        'isFree': true,
        'orderId': null,
        'amount': 0,
        'finalAmount': 0,
        'originalPrice': 999,
        'discountAmount': 999,
        'couponCode': '100FREE',
      });
      expect(order.isFree, isTrue);
      expect(order.orderId, isNull);
      expect(order.amountInPaise, 0);
      expect(order.couponCode, '100FREE');
    },
  );

  test(
    'nested coupon fields are supported without treating base price as payable',
    () {
      final order = RazorpayOrderModel.fromJson({
        'isFree': false,
        'planDetails': {'price': 999},
        'couponDetails': {
          'couponCode': 'SAVE',
          'serverCalculatedPrice': 799,
          'savings': 200,
        },
      });
      expect(order.finalAmount, 799);
      expect(order.originalPrice, 999);
      expect(order.discountAmount, 200);
      expect(order.couponCode, 'SAVE');
      expect(
        () => RazorpayOrderModel.fromJson({
          'isFree': false,
          'originalPrice': 999,
        }),
        throwsFormatException,
      );
    },
  );

  test('verification maps the backend payment IDs and transaction ID', () {
    final result = RazorpayVerificationModel.fromJson({
      'verified': true,
      'razorpayOrderId': 'order_123',
      'razorpayPaymentId': 'pay_123',
      'transactionId': 'pay_123',
    });
    expect(result.verified, isTrue);
    expect(result.orderId, 'order_123');
    expect(result.paymentId, 'pay_123');
    expect(result.transactionId, 'pay_123');
  });

  for (final status in [200, 403]) {
    test(
      'ad verification rejection survives HTTP $status with status data',
      () async {
        const message =
            'Only verified vendors can purchase ad plans. Your vendor account verification is currently pending.';
        final dio = Injector().getDio();
        final interceptor = InterceptorsWrapper(
          onRequest: (options, handler) {
            final response = Response<dynamic>(
              requestOptions: options,
              statusCode: status,
              data: {
                'success': false,
                'message': message,
                'data': {'isVerified': false, 'applicationStatus': 'Pending'},
              },
            );
            if (status == 200) {
              handler.resolve(response);
            } else {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: response,
                  type: DioExceptionType.badResponse,
                ),
              );
            }
          },
        );
        dio.interceptors.insert(0, interceptor);
        addTearDown(() => dio.interceptors.remove(interceptor));
        final order = await VendorApiProvider().createRazorpayOrder(
          type: 'ad',
          planId: 'plan_test',
        );
        expect(order.isSuccess, isFalse);
        expect(order.data, isNull);
        expect(order.message, message);
        final coupon = await AdApiProvider().validateAdCoupon(
          couponCode: 'SAVE',
          adPlanId: 'plan_test',
        );
        expect(coupon.isSuccess, isFalse);
        expect(coupon.data, isNull);
        expect(coupon.message, message);
      },
    );
  }
}
