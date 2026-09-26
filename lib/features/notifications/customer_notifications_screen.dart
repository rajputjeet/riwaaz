import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/booking_service.dart';

class CustomerNotificationsScreen extends StatefulWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  State<CustomerNotificationsScreen> createState() =>
      _CustomerNotificationsScreenState();
}

class _CustomerNotificationsScreenState
    extends State<CustomerNotificationsScreen> {
  int _selectedFilter = 0; // 0: All, 1: Bookings, 2: Planning

  final List<Map<String, dynamic>> _staticNotifications = [
    {
      'id': 'cust_1',
      'title': 'Wedding Checklist Milestone',
      'message':
          'Great progress! You have completed 12 of 24 wedding milestones. Next task: Finalize catering menu.',
      'time': '3 hours ago',
      'icon': Icons.checklist_rounded,
      'color': AppColors.primary,
      'isRead': false,
      'category': 'Planning',
    },
    {
      'id': 'cust_2',
      'title': 'Pay In Person Reminder',
      'message':
          'Riwaaz protects your budget. No advance is paid on the app. Pay your vendor directly in cash, UPI, or bank transfer.',
      'time': 'Yesterday',
      'icon': Icons.handshake_rounded,
      'color': AppColors.success,
      'isRead': true,
      'category': 'Planning',
    },
    {
      'id': 'cust_3',
      'title': 'Wedding Budget Summary',
      'message':
          '₹5,75,000 out of your ₹9,00,000 budget is booked across Photography, Venue & Decor.',
      'time': '2 days ago',
      'icon': Icons.account_balance_wallet_rounded,
      'color': AppColors.goldDark,
      'isRead': true,
      'category': 'Planning',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppBookingService.instance,
      builder: (context, _) {
        final activeBookings = AppBookingService.instance.customerBookings;

        final List<Map<String, dynamic>> bookingNotifs = [];

        for (final b in activeBookings) {
          final isPending = b.isPending;
          bookingNotifs.add({
            'id': 'cust_booking_${b.id}',
            'title': isPending
                ? 'Booking Request Sent'
                : 'Booking Confirmed • Contact Unlocked',
            'message': isPending
                ? 'Your request for ${b.package} with ${b.vendorName} is pending vendor acceptance.'
                : '${b.vendorName} accepted! Direct phone ${b.vendorPhone} and WhatsApp are now available in My Bookings.',
            'time': isPending ? 'Pending' : 'Confirmed',
            'icon': isPending
                ? Icons.hourglass_top_rounded
                : Icons.check_circle_rounded,
            'color': isPending ? const Color(0xFFD97706) : AppColors.success,
            'isRead': !isPending,
            'category': 'Bookings',
          });
        }

        final allItems = [...bookingNotifs, ..._staticNotifications];

        final filteredItems = allItems.where((item) {
          if (_selectedFilter == 1) return item['category'] == 'Bookings';
          if (_selectedFilter == 2) return item['category'] == 'Planning';
          return true;
        }).toList();

        final unreadCount = allItems.where((i) => i['isRead'] == false).length;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primary, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            centerTitle: true,
            actions: [
              if (unreadCount > 0)
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (final item in _staticNotifications) {
                        item['isRead'] = true;
                      }
                    });
                  },
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFilterChip(0, 'All (${allItems.length})'),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                          1, 'Bookings (${bookingNotifs.length})'),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                          2, 'Planning (${_staticNotifications.length})'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_off_outlined,
                                size: 54,
                                color: AppColors.grey.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            const Text(
                              'No notifications',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkGrey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                        itemCount: filteredItems.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final isUnread = item['isRead'] == false;

                          return Container(
                            decoration: BoxDecoration(
                              color: isUnread
                                  ? const Color(0xFFFFF6F8)
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isUnread
                                    ? AppColors.primary.withValues(alpha: 0.3)
                                    : AppColors.grey.withValues(alpha: 0.15),
                                width: isUnread ? 1.2 : 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isUnread
                                      ? AppColors.primary.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (item['color'] as Color)
                                        .withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    item['icon'] as IconData,
                                    color: item['color'] as Color,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item['title'] as String,
                                              style: TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: isUnread
                                                    ? FontWeight.w800
                                                    : FontWeight.w600,
                                                color: AppColors.black,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            item['time'] as String,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['message'] as String,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.darkGrey,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.grey.withValues(alpha: 0.22),
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: isSelected ? 6 : 4,
              offset: const Offset(0, 1.5),
            ),
          ],
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
