import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class VendorBookingsTab extends StatefulWidget {
  const VendorBookingsTab({super.key});

  @override
  State<VendorBookingsTab> createState() => _VendorBookingsTabState();
}

class _VendorBookingsTabState extends State<VendorBookingsTab> {
  int _selectedFilter = 0; // 0 = Upcoming, 1 = Completed, 2 = All

  final List<Map<String, dynamic>> _upcomingBookings = [
    {
      'client': 'Aman & Simran Wedding',
      'date': '18 Dec 2026',
      'venue': 'The Grand Palace, Chandigarh',
      'package': 'Royal Diamond 4K Package (₹75,000)',
      'status': 'Confirmed',
      'advance': '₹25,000 Paid (Advance)',
      'balance': '₹50,000 Due on Event',
      'phone': '+91 98765 11223',
    },
    {
      'client': 'Pooja & Rohan Engagement',
      'date': '04 Nov 2026',
      'venue': 'Kasauli Pine Hills Resort',
      'package': 'Standard Gold Package (₹45,000)',
      'status': 'Confirmed',
      'advance': '₹15,000 Paid (Advance)',
      'balance': '₹30,000 Due on Event',
      'phone': '+91 98112 33445',
    },
    {
      'client': 'Kavita & Nitin Sangeet Night',
      'date': '22 Jan 2027',
      'venue': 'Hyatt Regency, Ludhiana',
      'package': 'Custom 4K Cinematic (₹60,000)',
      'status': 'Confirmed',
      'advance': '₹20,000 Paid (Advance)',
      'balance': '₹40,000 Due on Event',
      'phone': '+91 98234 55667',
    },
  ];

  final List<Map<String, dynamic>> _completedBookings = [
    {
      'client': 'Gurpreet & Harleen Wedding',
      'date': '12 May 2026',
      'venue': 'JW Marriott, Chandigarh',
      'package': 'Royal Diamond Package (₹85,000)',
      'status': 'Delivered & Paid',
      'advance': '₹85,000 Paid (100%)',
      'balance': 'Album & 4K Video Delivered ✓',
      'phone': '+91 98881 22334',
    },
    {
      'client': 'Deepak & Sunita Reception',
      'date': '28 Apr 2026',
      'venue': 'Heritage Haveli, Mohali',
      'package': 'Standard Package (₹45,000)',
      'status': 'Delivered & Paid',
      'advance': '₹45,000 Paid (100%)',
      'balance': 'Drive Link Sent ✓',
      'phone': '+91 98770 99881',
    },
    {
      'client': 'Vikram & Ananya Pre-Wedding',
      'date': '14 Apr 2026',
      'venue': 'Timber Trail Resort, Parwanoo',
      'package': 'Pre-Wedding Special (₹35,000)',
      'status': 'Delivered & Paid',
      'advance': '₹35,000 Paid (100%)',
      'balance': 'Photos Edited & Delivered ✓',
      'phone': '+91 98144 55667',
    },
  ];

  List<Map<String, dynamic>> get _displayedBookings {
    if (_selectedFilter == 0) return _upcomingBookings;
    if (_selectedFilter == 1) return _completedBookings;
    return [..._upcomingBookings, ..._completedBookings];
  }

  @override
  Widget build(BuildContext context) {
    final bookings = _displayedBookings;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text('Upcoming (${_upcomingBookings.length})'),
                  selected: _selectedFilter == 0,
                  onSelected: (val) => setState(() => _selectedFilter = 0),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _selectedFilter == 0
                        ? AppColors.white
                        : AppColors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  backgroundColor: AppColors.offWhite,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Completed (${_completedBookings.length})'),
                  selected: _selectedFilter == 1,
                  onSelected: (val) => setState(() => _selectedFilter = 1),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _selectedFilter == 1
                        ? AppColors.white
                        : AppColors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  backgroundColor: AppColors.offWhite,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text('All (${_upcomingBookings.length + _completedBookings.length})'),
                  selected: _selectedFilter == 2,
                  onSelected: (val) => setState(() => _selectedFilter = 2),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _selectedFilter == 2
                        ? AppColors.white
                        : AppColors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  backgroundColor: AppColors.offWhite,
                ),
              ],
            ),
          ),

          // Bookings List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: bookings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final b = bookings[index];
                final isCompleted = b['status'].toString().contains('Delivered');

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.grey.withValues(alpha: 0.25)
                          : AppColors.gold.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              b['client'],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? AppColors.successLight
                                  : AppColors.successLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              b['status'],
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 13, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            b['date'],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.inventory_2_outlined,
                              size: 13, color: AppColors.goldDark),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              b['package'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.darkGrey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: AppColors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              b['venue'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.offWhite,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              b['advance'],
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                            Text(
                              b['balance'],
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Calling ${b['phone']}...')),
                                );
                              },
                              icon: const Icon(Icons.call_rounded, size: 14),
                              label: const Text('Call Client'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(
                                    color: AppColors.primary, width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Chat opened with ${b['client']}!'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.chat_bubble_outline_rounded,
                                  size: 14),
                              label: const Text('Message'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8),
                              ),
                            ),
                          ),
                        ],
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
  }
}
