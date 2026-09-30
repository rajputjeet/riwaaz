/// Model for GET /api/users/vendor/plan/active response
class ActivePlanModel {
  final bool isSubscriptionActive;
  final bool isExpired;
  final int daysRemaining;
  final String? message;
  final String? subscriptionStartDate;
  final String? subscriptionEndDate;
  final ActivePlanDetail? subscriptionPlan;

  ActivePlanModel({
    this.isSubscriptionActive = false,
    this.isExpired = true,
    this.daysRemaining = 0,
    this.message,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.subscriptionPlan,
  });

  factory ActivePlanModel.fromJson(Map<String, dynamic> json) {
    return ActivePlanModel(
      isSubscriptionActive: json['isSubscriptionActive'] ?? false,
      isExpired: json['isExpired'] ?? true,
      daysRemaining: (json['daysRemaining'] is num)
          ? (json['daysRemaining'] as num).toInt()
          : int.tryParse(json['daysRemaining']?.toString() ?? '') ?? 0,
      message: json['message']?.toString(),
      subscriptionStartDate: json['subscriptionStartDate']?.toString(),
      subscriptionEndDate: json['subscriptionEndDate']?.toString(),
      subscriptionPlan: json['subscriptionPlan'] != null &&
              json['subscriptionPlan'] is Map<String, dynamic>
          ? ActivePlanDetail.fromJson(
              json['subscriptionPlan'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'isSubscriptionActive': isSubscriptionActive,
        'isExpired': isExpired,
        'daysRemaining': daysRemaining,
        if (message != null) 'message': message,
        if (subscriptionStartDate != null)
          'subscriptionStartDate': subscriptionStartDate,
        if (subscriptionEndDate != null)
          'subscriptionEndDate': subscriptionEndDate,
        if (subscriptionPlan != null)
          'subscriptionPlan': subscriptionPlan!.toJson(),
      };
}

class ActivePlanDetail {
  final String? id;
  final String? title;
  final String? type;
  final num? price;
  final int? durationInMonths;

  ActivePlanDetail({
    this.id,
    this.title,
    this.type,
    this.price,
    this.durationInMonths,
  });

  factory ActivePlanDetail.fromJson(Map<String, dynamic> json) {
    return ActivePlanDetail(
      id: (json['_id'] ?? json['id'])?.toString(),
      title: json['title']?.toString(),
      type: json['type']?.toString(),
      price: json['price'] is num ? json['price'] : null,
      durationInMonths: json['durationInMonths'] is num
          ? (json['durationInMonths'] as num).toInt()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) '_id': id,
        if (title != null) 'title': title,
        if (type != null) 'type': type,
        if (price != null) 'price': price,
        if (durationInMonths != null) 'durationInMonths': durationInMonths,
      };
}
