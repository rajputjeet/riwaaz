import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/booking_service.dart';
import '../../data/api_provider/vendor_api_provider.dart';
import '../../shared/widgets/app_states.dart';
import '../../utils/utils.dart';

class VendorMessagesTab extends StatefulWidget {
  const VendorMessagesTab({super.key});

  @override
  State<VendorMessagesTab> createState() => _VendorMessagesTabState();
}

class _VendorMessagesTabState extends State<VendorMessagesTab> {
  final _vendorApi = VendorApiProvider();
  List<Map<String, dynamic>> _threads = [];
  bool _isLoading = true;
  bool _isNoInternet = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadThreads();
  }

  Future<void> _loadThreads() async {
    setState(() {
      _isLoading = true;
      _isNoInternet = false;
      _errorMsg = null;
    });

    try {
      final res = await _vendorApi.getBookings(limit: 20);
      if (!mounted) return;

      if (res.isSuccess == true && res.data != null) {
        // Derive conversation threads from active client bookings
        final bookings = res.data!.bookings;
        final List<Map<String, dynamic>> threads = [];

        for (final b in bookings) {
          final name = b.customerName?.trim() ?? '';
          if (name.isNotEmpty) {
            final initials = name.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();
            threads.add({
              'id': b.id ?? b.bookingId,
              'name': name,
              'lastMsg': b.notes?.isNotEmpty == true
                  ? b.notes!
                  : 'Booking inquiry for ${b.serviceName ?? 'package'}',
              'time': b.eventDate ?? 'Recent',
              'unread': b.isPending ? 1 : 0,
              'avatar': initials.isNotEmpty ? initials : 'CL',
              'phone': b.customerPhone ?? '',
            });
          }
        }

        // Also merge local bookings if any
        for (final local in AppBookingService.instance.bookings) {
          if (!threads.any((t) => t['id'] == local.id)) {
            final initials = local.clientName.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();
            threads.add({
              'id': local.id,
              'name': local.clientName,
              'lastMsg': 'Booking status: ${local.status}',
              'time': local.date,
              'unread': local.isPending ? 1 : 0,
              'avatar': initials.isNotEmpty ? initials : 'CL',
              'phone': local.clientPhone,
            });
          }
        }

        setState(() {
          _threads = threads;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMsg = res.message ?? 'Could not load messages.';
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: AppLoadingState(message: 'Loading conversations...'),
      );
    }

    if (_isNoInternet) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: AppNoInternetState(onRetry: _loadThreads),
      );
    }

    if (_errorMsg != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: AppErrorState(
          message: _errorMsg!,
          onRetry: _loadThreads,
        ),
      );
    }

    if (_threads.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          onRefresh: _loadThreads,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: const AppEmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'No Messages Yet',
                subtitle:
                    'When clients message you about your packages or bookings, conversations will appear here in real time.',
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadThreads,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _threads.length,
          separatorBuilder: (context, index) => Divider(
            color: AppColors.grey.withValues(alpha: 0.15),
            height: 1,
            indent: 72,
          ),
          itemBuilder: (context, index) {
            final c = _threads[index];
            final unread = (c['unread'] as int? ?? 0) > 0;

            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: unread
                    ? AppColors.primary
                    : AppColors.gold.withValues(alpha: 0.2),
                child: Text(
                  c['avatar'] as String,
                  style: TextStyle(
                    color: unread ? AppColors.white : AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      c['name'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  Text(
                    c['time'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: unread ? AppColors.primary : AppColors.grey,
                      fontWeight: unread ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              subtitle: Row(
                children: [
                  Expanded(
                    child: Text(
                      c['lastMsg'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: unread ? AppColors.black : AppColors.grey,
                        fontWeight:
                            unread ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (unread) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${c['unread']}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              onTap: () {
                Utils.showInfo('Chat with ${c['name']}');
              },
            );
          },
        ),
      ),
    );
  }
}
