import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_animations.dart';
import '../../utils/helper/storage_helper.dart';
import 'vendor_packages_screen.dart';
import 'vendor_portfolio_screen.dart';
import 'vendor_profile_screen.dart';
import 'vendor_subscription_plan_screen.dart';
import '../../core/services/booking_service.dart';

class VendorDashboardTab extends StatelessWidget {
  final void Function(int tabIndex)? onNavigateTab;

  const VendorDashboardTab({super.key, this.onNavigateTab});

  /// Reads business/owner name from storage for the greeting
  String _vendorDisplayName() {
    final name = StorageHelper().getUserName() ?? '';
    return name.trim().isEmpty ? 'Partner' : name.trim();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppBookingService.instance,
      builder: (context, _) {
        final bookingService = AppBookingService.instance;
        final pendingCount = bookingService.pendingCount;
        final confirmedCount = bookingService.confirmedCount;
        final completedCount = bookingService.completedCount;
        final totalCount = bookingService.totalCount;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting & Subtitle
              Text(
                'Hello, ${_vendorDisplayName()} 👑',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                "Here's your real-time business & bookings overview",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 16),

              // Pending Requests Alert Banner (if any)
              if (pendingCount > 0) ...[
                InkWell(
                  onTap: () => onNavigateTab?.call(1),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD97706).withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active_rounded,
                            color: Color(0xFFD97706), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$pendingCount New Booking Request${pendingCount > 1 ? 's' : ''} Awaiting Acceptance',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Tap to review and accept/decline now',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD97706),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Review',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // 4 Metric KPI Cards in a row
              Row(
                children: [
                  _buildStatCard(
                    title: 'Pending',
                    value: '$pendingCount',
                    accentColor: const Color(0xFFD97706),
                  ),
                  const SizedBox(width: 8),
                  _buildStatCard(
                    title: 'Upcoming',
                    value: '$confirmedCount',
                    accentColor: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  _buildStatCard(
                    title: 'Completed',
                    value: '$completedCount',
                    accentColor: AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  _buildStatCard(
                    title: 'Total Bookings',
                    value: '$totalCount',
                    accentColor: AppColors.goldDark,
                  ),
                ],
              ),

              const SizedBox(height: 16),

          // Vendor Membership Status Banner (3M, 6M, 1Y)
          _buildMembershipBanner(context),

          const SizedBox(height: 14),

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

          // Recent Booking Requests & Clients Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Booking Requests & Clients',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              TextButton(
                onPressed: () => onNavigateTab?.call(1), // go to bookings
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

          ...bookingService.bookings.take(3).map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildRecentEnquiryCard(
                    clientName: b.clientName,
                    event: '${b.eventType} • ${b.package}',
                    budget: b.total,
                    date: b.date,
                    venue: b.venue,
                    timeAgo: b.status,
                  ),
                ),
              ),

          const SizedBox(height: 20),
            ],
          ),
        );
      },
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

  Widget _buildMembershipBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C1810), Color(0xFF4A1E18)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.gold,
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
                    const Text(
                      '6 Months Plan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF81C784),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Active Membership • 84 Days Remaining',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.cream,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              FadeScaleRoute(page: const VendorSubscriptionPlanScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.black,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Plans',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
            ),
          ),
        ],
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
        Icons.card_membership_rounded,
        'Plans',
        () => Navigator.of(context).push(
              FadeScaleRoute(page: const VendorSubscriptionPlanScreen()),
            )
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
        Icons.handshake_outlined,
        'Settlements',
        () => _showDirectSettlementSheet(context),
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      event,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
              const SizedBox(width: 10),
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
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: timeAgo == 'Confirmed' || timeAgo == 'Accepted'
                      ? AppColors.successLight
                      : timeAgo == 'Pending'
                          ? const Color(0xFFFEF3C7)
                          : AppColors.offWhite,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: timeAgo == 'Confirmed' || timeAgo == 'Accepted'
                        ? AppColors.success
                        : timeAgo == 'Pending'
                            ? const Color(0xFFD97706)
                            : AppColors.darkGrey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDirectSettlementSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.handshake_rounded,
                      color: AppColors.success, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Direct In-Person Settlement',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        'Zero platform commissions or bank payout delays',
                        style: TextStyle(fontSize: 12, color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.grey.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Direct Settlement Policy:',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Direct Transactions: Customers pay you directly in cash, UPI, or bank transfer on event day.',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGrey,
                        height: 1.4),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '• No Bank Payout Delays: Riwaaz does not hold escrow or bank payouts. 100% of the client amount is yours.',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGrey,
                        height: 1.4),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '• Flat Membership Model: You keep every rupee you earn from clients.',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGrey,
                        height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Understood'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
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
