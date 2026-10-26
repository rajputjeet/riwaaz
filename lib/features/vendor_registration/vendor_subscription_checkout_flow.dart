import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../data/api_provider/ad_api_provider.dart';
import '../../data/api_provider/vendor_api_provider.dart';
import '../../data/models/vendor_coupon_model.dart';
import '../../data/models/razorpay_payment_models.dart';
import '../../utils/helper/storage_helper.dart';

typedef VendorPlanPurchase =
    Future<bool> Function(
      String paymentMethod,
      String? couponCode,
      String? transactionId,
    );

/// Coupon entry and checkout are separate routes to keep each step focused
/// and avoid nested bottom-sheet layout constraints.
class VendorSubscriptionCouponScreen extends StatefulWidget {
  final Map<String, dynamic> plan;
  final VendorPlanPurchase onPay;
  final VendorApiProvider? api;
  final bool isAd;
  final AdApiProvider? adApi;

  const VendorSubscriptionCouponScreen({
    super.key,
    required this.plan,
    required this.onPay,
    this.api,
    this.isAd = false,
    this.adApi,
  });

  @override
  State<VendorSubscriptionCouponScreen> createState() =>
      _VendorSubscriptionCouponScreenState();
}

class _VendorSubscriptionCouponScreenState
    extends State<VendorSubscriptionCouponScreen> {
  final TextEditingController _couponController = TextEditingController();
  late final VendorApiProvider _vendorApi;
  late final AdApiProvider _adApi;
  List<VendorCouponModel> _coupons = [];
  ApplyCouponResultModel? _appliedCoupon;
  bool _isLoadingCoupons = true;
  bool _isApplyingCoupon = false;
  String? _couponLoadError;
  String? _couponError;
  bool _isOpeningCheckout = false;

  String get _planId =>
      (widget.plan['serverPlanId'] ?? widget.plan['id'] ?? '').toString();

  @override
  void initState() {
    super.initState();
    _vendorApi = widget.api ?? VendorApiProvider();
    _adApi = widget.adApi ?? AdApiProvider();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    setState(() {
      _isLoadingCoupons = true;
      _couponLoadError = null;
    });

    if (widget.isAd) {
      final result = await _adApi.getAvailableAdCoupons();
      if (!mounted) return;
      setState(() {
        _coupons = (result.data ?? [])
            .map(
              (c) => VendorCouponModel(
                id: c.id,
                title: c.title,
                description: c.description,
                couponCode: c.couponCode,
                discountType: c.discountType,
                discountValue: c.discountValue,
                discountPercentage: c.discountPercentage,
                applicableFor: 'ad',
                minAmount: c.minAmount,
                validUntil: c.validUntil,
              ),
            )
            .toList();
        _isLoadingCoupons = false;
        if (result.isSuccess != true) {
          _couponLoadError = result.message ?? 'Could not load ad coupons.';
        }
      });
      return;
    }

    final result = await _vendorApi.getVendorCoupons();
    if (!mounted) return;
    setState(() {
      _coupons = result.data ?? [];
      _isLoadingCoupons = false;
      if (result.isSuccess != true) {
        _couponLoadError = result.message ?? 'Could not load coupons.';
      }
    });
  }

  Future<void> _applyCoupon([String? code]) async {
    if (_isApplyingCoupon) return;
    final couponCode = (code ?? _couponController.text).trim().toUpperCase();
    if (couponCode.isEmpty) {
      setState(() => _couponError = 'Enter a coupon code to apply.');
      return;
    }
    if (_planId.isEmpty) {
      setState(
        () => _couponError =
            'The selected plan is unavailable. Please select it again.',
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isApplyingCoupon = true;
      _couponError = null;
    });
    if (widget.isAd) {
      final result = await _adApi.validateAdCoupon(
        couponCode: couponCode,
        adPlanId: _planId,
      );
      if (!mounted) return;
      setState(() => _isApplyingCoupon = false);
      if (result.isSuccess == true && result.data != null) {
        final d = result.data!;
        setState(() {
          _appliedCoupon = ApplyCouponResultModel(
            couponCode: d.couponCode,
            title: d.couponCode,
            description: '',
            discountType: d.discountType,
            originalPrice: d.originalPrice,
            discountAmount: d.discountAmount,
            finalPrice: d.finalPrice,
            isFree: d.isFree,
            savings: d.discountAmount,
            duration: d.duration,
            durationInMonths: d.durationInMonths,
            durationMonths: d.durationMonths,
            durationMonth: d.durationMonth,
          );
          _couponController.text = d.couponCode.isNotEmpty
              ? d.couponCode
              : couponCode;
        });
      } else {
        setState(() {
          _appliedCoupon = null;
          _couponError =
              result.message ?? result.error ?? 'Could not apply this coupon.';
        });
      }
      return;
    }

    final result = await _vendorApi.applyVendorCoupon(
      couponCode: couponCode,
      subscriptionPlanId: _planId,
    );
    if (!mounted) return;
    setState(() => _isApplyingCoupon = false);
    if (result.isSuccess == true && result.data != null) {
      setState(() {
        _appliedCoupon = result.data;
        _couponController.text = result.data!.couponCode.isNotEmpty
            ? result.data!.couponCode
            : couponCode;
      });
    } else {
      setState(() {
        _appliedCoupon = null;
        _couponError =
            result.message ?? result.error ?? 'Could not apply this coupon.';
      });
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _couponController.clear();
      _couponError = null;
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _continueToCheckout() async {
    if (_isApplyingCoupon || _isOpeningCheckout) return;
    if (_couponController.text.trim().isNotEmpty && _appliedCoupon == null) {
      setState(() => _couponError = 'Apply the coupon code before checkout.');
      return;
    }
    setState(() => _isOpeningCheckout = true);
    final paid = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => VendorSecureCheckoutScreen(
          plan: widget.plan,
          coupon: _appliedCoupon,
          onPay: widget.onPay,
          isAd: widget.isAd,
          api: widget.api,
        ),
      ),
    );

    if (!mounted) return;
    setState(() => _isOpeningCheckout = false);
    if (paid == true) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final planName = widget.plan['name']?.toString() ?? 'Subscription Plan';
    final duration = widget.plan['duration']?.toString() ?? '';
    final priceValue = widget.plan['price'];
    final price = priceValue is num
        ? priceValue.round()
        : int.tryParse('$priceValue') ?? 0;
    final applied = _appliedCoupon;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.isAd ? 'Ad Coupons & Offers' : 'Coupons & Offers',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadCoupons,
                  color: AppColors.primary,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    children: [
                      _PlanSummaryCard(
                        title: planName,
                        subtitle: duration,
                        price: price,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Available coupons',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildCouponList(),
                    ],
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * 0.75,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: _cardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text.rich(
                              TextSpan(
                                text: 'Enter coupon code',
                                children: [
                                  TextSpan(
                                    text: ' *',
                                    style: TextStyle(color: AppColors.error),
                                  ),
                                ],
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _couponController,
                                    enabled: !_isApplyingCoupon,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    onChanged: (_) => setState(() {
                                      _couponError = null;
                                      _appliedCoupon = null;
                                    }),
                                    decoration: InputDecoration(
                                      hintText: 'Type coupon code',
                                      isDense: true,
                                      filled: true,
                                      fillColor: AppColors.offWhite,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 13,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: AppColors.grey.withValues(
                                            alpha: 0.25,
                                          ),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: AppColors.grey.withValues(
                                            alpha: 0.25,
                                          ),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 88,
                                  height: 44,
                                  child: ElevatedButton(
                                    onPressed: _isApplyingCoupon
                                        ? null
                                        : () => _applyCoupon(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: AppColors.white,
                                      disabledBackgroundColor:
                                          AppColors.greyLight,
                                      disabledForegroundColor:
                                          AppColors.darkGrey,
                                      minimumSize: const Size(0, 44),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0,
                                      ),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: _isApplyingCoupon
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.white,
                                            ),
                                          )
                                        : const FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              'Apply',
                                              maxLines: 1,
                                              softWrap: false,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                            if (_couponError != null) ...[
                              const SizedBox(height: 7),
                              Text(
                                _couponError!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                            if (applied != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    size: 16,
                                    color: Color(0xFF16834A),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${applied.couponCode} applied · You save ₹${applied.savings.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF16834A),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _isApplyingCoupon
                                        ? null
                                        : _removeCoupon,
                                    child: const Text('Remove'),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isApplyingCoupon || _isOpeningCheckout
                              ? null
                              : _continueToCheckout,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 50),
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            applied == null
                                ? 'Continue to checkout'
                                : applied.isFree
                                ? 'Continue · Free'
                                : 'Continue · Pay ₹${applied.finalPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
    );
  }

  Widget _buildCouponList() {
    if (_isLoadingCoupons) {
      return Container(
        height: 150,
        decoration: _cardDecoration(),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (_couponLoadError != null && _coupons.isEmpty) {
      return Container(
        constraints: const BoxConstraints(minHeight: 150),
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.darkGrey,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              _couponLoadError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.darkGrey, fontSize: 12),
            ),
            TextButton(onPressed: _loadCoupons, child: const Text('Try again')),
          ],
        ),
      );
    }
    if (_coupons.isEmpty) {
      return Container(
        constraints: const BoxConstraints(minHeight: 150),
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              color: AppColors.primary,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'No coupons for now',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Please try again later.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _coupons.map((coupon) {
        final isApplied =
            _appliedCoupon?.couponCode.toUpperCase() ==
            coupon.couponCode.toUpperCase();
        final terms = <String>[
          if (coupon.minAmount > 0)
            'Minimum plan price ₹${coupon.minAmount.toStringAsFixed(0)}',
          if (coupon.maxDiscountAmount != null)
            'Maximum saving ₹${coupon.maxDiscountAmount!.toStringAsFixed(0)}',
          if (coupon.validUntil != null)
            'Valid until ${coupon.validUntil!.day.toString().padLeft(2, '0')}/${coupon.validUntil!.month.toString().padLeft(2, '0')}/${coupon.validUntil!.year}',
        ];
        return Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: _cardDecoration().copyWith(
              border: Border.all(
                color: isApplied
                    ? const Color(0xFF16834A)
                    : AppColors.grey.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    coupon.discountBadge,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coupon.title.isEmpty ? coupon.couponCode : coupon.title,
                        style: const TextStyle(
                          color: AppColors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (coupon.description.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          coupon.description,
                          style: const TextStyle(
                            color: AppColors.darkGrey,
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ],
                      Text(
                        coupon.couponCode,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (terms.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          terms.join(' · '),
                          style: const TextStyle(
                            color: AppColors.darkGrey,
                            fontSize: 10,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _isApplyingCoupon || isApplied
                      ? null
                      : () {
                          _couponController.text = coupon.couponCode;
                          _applyCoupon(coupon.couponCode);
                        },
                  child: Text(isApplied ? 'Applied' : 'Apply'),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class VendorSecureCheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> plan;
  final ApplyCouponResultModel? coupon;
  final VendorPlanPurchase onPay;
  final bool isAd;
  final VendorApiProvider? api;

  const VendorSecureCheckoutScreen({
    super.key,
    required this.plan,
    required this.coupon,
    required this.onPay,
    this.isAd = false,
    this.api,
  });

  @override
  State<VendorSecureCheckoutScreen> createState() =>
      _VendorSecureCheckoutScreenState();
}

class _VendorSecureCheckoutScreenState
    extends State<VendorSecureCheckoutScreen> {
  late final Razorpay _razorpay;
  Completer<PaymentSuccessResponse?>? _paymentCompleter;
  RazorpayOrderModel? _pendingOrder;
  PaymentSuccessResponse? _pendingPayment;
  String? _verifiedTransactionId;
  num? _serverConfirmedPrice;
  late final VendorApiProvider _paymentApi;
  RazorpayOrderModel? _checkoutOrder;
  bool _isPreparingOrder = true;
  String? _orderError;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentFailure)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
    _paymentApi = widget.api ?? VendorApiProvider();
    _prepareOrder();
  }

  @override
  void dispose() {
    final pending = _paymentCompleter;
    if (pending != null && !pending.isCompleted) pending.complete(null);
    _razorpay.clear();
    super.dispose();
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) {
    final pending = _paymentCompleter;
    if (pending != null && !pending.isCompleted) {
      pending.complete(response);
    }
  }

  void _onPaymentFailure(PaymentFailureResponse response) {
    final pending = _paymentCompleter;
    if (pending != null && !pending.isCompleted) {
      pending.completeError(
        response.message?.trim().isNotEmpty == true
            ? response.message!
            : 'Payment was not completed.',
      );
    }
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    // Checkout continues after wallet selection and reports its final result
    // through the payment success or failure event.
  }

  Future<PaymentSuccessResponse?> _openRazorpay({
    required RazorpayOrderModel order,
    required String planName,
  }) async {
    final orderId = order.orderId?.trim() ?? '';
    final keyId = order.keyId?.trim() ?? '';
    if (orderId.isEmpty || keyId.isEmpty || order.amountInPaise <= 0) {
      throw StateError('The server returned incomplete payment order details.');
    }
    final pending = Completer<PaymentSuccessResponse?>();
    _paymentCompleter = pending;
    final storage = StorageHelper();
    try {
      // razorpay_flutter exposes open() as `void async`, so a missing native
      // plugin throws into the current Zone instead of returning a Future we
      // can await. Capture that asynchronous error and route it through the
      // same checkout error handling as payment failures.
      runZonedGuarded(
        () {
          _razorpay.open({
            'key': keyId,
            'amount': order.amountInPaise,
            'currency': order.currency,
            'order_id': orderId,
            'name': 'Widoora',
            'description': planName,
            'prefill': {
              if (storage.getUserEmail()?.trim().isNotEmpty == true)
                'email': storage.getUserEmail()!.trim(),
              if (storage.getUserMobile()?.trim().isNotEmpty == true)
                'contact': storage.getUserMobile()!.trim(),
            },
            'theme': {'color': '#790D16'},
          });
        },
        (error, stackTrace) {
          if (!pending.isCompleted) {
            pending.completeError(
              error is MissingPluginException
                  ? StateError(
                      'Razorpay is not registered in this app build. Fully stop the app, rebuild and reinstall it, then try again.',
                    )
                  : error,
              stackTrace,
            );
          }
        },
      );
    } catch (_) {
      _paymentCompleter = null;
      rethrow;
    }
    try {
      return await pending.future;
    } finally {
      if (identical(_paymentCompleter, pending)) _paymentCompleter = null;
    }
  }

  Future<void> _prepareOrder() async {
    setState(() {
      _isPreparingOrder = true;
      _orderError = null;
      _checkoutOrder = null;
    });
    try {
      final planId =
          (widget.plan['serverPlanId'] ?? widget.plan['id'])
              ?.toString()
              .trim() ??
          '';
      if (planId.isEmpty) throw StateError('Plan ID is missing. Please retry.');
      final couponCode = widget.coupon?.couponCode.trim();
      final orderResult = await _paymentApi.createRazorpayOrder(
        type: widget.isAd ? 'ad' : 'subscription',
        planId: planId,
        couponCode: couponCode?.isNotEmpty == true ? couponCode : null,
      );
      if (orderResult.isSuccess != true || orderResult.data == null) {
        throw StateError(
          orderResult.message ??
              orderResult.error ??
              'Could not create a payment order.',
        );
      }
      final order = orderResult.data!;
      if (couponCode?.isNotEmpty == true &&
          order.couponCode?.trim().toUpperCase() != couponCode!.toUpperCase()) {
        throw StateError(
          'The server did not confirm coupon ${couponCode.toUpperCase()}. Reapply the coupon or try another one.',
        );
      }
      if (!mounted) return;
      setState(() {
        _checkoutOrder = order;
        _serverConfirmedPrice = order.amountInPaise / 100;
        _isPreparingOrder = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isPreparingOrder = false;
        _orderError = error.toString().replaceFirst('Bad state: ', '');
      });
    }
  }

  Future<void> _pay() async {
    if (_isProcessing || _isPreparingOrder || _checkoutOrder == null) return;
    setState(() => _isProcessing = true);
    try {
      final couponCode = widget.coupon?.couponCode.trim();
      final paymentApi = _paymentApi;
      bool completed;
      if (_verifiedTransactionId != null) {
        completed = await widget.onPay(
          'Razorpay',
          couponCode,
          _verifiedTransactionId,
        );
      } else if (_pendingPayment != null && _pendingOrder != null) {
        completed = await _verifyAndFinalize(
          paymentApi: paymentApi,
          couponCode: couponCode,
        );
      } else {
        final order = _checkoutOrder!;
        if (order.isFree) {
          completed = await widget.onPay('Coupon', couponCode, null);
        } else {
          _pendingOrder = order;
          _pendingPayment = await _openRazorpay(
            order: order,
            planName:
                order.planTitle ??
                widget.plan['name']?.toString() ??
                'Vendor plan',
          );
          completed = await _verifyAndFinalize(
            paymentApi: paymentApi,
            couponCode: couponCode,
          );
        }
      }
      if (!mounted) return;
      if (completed) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => _isProcessing = false);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Bad state: ', '')),
        ),
      );
    }
  }

  Future<bool> _verifyAndFinalize({
    required VendorApiProvider paymentApi,
    required String? couponCode,
  }) async {
    final order = _pendingOrder!;
    final payment = _pendingPayment!;
    final paymentId = payment.paymentId?.trim() ?? '';
    final signature = payment.signature?.trim() ?? '';
    final razorpayOrderId = payment.orderId?.trim() ?? '';
    if (paymentId.isEmpty || signature.isEmpty || razorpayOrderId.isEmpty) {
      throw StateError('Razorpay did not return complete payment details.');
    }
    if (razorpayOrderId != order.orderId) {
      throw StateError('The payment does not match this checkout order.');
    }
    final verification = await paymentApi.verifyRazorpayPayment(
      orderId: razorpayOrderId,
      paymentId: paymentId,
      signature: signature,
    );
    if (verification.isSuccess != true || verification.data?.verified != true) {
      throw StateError(
        verification.message ??
            'Payment verification failed. Your plan was not activated.',
      );
    }
    if ((verification.data?.orderId != null &&
            verification.data!.orderId != razorpayOrderId) ||
        (verification.data?.paymentId != null &&
            verification.data!.paymentId != paymentId)) {
      throw StateError('Payment verification returned a different purchase.');
    }
    _verifiedTransactionId = verification.data?.transactionId ?? paymentId;
    return widget.onPay('Razorpay', couponCode, _verifiedTransactionId);
  }

  @override
  Widget build(BuildContext context) {
    final planName = widget.plan['name']?.toString() ?? 'Subscription Plan';
    final duration = widget.plan['duration']?.toString() ?? '';
    final priceValue = widget.plan['price'];
    final originalPrice =
        _checkoutOrder?.originalPrice ??
        (priceValue is num ? priceValue : num.tryParse('$priceValue') ?? 0);
    final price =
        _serverConfirmedPrice ?? widget.coupon?.finalPrice ?? originalPrice;
    final priceLabel = price.toStringAsFixed(price % 1 == 0 ? 0 : 2);
    final discountAmount =
        _checkoutOrder?.discountAmount ?? widget.coupon?.discountAmount ?? 0;
    final isFree = _checkoutOrder?.isFree ?? (widget.coupon?.isFree == true);

    return PopScope(
      canPop: !_isProcessing,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: _isProcessing
                ? null
                : () => Navigator.of(context).pop(false),
          ),
          title: const Text(
            'Secure Checkout',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _PlanSummaryCard(
                title: planName,
                subtitle: duration,
                price: price,
              ),
              if (widget.coupon != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6EE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFB8E2C5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_offer_outlined,
                            color: Color(0xFF16834A),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${widget.coupon!.couponCode} applied',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF16834A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      _PriceLine(label: 'Plan price', value: originalPrice),
                      const SizedBox(height: 5),
                      _PriceLine(
                        label: 'Coupon savings',
                        value: -discountAmount,
                        isDiscount: true,
                      ),
                      const Divider(height: 16),
                      _PriceLine(
                        label: isFree ? 'Amount due' : 'Total to pay',
                        value: price,
                        isEmphasized: true,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 22),
              if (isFree)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6EE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF16834A),
                        size: 20,
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Your coupon covers the full plan price. No payment method is needed.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_orderError != null) ...[
                Text(
                  _orderError!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
                const SizedBox(height: 10),
              ],
              if (!isFree) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Pay securely with Razorpay. UPI, cards, net banking and supported wallets are available at checkout.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing || _isPreparingOrder
                      ? null
                      : _orderError != null
                      ? _prepareOrder
                      : _pay,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing || _isPreparingOrder
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _orderError != null
                              ? 'Retry checkout'
                              : isFree
                              ? 'Activate plan for free'
                              : 'Pay ₹$priceLabel securely',
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
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label;
  final num value;
  final bool isDiscount;
  final bool isEmphasized;

  const _PriceLine({
    required this.label,
    required this.value,
    this.isDiscount = false,
    this.isEmphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDiscount
        ? const Color(0xFF16834A)
        : (isEmphasized ? AppColors.black : AppColors.darkGrey);
    final amount = value.abs().toStringAsFixed(value.abs() % 1 == 0 ? 0 : 2);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: isEmphasized ? 13 : 12,
              fontWeight: isEmphasized ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          '${isDiscount ? '−' : ''}₹$amount',
          style: TextStyle(
            color: color,
            fontSize: isEmphasized ? 14 : 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _PlanSummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final num price;

  const _PlanSummaryCard({
    required this.title,
    required this.subtitle,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.darkGrey,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '₹${price.toStringAsFixed(price % 1 == 0 ? 0 : 2)}',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: AppColors.white,
  borderRadius: BorderRadius.circular(15),
  border: Border.all(color: AppColors.grey.withValues(alpha: 0.18)),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.035),
      blurRadius: 12,
      offset: const Offset(0, 3),
    ),
  ],
);
