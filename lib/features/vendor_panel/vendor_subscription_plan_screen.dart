import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/api_provider/vendor_api_provider.dart';
import '../../data/api_provider/subscription_api_provider.dart';
import '../../data/models/subscription_model.dart';
import '../../data/models/active_plan_model.dart';
import '../../shared/widgets/app_states.dart';
import '../../utils/utils.dart';
import '../vendor_registration/vendor_subscription_checkout_flow.dart';

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
  // ignore: unused_field
  String _activePlanServerId = '';
  ActivePlanModel? _activePlan;
  bool _isLoadingPlans = false;
  bool _isNoInternet = false;
  String? _errorMsg;
  List<SubscriptionModel> _serverPlans = [];

  // Map local plan key -> server _id (populated after API fetch)
  String _getServerPlanId(String localId) {
    if (_serverPlans.isEmpty) return '';
    final direct = _serverPlans.firstWhere(
      (p) => p.id == localId,
      orElse: () => SubscriptionModel(),
    );
    if (direct.id != null && direct.id!.isNotEmpty) return direct.id!;
    const monthsMap = {'3_months': 3, '6_months': 6, '12_months': 12};
    final months = monthsMap[localId];
    if (months == null) return '';
    return _serverPlans
            .firstWhere(
              (p) => p.durationInMonths == months,
              orElse: () => SubscriptionModel(),
            )
            .id ??
        '';
  }

  @override
  void initState() {
    super.initState();
    _activePlanId = widget.currentPlanId;
    _loadServerData();
  }

  Future<void> _loadServerData() async {
    setState(() {
      _isLoadingPlans = true;
      _isNoInternet = false;
      _errorMsg = null;
    });
    try {
      final plansResult = await SubscriptionApiProvider().getSubscriptionList();
      final planResult = await VendorApiProvider().getActivePlan();
      if (!mounted) return;
      final plansError = plansResult.isSuccess == true
          ? null
          : (plansResult.message ?? 'Failed to load subscription plans.');
      final plansErrorLower = plansError?.toLowerCase() ?? '';
      setState(() {
        if (plansResult.isSuccess == true && plansResult.data != null) {
          _serverPlans = plansResult.data!;
        }
        if (planResult.isSuccess == true && planResult.data != null) {
          _activePlan = planResult.data;
          final sPlan = planResult.data!.subscriptionPlan;
          _activePlanServerId = sPlan?.id ?? '';
          if (sPlan?.id != null && sPlan!.id!.isNotEmpty) {
            _activePlanId = sPlan.id!;
          } else if (sPlan?.durationInMonths != null) {
            _activePlanId = '${sPlan!.durationInMonths}_months';
          }
        }
        _isLoadingPlans = false;
        _isNoInternet = plansErrorLower.contains('socket') ||
            plansErrorLower.contains('connection') ||
            plansErrorLower.contains('network');
        _errorMsg = plansError;
      });
    } catch (e) {
      if (!mounted) return;
      final isNet = e.toString().toLowerCase().contains('socket') ||
          e.toString().toLowerCase().contains('connection') ||
          e.toString().toLowerCase().contains('network');
      setState(() {
        _isNoInternet = isNet;
        _errorMsg = isNet ? null : 'Failed to load subscription plans.';
        _isLoadingPlans = false;
      });
    }
  }

  List<Map<String, dynamic>> get _effectivePlans {
    if (_serverPlans.isEmpty) return const [];
    return _serverPlans.map((sp) {
      final months = sp.durationInMonths ?? 0;
      final price = sp.planPrice;
      final monthly = months > 0 ? (price / months).round() : price;
      final isPopular = months == 6;
      final isBest = months >= 12;
      return {
        'id': sp.id ?? '${months}_months',
        'serverPlanId': sp.id,
        'name': sp.displayName,
        'duration': sp.durationLabel,
        'months': months,
        'price': price,
        'monthlyRate': monthly,
        'tagline': sp.description?.trim() ?? '',
        'color': isBest
            ? const Color(0xFF790D16)
            : (isPopular ? AppColors.primary : const Color(0xFF5A6270)),
        'icon': isBest
            ? Icons.diamond_rounded
            : (isPopular ? Icons.stars_rounded : Icons.calendar_today_rounded),
        'isPopular': isPopular,
      };
    }).toList();
  }

  Future<void> _showCheckoutSheet(Map<String, dynamic> plan) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => VendorSubscriptionCouponScreen(
          plan: plan,
          onPay: (paymentMethod, couponCode) async {
            final serverPlanId = _getServerPlanId(plan['id'] as String);
            if (serverPlanId.isEmpty) {
              Utils.showError('Plan ID not found. Please retry.');
              return false;
            }

            final normalizedMethod = paymentMethod == 'Net banking'
                ? 'NetBanking'
                : paymentMethod;
            final result = await VendorApiProvider().buyPlan(
              subscriptionPlanId: serverPlanId,
              paymentMethod: normalizedMethod,
              couponCode: couponCode,
              transactionId: paymentMethod == 'Free' ? 'FREE-COUPON' : null,
            );
            if (!mounted) return false;

            if (result.isSuccess == true) {
              setState(() {
                _activePlan = result.data;
                _activePlanId = plan['id'] as String;
                _activePlanServerId = serverPlanId;
              });
              _loadServerData();
              Utils.showSuccess(
                'Plan Activated! You are now on the ${plan['name']}.',
              );
              return true;
            }

            Utils.showError(
              result.message ?? 'Payment failed. Please try again.',
            );
            return false;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingPlans && _serverPlans.isEmpty) {
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
          title: const Text('Subscription Plans',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black)),
          centerTitle: true,
        ),
        body: const AppLoadingState(
            message: 'Loading subscription plans...'),
      );
    }

    if (_isNoInternet) {
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
          title: const Text('Subscription Plans',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black)),
          centerTitle: true,
        ),
        body: AppNoInternetState(onRetry: _loadServerData),
      );
    }

    if (_errorMsg != null && _serverPlans.isEmpty) {
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
          title: const Text('Subscription Plans',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black)),
          centerTitle: true,
        ),
        body: AppErrorState(message: _errorMsg!, onRetry: _loadServerData),
      );
    }

    final plansToDisplay = _effectivePlans;
    if (plansToDisplay.isEmpty) {
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
          title: const Text('Subscription Plans',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black)),
          centerTitle: true,
        ),
        body: const AppEmptyState(
          icon: Icons.card_membership_rounded,
          title: 'No Plans Available',
          subtitle:
              'Subscription plans will appear here once configured by the platform.',
        ),
      );
    }

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
          'Subscription Plans',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadServerData,
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
              // Current Active Membership Card
              _buildCurrentPlanBanner(),

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
              const SizedBox(height: 12),

              // Plan Cards
              ...plansToDisplay.map((plan) {
                final isCurrent = (_activePlan?.isSubscriptionActive == true &&
                        _activePlan?.isExpired != true) &&
                    (plan['id'] == _activePlanId ||
                        plan['serverPlanId'] == _activePlanServerId);
                final isPopular = plan['isPopular'] == true;
                final price = plan['price'] as int;
                final monthlyEq = plan['monthlyRate'] as int;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCurrent
                        ? AppColors.success
                        : isPopular
                            ? AppColors.primary.withValues(alpha: 0.35)
                            : AppColors.grey.withValues(alpha: 0.2),
                    width: isCurrent ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isCurrent
                          ? AppColors.success.withValues(alpha: 0.07)
                          : Colors.black.withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Icon, Name, Tagline, Highlight
                          Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: (plan['color'] as Color)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                alignment: Alignment.center,
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
                                        Expanded(
                                          child: Text(
                                            plan['name'] as String,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.black,
                                            ),
                                          ),
                                        ),
                                        if (isCurrent) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 7, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.success
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              'CURRENT',
                                              style: TextStyle(
                                                fontSize: 8.5,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.success,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
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
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              alignment: WrapAlignment.spaceBetween,
                              children: [
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
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

                          // Keep the plan description concise and below the price.
                          if ((plan['tagline'] as String?)?.trim().isNotEmpty ==
                              true) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.offWhite,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                (plan['tagline'] as String).trim(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: AppColors.darkGrey,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 12),

                          // Action CTA Button
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () => _showCheckoutSheet(plan),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(0, 44),
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
                                    ? 'Extend ${plan['name']}'
                                    : 'Buy ${plan['name']}',
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

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  Widget _buildCurrentPlanBanner() {
    final active = _activePlan;
    final isActive = active?.isSubscriptionActive == true && active?.isExpired != true;
    final isExpired = active?.isExpired == true;

    if (!isActive && !isExpired) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.card_membership_rounded,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'No Active Subscription',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Choose a plan below to activate vendor partner benefits',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final planName = active?.subscriptionPlan?.title ??
        active?.planTitle ??
        'Active Partner';
    final daysRemaining = active?.daysRemaining ?? 0;
    final endDateFormatted = _formatDate(active?.subscriptionEndDate);

    if (isActive) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
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
                        'ACTIVE SUBSCRIPTION',
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
                  child: Text(
                    '$daysRemaining Day${daysRemaining == 1 ? '' : 's'} Left',
                    style: const TextStyle(
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
                  planName,
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
            if (endDateFormatted.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Expires on $endDateFormatted',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.cream,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Expired
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
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
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'EXPIRED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Text(
                '0 Days Left',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            planName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          if (endDateFormatted.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Expired on $endDateFormatted',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.darkGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
