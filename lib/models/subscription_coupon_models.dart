// ignore_for_file: non_constant_identifier_names

class SubscriptionPlanModel {
  final String id;
  final String title;
  final String type; // e.g. "1 Month", "6 Months", "1 Year"
  final int durationInMonths;
  final int durationMonth; // Alias for durationInMonths
  final int durationMonths; // Alias for durationInMonths
  final String duration; // e.g. "1 Month", "6 Months", "12 Months"
  final String durations; // Alias for duration
  final num price;
  final String description;

  int get duration_months => durationMonths;
  int get duration_month => durationMonth;

  SubscriptionPlanModel({
    required this.id,
    required this.title,
    required this.type,
    required this.durationInMonths,
    this.durationMonth = 1,
    this.durationMonths = 1,
    this.duration = '',
    this.durations = '',
    required this.price,
    required this.description,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    final int months = ((json['durationInMonths'] ??
            json['durationMonths'] ??
            json['durationMonth'] ??
            json['duration_months'] ??
            json['duration_month'] ??
            (json['type'] == '1 Year' ? 12 : json['type'] == '6 Months' ? 6 : json['type'] == '3 Months' ? 3 : 1)) as num)
        .toInt();
    final String durStr = json['duration']?.toString() ??
        json['durations']?.toString() ??
        '$months Month${months > 1 ? "s" : ""}';
    return SubscriptionPlanModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      durationInMonths: months,
      durationMonth: months,
      durationMonths: months,
      duration: durStr,
      durations: durStr,
      price: json['price'] ?? 0,
      description: json['description']?.toString() ?? '',
    );
  }
}

class CouponModel {
  final String id;
  final String title;
  final String description;
  final String couponCode;
  final String discountType; // "percentage", "flat", "fixed", "free"
  final num discountValue;
  final num discountPercentage;
  final num minAmount;
  final int usageLimit; // 0 = Unlimited
  final int usageLimitPerUser; // 0 = Unlimited
  final int usedCount;
  final DateTime? validUntil;

  CouponModel({
    required this.id,
    required this.title,
    required this.description,
    required this.couponCode,
    required this.discountType,
    required this.discountValue,
    required this.discountPercentage,
    required this.minAmount,
    this.usageLimit = 0,
    this.usageLimitPerUser = 0,
    this.usedCount = 0,
    this.validUntil,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      couponCode: json['couponCode'] ?? '',
      discountType: json['discountType'] ?? 'percentage',
      discountValue: json['discountValue'] ?? 0,
      discountPercentage: json['discountPercentage'] ?? 0,
      minAmount: json['minAmount'] ?? 0,
      usageLimit: json['usageLimit'] ?? 0,
      usageLimitPerUser: json['usageLimitPerUser'] ?? 0,
      usedCount: json['usedCount'] ?? 0,
      validUntil: json['validUntil'] != null ? DateTime.tryParse(json['validUntil'].toString()) : null,
    );
  }
}

class CouponValidationResult {
  final String couponCode;
  final String discountType;
  final num originalPrice;
  final num discountAmount;
  final num finalPrice;
  final bool isFree;
  final int durationInMonths;
  final int durationMonths;
  final int durationMonth;
  final String duration;
  final String durations;
  final SubscriptionPlanModel? subscriptionPlan;

  int get duration_months => durationMonths;
  int get duration_month => durationMonth;

  CouponValidationResult({
    required this.couponCode,
    required this.discountType,
    required this.originalPrice,
    required this.discountAmount,
    required this.finalPrice,
    required this.isFree,
    this.durationInMonths = 1,
    this.durationMonths = 1,
    this.durationMonth = 1,
    this.duration = '',
    this.durations = '',
    this.subscriptionPlan,
  });

  factory CouponValidationResult.fromJson(Map<String, dynamic> json) {
    final subPlan = json['subscriptionPlan'] != null
        ? SubscriptionPlanModel.fromJson(json['subscriptionPlan'])
        : null;
    final int months = ((json['durationMonths'] ??
            json['durationMonth'] ??
            json['durationInMonths'] ??
            json['duration_months'] ??
            json['duration_month'] ??
            subPlan?.durationInMonths ??
            1) as num)
        .toInt();
    final String durStr = json['duration']?.toString() ??
        json['durations']?.toString() ??
        subPlan?.duration ??
        '$months Month${months > 1 ? "s" : ""}';

    return CouponValidationResult(
      couponCode: json['couponCode']?.toString() ?? '',
      discountType: json['discountType']?.toString() ?? 'percentage',
      originalPrice: json['originalPrice'] ?? 0,
      discountAmount: json['discountAmount'] ?? 0,
      finalPrice: json['finalPrice'] ?? 0,
      isFree: json['isFree'] ?? false,
      durationInMonths: months,
      durationMonths: months,
      durationMonth: months,
      duration: durStr,
      durations: durStr,
      subscriptionPlan: subPlan,
    );
  }
}

class VendorActivePlanModel {
  final bool isSubscriptionActive;
  final bool isExpired;
  final int daysRemaining;
  final int durationInMonths;
  final int durationMonths;
  final int durationMonth;
  final String duration;
  final String durations;
  final SubscriptionPlanModel? subscriptionPlan;
  final DateTime? startDate;
  final DateTime? endDate;
  final num originalPrice;
  final num discountAmount;
  final num finalAmount;
  final bool couponApplied;
  final String? couponCode;
  final String paymentMethod;
  final String transactionId;
  final List<SubscriptionHistoryItem> history;
  final String message;

  int get duration_months => durationMonths;
  int get duration_month => durationMonth;

  VendorActivePlanModel({
    required this.isSubscriptionActive,
    required this.isExpired,
    required this.daysRemaining,
    this.durationInMonths = 1,
    this.durationMonths = 1,
    this.durationMonth = 1,
    this.duration = '',
    this.durations = '',
    this.subscriptionPlan,
    this.startDate,
    this.endDate,
    required this.originalPrice,
    required this.discountAmount,
    required this.finalAmount,
    required this.couponApplied,
    this.couponCode,
    required this.paymentMethod,
    required this.transactionId,
    required this.history,
    required this.message,
  });

  factory VendorActivePlanModel.fromJson(Map<String, dynamic> json) {
    final subPlan = json['subscriptionPlan'] != null
        ? SubscriptionPlanModel.fromJson(json['subscriptionPlan'])
        : null;
    final int months = ((json['durationMonths'] ??
            json['durationMonth'] ??
            json['durationInMonths'] ??
            json['duration_months'] ??
            json['duration_month'] ??
            subPlan?.durationInMonths ??
            1) as num)
        .toInt();
    final String durStr = json['duration']?.toString() ??
        json['durations']?.toString() ??
        subPlan?.duration ??
        '$months Month${months > 1 ? "s" : ""}';

    return VendorActivePlanModel(
      isSubscriptionActive: json['isSubscriptionActive'] ?? false,
      isExpired: json['isExpired'] ?? false,
      daysRemaining: json['daysRemaining'] ?? 0,
      durationInMonths: months,
      durationMonths: months,
      durationMonth: months,
      duration: durStr,
      durations: durStr,
      subscriptionPlan: subPlan,
      startDate: json['subscriptionStartDate'] != null
          ? DateTime.tryParse(json['subscriptionStartDate'])
          : null,
      endDate: json['subscriptionEndDate'] != null
          ? DateTime.tryParse(json['subscriptionEndDate'])
          : null,
      originalPrice: json['subscriptionOriginalPrice'] ?? 0,
      discountAmount: json['subscriptionDiscountAmount'] ?? 0,
      finalAmount: json['subscriptionFinalAmount'] ?? 0,
      couponApplied: json['subscriptionCouponApplied'] ?? false,
      couponCode: json['subscriptionCouponCode'],
      paymentMethod: json['subscriptionPaymentMethod'] ?? 'In-App',
      transactionId: json['subscriptionTransactionId'] ?? '',
      history: (json['subscriptionHistory'] as List<dynamic>? ?? [])
          .map((item) => SubscriptionHistoryItem.fromJson(item))
          .toList(),
      message: json['message'] ?? '',
    );
  }
}

class SubscriptionHistoryItem {
  final String planTitle;
  final String planType;
  final int durationInMonths;
  final int durationMonths;
  final int durationMonth;
  final String duration;
  final String durations;
  final num originalPrice;
  final num discountAmount;
  final num finalAmount;
  final bool couponApplied;
  final String? couponCode;
  final String paymentMethod;
  final String transactionId;
  final DateTime? purchasedAt;
  final DateTime? endDate;

  int get duration_months => durationMonths;
  int get duration_month => durationMonth;

  SubscriptionHistoryItem({
    required this.planTitle,
    required this.planType,
    this.durationInMonths = 1,
    this.durationMonths = 1,
    this.durationMonth = 1,
    this.duration = '',
    this.durations = '',
    required this.originalPrice,
    required this.discountAmount,
    required this.finalAmount,
    required this.couponApplied,
    this.couponCode,
    required this.paymentMethod,
    required this.transactionId,
    this.purchasedAt,
    this.endDate,
  });

  factory SubscriptionHistoryItem.fromJson(Map<String, dynamic> json) {
    final int months = ((json['durationMonths'] ??
            json['durationMonth'] ??
            json['durationInMonths'] ??
            json['duration_months'] ??
            json['duration_month'] ??
            (json['planType'] == '1 Year'
                ? 12
                : json['planType'] == '6 Months'
                    ? 6
                    : json['planType'] == '3 Months'
                        ? 3
                        : 1)) as num)
        .toInt();
    final String durStr = json['duration']?.toString() ??
        json['durations']?.toString() ??
        '$months Month${months > 1 ? "s" : ""}';

    return SubscriptionHistoryItem(
      planTitle: json['planTitle'] ?? '',
      planType: json['planType'] ?? '',
      durationInMonths: months,
      durationMonths: months,
      durationMonth: months,
      duration: durStr,
      durations: durStr,
      originalPrice: json['originalPrice'] ?? 0,
      discountAmount: json['discountAmount'] ?? 0,
      finalAmount: json['finalAmount'] ?? 0,
      couponApplied: json['couponApplied'] ?? false,
      couponCode: json['couponCode'],
      paymentMethod: json['paymentMethod'] ?? 'In-App',
      transactionId: json['transactionId'] ?? '',
      purchasedAt: json['purchasedAt'] != null ? DateTime.tryParse(json['purchasedAt']) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
    );
  }
}
