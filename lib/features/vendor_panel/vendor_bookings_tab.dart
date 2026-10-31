import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/booking_service.dart';
import '../../data/api_provider/vendor_api_provider.dart';
import '../../data/models/booking_model.dart';
import '../../shared/widgets/cached_image_view.dart';
import '../../utils/utils.dart';

class VendorBookingsTab extends StatefulWidget {
  const VendorBookingsTab({super.key});

  @override
  State<VendorBookingsTab> createState() => _VendorBookingsTabState();
}

class _VendorBookingsTabState extends State<VendorBookingsTab> {
  // 0 = All, 1 = Pending, 2 = Upcoming, 3 = Completed, 4 = Cancelled
  int _selectedFilter = 0;
  final _vendorApi = VendorApiProvider();

  List<BookingModel> _allBookings = [];
  bool _isLoading = true;
  String? _errorMsg;

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

  Future<void> _loadBookings({bool showLoader = true}) async {
    if (!mounted) return;
    if (showLoader) {
      setState(() {
        _isLoading = true;
        _errorMsg = null;
      });
    }
    try {
      final result = await _vendorApi.getBookings(limit: 100);
      if (!mounted) return;
      if (result.isSuccess == true && result.data != null) {
        AppBookingService.instance.setVendorBookings(result.data!.bookings);
        setState(() {
          _allBookings = result.data!.bookings;
          _isLoading = false;
          _errorMsg = null;
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
      case 1:
        return _allBookings.where((b) => b.isPending).toList();
      case 2:
        return _allBookings.where((b) => b.isConfirmed).toList();
      case 3:
        return _allBookings.where((b) => b.isCompleted).toList();
      case 4:
        return _allBookings.where((b) => b.isCancelled).toList();
      case 0:
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
      Utils.showSuccess(
        'Booking confirmed for ${booking.customerName ?? 'Client'}!',
      );
      _loadBookings(); // Refresh from server
    } else {
      // Revert on failure
      setState(() => booking.status = 'Pending');
      Utils.showError(result.message ?? 'Failed to accept booking');
    }
  }

  Future<void> _handleDecline(BookingModel booking) async {
    final bookingId = booking.id ?? booking.bookingId ?? '';
    if (bookingId.isEmpty) return;

    // Optimistic update
    setState(() => booking.status = 'Rejected');

    final result = await _vendorApi.updateBookingStatus(
      bookingId: bookingId,
      accept: false,
    );

    if (!mounted) return;
    if (result.isSuccess == true) {
      Utils.showInfo(
        'Booking rejected for ${booking.customerName ?? 'Client'}.',
      );
      _loadBookings();
    } else {
      setState(() => booking.status = 'Pending');
      Utils.showError(result.message ?? 'Failed to decline booking');
    }
  }

  Future<void> _callClient(String? phone) async {
    final digits = (phone ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      Utils.showError('Customer phone number is not available.');
      return;
    }

    final dialNumber = (phone?.trim().startsWith('+') ?? false)
        ? '+$digits'
        : digits;
    try {
      final launched = await launchUrl(
        Uri(scheme: 'tel', path: dialNumber),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) Utils.showError('Unable to open the phone dialer.');
    } catch (_) {
      Utils.showError('Unable to open the phone dialer.');
    }
  }

  Future<void> _openClientWhatsApp(String? phone) async {
    var digits = (phone ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00')) digits = digits.substring(2);
    if (digits.length == 10) digits = '91$digits';
    if (digits.length == 11 && digits.startsWith('0')) {
      digits = '91${digits.substring(1)}';
    }
    if (digits.isEmpty) {
      Utils.showError('Customer phone number is not available.');
      return;
    }

    final appUri = Uri(
      scheme: 'whatsapp',
      host: 'send',
      queryParameters: {'phone': digits},
    );
    try {
      if (await launchUrl(appUri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {}

    try {
      final webUri = Uri.https('wa.me', '/$digits');
      if (await launchUrl(webUri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {}
    Utils.showError('Unable to open WhatsApp.');
  }

  void _showBookingDetails(BookingModel booking) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.white,
      builder: (_) =>
          _VendorBookingDetailsSheet(booking: booking, api: _vendorApi),
    );
  }

  int get _pendingCount => _allBookings.where((b) => b.isPending).length;
  int get _upcomingCount => _allBookings.where((b) => b.isConfirmed).length;
  int get _completedCount => _allBookings.where((b) => b.isCompleted).length;
  int get _cancelledCount => _allBookings.where((b) => b.isCancelled).length;
  int get _allCount => _allBookings.length;

  @override
  Widget build(BuildContext context) {
    final bookings = _displayedBookings;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text('All ($_allCount)'),
                    selected: _selectedFilter == 0,
                    onSelected: (_) => setState(() => _selectedFilter = 0),
                    selectedColor: AppColors.primary,
                    showCheckmark: false,
                    elevation: _selectedFilter == 0 ? 1 : 0,
                    side: BorderSide(
                      color: _selectedFilter == 0
                          ? AppColors.primary
                          : AppColors.grey.withValues(alpha: 0.22),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelStyle: TextStyle(
                      color: _selectedFilter == 0
                          ? AppColors.white
                          : AppColors.darkGrey,
                      fontWeight: _selectedFilter == 0
                          ? FontWeight.w700
                          : FontWeight.w600,
                      fontSize: 12.5,
                    ),
                    backgroundColor: AppColors.white,
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: _pendingCount > 0
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _selectedFilter == 1
                                  ? AppColors.white
                                  : const Color(0xFFD97706),
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                    label: Text('Pending ($_pendingCount)'),
                    selected: _selectedFilter == 1,
                    onSelected: (_) => setState(() => _selectedFilter = 1),
                    selectedColor: AppColors.primary,
                    showCheckmark: false,
                    elevation: _selectedFilter == 1 ? 1 : 0,
                    side: BorderSide(
                      color: _selectedFilter == 1
                          ? AppColors.primary
                          : AppColors.grey.withValues(alpha: 0.22),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelStyle: TextStyle(
                      color: _selectedFilter == 1
                          ? AppColors.white
                          : AppColors.darkGrey,
                      fontWeight: _selectedFilter == 1
                          ? FontWeight.w700
                          : FontWeight.w600,
                      fontSize: 12.5,
                    ),
                    backgroundColor: AppColors.white,
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Upcoming ($_upcomingCount)'),
                    selected: _selectedFilter == 2,
                    onSelected: (_) => setState(() => _selectedFilter = 2),
                    selectedColor: AppColors.primary,
                    showCheckmark: false,
                    elevation: _selectedFilter == 2 ? 1 : 0,
                    side: BorderSide(
                      color: _selectedFilter == 2
                          ? AppColors.primary
                          : AppColors.grey.withValues(alpha: 0.22),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelStyle: TextStyle(
                      color: _selectedFilter == 2
                          ? AppColors.white
                          : AppColors.darkGrey,
                      fontWeight: _selectedFilter == 2
                          ? FontWeight.w700
                          : FontWeight.w600,
                      fontSize: 12.5,
                    ),
                    backgroundColor: AppColors.white,
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Completed ($_completedCount)'),
                    selected: _selectedFilter == 3,
                    onSelected: (_) => setState(() => _selectedFilter = 3),
                    selectedColor: AppColors.primary,
                    showCheckmark: false,
                    elevation: _selectedFilter == 3 ? 1 : 0,
                    side: BorderSide(
                      color: _selectedFilter == 3
                          ? AppColors.primary
                          : AppColors.grey.withValues(alpha: 0.22),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelStyle: TextStyle(
                      color: _selectedFilter == 3
                          ? AppColors.white
                          : AppColors.darkGrey,
                      fontWeight: _selectedFilter == 3
                          ? FontWeight.w700
                          : FontWeight.w600,
                      fontSize: 12.5,
                    ),
                    backgroundColor: AppColors.white,
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Cancelled ($_cancelledCount)'),
                    selected: _selectedFilter == 4,
                    onSelected: (_) => setState(() => _selectedFilter = 4),
                    selectedColor: AppColors.primary,
                    showCheckmark: false,
                    elevation: _selectedFilter == 4 ? 1 : 0,
                    side: BorderSide(
                      color: _selectedFilter == 4
                          ? AppColors.primary
                          : AppColors.grey.withValues(alpha: 0.22),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelStyle: TextStyle(
                      color: _selectedFilter == 4
                          ? AppColors.white
                          : AppColors.darkGrey,
                      fontWeight: _selectedFilter == 4
                          ? FontWeight.w700
                          : FontWeight.w600,
                      fontSize: 12.5,
                    ),
                    backgroundColor: AppColors.white,
                  ),
                ],
              ),
            ),
          ),

          // Body: loading / error / list
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final showPlaceholder =
                    _isLoading || _errorMsg != null || bookings.isEmpty;
                return RefreshIndicator(
                  onRefresh: () => _loadBookings(showLoader: false),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: showPlaceholder ? 1 : bookings.length,
                    itemBuilder: (context, index) {
                      if (_isLoading) {
                        return SizedBox(
                          height: constraints.maxHeight,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (_errorMsg != null) {
                        return SizedBox(
                          height: constraints.maxHeight,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.cloud_off_rounded,
                                    size: 56,
                                    color: AppColors.grey,
                                  ),
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
                                    icon: const Icon(
                                      Icons.refresh_rounded,
                                      size: 16,
                                    ),
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
                          ),
                        );
                      }
                      if (bookings.isEmpty) {
                        return SizedBox(
                          height: constraints.maxHeight,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _selectedFilter == 1
                                        ? Icons.mark_email_read_rounded
                                        : Icons.event_busy_rounded,
                                    size: 56,
                                    color: AppColors.grey.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _selectedFilter == 1
                                        ? 'No Pending Requests'
                                        : _selectedFilter == 2
                                        ? 'No Upcoming Bookings'
                                        : _selectedFilter == 3
                                        ? 'No Completed Bookings'
                                        : _selectedFilter == 4
                                        ? 'No Cancelled Bookings'
                                        : 'No Bookings Found',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _selectedFilter == 1
                                        ? 'New customer booking requests will appear here instantly for your review.'
                                        : _selectedFilter == 4
                                        ? 'Cancelled and rejected bookings will appear here.'
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
                          ),
                        );
                      }
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == bookings.length - 1 ? 0 : 12,
                        ),
                        child: _buildBookingCard(bookings[index]),
                      );
                    },
                  ),
                );
              },
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
    final statusColor = bookingStatusColor(b.status);
    final cancelledLabel =
        b.status.toLowerCase() == 'cancelled' ||
            b.status.toLowerCase() == 'canceled'
        ? 'Booking Cancelled'
        : 'Booking Rejected';

    final clientName = b.customerName ?? 'Client';
    final clientProfileImg = b.customerProfileImg;
    final bookingNumber = b.bookingId?.trim().isNotEmpty == true
        ? b.bookingId!.trim()
        : (b.id ?? '').trim();
    final clientPhone = b.customerPhone ?? '';
    final eventDate = b.eventDate != null
        ? _formatDate(b.eventDate!)
        : 'Event Day';
    final serviceName = b.serviceName ?? 'Service Package';
    final eventLocation = [b.eventLocation, b.venueLocation]
        .map((value) => value?.trim() ?? '')
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');
    final venue = eventLocation.isNotEmpty ? eventLocation : 'N/A';
    final totalAmount = b.totalAmount != null
        ? '₹${_formatAmount(b.totalAmount!)}'
        : 'N/A';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFD97706).withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bolt_rounded, color: Color(0xFFD97706), size: 16),
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
                child: Row(
                  children: [
                    CachedImageView(
                      imageUrl: clientProfileImg,
                      width: 44,
                      height: 44,
                      isCircle: true,
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.08,
                      ),
                      fallbackIcon: Icons.person_rounded,
                      iconColor: AppColors.primary,
                      iconSize: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (bookingNumber.isNotEmpty)
                            Text(
                              bookingNumber,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey,
                              ),
                            ),
                          const SizedBox(height: 3),
                          Text(
                            clientName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      bookingStatusIcon(b.status),
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      b.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Service / package comes first, followed by the event date.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.045),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 16,
                  color: AppColors.goldDark,
                ),
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
          ),

          const SizedBox(height: 10),
          Divider(height: 1, color: statusColor.withValues(alpha: 0.12)),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                eventDate,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          if (b.eventTime?.isNotEmpty == true) ...[
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  b.eventTime!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.darkGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],

          // Venue
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.grey,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  venue,
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Amount
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text(
                  'Booking total',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
                const Spacer(),
                Text(
                  totalAmount,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Actions
          if (isPending) ...[
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
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
                      child: const Text('Reject'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => _handleAccept(b),
                      child: const Text('Accept'),
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
                ),
              ],
            ),
          ] else if (isConfirmed) ...[
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: () => _callClient(clientPhone),
                      icon: const Icon(Icons.call_rounded, size: 14),
                      label: const Text('Call Client'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => _openClientWhatsApp(clientPhone),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone_android_rounded, size: 14),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'WhatsApp',
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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
              child: Center(
                child: Text(
                  cancelledLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
          if (isConfirmed) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                onPressed: () => _showBookingDetails(b),
                icon: const Icon(Icons.receipt_long_outlined, size: 16),
                label: const Text('View booking details'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.45),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  String _formatAmount(num value) {
    return value.toString();
  }
}

class _VendorBookingDetailsSheet extends StatefulWidget {
  final BookingModel booking;
  final VendorApiProvider api;

  const _VendorBookingDetailsSheet({required this.booking, required this.api});

  @override
  State<_VendorBookingDetailsSheet> createState() =>
      _VendorBookingDetailsSheetState();
}

class _VendorBookingDetailsSheetState
    extends State<_VendorBookingDetailsSheet> {
  late BookingModel _booking;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final id = widget.booking.id?.trim();
    if (id == null || id.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final response = await widget.api.getBookingDetail(id);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (response.isSuccess == true && response.data != null) {
        _booking = response.data!.mergeMissingFrom(widget.booking);
      }
    });
  }

  String _formatEventDate(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) return 'N/A';
    final date = DateTime.tryParse(rawDate)?.toLocal();
    if (date == null) return rawDate;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatPrice(num value) {
    final amount = value.toInt().toString();
    if (amount.length <= 3) return '₹$amount';
    final lastThree = amount.substring(amount.length - 3);
    final rest = amount.substring(0, amount.length - 3);
    final formattedRest = rest.replaceAllMapped(
      RegExp(r'(\d)(?=(\d\d)+$)'),
      (match) => '${match[1]},',
    );
    return '₹$formattedRest,$lastThree';
  }

  Widget _detailRow(String label, String? value, {IconData? icon}) {
    final cleanValue = value?.trim() ?? '';
    if (cleanValue.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 17, color: AppColors.primary),
            const SizedBox(width: 9),
          ],
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
          ),
          Expanded(
            child: Text(
              cleanValue,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventLocation = [_booking.eventLocation, _booking.venueLocation]
        .map((value) => value?.trim() ?? '')
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');
    final price = _booking.totalAmount;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.96,
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Booking details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: bookingStatusColor(
                        _booking.status,
                      ).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          bookingStatusIcon(_booking.status),
                          size: 14,
                          color: bookingStatusColor(_booking.status),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _booking.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: bookingStatusColor(_booking.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_isLoading) ...[
                const SizedBox(height: 10),
                const LinearProgressIndicator(color: AppColors.primary),
              ],
              const Divider(height: 24),
              _detailRow(
                'Booking ID',
                _booking.bookingId ?? _booking.id,
                icon: Icons.confirmation_number_outlined,
              ),
              _detailRow(
                'Customer',
                _booking.customerName,
                icon: Icons.person_outline_rounded,
              ),
              _detailRow(
                'Email',
                _booking.customerEmail,
                icon: Icons.email_outlined,
              ),
              _detailRow(
                'Phone',
                _booking.customerPhone,
                icon: Icons.phone_outlined,
              ),
              _detailRow(
                'Service / package',
                _booking.serviceName,
                icon: Icons.inventory_2_outlined,
              ),
              _detailRow(
                'Event date',
                _formatEventDate(_booking.eventDate),
                icon: Icons.calendar_month_outlined,
              ),
              _detailRow(
                'Event time',
                _booking.eventTime,
                icon: Icons.schedule_rounded,
              ),
              _detailRow(
                'Event location',
                eventLocation.isEmpty ? 'N/A' : eventLocation,
                icon: Icons.location_on_outlined,
              ),
              _detailRow(
                'Price',
                price == null ? 'N/A' : _formatPrice(price),
                icon: Icons.currency_rupee_rounded,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
