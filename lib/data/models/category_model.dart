import '../api_provider/api_constant.dart';

/// Category model mapping the server API `/api/category/list`
/// Supports both object icon `{"url": "...", "public_id": "..."}` and string icon,
/// resolving relative `/uploads/...` paths to full URLs via [ApiConstants.baseUrl].
class CategoryModel {
  String? id;
  String? name;
  String? icon;
  String? iconUrl;
  String? desc;
  int? stateId;
  String? status;
  String? createdAt;
  String? updatedAt;

  CategoryModel({
    this.id,
    this.name,
    this.icon,
    this.iconUrl,
    this.desc,
    this.stateId,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  /// Resolves server-returned relative icon paths to absolute URLs according to docs
  static String resolveImageUrl(dynamic icon, [String? baseUrl]) {
    if (icon == null) return '';
    String? rawUrl;
    if (icon is Map) {
      rawUrl = icon['url']?.toString();
    } else if (icon is String) {
      rawUrl = icon;
    }
    if (rawUrl == null || rawUrl.trim().isEmpty) return '';
    rawUrl = rawUrl.trim();
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      final base = (baseUrl ?? ApiConstants.baseUrl).replaceAll(RegExp(r'/+$'), '');
      if (rawUrl.contains('localhost:5174') || rawUrl.contains('127.0.0.1:5174')) {
        return rawUrl.replaceAll(RegExp(r'https?://(localhost|127\.0\.0\.1):5174'), base);
      }
      return rawUrl;
    }
    if (rawUrl.startsWith('assets/')) {
      return rawUrl;
    }
    final base = (baseUrl ?? ApiConstants.baseUrl).replaceAll(RegExp(r'/+$'), '');
    final path = rawUrl.startsWith('/') ? rawUrl : '/$rawUrl';
    return '$base$path';
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json, [String? baseUrl]) {
    final rawIcon = json['icon'];
    String? iconStr;
    if (rawIcon is String) {
      iconStr = rawIcon;
    } else if (rawIcon is Map) {
      iconStr = rawIcon['url']?.toString();
    }

    final fullUrl = resolveImageUrl(rawIcon ?? json['iconUrl'], baseUrl);

    return CategoryModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      name: (json['name'] ?? json['title'])?.toString(),
      icon: iconStr,
      iconUrl: fullUrl.isNotEmpty ? fullUrl : null,
      desc: (json['description'] ?? json['desc'])?.toString(),
      stateId: json['stateId'] is int
          ? json['stateId'] as int
          : int.tryParse(json['stateId']?.toString() ?? ''),
      status: json['status']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (iconUrl != null) 'iconUrl': iconUrl,
      if (desc != null) 'description': desc,
      if (stateId != null) 'stateId': stateId,
      if (status != null) 'status': status,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}
