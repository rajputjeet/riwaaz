import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/app_animations.dart';
import '../shell/main_shell.dart';
import '../service_listing/service_listing_screen.dart';
import '../wedding_details/wedding_details_screen.dart';

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

  static const List<_WeddingEvent> _createdEvents = [
    _WeddingEvent(
      title: 'TechCorp Annual Gala 2026',
      ceremonyType: 'Office Party',
      date: '15 Jan 2027',
      time: '5:00 PM',
      venue: 'JW Marriott Grand Ballroom, Chandigarh',
      guests: '450 Team Members',
      daysLeft: '142',
      hoursLeft: '18',
      minLeft: '30',
      gradientColors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
      icon: Icons.business_center_rounded,
    ),
    _WeddingEvent(
      title: 'Reyansh 5th Birthday Bash',
      ceremonyType: 'Birthday Party',
      date: '10 Jan 2027',
      time: '4:30 PM',
      venue: 'Forest Hill Resort Clubhouse, Mohali',
      guests: '120 Guests',
      daysLeft: '137',
      hoursLeft: '14',
      minLeft: '15',
      gradientColors: [Color(0xFF7C2D12), Color(0xFFD97706)],
      icon: Icons.cake_rounded,
    ),
    _WeddingEvent(
      title: 'Neon Music & Cocktail Night',
      ceremonyType: 'Private Party',
      date: '31 Dec 2026',
      time: '8:30 PM',
      venue: 'The Lalit Sky Lounge, Chandigarh',
      guests: '200 Guests',
      daysLeft: '127',
      hoursLeft: '21',
      minLeft: '00',
      gradientColors: [Color(0xFF3B0764), Color(0xFF7E22CE)],
      icon: Icons.nightlife_rounded,
    ),
    _WeddingEvent(
      title: 'Grand Royal Vivah & Reception',
      ceremonyType: 'Wedding Vivah',
      date: '28 Dec 2026',
      time: '7:00 PM',
      venue: 'The Oberoi Sukhvilas, New Chandigarh',
      guests: '550 Guests',
      daysLeft: '124',
      hoursLeft: '16',
      minLeft: '42',
      gradientColors: [Color(0xFF5E1B33), Color(0xFF380C1D)],
      icon: Icons.celebration_rounded,
    ),
    _WeddingEvent(
      title: 'Silver Jubilee Anniversary Gala',
      ceremonyType: 'Anniversary',
      date: '05 Jan 2027',
      time: '7:30 PM',
      venue: 'Noorani Lawns, Zirakpur',
      guests: '280 Guests',
      daysLeft: '132',
      hoursLeft: '19',
      minLeft: '20',
      gradientColors: [Color(0xFF134E4A), Color(0xFF0D9488)],
      icon: Icons.favorite_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _eventsPageController = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_eventsPageController.hasClients) return;
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
    _autoScrollTimer?.cancel();
    _eventsPageController.dispose();
    super.dispose();
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  _buildCreatedEventsSection(),
                  const SizedBox(height: 18),
                  _buildBookingsSection(),
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
                    'Hello Simran',
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                  duration: Duration(seconds: 1),
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

  Widget _buildCreatedEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
              onTap: () {
                Navigator.of(context).push(
                  FadeScaleRoute(page: const WeddingDetailsScreen()),
                );
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
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
        ),
        const SizedBox(height: 10),
        Row(
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
        ),
      ],
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
        width: double.infinity,
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
    final recentBookings = [
      {
        'name': 'Grand Stage Crafters & AV Tech',
        'event': 'TechCorp Office Gala',
        'eventType': 'Office Party',
        'service': 'Corporate 4K LED & Audio Setup',
        'date': '15 Jan 2027',
        'status': 'Confirmed',
        'price': '₹1,20,000',
        'paid': '₹60,000 Paid',
        'icon': Icons.business_center_rounded,
        'color': const Color(0xFF1E3A8A),
      },
      {
        'name': 'Rainbow Balloon & Themes',
        'event': 'Reyansh 5th Birthday',
        'eventType': 'Birthday Party',
        'service': 'Kids Carnival Balloon Stage',
        'date': '10 Jan 2027',
        'status': 'Confirmed',
        'price': '₹35,000',
        'paid': '₹35,000 Paid (Full)',
        'icon': Icons.cake_rounded,
        'color': const Color(0xFFD97706),
      },
      {
        'name': 'DJ Sandy Beats & Sound',
        'event': 'Neon Cocktail Bash',
        'eventType': 'Private Party',
        'service': 'Club Sound & Laser FX',
        'date': '31 Dec 2026',
        'status': 'Confirmed',
        'price': '₹45,000',
        'paid': '₹20,000 Paid',
        'icon': Icons.nightlife_rounded,
        'color': const Color(0xFF7E22CE),
      },
      {
        'name': 'Royal Click Studio',
        'event': 'Grand Royal Wedding',
        'eventType': 'Wedding',
        'service': 'Photography & 4K Cinema',
        'date': '28 Dec 2026',
        'status': 'Confirmed',
        'price': '₹75,000',
        'paid': '₹25,000 Paid',
        'icon': Icons.camera_alt_rounded,
        'color': const Color(0xFF8B1A2E),
      },
    ];

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
                    color: (b['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    b['icon'] as IconData,
                    color: b['color'] as Color,
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
                              color: (b['color'] as Color).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              b['event'] as String,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: b['color'] as Color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        b['name'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        b['service'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            b['paid'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${b['date']}',
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
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Confirmed',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
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
