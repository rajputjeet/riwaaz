import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/booking_service.dart';
import '../../data/api_provider/vendor_api_provider.dart';
import '../../data/models/booking_model.dart';

class VendorBookingsTab extends StatefulWidget {
  const VendorBookingsTab({super.key});

  @override
  State<VendorBookingsTab> createState() => _VendorBookingsTabState();
}

class _VendorBookingsTabState extends State<VendorBookingsTab> {
  // 0 = Pending, 1 = Upcoming(Confirmed), 2 = Completed, 3 = All
  int _selectedFilter = 0;
  final _vendorApi = VendorApiProvider();

  List<BookingModel> _allBookings = [];
  bool _isLoading = true;
  String? _errorMsg;
  BookingsSummary? _summary;

  @override
  void initState() {
    super.initState();
    AppBookingService.instance.addListener(_onLocalBookingsChanged);
    _loadBookings();
  }

  @override
  void dispose() {
    AppBookingService.instance.removeListener(_onLocalBookingsChanged);
    super.dispose();
  }

  void _onLocalBookingsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadBookings() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final result = await _vendorApi.getBookings(limit: 100);
      if (!mounted) return;
      if (result.isSuccess == true && result.data != null) {
        setState(() {
          _allBookings = result.data!.bookings;
          _summary = result.data!.summary;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMsg = result.message ?? 'Failed to load bookings';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = 'Network error. Please retry.';
          _isLoading = false;
        });
      }
    }
  }

  List<BookingModel> get _displayedBookings {
    switch (_selectedFilter) {
      case 0:
        return _allBookings.where((b) => b.isPending).toList();
      case 1:
        return _allBookings.where((b) => b.isConfirmed).toList();
      case 2:
        return _allBookings.where((b) => b.isCompleted).toList();
      case 3:
      default:
        return _allBookings;
    }
  }

  Future<void> _handleAccept(BookingModel booking) async {
    final bookingId = booking.id ?? booking.bookingId ?? '';
    if (bookingId.isEmpty) return;

    // Optimistic update
    setState(() => booking.status = 'Confirmed');

    final result = await _vendorApi.updateBookingStatus(
      bookingId: bookingId,
      accept: true,
    );

    if (!mounted) return;
    if (result.isSuccess == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Booking accepted for ${booking.customerName ?? 'Client'}!'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadBookings(); // Refresh from server
    } else {
      // Revert on failure
      setState(() => booking.status = 'Pending');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Failed to accept booking'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleDecline(BookingModel booking) async {
    final bookingId = booking.id ?? booking.bookingId ?? '';
    if (bookingId.isEmpty) return;

    // Optimistic update
    setState(() => booking.status = 'Cancelled');

    final result = await _vendorApi.updateBookingStatus(
      bookingId: bookingId,
      accept: false,
    );

    if (!mounted) return;
    if (result.isSuccess == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Booking declined for ${booking.customerName ?? 'Client'}.'),
          backgroundColor: Colors.red,
        ),
      );
      _loadBookings();
    } else {
      setState(() => booking.status = 'Pending');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Failed to decline booking'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int get _pendingCount =>
      _summary?.pending ?? _allBookings.where((b) => b.isPending).length;
  int get _upcomingCount =>
      _summary?.upcoming ?? _allBookings.where((b) => b.isConfirmed).length;
  int get _completedCount =>
      _summary?.completed ?? _allBookings.where((b) => b.isCompleted).length;
  int get _allCount => _summary?.all ?? _allBookings.length;

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
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  ChoiceChip(
                    avatar: _pendingCount > 0
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD97706),
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                    label: Text('Pending ($_pendingCount)'),
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
                    label: Text('Upcoming ($_upcomingCount)'),
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
                    label: Text('Completed ($_completedCount)'),
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
                    label: Text('All ($_allCount)'),
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

          // Body: loading / error / list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMsg != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_off_rounded,
                                  size: 56, color: AppColors.grey),
                              const SizedBox(height: 12),
                              Text(
                                _errorMsg!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.darkGrey,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadBookings,
                                icon: const Icon(Icons.refresh_rounded,
                                    size: 16),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : bookings.isEmpty
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
                                    color: AppColors.grey
                                        .withValues(alpha: 0.6),
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
                        : RefreshIndicator(
                            onRefresh: _loadBookings,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: bookings.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _buildBookingCard(bookings[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BookingModel b) {
    final isPending = b.isPending;
    final isConfirmed = b.isConfirmed;
    final isCompleted = b.isCompleted;
    final isCancelled = b.isCancelled;

    final clientName = b.customerName ?? 'Client';
    final clientPhone = b.customerPhone ?? '';
    final eventDate = b.eventDate != null
        ? _formatDate(b.eventDate!)
        : 'Event Day';
    final serviceName = b.serviceName ?? 'Service Package';
    final venue = b.venueLocation ?? b.city ?? 'Venue Pending';
    final totalAmount = b.totalAmount != null
        ? '₹${_formatAmount(b.totalAmount!)}'
        : '—';

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
          // New request banner
          if (isPending) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFD97706).withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bolt_rounded,
                      color: Color(0xFFD97706), size: 16),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'NEW BOOKING REQUEST',
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

          // Client name + status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    if (b.bookingId != null)
                      Text(
                        b.bookingId!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  b.status,
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

          // Event date + service
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 13, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                eventDate,
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
                  serviceName,
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

          // Venue
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 13, color: AppColors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  venue,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Amount
          Row(
            children: [
              const Icon(Icons.currency_rupee_rounded,
                  size: 13, color: AppColors.success),
              const SizedBox(width: 4),
              Text(
                totalAmount,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
              if (b.paymentStatus != null) ...[
                const SizedBox(width: 8),
                Text(
                  '• ${b.paymentStatus}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // Actions
          if (isPending) ...[
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: OutlinedButton(
                    onPressed: () => _handleDecline(b),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 5,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleAccept(b),
                    icon: const Icon(Icons.check_circle_rounded, size: 16),
                    label: const Text('Accept Booking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Calling $clientName ($clientPhone)...'),
                        ),
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
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Opening WhatsApp with $clientName...'),
                          backgroundColor: const Color(0xFF25D366),
                        ),
                      );
                    },
                    icon: const Icon(Icons.phone_android_rounded, size: 14),
                    label: const Text('WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
                  'Event Completed ✓',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ),
            ),
          ] else if (isCancelled) ...[
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
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  String _formatAmount(num value) {
    if (value >= 100000) {
      final l = value / 100000;
      return '${l.toStringAsFixed(l.truncateToDouble() == l ? 0 : 1)}L';
    } else if (value >= 1000) {
      final k = value / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
