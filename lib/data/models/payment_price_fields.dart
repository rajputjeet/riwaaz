/// Normalizes the synchronized rupee fields shared by checkout APIs.
class PaymentPriceFields {
  static const payableKeys = [
    'finalAmount',
    'finalPrice',
    'finalAmountPaid',
    'serverCalculatedPrice',
    'calculatedPrice',
    'serverPrice',
    'subscriptionPrice',
    'adPrice',
    'planPrice',
    'price',
    'amount',
  ];
  static const originalKeys = [
    'originalPrice',
    'originalSubscriptionPrice',
    'originalAdPrice',
    'originalPlanPrice',
    'basePrice',
  ];

  static num? read(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json[key] == null) continue;
      final value = num.tryParse(json[key].toString());
      if (value == null || !value.isFinite || value < 0) {
        throw FormatException('Invalid payment amount: $key.');
      }
      return value;
    }
    final coupon = json['couponDetails'];
    if (coupon is Map) {
      // Only read pricing fields from the nested coupon, not arbitrary nesting.
      return read({for (final key in keys) key: coupon[key]}, keys);
    }
    return null;
  }

  static num payable(Map<String, dynamic> json) =>
      read(json, payableKeys) ??
      (throw const FormatException('No valid payable amount was provided.'));

  static num? original(Map<String, dynamic> json) => read(json, originalKeys);
  static num? discount(Map<String, dynamic> json) =>
      read(json, const ['discountAmount', 'savings']);
}
