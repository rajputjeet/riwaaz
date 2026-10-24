import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/notification_service.dart';
import '../../data/models/notification_model.dart';
import '../../shared/widgets/app_states.dart';

class NotificationInbox extends StatefulWidget {
  final bool isVendor;

  const NotificationInbox({super.key, required this.isVendor});

  @override
  State<NotificationInbox> createState() => _NotificationInboxState();
}

class _NotificationInboxState extends State<NotificationInbox> {
  final NotificationService _service = NotificationService.instance;
  final ScrollController _scrollController = ScrollController();
  final Set<String> _selectedIds = <String>{};
  int _selectedFilter = 0;
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _service.refresh();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 240) _service.loadMore();
  }

  bool _isBooking(NotificationModel item) {
    return const {'BOOKING', 'BOOKING_UPDATE', 'ORDER'}.contains(
      item.type.toUpperCase(),
    );
  }

  List<NotificationModel> _filtered(List<NotificationModel> items) {
    if (_selectedFilter == 1) {
      return items.where(_isBooking).toList();
    }
    if (_selectedFilter == 2) {
      return items.where((item) => !_isBooking(item)).toList();
    }
    return items;
  }

  Future<void> _openNotification(NotificationModel item) async {
    final notification = await _service.view(item.id);
    if (!mounted) return;
    if (notification == null) {
      _showMessage(_service.error ?? 'Unable to open notification.');
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NotificationDetailSheet(item: notification),
    );
  }

  Future<void> _deleteNotification(NotificationModel item) async {
    final deleted = await _service.delete(item.id);
    if (!mounted) return;
    _showMessage(
      deleted ? 'Notification deleted.' : _service.error ?? 'Delete failed.',
    );
  }

  void _toggleSelection(NotificationModel item) {
    setState(() {
      _isSelectionMode = true;
      if (!_selectedIds.add(item.id)) _selectedIds.remove(item.id);
      if (_selectedIds.isEmpty) _isSelectionMode = false;
    });
  }

  void _selectAll(List<NotificationModel> items) {
    setState(() {
      _isSelectionMode = true;
      _selectedIds
        ..clear()
        ..addAll(items.map((item) => item.id));
    });
  }

  void _clearSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
  }

  Future<void> _deleteSelected() async {
    final ids = _selectedIds.toList();
    final deleted = await _service.deleteMultiple(ids);
    if (!mounted) return;
    if (deleted) {
      _clearSelection();
      _showMessage('${ids.length} notification(s) deleted.');
    } else {
      _showMessage(_service.error ?? 'Unable to delete selected notifications.');
    }
  }

  Future<void> _markNotificationRead(NotificationModel item) async {
    final marked = await _service.markAsRead(item.id);
    if (mounted && !marked) {
      _showMessage(_service.error ?? 'Unable to mark notification as read.');
    }
  }

  Future<void> _deleteAll() async {
    if (_service.notifications.isEmpty) return;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all notifications?'),
        content: const Text('This will permanently remove all notifications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;
    final deleted = await _service.deleteAll();
    if (mounted) {
      _showMessage(
        deleted ? 'All notifications cleared.' : _service.error ?? 'Clear failed.',
      );
    }
  }

  Future<void> _markAllRead() async {
    final marked = await _service.markAllAsRead();
    if (mounted && !marked) {
      _showMessage(_service.error ?? 'Unable to mark notifications as read.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _service,
      builder: (context, _) {
        final allItems = _service.notifications;
        final visibleItems = _filtered(allItems);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              _isSelectionMode
                  ? '${_selectedIds.length} selected'
                  : 'Notifications',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            centerTitle: true,
            actions: [
              if (_isSelectionMode) ...[
                TextButton(
                  onPressed: () => _selectAll(visibleItems),
                  child: const Text('Select all'),
                ),
                TextButton(
                  onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
                IconButton(
                  tooltip: 'Cancel selection',
                  onPressed: _clearSelection,
                  icon: const Icon(Icons.close_rounded),
                ),
              ] else ...[
                if (_service.unreadCount > 0)
                  TextButton(
                    onPressed: _markAllRead,
                    child: const Text(
                      'Mark all read',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                PopupMenuButton<String>(
                  onSelected: (action) {
                    if (action == 'select') setState(() => _isSelectionMode = true);
                    if (action == 'delete_all') _deleteAll();
                  },
                  itemBuilder: (_) => [
                    if (allItems.isNotEmpty)
                      const PopupMenuItem(
                        value: 'select',
                        child: Text('Select notifications'),
                      ),
                    if (allItems.isNotEmpty)
                      const PopupMenuItem(
                        value: 'delete_all',
                        child: Text('Clear all notifications'),
                      ),
                  ],
                ),
              ],
            ],
          ),
          body: _buildBody(allItems, visibleItems),
        );
      },
    );
  }

  Widget _buildBody(
    List<NotificationModel> allItems,
    List<NotificationModel> visibleItems,
  ) {
    if (_service.isLoading && allItems.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_service.error != null && allItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _service.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.darkGrey),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _service.refresh,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    final bookingCount = allItems.where(_isBooking).length;
    final updatesCount = allItems.length - bookingCount;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _filterChip(0, 'All (${allItems.length})'),
                const SizedBox(width: 8),
                _filterChip(1, 'Bookings ($bookingCount)'),
                if (widget.isVendor) ...[
                  const SizedBox(width: 8),
                  _filterChip(2, 'Updates ($updatesCount)'),
                ],
              ],
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              await _service.refresh();
            },
            child: visibleItems.isEmpty
                ? ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 100),
                      AppEmptyState(
                        icon: Icons.notifications_none_rounded,
                        title: 'No Notifications Yet',
                        subtitle: widget.isVendor
                            ? 'Booking requests and account updates will appear here.'
                            : 'Booking updates will appear here.',
                      ),
                    ],
                  )
                : ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                    itemCount:
                        visibleItems.length + (_service.isLoadingMore ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index >= visibleItems.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }
                      final item = visibleItems[index];
                      return _NotificationCard(
                        item: item,
                        selected: _selectedIds.contains(item.id),
                        isSelectionMode: _isSelectionMode,
                        onTap: _isSelectionMode
                            ? () => _toggleSelection(item)
                            : () => _openNotification(item),
                        onLongPress: () => _toggleSelection(item),
                        onMarkRead: item.isRead
                            ? null
                            : () => _markNotificationRead(item),
                        onDelete: () => _deleteNotification(item),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _filterChip(int index, String label) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.grey.withValues(alpha: 0.22),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? AppColors.white : AppColors.darkGrey,
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel item;
  final bool selected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onMarkRead;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.item,
    required this.selected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onMarkRead,
    required this.onDelete,
  });

  (IconData, Color) _styleForType(String type) {
    switch (type.toUpperCase()) {
      case 'BOOKING':
      case 'ORDER':
        return (Icons.event_available_rounded, const Color(0xFFD97706));
      case 'BOOKING_UPDATE':
        return (Icons.event_note_rounded, AppColors.success);
      case 'APPLICATION':
        return (Icons.verified_user_rounded, AppColors.primary);
      case 'AD_ACTIVATED':
        return (Icons.campaign_rounded, const Color(0xFF7C3AED));
      case 'AD_EXPIRED':
        return (Icons.campaign_outlined, const Color(0xFF6B7280));
      case 'SUBSCRIPTION':
        return (Icons.workspace_premium_rounded, const Color(0xFFB7791F));
      case 'SUBSCRIPTION_EXPIRED':
        return (Icons.event_busy_rounded, AppColors.error);
      default:
        return (Icons.notifications_active_rounded, AppColors.primary);
    }
  }

  String _timeLabel(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inSeconds < 60) return 'Now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _styleForType(item.type);
    return Material(
      color: item.isRead ? AppColors.white : const Color(0xFFFFF6F8),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: item.isRead
                  ? AppColors.grey.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: item.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _timeLabel(item.createdAt),
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGrey,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelectionMode)
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? AppColors.primary : AppColors.grey,
                )
              else
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 160),
                  onSelected: (value) {
                    if (value == 'read') onMarkRead?.call();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    if (onMarkRead != null)
                      const PopupMenuItem(
                        value: 'read',
                        child: Text('Mark as read'),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete notification'),
                    ),
                  ],
                  child: const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(
                      Icons.more_vert_rounded,
                      color: AppColors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationDetailSheet extends StatelessWidget {
  final NotificationModel item;

  const _NotificationDetailSheet({required this.item});

  String _labelForKey(String key) {
    return key
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match[1]} ${match[2]}',
        )
        .replaceAll('_', ' ')
        .trim()
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final metadata = item.metadata.entries
        .where(
          (entry) =>
              entry.value != null && entry.value.toString().trim().isNotEmpty,
        )
        .toList();
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.message,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.darkGrey,
                ),
              ),
              if (metadata.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                ...metadata.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 122,
                          child: Text(
                            _labelForKey(entry.key),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}  •  ${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 11, color: AppColors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
