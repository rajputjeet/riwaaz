class CmsModel {
  final String? id;
  final String? title;
  final String? type;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  CmsModel({
    this.id,
    this.title,
    this.type,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory CmsModel.fromJson(Map<String, dynamic> json) {
    final rawDesc = json['description'] ??
        json['content'] ??
        json['html'] ??
        json['body'] ??
        json['details'] ??
        (json['data'] is Map ? (json['data']['description'] ?? json['data']['content'] ?? json['data']['html']) : null);

    return CmsModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      title: json['title']?.toString() ?? json['name']?.toString(),
      type: json['type']?.toString(),
      description: rawDesc?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
    };
  }
}
