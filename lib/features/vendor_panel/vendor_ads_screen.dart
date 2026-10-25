import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/api_provider/ad_api_provider.dart';
import '../../data/models/ad_plan_model.dart';
import '../../utils/utils.dart';
import '../vendor_registration/vendor_subscription_checkout_flow.dart';
import 'ad_banner_upload_dialog.dart';

class VendorAdsScreen extends StatefulWidget {
  const VendorAdsScreen({super.key});

  @override
  State<VendorAdsScreen> createState() => _VendorAdsScreenState();
}

class _VendorAdsScreenState extends State<VendorAdsScreen> {
  final AdApiProvider _adApi = AdApiProvider();

  bool _isLoading = true;
  bool _campaignStatusLoaded = false;
  String? _errorMsg;

  VendorMyAdModel _myAd = VendorMyAdModel();
  List<AdPlanModel> _adPlans = [];
  String? _selectedPlanId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _campaignStatusLoaded = false;
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
            _campaignStatusLoaded = true;
          } else {
            _errorMsg =
                'Unable to check your current campaign. Please refresh to try again.';
          }
          if (plansRes.isSuccess == true && plansRes.data != null) {
            _adPlans = (plansRes.data as List<AdPlanModel>);
          }
          // Coupons are fetched natively inside VendorSubscriptionCouponScreen

          // Fallback demo plans if server list is empty
          if (_adPlans.isEmpty) {
            _adPlans = [
              AdPlanModel(
                id: '1_day_boost',
                title: '1 Day Featured Boost',
                duration: '1 Day',
                durationInDays: 1,
                price: 199,
                description:
                    'Showcase your business at top of homepage for 24 hours.',
              ),
              AdPlanModel(
                id: '3_days_spotlight',
                title: '3 Days Vendor Spotlight',
                duration: '3 Days',
                durationInDays: 3,
                price: 499,
                description:
                    'Get featured on home & category listings for 3 full days.',
              ),
              AdPlanModel(
                id: '1_week_platinum',
                title: '1 Week Ultimate Platinum Ad',
                duration: '1 Week',
                durationInDays: 7,
                price: 999,
                description:
                    'Maximum visibility across app for 7 consecutive days.',
              ),
            ];
          }

          if (_selectedPlanId == null && _adPlans.isNotEmpty) {
            // Default select the middle/popular plan or first
            _selectedPlanId = _adPlans.length > 1
                ? _adPlans[1].id
                : _adPlans.first.id;
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

  Future<void> _openAdCheckoutFlow([AdPlanModel? targetPlan]) async {
    if (!_campaignStatusLoaded || _myAd.isAdActive) {
      Utils.showError(
        _myAd.isAdActive
            ? 'You can buy another ad plan once your current campaign is inactive.'
            : 'Please refresh to check your current campaign before buying an ad plan.',
      );
      return;
    }
    final plan =
        targetPlan ??
        _selectedPlan ??
        (_adPlans.isNotEmpty ? _adPlans.first : null);
    if (plan == null) {
      Utils.showError('Please select an Ad plan first.');
      return;
    }

    final planMap = {
      'id': plan.id ?? '',
      'serverPlanId': plan.id ?? '',
      'name': plan.title ?? 'Sponsored Ad Boost',
      'duration': plan.duration ?? '${plan.durationInDays ?? 30} Days',
      'price': plan.planPrice,
      'isAd': true,
    };

    final paid = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => VendorSubscriptionCouponScreen(
          plan: planMap,
          isAd: true,
          onPay: (paymentMethod, couponCode) async {
            // Recheck immediately before purchase in case another device activated an ad.
            final currentAd = await _adApi.getMyAd();
            if (!mounted) return false;
            if (currentAd.isSuccess != true || currentAd.data == null) {
              Utils.showError(
                'Unable to check your current campaign. Please try again.',
              );
              return false;
            }
            setState(() => _myAd = currentAd.data!);
            if (_myAd.isAdActive) {
              Utils.showError(
                'You can buy another ad plan once your current campaign is inactive.',
              );
              return false;
            }
            final res = await _adApi.buyAdPlan(
              plan.id ?? '',
              couponCode: couponCode,
              paymentMethod: paymentMethod,
              transactionId: paymentMethod == 'Free' ? 'FREE-COUPON' : null,
            );
            if (!mounted) return false;
            if (res.isSuccess == true) {
              Utils.showSuccess(res.message ?? 'Ad activated successfully!');
              return true;
            } else {
              Utils.showError(
                res.message ?? res.error ?? 'Failed to activate ad.',
              );
              return false;
            }
          },
        ),
      ),
    );

    if (paid == true && mounted) {
      await _loadData();
      // Mandatory popup to upload the homepage ad banner
      await _openBannerUploadDialog(plan);
      await _loadData();
    }
  }

  Future<void> _openBannerUploadDialog([AdPlanModel? plan]) async {
    final targetPlan = plan ?? _selectedPlan;
    await AdBannerUploadDialog.show(
      context,
      adPlan: targetPlan,
      vendorName: targetPlan?.title ?? _myAd.activeAd?.title,
      vendorCategory: 'Featured Wedding Partner',
      onUploadBanner: (bannerFile, bannerUrl) async {
        final res = await _adApi.uploadAdBanner(bannerFile);
        if (res.isSuccess == true) {
          Utils.showSuccess(
            res.message ??
                'Ad banner uploaded and attached to running campaign!',
          );
          await _loadData();
          return true;
        } else {
          Utils.showError(
            res.message ?? res.error ?? 'Failed to upload ad banner.',
          );
          return false;
        }
      },
    );
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.black,
          ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
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
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMsg!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // 1. Current Ad Campaign Section Card
                    _buildActiveAdCard(),
                    const SizedBox(height: 20),

                    // 2. How Sponsored Ads Work (Moved above Choose Your Ad Duration)
                    _buildWhySponsorBanner(),

                    const SizedBox(height: 24),

                    if (_campaignStatusLoaded && !_myAd.isAdActive) ...[
                      // 3. Section Header: Available Ad Plans
                      Row(
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            color: Color(0xFFEAB308),
                            size: 22,
                          ),
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
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.darkGrey,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 4. Ad Plans List
                      ..._adPlans.map((plan) => _buildAdPlanCard(plan)),
                    ],

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
      bottomNavigationBar:
          _isLoading || !_campaignStatusLoaded || _myAd.isAdActive
          ? null
          : Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _openAdCheckoutFlow(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 1,
                    ),
                    child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Activating Ad...',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.rocket_launch_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Boost Profile with Ad (₹${_selectedPlan?.planPrice ?? 499})',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
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

    // 1. ACTIVE CAMPAIGN STATE (High-End Royal Crimson Gradient Card)
    if (isActive && ad != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4.5,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF3D088), Color(0xFFD4A017)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFF2E090D),
                        size: 13,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'ACTIVE AD CAMPAIGN',
                        style: TextStyle(
                          color: Color(0xFF2E090D),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${ad.daysLeft} Day${ad.daysLeft == 1 ? "" : "s"} Left',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              ad.title ?? 'Sponsored Ad Boost',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Duration: ${ad.duration ?? "${ad.durationInDays ?? 3} Days"}',
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            if (ad.hasBanner) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        ad.bannerUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(
                                Icons.broken_image_rounded,
                                color: Colors.white70,
                              ),
                            ),
                      ),
                      Positioned(
                        top: 6,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 11,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Live on Home Carousel',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => _openBannerUploadDialog(),
                icon: Icon(
                  ad.hasBanner
                      ? Icons.edit_rounded
                      : Icons.add_photo_alternate_outlined,
                  size: 16,
                  color: AppColors.primaryDark,
                ),
                label: Text(
                  ad.hasBanner
                      ? 'Update Ad Banner'
                      : 'Upload Homepage Ad Banner',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3D088),
                  foregroundColor: AppColors.primaryDark,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 2. INACTIVE CAMPAIGN STATE (Clean, Minimal, Modern Card)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8DCCF), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: const Icon(
              Icons.campaign_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'No Active Ad Campaign',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Choose a plan below to get featured on the couple homepage',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.darkGrey,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdPlanCard(AdPlanModel plan) {
    final isSelected = _selectedPlanId == plan.id;
    final isPopular =
        (plan.durationInDays == 3) ||
        (plan.title?.contains('Spotlight') == true);
    final days = plan.durationInDays ?? 1;

    final IconData planIcon = days <= 1
        ? Icons.flash_on_rounded
        : (days <= 3 ? Icons.stars_rounded : Icons.diamond_rounded);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => setState(() => _selectedPlanId = plan.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFFDF9) : AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : const Color(0xFFE8DCCF).withValues(alpha: 0.8),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: isSelected ? 12 : 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Plan Icon, Name, and Selected / Popular Pill (NO circles!)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : const Color(0xFFF7EFE6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.25)
                              : Colors.transparent,
                        ),
                      ),
                      child: Icon(
                        planIcon,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.goldDark,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        plan.title ?? 'Ad Plan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? AppColors.primaryDark
                              : AppColors.black,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Selected Pill (with check icon) or Popular Badge
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4.5,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'SELECTED',
                              style: TextStyle(
                                fontSize: 10,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF3D088), Color(0xFFD4A017)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Text(
                          'POPULAR',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2E090D),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  plan.description ??
                      'Boost your business visibility and get top placement.',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.darkGrey,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                // Bottom Price & Duration Row (without 'Featured Homepage Placement')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Duration: ${plan.duration ?? "$days Days"}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Text(
                      '₹${plan.planPrice}',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWhySponsorBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8DCCF).withValues(alpha: 0.9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.primaryDark,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How Sponsored Ads Work',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                          letterSpacing: 0.2,
                        ),
                      ),
                      Text(
                        '3 simple steps to 3X your verified wedding bookings',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: AppColors.darkGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF0E5D8)),

          // 3-Step Process (Timeline Layout)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                _buildProcessStep(
                  stepNumber: '1',
                  icon: Icons.tune_rounded,
                  title: 'Select Plan & Apply Coupon',
                  description:
                      'Pick a 1, 3, or 7-day boost. Use discount coupons at checkout to save up to 100%.',
                  isLast: false,
                ),
                _buildProcessStep(
                  stepNumber: '2',
                  icon: Icons.add_photo_alternate_rounded,
                  title: 'Upload Homepage Banner',
                  description:
                      'Upload your high-res photo to display prominently at the very top of user homepage carousels.',
                  isLast: false,
                ),
                _buildProcessStep(
                  stepNumber: '3',
                  icon: Icons.rocket_launch_rounded,
                  title: 'Receive Direct WhatsApp Leads',
                  description:
                      'Couples explore your portfolio and reach out directly via call & WhatsApp with zero commission.',
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessStep({
    required String stepNumber,
    required IconData icon,
    required String title,
    required String description,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Counter & Connecting Line
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    stepNumber,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: const Color(0xFFE8DCCF),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Step Details
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 15, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.darkGrey,
                      height: 1.38,
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
        ..._myAd.history.map(
          (h) => Container(
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
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${h.duration ?? ""} • ₹${h.price?.toInt() ?? 0}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.offWhite,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    h.status ?? 'Completed',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
