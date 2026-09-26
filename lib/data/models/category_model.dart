class CategoryModel {
  String? id;
  String? name;
  String? icon;
  String? status;

  CategoryModel({
    this.id,
    this.name,
    this.icon,
    this.status,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      name: json['name']?.toString(),
      icon: json['icon']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (status != null) 'status': status,
    };
  }
}
