import 'package:flutter_test/flutter_test.dart';
import 'package:shaadi_hub/data/models/active_plan_model.dart';
import 'package:shaadi_hub/data/models/subscription_model.dart';
import 'package:shaadi_hub/data/models/vendor_coupon_model.dart';

void main() {
  test(
    'duration aliases accept numeric and string values on list and active plans',
    () {
      for (final key in [
        'durationInMonths',
        'durationMonths',
        'durationMonth',
        'duration_months',
        'duration_month',
      ]) {
        for (final value in [6, '6']) {
          final json = <String, dynamic>{key: value, 'durations': 'Six months'};
          final plan = SubscriptionModel.fromJson(json);
          expect(plan.durationInMonths, 6);
          expect(plan.durationMonth, 6);
          expect(plan.durationMonths, 6);
          expect(plan.durationLabel, 'Six months');
          expect(ActivePlanDetail.fromJson(json).durationInMonths, 6);
          expect(
            SubscriptionModel.fromJson(plan.toJson()).durationLabel,
            'Six months',
          );
        }
      }
      expect(
        SubscriptionModel.fromJson({'type': '1 Year'}).durationInMonths,
        12,
      );
      expect(
        SubscriptionModel.fromJson({'type': '3 Months'}).durationInMonths,
        3,
      );
      expect(SubscriptionModel.fromJson({}).durationLabel, '1 Month');
      expect(
        SubscriptionModel.fromJson({
          'duration': '',
          'durations': '6 Months',
        }).durationLabel,
        '6 Months',
      );
    },
  );

  test(
    'active plan retains new purchase fields and history including free amounts',
    () {
      final active = ActivePlanModel.fromJson({
        'isSubscriptionActive': true,
        'subscriptionPlan': {'_id': 'p1', 'durationMonth': 1, 'price': '999'},
        'subscriptionOriginalPrice': '999',
        'subscriptionDiscountAmount': 999,
        'subscriptionFinalAmount': 0,
        'finalAmountPaid': 999,
        'subscriptionCouponApplied': true,
        'subscriptionCouponCode': 'FREE100',
        'subscriptionPaymentMethod': 'Free',
        'subscriptionTransactionId': 'FREE-COUPON',
        'subscriptionHistory': [
          {
            'planTitle': 'Starter',
            'planType': '1 Month',
            'originalPrice': 999,
            'discountAmount': 999,
            'finalAmount': 0,
            'couponApplied': true,
            'couponCode': 'FREE100',
            'paymentMethod': 'Free',
            'transactionId': 'FREE-COUPON',
            'purchasedAt': '2026-10-25T00:00:00Z',
            'endDate': '2026-11-25T00:00:00Z',
          },
        ],
      });
      expect(active.isExpired, isFalse);
      expect(active.finalAmount, 0);
      expect(active.subscriptionPlan!.price, 999);
      expect(active.history.single.purchasedAt, DateTime.utc(2026, 10, 25));
      final restored = ActivePlanModel.fromJson(active.toJson());
      expect(restored.couponCode, 'FREE100');
      expect(restored.paymentMethod, 'Free');
      expect(restored.transactionId, 'FREE-COUPON');
      expect(restored.history.single.finalAmount, 0);
    },
  );

  test('legacy buy response fields still parse', () {
    final plan = ActivePlanModel.fromJson({
      'originalPrice': 1299,
      'discountAmount': 325,
      'finalAmountPaid': 974,
      'couponApplied': true,
      'couponCode': 'SAVE25',
      'paymentMethod': 'UPI',
      'transactionId': 'paid-reference',
    });
    expect(plan.originalPrice, 1299);
    expect(plan.discountAmount, 325);
    expect(plan.finalAmount, 974);
    expect(plan.couponApplied, isTrue);
    expect(plan.couponCode, 'SAVE25');
    expect(plan.history, isEmpty);
    expect(ActivePlanModel.fromJson({}).finalAmount, isNull);
  });

  test('coupon limits support unlimited zero and fixed discounts', () {
    final coupon = VendorCouponModel.fromJson({
      'usageLimit': '100',
      'usageLimitPerUser': '2',
      'usedCount': 7,
      'discountType': 'fixed',
      'discountValue': '250',
    });
    expect(coupon.usageLimit, 100);
    expect(coupon.usageLimitPerUser, 2);
    expect(coupon.usedCount, 7);
    expect(coupon.discountBadge, '₹250 OFF');
    expect(VendorCouponModel.fromJson({}).usageLimit, 0);
    expect(
      VendorCouponModel.fromJson({'usageLimitPerUser': 0}).usageLimitPerUser,
      0,
    );
  });
}
