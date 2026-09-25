import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class VendorSubscriptionPlanScreen extends StatefulWidget {
  final String currentPlanId;

  const VendorSubscriptionPlanScreen({
    super.key,
    this.currentPlanId = '6_months',
  });

  @override
  State<VendorSubscriptionPlanScreen> createState() =>
      _VendorSubscriptionPlanScreenState();
}

class _VendorSubscriptionPlanScreenState
    extends State<VendorSubscriptionPlanScreen> {
  late String _activePlanId;
  String _selectedPaymentMethod = 'UPI';

  final List<Map<String, dynamic>> _plans = [
    {
      'id': '3_months',
      'name': '3 Months Plan',
      'duration': '3 Months',
      'months': 3,
      'price': 2999,
      'monthlyRate': 1000,
      'badge': 'STARTER',
      'tagline': 'Quarterly partner access to start receiving leads',
      'color': const Color(0xFF5A6270),
      'icon': Icons.calendar_today_rounded,
      'isPopular': false,
      'features': [
        'Verified Vendor Profile badge for 3 months',
        '25 Verified Client Leads / month',
        'Direct WhatsApp & Call inquiries',
        'Upload up to 15 Portfolio photos',
        'Standard category search ranking',
        'Real-time inquiry dashboard & SMS alerts',
        '5% platform booking fee',
      ],
      'highlight': '25 Leads / Month',
    },
    {
      'id': '6_months',
      'name': '6 Months Plan',
      'duration': '6 Months',
      'months': 6,
      'price': 4999,
      'monthlyRate': 833,
      'badge': 'MOST POPULAR',
      'savings': 'SAVE 15%',
      'tagline': 'High-growth package for wedding season',
      'color': AppColors.primary,
      'icon': Icons.stars_rounded,
      'isPopular': true,
      'features': [
        'Verified Partner Badge with Priority Star',
        '60 High-Intent Client Leads / month',
        'Priority Search & Category Placement',
        'Unlimited Portfolio photos & 4K videos',
        'Featured in "Top Recommended Vendors"',
        'Direct customer quotation generator',
        'Dedicated WhatsApp account manager',
        'Low 2% platform booking fee',
      ],
      'highlight': '60 Leads / Month + Priority',
    },
    {
      'id': '12_months',
      'name': '12 Months Plan',
      'duration': '12 Months (1 Year)',
      'months': 12,
      'price': 8999,
      'monthlyRate': 749,
      'badge': 'BEST VALUE',
      'savings': 'SAVE 25%',
      'tagline': 'Full year dominance & maximum client bookings',
      'color': const Color(0xFF8B1A2E),
      'icon': Icons.diamond_rounded,
      'isPopular': false,
      'features': [
        'Annual Royal Verified Partner Badge',
        'Unlimited Direct Bride & Groom Leads',
        'Guaranteed Top 3 City Banner Ranking',
        'Social Media Spotlight on Riwaaz Instagram',
        '0% Commission on all client bookings',
        'Instant Priority SMS & Push lead alerts',
        'Personalized brand promotional video',
        '24/7 Priority VIP Concierge service',
      ],
      'highlight': 'Unlimited Leads + 0% Commission',
    },
  ];

  @override
  void initState() {
    super.initState();
    _activePlanId = widget.currentPlanId;
  }

  void _showCheckoutSheet(Map<String, dynamic> plan) {
    final price = plan['price'] as int;
    final isCurrent = plan['id'] == _activePlanId;
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
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
                  width: 44,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCurrent ? 'Renew Membership' : 'Activate Membership',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${plan['name']} • ${plan['duration']}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, color: AppColors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Order Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${plan['name']} (${plan['duration']})',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          '₹$price',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Monthly Equivalent',
                          style: TextStyle(fontSize: 12, color: AppColors.grey),
                        ),
                        Text(
                          '₹${plan['monthlyRate']}/month',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'GST (18% Included)',
                          style: TextStyle(fontSize: 12, color: AppColors.grey),
                        ),
                        Text(
                          '₹0 Extra',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Payable Amount',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          '₹$price',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Payment Method Picker
              const Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPaymentChip(setSheetState, 'UPI', Icons.qr_code_rounded),
                  const SizedBox(width: 8),
                  _buildPaymentChip(setSheetState, 'Card', Icons.credit_card_rounded),
                  const SizedBox(width: 8),
                  _buildPaymentChip(setSheetState, 'NetBanking', Icons.account_balance_rounded),
                ],
              ),

              const SizedBox(height: 20),

              // Pay CTA Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : () async {
                          final nav = Navigator.of(ctx);
                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          setSheetState(() => isProcessing = true);
                          await Future.delayed(const Duration(milliseconds: 900));
                          if (!mounted) return;

                          setState(() {
                            _activePlanId = plan['id'] as String;
                          });
                          nav.pop();

                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Plan Activated! You are now on the ${plan['name']}.',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isProcessing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Pay ₹$price & Activate',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 10),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.shield_outlined, size: 14, color: AppColors.grey),
                    SizedBox(width: 4),
                    Text(
                      '256-Bit SSL Encrypted • Powered by Riwaaz Pay',
                      style: TextStyle(fontSize: 11, color: AppColors.grey),
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

  Widget _buildPaymentChip(
    StateSetter setSheetState,
    String method,
    IconData icon,
  ) {
    final isSelected = _selectedPaymentMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setSheetState(() => _selectedPaymentMethod = method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : const Color(0xFFE2D6C7),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.darkGrey,
              ),
              const SizedBox(width: 6),
              Text(
                method,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.primary : AppColors.darkGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activePlan = _plans.firstWhere(
      (p) => p['id'] == _activePlanId,
      orElse: () => _plans[1],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Vendor Membership Plans',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Active Membership Card
            _buildCurrentPlanBanner(activePlan),

            const SizedBox(height: 18),

            // Section Heading
            const Text(
              'Choose Your Plan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select from 3 Month, 6 Month, or 12 Month partnership plans',
              style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
            const SizedBox(height: 14),

            // 3 Plan Cards (3 Months, 6 Months, 12 Months)
            ..._plans.map((plan) {
              final isCurrent = plan['id'] == _activePlanId;
              final isPopular = plan['isPopular'] == true;
              final savings = plan['savings'] as String?;
              final price = plan['price'] as int;
              final monthlyEq = plan['monthlyRate'] as int;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isCurrent
                        ? AppColors.primary
                        : isPopular
                            ? AppColors.primary.withValues(alpha: 0.35)
                            : AppColors.grey.withValues(alpha: 0.2),
                    width: isCurrent ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isCurrent
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Ribbon for Current Plan or Popular / Best Value
                    if (isCurrent)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded,
                                size: 14, color: Colors.white),
                            SizedBox(width: 5),
                            Text(
                              'YOUR CURRENT ACTIVE PLAN',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (isPopular)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star_rounded,
                                size: 14, color: AppColors.cream),
                            SizedBox(width: 5),
                            Text(
                              'MOST POPULAR CHOICE • SAVE 15%',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.cream,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (savings != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        decoration: const BoxDecoration(
                          color: Color(0xFF8B1A2E),
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.diamond_rounded,
                                size: 14, color: AppColors.cream),
                            const SizedBox(width: 5),
                            Text(
                              'BEST VALUE • $savings ON ANNUAL',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.cream,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Icon, Name, Tagline, Highlight
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (plan['color'] as Color)
                                      .withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  plan['icon'] as IconData,
                                  color: plan['color'] as Color,
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
                                        Text(
                                          plan['name'] as String,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: (plan['color'] as Color)
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            plan['badge'] as String,
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: plan['color'] as Color,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      plan['tagline'] as String,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.darkGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Price Row
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.offWhite,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '₹$price',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '/ ${plan['duration']}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.darkGrey,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E7D32)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '₹$monthlyEq/mo',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Features list
                          ...((plan['features'] as List<String>).map((feat) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 7),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2, right: 8),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.success,
                                      size: 15,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      feat,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.black,
                                        fontWeight: FontWeight.w500,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })),

                          const SizedBox(height: 12),

                          // Action CTA Button
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () => _showCheckoutSheet(plan),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCurrent
                                    ? AppColors.white
                                    : AppColors.primary,
                                foregroundColor: isCurrent
                                    ? AppColors.primary
                                    : AppColors.white,
                                elevation: 0,
                                side: isCurrent
                                    ? const BorderSide(
                                        color: AppColors.primary, width: 1.5)
                                    : BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                isCurrent
                                    ? 'Renew ${plan['name']}'
                                    : 'Select ${plan['name']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 10),

            // Plan Comparison Table Card
            _buildComparisonCard(),

            const SizedBox(height: 18),

            // Plan FAQ & Assurance Card
            _buildFaqCard(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlanBanner(Map<String, dynamic> activePlan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B1A2E), Color(0xFF6A1021)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.verified_rounded,
                        color: AppColors.cream, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'ACTIVE MEMBERSHIP',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cream,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '84 Days Left',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${activePlan['name']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.stars_rounded, color: AppColors.gold, size: 20),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Active Partner • Renews on Dec 18, 2026',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.cream,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _StatMini(label: 'Monthly Leads', value: '60 Leads'),
                _StatMini(label: 'Platform Fee', value: '2% Only'),
                _StatMini(label: 'Search Rank', value: 'Priority'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.compare_arrows_rounded,
                  color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Plans Comparison',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildComparisonRow(
            'Validity',
            '3 Months',
            '6 Months ⭐',
            '12 Months 💎',
            isHeader: true,
          ),
          _buildComparisonRow(
            'Price (Total)',
            '₹2,999',
            '₹4,999',
            '₹8,999',
          ),
          _buildComparisonRow(
            'Monthly Rate',
            '₹1,000/mo',
            '₹833/mo',
            '₹749/mo',
          ),
          _buildComparisonRow(
            'Client Leads / Mo',
            '25 Leads',
            '60 Leads',
            'Unlimited',
          ),
          _buildComparisonRow(
            'Search Visibility',
            'Standard',
            'Priority',
            'Top 3 Guaranteed',
          ),
          _buildComparisonRow(
            'Platform Fee',
            '5%',
            '2%',
            '0% Commission',
          ),
          _buildComparisonRow(
            'Account Manager',
            'In-App',
            'Dedicated WA',
            '24/7 VIP Concierge',
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    String feature,
    String col3,
    String col6,
    String col12, {
    bool isHeader = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isHeader ? FontWeight.w800 : FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              col3,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.darkGrey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              col6,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              col12,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF8B1A2E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.help_outline_rounded,
                  color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Membership FAQs',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          _FaqItem(
            question: 'Can I switch from 3 Months to 6 or 12 Months anytime?',
            answer:
                'Yes! You can upgrade your plan anytime. Any remaining days on your current active plan are automatically added to your new duration.',
          ),
          Divider(height: 16),
          _FaqItem(
            question: 'How do client leads reach my studio?',
            answer:
                'Verified inquiries are delivered instantly to your vendor dashboard, SMS, and WhatsApp number when couples look for vendors in your city.',
          ),
          Divider(height: 16),
          _FaqItem(
            question: 'What is the 0% commission guarantee on 12 Months?',
            answer:
                'On our 12 Months Annual plan, Riwaaz takes zero commission on your client contracts and booking fees.',
          ),
        ],
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final String value;

  const _StatMini({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: AppColors.cream,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          answer,
          style: const TextStyle(
            fontSize: 11.5,
            color: AppColors.darkGrey,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
