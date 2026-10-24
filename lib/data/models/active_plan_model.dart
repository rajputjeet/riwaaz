import 'subscription_model.dart';

/// Model for active-plan and buy/renew responses.
class ActivePlanModel {
  final bool isSubscriptionActive;
  final bool isExpired;
  final int daysRemaining;
  final String? message;
  final String? subscriptionStartDate;
  final String? subscriptionEndDate;
  final ActivePlanDetail? subscriptionPlan;
  final num? originalPrice;
  final num? discountAmount;
  final num? finalAmount;
  final bool couponApplied;
  final String? couponCode;
  final String? paymentMethod;
  final String? transactionId;
  final List<SubscriptionHistoryItem> history;

  ActivePlanModel({
    this.isSubscriptionActive = false,
    this.isExpired = true,
    this.daysRemaining = 0,
    this.message,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.subscriptionPlan,
    this.originalPrice,
    this.discountAmount,
    this.finalAmount,
    this.couponApplied = false,
    this.couponCode,
    this.paymentMethod,
    this.transactionId,
    this.history = const [],
  });

  String? get planTitle => subscriptionPlan?.title;
  DateTime? get startDate => DateTime.tryParse(subscriptionStartDate ?? '');
  DateTime? get endDate => DateTime.tryParse(subscriptionEndDate ?? '');

  factory ActivePlanModel.fromJson(Map<String, dynamic> json) {
    return ActivePlanModel(
      isSubscriptionActive: json['isSubscriptionActive'] ?? false,
      isExpired: json['isExpired'] ?? false,
      daysRemaining: (json['daysRemaining'] is num)
          ? (json['daysRemaining'] as num).toInt()
          : int.tryParse(json['daysRemaining']?.toString() ?? '') ?? 0,
      message: json['message']?.toString(),
      subscriptionStartDate: json['subscriptionStartDate']?.toString(),
      subscriptionEndDate: json['subscriptionEndDate']?.toString(),
      subscriptionPlan: json['subscriptionPlan'] is Map
          ? ActivePlanDetail.fromJson(
              Map<String, dynamic>.from(json['subscriptionPlan'] as Map),
            )
          : null,
      originalPrice: _amount(
        json['subscriptionOriginalPrice'] ?? json['originalPrice'],
      ),
      discountAmount: _amount(
        json['subscriptionDiscountAmount'] ?? json['discountAmount'],
      ),
      finalAmount: _amount(
        json['subscriptionFinalAmount'] ??
            json['finalAmountPaid'] ??
            json['finalAmount'],
      ),
      couponApplied:
          (json['subscriptionCouponApplied'] ?? json['couponApplied']) == true,
      couponCode: (json['subscriptionCouponCode'] ?? json['couponCode'])
          ?.toString(),
      paymentMethod:
          (json['subscriptionPaymentMethod'] ?? json['paymentMethod'])
              ?.toString(),
      transactionId:
          (json['subscriptionTransactionId'] ?? json['transactionId'])
              ?.toString(),
      history: json['subscriptionHistory'] is List
          ? (json['subscriptionHistory'] as List)
                .whereType<Map>()
                .map(
                  (item) => SubscriptionHistoryItem.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'isSubscriptionActive': isSubscriptionActive,
    'isExpired': isExpired,
    'daysRemaining': daysRemaining,
    if (message != null) 'message': message,
    if (subscriptionStartDate != null)
      'subscriptionStartDate': subscriptionStartDate,
    if (subscriptionEndDate != null) 'subscriptionEndDate': subscriptionEndDate,
    if (subscriptionPlan != null)
      'subscriptionPlan': subscriptionPlan!.toJson(),
    if (originalPrice != null) 'subscriptionOriginalPrice': originalPrice,
    if (discountAmount != null) 'subscriptionDiscountAmount': discountAmount,
    if (finalAmount != null) 'subscriptionFinalAmount': finalAmount,
    'subscriptionCouponApplied': couponApplied,
    if (couponCode != null) 'subscriptionCouponCode': couponCode,
    if (paymentMethod != null) 'subscriptionPaymentMethod': paymentMethod,
    if (transactionId != null) 'subscriptionTransactionId': transactionId,
    'subscriptionHistory': history.map((item) => item.toJson()).toList(),
  };
}

class ActivePlanDetail {
  final String? id;
  final String? title;
  final String? type;
  final num? price;
  final int? durationInMonths;
  final String? duration;
  final String? description;
  int? get durationMonth => durationInMonths;
  int? get durationMonths => durationInMonths;
  String? get durations => duration;

  ActivePlanDetail({
    this.id,
    this.title,
    this.type,
    this.price,
    this.durationInMonths,
    this.duration,
    this.description,
  });

  factory ActivePlanDetail.fromJson(Map<String, dynamic> json) {
    final plan = SubscriptionModel.fromJson(json);
    return ActivePlanDetail(
      id: (json['_id'] ?? json['id'])?.toString(),
      title: json['title']?.toString(),
      type: json['type']?.toString(),
      price: plan.price,
      durationInMonths: plan.durationInMonths,
      duration: plan.durationLabel,
      description: plan.description,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) '_id': id,
    if (title != null) 'title': title,
    if (type != null) 'type': type,
    if (price != null) 'price': price,
    if (durationInMonths != null) 'durationInMonths': durationInMonths,
    if (duration != null) 'duration': duration,
    if (description != null) 'description': description,
  };
}

class SubscriptionHistoryItem {
  final String planTitle;
  final String planType;
  final num? originalPrice;
  final num? discountAmount;
  final num? finalAmount;
  final bool couponApplied;
  final String? couponCode;
  final String? paymentMethod;
  final String? transactionId;
  final DateTime? purchasedAt;
  final DateTime? endDate;

  const SubscriptionHistoryItem({
    this.planTitle = '',
    this.planType = '',
    this.originalPrice,
    this.discountAmount,
    this.finalAmount,
    this.couponApplied = false,
    this.couponCode,
    this.paymentMethod,
    this.transactionId,
    this.purchasedAt,
    this.endDate,
  });

  factory SubscriptionHistoryItem.fromJson(Map<String, dynamic> json) =>
      SubscriptionHistoryItem(
        planTitle: json['planTitle']?.toString() ?? '',
        planType: json['planType']?.toString() ?? '',
        originalPrice: _amount(json['originalPrice']),
        discountAmount: _amount(json['discountAmount']),
        finalAmount: _amount(json['finalAmount'] ?? json['finalAmountPaid']),
        couponApplied: json['couponApplied'] == true,
        couponCode: json['couponCode']?.toString(),
        paymentMethod: json['paymentMethod']?.toString(),
        transactionId: json['transactionId']?.toString(),
        purchasedAt: DateTime.tryParse(json['purchasedAt']?.toString() ?? ''),
        endDate: DateTime.tryParse(json['endDate']?.toString() ?? ''),
      );

  Map<String, dynamic> toJson() => {
    'planTitle': planTitle,
    'planType': planType,
    if (originalPrice != null) 'originalPrice': originalPrice,
    if (discountAmount != null) 'discountAmount': discountAmount,
    if (finalAmount != null) 'finalAmount': finalAmount,
    'couponApplied': couponApplied,
    if (couponCode != null) 'couponCode': couponCode,
    if (paymentMethod != null) 'paymentMethod': paymentMethod,
    if (transactionId != null) 'transactionId': transactionId,
    if (purchasedAt != null) 'purchasedAt': purchasedAt!.toIso8601String(),
    if (endDate != null) 'endDate': endDate!.toIso8601String(),
  };
}

num? _amount(dynamic value) {
  final result = value is num ? value : num.tryParse(value?.toString() ?? '');
  return result != null && result.isFinite ? result : null;
}
