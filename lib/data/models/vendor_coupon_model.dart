// ignore_for_file: non_constant_identifier_names

class VendorCouponModel {
  final String id;
  final String title;
  final String description;
  final String couponCode;
  final String discountType;
  final num discountValue;
  final num discountPercentage;
  final String applicableFor;
  final num minAmount;
  final num? maxDiscountAmount;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final int usageLimit;
  final int usageLimitPerUser;
  final int usedCount;

  const VendorCouponModel({
    this.id = '',
    this.title = '',
    this.description = '',
    this.couponCode = '',
    this.discountType = 'percentage',
    this.discountValue = 0,
    this.discountPercentage = 0,
    this.applicableFor = 'subscription',
    this.minAmount = 0,
    this.maxDiscountAmount,
    this.validFrom,
    this.validUntil,
    this.usageLimit = 0,
    this.usageLimitPerUser = 0,
    this.usedCount = 0,
  });

  factory VendorCouponModel.fromJson(Map<String, dynamic> json) {
    return VendorCouponModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      couponCode: json['couponCode']?.toString() ?? '',
      discountType: json['discountType']?.toString() ?? 'percentage',
      discountValue: _number(json['discountValue']),
      discountPercentage: _number(json['discountPercentage']),
      applicableFor: json['applicableFor']?.toString() ?? 'subscription',
      minAmount: _number(json['minAmount']),
      maxDiscountAmount: json['maxDiscountAmount'] == null
          ? null
          : _number(json['maxDiscountAmount']),
      validFrom: DateTime.tryParse(json['validFrom']?.toString() ?? ''),
      validUntil: DateTime.tryParse(json['validUntil']?.toString() ?? ''),
      usageLimit: _number(json['usageLimit']).toInt(),
      usageLimitPerUser: _number(json['usageLimitPerUser']).toInt(),
      usedCount: _number(json['usedCount']).toInt(),
    );
  }

  String get discountBadge {
    switch (discountType.toLowerCase()) {
      case 'free':
        return 'FREE';
      case 'percentage':
        final value = discountPercentage == 0
            ? discountValue
            : discountPercentage;
        return '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}% OFF';
      default:
        return '₹${discountValue.toStringAsFixed(0)} OFF';
    }
  }
}

class ApplyCouponResultModel {
  final String couponCode;
  final String title;
  final String description;
  final String discountType;
  final num discountValue;
  final num discountPercentage;
  final num originalPrice;
  final num discountAmount;
  final num finalPrice;
  final bool isFree;
  final num savings;
  final int durationInMonths;
  final int durationMonths;
  final int durationMonth;
  final String duration;
  final String durations;

  int get duration_months => durationMonths;
  int get duration_month => durationMonth;

  const ApplyCouponResultModel({
    this.couponCode = '',
    this.title = '',
    this.description = '',
    this.discountType = '',
    this.discountValue = 0,
    this.discountPercentage = 0,
    this.originalPrice = 0,
    this.discountAmount = 0,
    this.finalPrice = 0,
    this.isFree = false,
    this.savings = 0,
    this.durationInMonths = 1,
    this.durationMonths = 1,
    this.durationMonth = 1,
    this.duration = '',
    this.durations = '',
  });

  factory ApplyCouponResultModel.fromJson(Map<String, dynamic> json) {
    final finalPrice = num.tryParse(json['finalPrice']?.toString() ?? '');
    if (finalPrice == null || !finalPrice.isFinite || finalPrice < 0) {
      throw const FormatException(
        'Coupon response has no valid payable amount.',
      );
    }
    final discount = _number(json['discountAmount']);
    final int months =
        ((json['durationMonths'] ??
                    json['durationMonth'] ??
                    json['durationInMonths'] ??
                    json['duration_months'] ??
                    json['duration_month'] ??
                    1)
                as num)
            .toInt();
    final String durStr =
        json['duration']?.toString() ??
        json['durations']?.toString() ??
        '$months Month${months > 1 ? "s" : ""}';

    return ApplyCouponResultModel(
      couponCode: json['couponCode']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      discountType: json['discountType']?.toString() ?? '',
      discountValue: _number(json['discountValue']),
      discountPercentage: _number(json['discountPercentage']),
      originalPrice: _number(json['originalPrice']),
      discountAmount: discount,
      finalPrice: finalPrice,
      isFree: finalPrice == 0,
      savings: _number(json['savings'], fallback: discount),
      durationInMonths: months,
      durationMonths: months,
      durationMonth: months,
      duration: durStr,
      durations: durStr,
    );
  }
}

num _number(dynamic value, {num fallback = 0}) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '') ?? fallback;
}
