import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/app_animations.dart';
import '../../utils/helper/storage_helper.dart';
import '../shell/main_shell.dart';
import '../service_listing/service_listing_screen.dart';
import '../wedding_details/wedding_details_screen.dart';
import '../notifications/customer_notifications_screen.dart';
import '../../core/services/booking_service.dart';
import '../../shared/widgets/app_states.dart';

/// Standalone Dashboard screen wrapper that launches MainShell at tab index 0
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainShell(initialIndex: 0);
  }
}

/// Body-only dashboard widget — no Scaffold, no BottomNav.
/// Owned by [MainShell] which provides the surrounding Scaffold + nav.
class DashboardBody extends StatefulWidget {
  const DashboardBody({super.key});

  @override
  State<DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<DashboardBody> {
  late final PageController _eventsPageController;
  Timer? _autoScrollTimer;
  int _currentEventIndex = 0;

  List<_WeddingEvent> get _createdEvents {
    final rawEvents = StorageHelper().getWeddingEvents() ?? [];
    final weddingDateStr = StorageHelper().getWeddingDate();
    final weddingDate = (weddingDateStr != null && DateTime.tryParse(weddingDateStr) != null)
        ? DateTime.parse(weddingDateStr)
        : null;
    final now = DateTime.now();

    return rawEvents.map((e) {
      final title = e['title']?.toString() ?? 'Wedding Event';
      final date = e['date']?.toString() ?? 'Upcoming';
      final time = e['time']?.toString() ?? '';
      final venue = e['location']?.toString() ?? 'TBD';

      final diff = weddingDate?.difference(now);
      final days = (diff != null && !diff.isNegative) ? '${diff.inDays}' : '0';
      final hours = (diff != null && !diff.isNegative) ? '${diff.inHours % 24}' : '0';
      final mins = (diff != null && !diff.isNegative) ? '${diff.inMinutes % 60}' : '0';

      return _WeddingEvent(
        title: title,
        ceremonyType: 'Ceremony',
        date: date,
        time: time,
        venue: venue,
        guests: 'Event Function',
        daysLeft: days,
        hoursLeft: hours,
        minLeft: mins,
        gradientColors: const [Color(0xFF5E1B33), Color(0xFF380C1D)],
        icon: Icons.celebration_rounded,
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _eventsPageController = PageController(viewportFraction: 0.91);
    AppBookingService.instance.addListener(_onBookingsChanged);
    _startAutoScroll();
  }

  void _onBookingsChanged() {
    if (mounted) setState(() {});
  }

  void _startAutoScroll() {
    // Avoid active periodic timer in test environment
    if (!kIsWeb) {
      try {
        if (Platform.environment.containsKey('FLUTTER_TEST')) return;
      } catch (_) {}
    }
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_eventsPageController.hasClients || _createdEvents.isEmpty) return;
      final nextIndex = (_currentEventIndex + 1) % _createdEvents.length;
      _eventsPageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    AppBookingService.instance.removeListener(_onBookingsChanged);
    _autoScrollTimer?.cancel();
    _eventsPageController.dispose();
    super.dispose();
  }

  /// Returns first name from storage, e.g. "Priya" from "Priya Sharma"
  String _firstName() {
    final full = StorageHelper().getUserName() ?? '';
    if (full.trim().isEmpty) return 'there';
    return full.trim().split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  // Events header with horizontal padding
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildEventsHeader(),
                  ),
                  const SizedBox(height: 12),
                  // PageView bleeds full width for spacing effect
                  _buildEventsCarousel(),
                  const SizedBox(height: 10),
                  _buildEventsDots(),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildBookingsSection(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Greeting
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Hello ${_firstName()}',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('👋', style: TextStyle(fontSize: 18)),
                ],
              ),
              Text(
                'Plan parties, birthdays, corporate & weddings',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
              ),
            ],
          ),
          const Spacer(),
          // Notification
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                FadeScaleRoute(
                  page: const CustomerNotificationsScreen(),
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.notifications_outlined,
                        size: 22, color: AppColors.darkGrey),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Header row: title badge + View All
  Widget _buildEventsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Created Events',
              style: AppTextStyles.headlineSmall.copyWith(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_createdEvents.length} Events',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () async {
            await Navigator.of(context).push(
              FadeScaleRoute(page: const WeddingDetailsScreen()),
            );
            if (mounted) setState(() {});
          },
          child: const Text(
            'Plan Event',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Full-width carousel so adjacent cards peek at the edges
  Widget _buildEventsCarousel() {
    if (_createdEvents.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              await Navigator.of(context).push(
                FadeScaleRoute(page: const WeddingDetailsScreen()),
              );
              if (mounted) setState(() {});
            },
            child: Stack(
              children: [
                Positioned(
                  right: -24,
                  top: -24,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.04),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.15),
                                  AppColors.gold.withValues(alpha: 0.25),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.event_note_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'No Events Planned Yet',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Start organizing your special days',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Set your wedding date, Sangeet, Mehendi, Haldi, or Reception ceremonies to begin your countdown and itinerary.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.darkGrey,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.of(context).push(
                              FadeScaleRoute(page: const WeddingDetailsScreen()),
                            );
                            if (mounted) setState(() {});
                          },
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text(
                            'Plan Wedding Event',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 205,
      child: PageView.builder(
        controller: _eventsPageController,
        itemCount: _createdEvents.length,
        onPageChanged: (i) {
          setState(() => _currentEventIndex = i);
        },
        itemBuilder: (context, i) {
          final event = _createdEvents[i];
          return _buildEventCard(event);
        },
      ),
    );
  }

  /// Dot indicators
  Widget _buildEventsDots() {
    if (_createdEvents.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _createdEvents.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _currentEventIndex == index ? 22 : 6,
          height: 5,
          decoration: BoxDecoration(
            color: _currentEventIndex == index
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(_WeddingEvent event) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          FadeScaleRoute(page: const WeddingDetailsScreen()),
        );
      },
      child: Container(
        // horizontal margin creates visible gap between adjacent cards
        margin: const EdgeInsets.symmetric(horizontal: 8),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: event.gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: event.gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Full width and height ambient decorative background bubbles/glow
            Positioned.fill(
              child: Stack(
                children: [
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -40,
                    bottom: -40,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.topRight,
                          radius: 1.25,
                          colors: [
                            AppColors.white.withValues(alpha: 0.16),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(event.icon,
                                size: 11, color: AppColors.goldLight),
                            const SizedBox(width: 4),
                            Text(
                              event.ceremonyType,
                              style: const TextStyle(
                                color: AppColors.goldLight,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          event.guests,
                          style: const TextStyle(
                            color: AppColors.cream,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.goldLight,
                          size: 11,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: AppColors.cream, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        '${event.date} • ${event.time}',
                        style: const TextStyle(
                          color: AppColors.cream,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: AppColors.cream, size: 13),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          event.venue,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.cream,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: _buildCountdownBox(event.daysLeft, 'Days')),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _buildCountdownBox(event.hoursLeft, 'Hrs')),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _buildCountdownBox(event.minLeft, 'Min')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.cream,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBookingsSection() {
    final recentBookings = AppBookingService.instance.customerBookings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Bookings',
              style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  FadeScaleRoute(
                    page: const ServiceListingScreen(category: 'Photography'),
                  ),
                );
              },
              child: Text(
                'Explore More',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (recentBookings.isEmpty)
          AppEmptyState(
            icon: Icons.event_busy_rounded,
            title: 'No Bookings Yet',
            subtitle: 'Browse and book top wedding photographers, venues, and caterers.',
            actionLabel: 'Explore Vendors',
            onAction: () {
              Navigator.of(context).push(
                FadeScaleRoute(
                  page: const ServiceListingScreen(category: 'Photography'),
                ),
              );
            },
          )
        else
          ...recentBookings.map((b) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: b.eventColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      b.eventIcon,
                      color: b.eventColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: b.eventColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                b.eventName,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: b.eventColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          b.vendorName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          b.package,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              b.total,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• ${b.date}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: b.isAccepted
                          ? AppColors.successLight
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      b.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: b.isAccepted
                            ? AppColors.success
                            : const Color(0xFFD97706),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _WeddingEvent {
  final String title;
  final String ceremonyType;
  final String date;
  final String time;
  final String venue;
  final String guests;
  final String daysLeft;
  final String hoursLeft;
  final String minLeft;
  final List<Color> gradientColors;
  final IconData icon;

  const _WeddingEvent({
    required this.title,
    required this.ceremonyType,
    required this.date,
    required this.time,
    required this.venue,
    required this.guests,
    required this.daysLeft,
    required this.hoursLeft,
    required this.minLeft,
    required this.gradientColors,
    required this.icon,
  });
}
