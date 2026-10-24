import 'package:flutter/foundation.dart';

import '../../data/api_provider/notification_api_provider.dart';
import '../../data/models/notification_model.dart';

class NotificationService extends ChangeNotifier {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final NotificationApiProvider _api = NotificationApiProvider();
  final List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  int _currentPage = 0;
  int _pageCount = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMore => _currentPage < _pageCount;

  Future<bool> refresh() async {
    if (_isLoading) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _api.getNotifications(page: 1, limit: 20);
    _isLoading = false;
    if (response.isSuccess == true && response.data != null) {
      final page = response.data!;
      _notifications
        ..clear()
        ..addAll(page.notifications);
      _unreadCount = page.unreadCount;
      _currentPage = page.currentPage;
      _pageCount = page.pageCount;
      notifyListeners();
      return true;
    }

    _error = response.message ?? 'Unable to load notifications.';
    notifyListeners();
    return false;
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    final response = await _api.getNotifications(
      page: _currentPage + 1,
      limit: 20,
    );
    _isLoadingMore = false;
    if (response.isSuccess == true && response.data != null) {
      final page = response.data!;
      final existingIds = _notifications.map((item) => item.id).toSet();
      _notifications.addAll(
        page.notifications.where((item) => !existingIds.contains(item.id)),
      );
      _unreadCount = page.unreadCount;
      _currentPage = page.currentPage;
      _pageCount = page.pageCount;
    } else {
      _error = response.message ?? 'Unable to load more notifications.';
    }
    notifyListeners();
  }

  Future<NotificationModel?> view(String id) async {
    final response = await _api.viewNotification(id);
    final viewed = response.data;
    if (response.isSuccess != true || viewed == null) {
      _error = response.message ?? 'Unable to open this notification.';
      notifyListeners();
      return null;
    }

    final index = _notifications.indexWhere((item) => item.id == id);
    if (index >= 0) {
      final wasUnread = !_notifications[index].isRead;
      _notifications[index] = viewed;
      if (wasUnread && viewed.isRead) {
        _unreadCount = (_unreadCount - 1).clamp(0, 1 << 30).toInt();
      }
    }
    _error = null;
    notifyListeners();
    return viewed;
  }

  Future<bool> markAsRead(String id) async {
    final response = await _api.markAsRead(id);
    if (response.isSuccess != true) {
      _error = response.message ?? 'Unable to mark notification as read.';
      notifyListeners();
      return false;
    }
    final index = _notifications.indexWhere((item) => item.id == id);
    if (index >= 0 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _unreadCount = (_unreadCount - 1).clamp(0, 1 << 30).toInt();
    }
    _error = null;
    notifyListeners();
    return true;
  }

  Future<bool> markAllAsRead() async {
    final response = await _api.markAllAsRead();
    if (response.isSuccess != true) {
      _error = response.message ?? 'Unable to mark notifications as read.';
      notifyListeners();
      return false;
    }
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _unreadCount = 0;
    _error = null;
    notifyListeners();
    return true;
  }

  Future<bool> delete(String id) async {
    final response = await _api.deleteNotification(id);
    if (response.isSuccess != true) {
      _error = response.message ?? 'Unable to delete notification.';
      notifyListeners();
      return false;
    }
    final index = _notifications.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (!_notifications[index].isRead) {
        _unreadCount = (_unreadCount - 1).clamp(0, 1 << 30).toInt();
      }
      _notifications.removeAt(index);
    }
    _error = null;
    notifyListeners();
    return true;
  }

  Future<bool> deleteMultiple(List<String> ids) async {
    if (ids.isEmpty) return false;
    final response = await _api.deleteMultipleNotifications(ids);
    if (response.isSuccess != true) {
      _error = response.message ?? 'Unable to delete selected notifications.';
      notifyListeners();
      return false;
    }

    final idsToDelete = ids.toSet();
    final removedItems = _notifications
        .where((item) => idsToDelete.contains(item.id))
        .toList();
    _unreadCount =
        (_unreadCount - removedItems.where((item) => !item.isRead).length)
        .clamp(0, 1 << 30)
        .toInt();
    _notifications.removeWhere((item) => idsToDelete.contains(item.id));
    _error = null;
    notifyListeners();
    return true;
  }

  Future<bool> deleteAll() async {
    final response = await _api.deleteAllNotifications();
    if (response.isSuccess != true) {
      _error = response.message ?? 'Unable to clear notifications.';
      notifyListeners();
      return false;
    }
    _notifications.clear();
    _unreadCount = 0;
    _currentPage = 1;
    _pageCount = 1;
    _error = null;
    notifyListeners();
    return true;
  }
}
