import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_animations.dart';
import 'vendor_packages_screen.dart';
import 'vendor_portfolio_screen.dart';
import 'vendor_payouts_screen.dart';
import 'vendor_profile_screen.dart';

class VendorDashboardTab extends StatelessWidget {
  final void Function(int tabIndex)? onNavigateTab;

  const VendorDashboardTab({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Subtitle
          const Text(
            'Hello, Royal Click Studio 👑',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            "Here's your business overview",
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          // 4 Metric KPI Cards in a row
          Row(
            children: [
              _buildStatCard(
                title: "Today's Bookings",
                value: '3',
                accentColor: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                title: 'Total Bookings',
                value: '27',
                accentColor: AppColors.goldDark,
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                title: 'Total Enquiries',
                value: '15',
                accentColor: AppColors.primaryDark,
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                title: 'Profile Views',
                value: '245',
                accentColor: AppColors.goldDark,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Earnings Summary Card with Visual Mini Chart
          _buildEarningsCard(context),

          const SizedBox(height: 20),

          // Quick Actions 8-Icon Grid
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickActionsGrid(context),

          const SizedBox(height: 20),

          // Recent Enquiries Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Client Enquiries',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              TextButton(
                onPressed: () => onNavigateTab?.call(2), // go to enquiries
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          _buildRecentEnquiryCard(
            clientName: 'Simran & Aman',
            event: 'Wedding & Reception (2 Days)',
            budget: '₹75,000',
            date: '18 Dec 2026',
            venue: 'The Grand Palace, Chandigarh',
            timeAgo: '10m ago',
          ),

          const SizedBox(height: 10),

          _buildRecentEnquiryCard(
            clientName: 'Pooja & Rohan',
            event: 'Pre-Wedding Shoot + Teaser',
            budget: '₹45,000',
            date: '04 Nov 2026',
            venue: 'Kasauli Pine Hills',
            timeAgo: '1h ago',
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color accentColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.grey.withValues(alpha: 0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: AppColors.darkGrey,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'This Month Earnings',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGrey,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_upward_rounded,
                        size: 11, color: AppColors.success),
                    SizedBox(width: 2),
                    Text(
                      '+28.5%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '₹ 1,25,000',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    'vs ₹97,200 last month',
                    style: TextStyle(fontSize: 10, color: AppColors.grey),
                  ),
                ],
              ),
              SizedBox(
                width: 120,
                height: 40,
                child: CustomPaint(
                  painter: _EarningsSparklinePainter(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      (
        Icons.person_outline_rounded,
        'My Profile',
        () => Navigator.of(context).push(
              FadeScaleRoute(page: const VendorProfileScreen()),
            )
      ),
      (
        Icons.inventory_2_outlined,
        'Packages',
        () => Navigator.of(context).push(
              FadeScaleRoute(page: const VendorPackagesScreen()),
            )
      ),
      (
        Icons.calendar_month_outlined,
        'Bookings',
        () => onNavigateTab?.call(1)
      ),
      (
        Icons.chat_bubble_outline_rounded,
        'Enquiries',
        () => onNavigateTab?.call(2)
      ),
      (
        Icons.access_time_rounded,
        'Availability',
        () => _showAvailabilitySheet(context),
      ),
      (
        Icons.photo_library_outlined,
        'Portfolio',
        () => Navigator.of(context).push(
              FadeScaleRoute(page: const VendorPortfolioScreen()),
            )
      ),
      (
        Icons.star_outline_rounded,
        'Reviews',
        () => _showReviewsSheet(context),
      ),
      (
        Icons.account_balance_wallet_outlined,
        'Payouts',
        () => Navigator.of(context).push(
              FadeScaleRoute(page: const VendorPayoutsScreen()),
            )
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 14,
        childAspectRatio: 0.86,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final item = actions[index];
        return GestureDetector(
          onTap: item.$3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.grey.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  item.$1,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.$2,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentEnquiryCard({
    required String clientName,
    required String event,
    required String budget,
    required String date,
    required String venue,
    required String timeAgo,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_rounded,
                        color: AppColors.primary, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clientName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        event,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                budget,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 12, color: AppColors.grey),
              const SizedBox(width: 4),
              Text(
                date,
                style: const TextStyle(fontSize: 11, color: AppColors.darkGrey),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.location_on_outlined,
                  size: 12, color: AppColors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  venue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.darkGrey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAvailabilitySheet(BuildContext context) {
    final bookedDates = [
      ('18 Dec 2026', 'Aman & Simran Wedding', 'Booked Full Day'),
      ('04 Nov 2026', 'Pooja & Rohan Engagement', 'Booked Evening'),
      ('22 Jan 2027', 'Kavita & Nitin Sangeet', 'Booked Full Day'),
      ('14 Feb 2027', 'Valentine Special Wedding', 'Slot Reserved'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Calendar & Availability',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Accepting 2026-2027',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage your booked dates and block unavailable slots',
              style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
            const Divider(height: 24),
            const Text(
              'Upcoming Reserved Dates',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: bookedDates.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final b = bookedDates[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.event_busy_rounded,
                              color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.$1,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.black,
                                ),
                              ),
                              Text(
                                b.$2,
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.darkGrey),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warningLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            b.$3,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Date blocked on your public calendar!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                icon: const Icon(Icons.block_rounded, size: 16),
                label: const Text('Block New Date / Vacation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewsSheet(BuildContext context) {
    final reviews = [
      (
        'Simran & Rahul',
        '28 Dec 2025',
        5,
        'Royal Click Studio captured our wedding day with so much emotion and perfection! The drone shots were unbelievable.',
      ),
      (
        'Pooja & Aman',
        '14 Nov 2025',
        5,
        'Very punctual, professional crew and premium hardbound album quality. Highly recommended for couples in Chandigarh!',
      ),
      (
        'Kavita & Nitin',
        '02 Oct 2025',
        4.8,
        'Loved the cinematic teaser video. Our families were overjoyed watching the highlights!',
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Client Reviews & Ratings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      '4.9 Rating ★ (84 Verified Reviews)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.goldDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: reviews.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final r = reviews[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              r.$1,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.black,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: AppColors.gold, size: 16),
                                const SizedBox(width: 2),
                                Text(
                                  '${r.$3}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          r.$2,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          r.$4,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.darkGrey,
                            height: 1.4,
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
      ),
    );
  }
}

// Sparkline Painter for Earnings Graph
class _EarningsSparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF1E88E5)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1E88E5).withValues(alpha: 0.25),
          const Color(0xFF1E88E5).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final points = [
      Offset(0, size.height * 0.75),
      Offset(size.width * 0.15, size.height * 0.70),
      Offset(size.width * 0.30, size.height * 0.40),
      Offset(size.width * 0.45, size.height * 0.55),
      Offset(size.width * 0.60, size.height * 0.30),
      Offset(size.width * 0.75, size.height * 0.45),
      Offset(size.width * 0.90, size.height * 0.15),
      Offset(size.width, size.height * 0.25),
    ];

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      final cy = (p0.dy + p1.dy) / 2;
      path.quadraticBezierTo(p0.dx, p0.dy, cx, cy);
    }
    path.lineTo(points.last.dx, points.last.dy);

    // Draw line
    canvas.drawPath(path, linePaint);

    // Draw fill area
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fillPath, fillPaint);

    // Draw end dot
    final dotPaint = Paint()..color = const Color(0xFF1E88E5);
    canvas.drawCircle(points.last, 4, dotPaint);
  }

  @override
  bool shouldRepaint(_EarningsSparklinePainter oldDelegate) => false;
}
