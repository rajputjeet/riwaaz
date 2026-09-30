class SubscriptionModel {
  String? id;
  String? title;
  String? name;
  String? type;
  int? durationInMonths;
  num? price;
  String? description;
  int? stateId;
  String? createdAt;

  SubscriptionModel({
    this.id,
    this.title,
    this.name,
    this.type,
    this.durationInMonths,
    this.price,
    this.description,
    this.stateId,
    this.createdAt,
  });

  String get displayName => (title?.trim().isNotEmpty == true)
      ? title!.trim()
      : ((name?.trim().isNotEmpty == true)
          ? name!.trim()
          : (type?.trim().isNotEmpty == true ? type!.trim() : 'Subscription Plan'));

  int get planPrice => price?.toInt() ?? 0;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      title: json['title']?.toString(),
      name: (json['title'] ?? json['name'])?.toString(),
      type: json['type']?.toString(),
      durationInMonths: json['durationInMonths'] is num
          ? (json['durationInMonths'] as num).toInt()
          : int.tryParse(json['durationInMonths']?.toString() ?? ''),
      price: json['price'] is num
          ? json['price']
          : num.tryParse(json['price']?.toString() ?? ''),
      description: json['description']?.toString(),
      stateId: json['stateId'] is num
          ? (json['stateId'] as num).toInt()
          : int.tryParse(json['stateId']?.toString() ?? ''),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (title != null) 'title': title,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (durationInMonths != null) 'durationInMonths': durationInMonths,
      if (price != null) 'price': price,
      if (description != null) 'description': description,
      if (stateId != null) 'stateId': stateId,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
