class RazorpayOrderModel {
  final bool isFree;
  final String? orderId;
  final String? keyId;
  final String currency;
  final String? type;
  final String? planId;
  final String? couponCode;
  final String? planTitle;
  final int amountInPaise;
  final num originalPrice;
  final num discountAmount;
  final num finalAmount;

  const RazorpayOrderModel({
    required this.isFree,
    required this.orderId,
    required this.keyId,
    required this.currency,
    required this.type,
    required this.planId,
    required this.couponCode,
    required this.planTitle,
    required this.amountInPaise,
    required this.originalPrice,
    required this.discountAmount,
    required this.finalAmount,
  });

  factory RazorpayOrderModel.fromJson(Map<String, dynamic> json) {
    final finalAmount = num.tryParse(
      (json['finalAmount'] ?? json['amount'])?.toString() ?? '',
    );
    final paise = json['amountInPaise'] == null
        ? finalAmount == null
              ? null
              : (finalAmount * 100).round()
        : num.tryParse(json['amountInPaise'].toString());
    if (finalAmount == null ||
        !finalAmount.isFinite ||
        finalAmount < 0 ||
        paise == null ||
        !paise.isFinite ||
        paise < 0 ||
        paise != paise.round() ||
        paise != (finalAmount * 100).round()) {
      throw const FormatException('Payment order contains an invalid amount.');
    }
    final isFree = json['isFree'] == true;
    if (isFree != (paise == 0)) {
      throw const FormatException(
        'Payment order contains an invalid free-plan confirmation.',
      );
    }
    final details = json['planDetails'] is Map
        ? Map<String, dynamic>.from(json['planDetails'] as Map)
        : const <String, dynamic>{};
    final coupon = json['couponDetails'] is Map
        ? Map<String, dynamic>.from(json['couponDetails'] as Map)
        : const <String, dynamic>{};
    return RazorpayOrderModel(
      isFree: isFree,
      orderId: (json['orderId'] ?? json['razorpayOrderId'])?.toString(),
      keyId: json['keyId']?.toString(),
      currency: json['currency']?.toString() ?? 'INR',
      type: json['type']?.toString(),
      planId: json['planId']?.toString(),
      couponCode: (json['couponCode'] ?? coupon['couponCode'])?.toString(),
      planTitle: details['title']?.toString(),
      amountInPaise: paise.round(),
      originalPrice: _paymentNumber(json['originalPrice']),
      discountAmount: _paymentNumber(
        json['discountAmount'] ?? coupon['discountAmount'],
      ),
      finalAmount: finalAmount,
    );
  }
}

class RazorpayVerificationModel {
  final bool verified;
  final String? orderId;
  final String? paymentId;
  final String? transactionId;

  const RazorpayVerificationModel({
    required this.verified,
    this.orderId,
    this.paymentId,
    this.transactionId,
  });

  factory RazorpayVerificationModel.fromJson(Map<String, dynamic> json) =>
      RazorpayVerificationModel(
        verified: json['verified'] == true,
        orderId: (json['razorpayOrderId'] ?? json['orderId'])?.toString(),
        paymentId: (json['razorpayPaymentId'] ?? json['paymentId'])?.toString(),
        transactionId: json['transactionId']?.toString(),
      );
}

num _paymentNumber(dynamic value, {num fallback = 0}) {
  if (value is num && value.isFinite) return value;
  final parsed = num.tryParse(value?.toString() ?? '');
  return parsed != null && parsed.isFinite ? parsed : fallback;
}
