import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/api_provider/ad_api_provider.dart';
import '../../data/models/ad_plan_model.dart';
import '../../utils/utils.dart';

class VendorAdsScreen extends StatefulWidget {
  const VendorAdsScreen({super.key});

  @override
  State<VendorAdsScreen> createState() => _VendorAdsScreenState();
}

class _VendorAdsScreenState extends State<VendorAdsScreen> {
  final AdApiProvider _adApi = AdApiProvider();

  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _errorMsg;

  VendorMyAdModel _myAd = VendorMyAdModel();
  List<AdPlanModel> _adPlans = [];
  String? _selectedPlanId;
  String _selectedPaymentMethod = 'UPI (GPay / PhonePe / Paytm / BHIM)';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final results = await Future.wait([
        _adApi.getMyAd(),
        _adApi.getAdPlansList(),
      ]);

      final myAdRes = results[0] as dynamic;
      final plansRes = results[1] as dynamic;

      if (mounted) {
        setState(() {
          if (myAdRes.isSuccess == true && myAdRes.data != null) {
            _myAd = myAdRes.data as VendorMyAdModel;
          }
          if (plansRes.isSuccess == true && plansRes.data != null) {
            _adPlans = (plansRes.data as List<AdPlanModel>);
          }

          // Fallback demo plans if server list is empty
          if (_adPlans.isEmpty) {
            _adPlans = [
              AdPlanModel(
                id: '1_day_boost',
                title: '1 Day Featured Boost',
                duration: '1 Day',
                durationInDays: 1,
                price: 199,
                description: 'Showcase your business at top of homepage for 24 hours.',
              ),
              AdPlanModel(
                id: '3_days_spotlight',
                title: '3 Days Vendor Spotlight',
                duration: '3 Days',
                durationInDays: 3,
                price: 499,
                description: 'Get featured on home & category listings for 3 full days.',
              ),
              AdPlanModel(
                id: '1_week_platinum',
                title: '1 Week Ultimate Platinum Ad',
                duration: '1 Week',
                durationInDays: 7,
                price: 999,
                description: 'Maximum visibility across app for 7 consecutive days.',
              ),
            ];
          }

          if (_selectedPlanId == null && _adPlans.isNotEmpty) {
            // Default select the middle/popular plan or first
            _selectedPlanId = _adPlans.length > 1 ? _adPlans[1].id : _adPlans.first.id;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = 'Failed to load ad data: $e';
          _isLoading = false;
        });
      }
    }
  }

  AdPlanModel? get _selectedPlan {
    if (_selectedPlanId == null) return null;
    return _adPlans.firstWhere(
      (p) => p.id == _selectedPlanId,
      orElse: () => _adPlans.first,
    );
  }

  void _showCheckoutSheet() {
    final plan = _selectedPlan;
    if (plan == null) {
      Utils.showError('Please select an Ad plan first.');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activate Sponsored Ad',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        'Boost your vendor ranking and lead volume',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.darkGrey,
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
              const SizedBox(height: 16),

              // Summary Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          plan.title ?? 'Sponsored Ad',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          '₹${plan.planPrice}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Duration: ${plan.duration ?? "${plan.durationInDays ?? 1} Days"}',
                          style: const TextStyle(fontSize: 12, color: AppColors.darkGrey),
                        ),
                        const Text(
                          '18% GST Included',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkGrey),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Payable',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          '₹${plan.planPrice}',
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
                'Select Payment Mode',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...[
                ('UPI (GPay / PhonePe / Paytm / BHIM)', Icons.qr_code_2_rounded),
                ('Credit / Debit Card (Visa, Master, RuPay)', Icons.credit_card_rounded),
                ('Net Banking (All Major Indian Banks)', Icons.account_balance_rounded),
              ].map((m) {
                final isSelected = _selectedPaymentMethod == m.$1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      setSheetState(() => _selectedPaymentMethod = m.$1);
                      setState(() => _selectedPaymentMethod = m.$1);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.cream : AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.grey.withValues(alpha: 0.3),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(m.$2, size: 20, color: isSelected ? AppColors.primary : AppColors.darkGrey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              m.$1,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? AppColors.primary : AppColors.black,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Buy Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isPurchasing
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          await _handleAdPurchase(plan);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.rocket_launch_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Pay ₹${plan.planPrice} & Launch Ad',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAdPurchase(AdPlanModel plan) async {
    setState(() => _isPurchasing = true);
    Utils.showInfo('Processing Ad activation...');

    try {
      final res = await _adApi.buyAdPlan(plan.id ?? '');
      setState(() => _isPurchasing = false);

      if (res.isSuccess == true) {
        Utils.showSuccess(res.message ?? 'Ad activated successfully for ${plan.duration ?? "selected period"}!');
        await _loadData();
      } else {
        Utils.showError(res.message ?? res.error ?? 'Failed to activate ad. Please try again.');
      }
    } catch (e) {
      setState(() => _isPurchasing = false);
      Utils.showError('An error occurred during Ad purchase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        title: Text(
          'Sponsored Ads & Boost',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMsg != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMsg!,
                                style: const TextStyle(color: AppColors.error, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // 1. Current Active Ad Card
                    _buildActiveAdCard(),

                    const SizedBox(height: 24),

                    // 2. Section Header: Available Ad Plans
                    Row(
                      children: [
                        const Icon(Icons.bolt_rounded, color: Color(0xFFEAB308), size: 22),
                        const SizedBox(width: 6),
                        Text(
                          'Choose Your Ad Duration',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Get guaranteed top placement on user app homepage, search ranking & category banners.',
                      style: TextStyle(fontSize: 12.5, color: AppColors.darkGrey, height: 1.35),
                    ),
                    const SizedBox(height: 16),

                    // 3. Ad Plans List
                    ..._adPlans.map((plan) => _buildAdPlanCard(plan)),

                    const SizedBox(height: 20),

                    // 4. Why Sponsor Banner
                    _buildWhySponsorBanner(),

                    const SizedBox(height: 24),

                    // 5. Ad Purchase History (if any)
                    if (_myAd.history.isNotEmpty) ...[
                      _buildHistorySection(),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _isLoading
          ? null
          : Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isPurchasing ? null : _showCheckoutSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 1,
                    ),
                    child: _isPurchasing
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              ),
                              SizedBox(width: 10),
                              Text('Activating Ad...', style: TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.rocket_launch_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _myAd.isAdActive
                                    ? 'Extend / Boost Ad Duration'
                                    : 'Boost Profile with Ad (₹${_selectedPlan?.planPrice ?? 499})',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildActiveAdCard() {
    final isActive = _myAd.isAdActive && _myAd.activeAd != null;
    final ad = _myAd.activeAd;

    if (isActive && ad != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2C1810), Color(0xFF6B1D2F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAB308),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.workspace_premium_rounded, color: Colors.black, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'LIVE SPONSORED AD',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${ad.daysLeft}d Left',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              ad.title ?? 'Active Ad Boost',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Duration: ${ad.duration ?? "${ad.durationInDays ?? 3} Days"} • ₹${ad.price?.toInt() ?? 0}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF4ADE80), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your profile is currently featured at the top of client search & homepage.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Inactive Ad Teaser Card
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8DCCF)),
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.campaign_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No Active Ad Campaign',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      'Get 3x more bookings with a homepage spotlight',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGrey.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildBenefitRow(Icons.visibility_rounded, 'Top Homepage Banner', 'Showcase directly to active wedding planners'),
          const SizedBox(height: 8),
          _buildBenefitRow(Icons.trending_up_rounded, '3x Priority Inquiries', 'Appear above competitor vendor profiles'),
          const SizedBox(height: 8),
          _buildBenefitRow(Icons.verified_rounded, 'Sponsored Badge', 'Gold featured ribbon on search listings'),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: '$title: ',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
              children: [
                TextSpan(
                  text: subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdPlanCard(AdPlanModel plan) {
    final isSelected = _selectedPlanId == plan.id;
    final isPopular = (plan.durationInDays == 3) || (plan.title?.contains('Spotlight') == true);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _selectedPlanId = plan.id),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFFBF5) : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : const Color(0xFFE8DCCF),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: isSelected ? 8 : 4,
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
                  Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? AppColors.primary : AppColors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        plan.title ?? 'Ad Plan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? AppColors.primary : AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  if (isPopular)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAB308),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'POPULAR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(
                  plan.description ?? 'Boost your business visibility on Widoora.',
                  style: const TextStyle(fontSize: 12, color: AppColors.darkGrey),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Duration: ${plan.duration ?? "${plan.durationInDays ?? 1} Days"}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Text(
                      '₹${plan.planPrice}',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
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

  Widget _buildWhySponsorBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EDE4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.stars_rounded, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'How Sponsored Ads Work',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Once activated, your business profile gets pinned to the Featured Vendors carousel on the client app. You receive direct phone and WhatsApp inquiry alerts in real time.',
                  style: TextStyle(fontSize: 12, color: AppColors.darkGrey, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Past Ad Campaigns',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        ..._myAd.history.map((h) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        h.title ?? 'Ad Campaign',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${h.duration ?? ""} • ₹${h.price?.toInt() ?? 0}',
                        style: const TextStyle(fontSize: 11.5, color: AppColors.darkGrey),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      h.status ?? 'Completed',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.darkGrey),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
