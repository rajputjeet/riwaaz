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

class _DashboardBodyState extends State<DashboardBody>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _progressAnim = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
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
                  _buildWeddingCard(),
                  const SizedBox(height: 20),
                  _buildBookingsSection(),
                  const SizedBox(height: 20),
                  _buildProgressSection(),
                  const SizedBox(height: 20),
                  _buildTasksSection(),
                  const SizedBox(height: 20),
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
                'Plan your dream wedding',
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

  Widget _buildWeddingCard() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          FadeScaleRoute(page: const WeddingDetailsScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Your Wedding',
                        style: TextStyle(
                          color: AppColors.goldLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.edit_outlined,
                        color: AppColors.goldLight, size: 18),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        color: AppColors.cream, size: 16),
                    SizedBox(width: 6),
                    Text(
                      '28 December 2026',
                      style: TextStyle(
                        color: AppColors.cream,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        color: AppColors.cream, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Mohali, Punjab',
                      style: TextStyle(
                        color: AppColors.cream,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Countdown
                Row(
                  children: [
                    _buildCountdownBox('124', 'Days'),
                    const SizedBox(width: 8),
                    _buildCountdownBox('16', 'Hrs'),
                    const SizedBox(width: 8),
                    _buildCountdownBox('42', 'Min'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.cream,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Wedding Planning Progress',
                style: AppTextStyles.headlineSmall.copyWith(fontSize: 13),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _progressAnim,
                builder: (context, child) => Text(
                  '${(42 * _progressAnim.value).toInt()}%',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (context, child) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0.42 * _progressAnim.value,
                backgroundColor: AppColors.lightGrey,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Complete',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Your Planning Tasks',
              style: AppTextStyles.headlineSmall,
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  FadeScaleRoute(
                    page: const ServiceListingScreen(category: 'Photography'),
                  ),
                );
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._buildTaskList(),
      ],
    );
  }

  List<Widget> _buildTaskList() {
    final tasks = [
      (
        Icons.location_city_rounded,
        AppColors.primary,
        'Venue',
        'Completed',
        true
      ),
      (
        Icons.camera_alt_rounded,
        const Color(0xFF1565C0),
        'Photographer',
        'In Progress',
        false
      ),
      (
        Icons.restaurant_rounded,
        const Color(0xFF2E7D32),
        'Catering',
        'Pending',
        false
      ),
      (
        Icons.local_florist_rounded,
        const Color(0xFFE65100),
        'Decoration',
        'Pending',
        false
      ),
      (
        Icons.directions_car_rounded,
        const Color(0xFF4527A0),
        'Wedding Car',
        'Completed',
        true
      ),
      (
        Icons.face_rounded,
        const Color(0xFFAD1457),
        'Makeup Artist',
        'Pending',
        false
      ),
    ];

    return tasks
        .map(
          (entry) => _buildTaskItem(
            entry.$1,
            entry.$2,
            entry.$3,
            entry.$4,
            entry.$5,
          ),
        )
        .toList();
  }

  Widget _buildTaskItem(
    IconData icon,
    Color color,
    String title,
    String status,
    bool done,
  ) {
    Color statusColor;
    Color statusBg;
    if (done) {
      statusColor = AppColors.success;
      statusBg = AppColors.successLight;
    } else if (status == 'In Progress') {
      statusColor = AppColors.warning;
      statusBg = AppColors.warningLight;
    } else {
      statusColor = AppColors.grey;
      statusBg = AppColors.lightGrey;
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          FadeScaleRoute(
            page: ServiceListingScreen(category: title),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: done
                ? AppColors.success.withValues(alpha: 0.2)
                : const Color(0xFFEEE8DF),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.grey.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsSection() {
    final recentBookings = [
      {
        'name': 'Royal Click Studio',
        'service': 'Photography & 4K Cinema',
        'date': '28 Dec 2026',
        'status': 'Confirmed',
        'price': '₹75,000',
        'paid': '₹25,000 Paid',
        'icon': Icons.camera_alt_rounded,
        'color': const Color(0xFF8B1A2E),
      },
      {
        'name': 'Royal Mandap & Floral Decor',
        'service': 'Grand Floral Mandap',
        'date': '28 Dec 2026',
        'status': 'Confirmed',
        'price': '₹1,50,000',
        'paid': '₹50,000 Paid',
        'icon': Icons.local_florist_rounded,
        'color': const Color(0xFF2E7D32),
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
