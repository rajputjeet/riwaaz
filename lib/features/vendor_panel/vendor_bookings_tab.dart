import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/booking_service.dart';

class VendorBookingsTab extends StatefulWidget {
  const VendorBookingsTab({super.key});

  @override
  State<VendorBookingsTab> createState() => _VendorBookingsTabState();
}

class _VendorBookingsTabState extends State<VendorBookingsTab> {
  int _selectedFilter = 0; // 0 = Pending, 1 = Upcoming, 2 = Completed, 3 = All

  @override
  void initState() {
    super.initState();
    AppBookingService.instance.addListener(_onBookingsChanged);
  }

  @override
  void dispose() {
    AppBookingService.instance.removeListener(_onBookingsChanged);
    super.dispose();
  }

  void _onBookingsChanged() {
    if (mounted) setState(() {});
  }

  List<Map<String, dynamic>> get _displayedBookings {
    return AppBookingService.instance.vendorBookingsForFilter(_selectedFilter);
  }

  @override
  Widget build(BuildContext context) {
    final bookings = _displayedBookings;
    final bookingService = AppBookingService.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Filter Tabs (Scrollable to prevent any RenderFlex overflow)
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  ChoiceChip(
                    avatar: bookingService.pendingCount > 0
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD97706),
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                    label: Text('Pending (${bookingService.pendingCount})'),
                    selected: _selectedFilter == 0,
                    onSelected: (_) => setState(() => _selectedFilter = 0),
                    selectedColor: const Color(0xFFD97706),
                    labelStyle: TextStyle(
                      color: _selectedFilter == 0
                          ? AppColors.white
                          : const Color(0xFF92400E),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    backgroundColor: const Color(0xFFFEF3C7),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Upcoming (${bookingService.confirmedCount})'),
                    selected: _selectedFilter == 1,
                    onSelected: (_) => setState(() => _selectedFilter = 1),
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
                    label: Text('Completed (${bookingService.completedCount})'),
                    selected: _selectedFilter == 2,
                    onSelected: (_) => setState(() => _selectedFilter = 2),
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
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('All (${bookingService.totalCount})'),
                    selected: _selectedFilter == 3,
                    onSelected: (_) => setState(() => _selectedFilter = 3),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: _selectedFilter == 3
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
          ),

          // Bookings List or Empty State
          Expanded(
            child: bookings.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedFilter == 0
                                ? Icons.mark_email_read_rounded
                                : Icons.event_busy_rounded,
                            size: 56,
                            color: AppColors.grey.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _selectedFilter == 0
                                ? 'No Pending Requests'
                                : 'No Bookings in this Tab',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _selectedFilter == 0
                                ? 'New customer booking requests will appear here instantly for your review.'
                                : 'Check other tabs to view upcoming and completed bookings.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.darkGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: bookings.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final b = bookings[index];
                      final status = (b['status'] as String?) ?? 'Pending';
                      final isPending = status == 'Pending';
                      final isConfirmed =
                          status == 'Confirmed' || status == 'Accepted';
                      final isCompleted = status.contains('Delivered') ||
                          status.contains('Completed');
                      final isDeclined = status == 'Declined';
                      final bookingId = b['id']?.toString() ?? '';
                      final clientName =
                          b['client']?.toString() ?? b['clientName']?.toString() ?? 'Client';
                      final clientPhone =
                          b['clientPhone']?.toString() ?? b['phone']?.toString() ?? '+91 98765 43210';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isPending
                                ? const Color(0xFFD97706).withValues(alpha: 0.4)
                                : isCompleted
                                    ? AppColors.grey.withValues(alpha: 0.25)
                                    : AppColors.gold.withValues(alpha: 0.3),
                            width: isPending ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isPending
                                  ? const Color(0xFFD97706).withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isPending) ...[
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFD97706)
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.bolt_rounded,
                                        color: Color(0xFFD97706), size: 16),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'NEW BOOKING REQUEST • In-Person Settlement',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF92400E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        clientName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.black,
                                        ),
                                      ),
                                      if (b['vendorName'] != null)
                                        Text(
                                          b['vendorName'].toString(),
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.goldDark,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isPending
                                        ? const Color(0xFFFEF3C7)
                                        : isConfirmed
                                            ? AppColors.successLight
                                            : isCompleted
                                                ? AppColors.offWhite
                                                : const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isPending
                                          ? const Color(0xFFD97706)
                                          : isConfirmed
                                              ? AppColors.success
                                              : isCompleted
                                                  ? AppColors.darkGrey
                                                  : Colors.red,
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
                                  b['date']?.toString() ?? 'Event Day',
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
                                    b['package']?.toString() ?? 'Service Package',
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
                                    b['venue']?.toString() ?? 'Venue Pending',
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      b['payment']?.toString() ??
                                          b['paymentMode']?.toString() ??
                                          'Pay In Person',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      b['balance']?.toString() ??
                                          'Settle on Event Day',
                                      textAlign: TextAlign.right,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.darkGrey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Dynamic Actions depending on booking status
                            if (isPending) ...[
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        bookingService.declineBooking(bookingId);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Booking request declined for $clientName.'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(
                                            color: Colors.red, width: 1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                      ),
                                      child: const Text('Decline'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 5,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        bookingService.acceptBooking(bookingId);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Booking accepted for $clientName! Contact details unlocked.'),
                                            backgroundColor: AppColors.success,
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                          Icons.check_circle_rounded,
                                          size: 16),
                                      label: const Text('Accept Booking'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.success,
                                        foregroundColor: AppColors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else if (isConfirmed) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Calling $clientName ($clientPhone)...'),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.call_rounded,
                                          size: 14),
                                      label: const Text('Call Client'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        side: const BorderSide(
                                            color: AppColors.primary, width: 1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Opening WhatsApp with $clientName ($clientPhone)...'),
                                            backgroundColor:
                                                const Color(0xFF25D366),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                          Icons.phone_android_rounded,
                                          size: 14),
                                      label: const Text('WhatsApp'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF25D366),
                                        foregroundColor: AppColors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else if (isCompleted) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.offWhite,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Event Delivered • Payment Settled in Person ✓',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ),
                              ),
                            ] else if (isDeclined) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Booking Declined',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
