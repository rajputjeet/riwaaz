class SubscriptionModel {
  String? id;
  String? name;
  String? type;
  num? price;
  String? description;

  SubscriptionModel({
    this.id,
    this.name,
    this.type,
    this.price,
    this.description,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      name: json['name']?.toString(),
      type: json['type']?.toString(),
      price: json['price'] is num
          ? json['price']
          : num.tryParse(json['price']?.toString() ?? ''),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (price != null) 'price': price,
      if (description != null) 'description': description,
    };
  }
}
