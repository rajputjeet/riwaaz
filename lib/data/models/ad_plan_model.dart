/// Models for Ads Pricing, Purchase, and Active Campaign APIs
class AdPlanModel {
  final String? id;
  final String? title;
  final String? duration;
  final int? durationInDays;
  final num? price;
  final String? description;
  final int? stateId;

  AdPlanModel({
    this.id,
    this.title,
    this.duration,
    this.durationInDays,
    this.price,
    this.description,
    this.stateId,
  });

  int get planPrice => price?.toInt() ?? 0;

  factory AdPlanModel.fromJson(Map<String, dynamic> json) {
    return AdPlanModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      title: json['title']?.toString(),
      duration: json['duration']?.toString(),
      durationInDays: json['durationInDays'] is num
          ? (json['durationInDays'] as num).toInt()
          : int.tryParse(json['durationInDays']?.toString() ?? ''),
      price: json['price'] is num
          ? json['price']
          : num.tryParse(json['price']?.toString() ?? ''),
      description: json['description']?.toString(),
      stateId: json['stateId'] is num
          ? (json['stateId'] as num).toInt()
          : int.tryParse(json['stateId']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (title != null) 'title': title,
      if (duration != null) 'duration': duration,
      if (durationInDays != null) 'durationInDays': durationInDays,
      if (price != null) 'price': price,
      if (description != null) 'description': description,
      if (stateId != null) 'stateId': stateId,
    };
  }
}

/// Model for Active Ad detail and purchase response
class ActiveAdDetailModel {
  final String? id;
  final String? vendorId;
  final String? adPlanId;
  final String? title;
  final String? duration;
  final int? durationInDays;
  final num? price;
  final String? startDate;
  final String? endDate;
  final String? status;

  ActiveAdDetailModel({
    this.id,
    this.vendorId,
    this.adPlanId,
    this.title,
    this.duration,
    this.durationInDays,
    this.price,
    this.startDate,
    this.endDate,
    this.status,
  });

  bool get isActive => status?.toLowerCase() == 'active';

  int get daysLeft {
    if (endDate == null) return durationInDays ?? 0;
    try {
      final end = DateTime.parse(endDate!);
      final now = DateTime.now();
      final diff = end.difference(now).inDays;
      return diff > 0 ? diff : (end.isAfter(now) ? 1 : 0);
    } catch (_) {
      return durationInDays ?? 0;
    }
  }

  factory ActiveAdDetailModel.fromJson(Map<String, dynamic> json) {
    return ActiveAdDetailModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      vendorId: json['vendorId']?.toString(),
      adPlanId: json['adPlanId']?.toString(),
      title: json['title']?.toString(),
      duration: json['duration']?.toString(),
      durationInDays: json['durationInDays'] is num
          ? (json['durationInDays'] as num).toInt()
          : int.tryParse(json['durationInDays']?.toString() ?? ''),
      price: json['price'] is num
          ? json['price']
          : num.tryParse(json['price']?.toString() ?? ''),
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
      status: json['status']?.toString() ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (vendorId != null) 'vendorId': vendorId,
      if (adPlanId != null) 'adPlanId': adPlanId,
      if (title != null) 'title': title,
      if (duration != null) 'duration': duration,
      if (durationInDays != null) 'durationInDays': durationInDays,
      if (price != null) 'price': price,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      if (status != null) 'status': status,
    };
  }
}

/// Response model for GET /api/ad/my-ad
class VendorMyAdModel {
  final bool isAdActive;
  final ActiveAdDetailModel? activeAd;
  final List<ActiveAdDetailModel> history;

  VendorMyAdModel({
    this.isAdActive = false,
    this.activeAd,
    this.history = const [],
  });

  factory VendorMyAdModel.fromJson(Map<String, dynamic> json) {
    final activeMap = json['activeAd'];
    final historyRaw = json['history'];

    final List<ActiveAdDetailModel> historyList = [];
    if (historyRaw is List) {
      for (final item in historyRaw) {
        if (item is Map<String, dynamic>) {
          historyList.add(ActiveAdDetailModel.fromJson(item));
        }
      }
    }

    return VendorMyAdModel(
      isAdActive: json['isAdActive'] is bool ? json['isAdActive'] as bool : false,
      activeAd: (activeMap != null && activeMap is Map<String, dynamic>)
          ? ActiveAdDetailModel.fromJson(activeMap)
          : null,
      history: historyList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isAdActive': isAdActive,
      if (activeAd != null) 'activeAd': activeAd!.toJson(),
      'history': history.map((e) => e.toJson()).toList(),
    };
  }
}
