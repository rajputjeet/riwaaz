import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/booking_service.dart';

class VendorNotificationsScreen extends StatefulWidget {
  const VendorNotificationsScreen({super.key});

  @override
  State<VendorNotificationsScreen> createState() =>
      _VendorNotificationsScreenState();
}

class _VendorNotificationsScreenState extends State<VendorNotificationsScreen> {
  int _selectedFilter = 0; // 0: All, 1: Bookings, 2: Updates

  final List<Map<String, dynamic>> _staticNotifications = [
    {
      'id': 'notif_1',
      'title': 'Gold Partner Badge Active',
      'message':
          'Your business profile is 100% verified. You now appear in top search results in Chandigarh.',
      'time': '2 hours ago',
      'icon': Icons.verified_rounded,
      'color': AppColors.goldDark,
      'isRead': false,
      'category': 'Updates',
    },
    {
      'id': 'notif_2',
      'title': 'Direct Settlement Reminder',
      'message':
          'Riwaaz charges 0% commission. Collect 100% of your service fee directly from clients in person.',
      'time': 'Yesterday',
      'icon': Icons.handshake_rounded,
      'color': AppColors.success,
      'isRead': true,
      'category': 'Updates',
    },
    {
      'id': 'notif_3',
      'title': 'New 5-Star Review Received',
      'message':
          '"Royal Click Studio captured our wedding beautifully!" — Neha Sharma rated 5.0 ★',
      'time': '2 days ago',
      'icon': Icons.star_rounded,
      'color': AppColors.gold,
      'isRead': true,
      'category': 'Updates',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppBookingService.instance,
      builder: (context, _) {
        final pendingBookings = AppBookingService.instance.bookings
            .where((b) => b.isPending)
            .toList();
        final confirmedBookings = AppBookingService.instance.bookings
            .where((b) => b.isAccepted)
            .toList();

        // Build dynamic booking notifications
        final List<Map<String, dynamic>> bookingNotifs = [];

        for (final b in pendingBookings) {
          bookingNotifs.add({
            'id': 'pending_${b.id}',
            'title': 'New Booking Request Awaiting Action!',
            'message':
                '${b.clientName} requested ${b.package} for ${b.date} (${b.total}). Accept to unlock direct contact.',
            'time': 'Just now',
            'icon': Icons.notifications_active_rounded,
            'color': AppColors.error,
            'isRead': false,
            'category': 'Bookings',
            'bookingId': b.id,
            'isPending': true,
          });
        }

        for (final b in confirmedBookings) {
          bookingNotifs.add({
            'id': 'confirmed_${b.id}',
            'title': 'Direct Contact Unlocked',
            'message':
                'Booking confirmed for ${b.clientName}. Call ${b.clientPhone} or chat on WhatsApp to finalize event timings.',
            'time': 'Active',
            'icon': Icons.phone_forwarded_rounded,
            'color': AppColors.success,
            'isRead': true,
            'category': 'Bookings',
            'bookingId': b.id,
            'isPending': false,
          });
        }

        final allItems = [...bookingNotifs, ..._staticNotifications];

        final filteredItems = allItems.where((item) {
          if (_selectedFilter == 1) return item['category'] == 'Bookings';
          if (_selectedFilter == 2) return item['category'] == 'Updates';
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
              'Partner Notifications',
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
              // Filter Chips
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFilterChip(
                          0, 'All (${allItems.length})'),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                          1, 'Bookings (${bookingNotifs.length})'),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                          2, 'Updates (${_staticNotifications.length})'),
                    ],
                  ),
                ),
              ),

              // Notification List
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
                              'No notifications in this tab',
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
                                      if (item['isPending'] == true) ...[
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                AppBookingService.instance
                                                    .acceptBooking(
                                                        item['bookingId']
                                                            as String);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Booking accepted! Client contact unlocked.'),
                                                    backgroundColor:
                                                        AppColors.success,
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.success,
                                                foregroundColor:
                                                    AppColors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 6),
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text('Accept',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                            ),
                                            const SizedBox(width: 8),
                                            OutlinedButton(
                                              onPressed: () {
                                                AppBookingService.instance
                                                    .declineBooking(
                                                        item['bookingId']
                                                            as String);
                                              },
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: AppColors.grey,
                                                side: const BorderSide(
                                                    color: AppColors.grey),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text('Decline',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                            ),
                                          ],
                                        ),
                                      ],
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
