class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final int role;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.role,
    required this.metadata,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawMetadata = json['metadata'];
    final parsedDate = DateTime.tryParse(json['createdAt']?.toString() ?? '');

    return NotificationModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'GENERAL',
      isRead: json['isRead'] == true,
      role: json['role'] is num
          ? (json['role'] as num).toInt()
          : int.tryParse(json['role']?.toString() ?? '') ?? 2,
      metadata: rawMetadata is Map
          ? Map<String, dynamic>.from(rawMetadata)
          : const <String, dynamic>{},
      createdAt: parsedDate?.toLocal() ?? DateTime.now(),
    );
  }

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
    id: id,
    title: title,
    message: message,
    type: type,
    isRead: isRead ?? this.isRead,
    role: role,
    metadata: metadata,
    createdAt: createdAt,
  );
}

class NotificationPage {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final int currentPage;
  final int pageCount;
  final int perPage;

  const NotificationPage({
    required this.notifications,
    required this.unreadCount,
    required this.currentPage,
    required this.pageCount,
    required this.perPage,
  });

  factory NotificationPage.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? meta,
  }) {
    final rawItems = json['notifications'];
    final rawUnread = json['unreadCount'];
    final rawPage = meta?['currentPage'];
    final rawPageCount = meta?['pageCount'];
    final rawPerPage = meta?['perPage'];

    return NotificationPage(
      notifications: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map((item) => NotificationModel.fromJson(
                  Map<String, dynamic>.from(item),
                ))
                .toList()
          : const [],
      unreadCount: rawUnread is num
          ? rawUnread.toInt()
          : int.tryParse(rawUnread?.toString() ?? '') ?? 0,
      currentPage: rawPage is num
          ? rawPage.toInt()
          : int.tryParse(rawPage?.toString() ?? '') ?? 1,
      pageCount: rawPageCount is num
          ? rawPageCount.toInt()
          : int.tryParse(rawPageCount?.toString() ?? '') ?? 1,
      perPage: rawPerPage is num
          ? rawPerPage.toInt()
          : int.tryParse(rawPerPage?.toString() ?? '') ?? 20,
    );
  }
}
