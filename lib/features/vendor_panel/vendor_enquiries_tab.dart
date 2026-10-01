import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/booking_service.dart';
import '../../data/api_provider/vendor_api_provider.dart';
import '../../data/models/booking_model.dart';
import '../../shared/widgets/app_states.dart';
import '../../utils/utils.dart';

class VendorEnquiriesTab extends StatefulWidget {
  const VendorEnquiriesTab({super.key});

  @override
  State<VendorEnquiriesTab> createState() => _VendorEnquiriesTabState();
}

class _VendorEnquiriesTabState extends State<VendorEnquiriesTab> {
  final _vendorApi = VendorApiProvider();
  List<BookingModel> _enquiries = [];
  bool _isLoading = true;
  bool _isNoInternet = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    AppBookingService.instance.addListener(_onLocalChanged);
    _loadEnquiries();
  }

  @override
  void dispose() {
    AppBookingService.instance.removeListener(_onLocalChanged);
    super.dispose();
  }

  void _onLocalChanged() {
    if (mounted) _loadEnquiries(silent: true);
  }

  Future<void> _loadEnquiries({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _isNoInternet = false;
        _errorMsg = null;
      });
    }

    try {
      final res = await _vendorApi.getBookings(limit: 50);
      if (!mounted) return;

      if (res.isSuccess == true && res.data != null) {
        setState(() {
          _enquiries = res.data!.bookings;
          _isLoading = false;
          _isNoInternet = false;
          _errorMsg = null;
        });
      } else {
        setState(() {
          _errorMsg = res.message ?? 'Could not load enquiries from server.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      final isNet = e.toString().toLowerCase().contains('socket') ||
          e.toString().toLowerCase().contains('connection') ||
          e.toString().toLowerCase().contains('network');
      setState(() {
        _isNoInternet = isNet;
        _errorMsg = isNet ? null : 'Failed to connect. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleStatusUpdate(BookingModel b, bool accept) async {
    final id = b.id ?? b.bookingId ?? '';
    if (id.isEmpty) return;

    final res = await _vendorApi.updateBookingStatus(
      bookingId: id,
      accept: accept,
      notes: accept ? 'Accepted by vendor' : 'Declined by vendor',
    );

    if (!mounted) return;
    if (res.isSuccess == true) {
      if (accept) {
        Utils.showSuccess('Enquiry accepted for ${b.customerName ?? 'Client'}!');
      } else {
        Utils.showInfo('Enquiry declined.');
      }
      _loadEnquiries();
    } else {
      Utils.showError(res.message ?? 'Action failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppLoadingState(message: 'Loading client enquiries & leads...');
    }

    if (_isNoInternet) {
      return AppNoInternetState(onRetry: () => _loadEnquiries());
    }

    if (_errorMsg != null) {
      return AppErrorState(
        message: _errorMsg!,
        onRetry: () => _loadEnquiries(),
      );
    }

    if (_enquiries.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _loadEnquiries(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: const AppEmptyState(
              icon: Icons.mark_email_unread_outlined,
              title: 'No Inquiries Yet',
              subtitle:
                  'When couples or event planners send you booking inquiries and lead requests, they will show up here instantly.',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _loadEnquiries(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: _enquiries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final e = _enquiries[index];
          final isPending = e.isPending;
          final name = e.customerName ?? 'Prospective Client';
          final service = e.serviceName ?? 'Wedding Package';
          final amount = e.totalAmount != null ? '₹${e.totalAmount}' : 'Custom';
          final date = e.eventDate ?? 'Date to be confirmed';
          final notes = e.notes ?? '';

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPending
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.grey.withValues(alpha: 0.2),
                width: isPending ? 1.5 : 1,
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
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isPending) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'NEW LEAD',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  service,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.goldDark,
                  ),
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '"$notes"',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined,
                        size: 13, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.darkGrey),
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.info_outline_rounded,
                        size: 13, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Text(
                      e.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isPending ? AppColors.warning : AppColors.success,
                      ),
                    ),
                  ],
                ),
                if (isPending) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleStatusUpdate(e, true),
                          icon: const Icon(Icons.check_rounded, size: 14),
                          label: const Text('Accept Lead'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _handleStatusUpdate(e, false),
                          icon: const Icon(Icons.close_rounded, size: 14),
                          label: const Text('Decline'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
