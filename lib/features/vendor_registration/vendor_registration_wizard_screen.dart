import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/service_categories.dart';
import '../../core/utils/app_animations.dart';
import '../../shared/widgets/service_categories_bar.dart';
import '../../shared/widgets/app_search_bar.dart';
import 'vendor_submitted_screen.dart';

class VendorRegistrationWizardScreen extends StatefulWidget {
  final int initialStep;
  final String? initialCategory;
  final String? initialBusinessName;
  final String? initialOwnerName;
  final String? initialPhone;
  final String? initialEmail;
  final String? initialExperience;

  const VendorRegistrationWizardScreen({
    super.key,
    this.initialStep = 1,
    this.initialCategory,
    this.initialBusinessName,
    this.initialOwnerName,
    this.initialPhone,
    this.initialEmail,
    this.initialExperience,
  });

  @override
  State<VendorRegistrationWizardScreen> createState() =>
      _VendorRegistrationWizardScreenState();
}

class _VendorRegistrationWizardScreenState
    extends State<VendorRegistrationWizardScreen> {
  late int _currentStep; // 1 to 7
  final int _totalSteps = 5;

  // Step 1 State: Business Type
  String _selectedCategory = 'Photography & Videography';
  final _searchTypeController = TextEditingController();

  List<ServiceCategoryItem> get _businessTypes => kServiceCategories;

  // Step 2 State: Basic Info
  final _businessNameController =
      TextEditingController(text: 'Royal Click Studio');
  final _ownerNameController = TextEditingController(text: 'Aman Verma');
  final _mobileController = TextEditingController(text: '9876543210');
  final _emailController =
      TextEditingController(text: 'contact@royalclickstudio.com');
  final _addressController =
      TextEditingController(text: 'SCO 142, Sector 70, Mohali, Punjab');

  // Step 3 State: Business Details
  String _experience = '5+ Years';
  final List<String> _experienceOptions = [
    '1-2 Years',
    '3-5 Years',
    '5+ Years',
    '10+ Years',
  ];

  final _descriptionController = TextEditingController(
    text:
        'Award-winning wedding studio in Chandigarh & Mohali capturing magical timeless memories since 2018 with artistic storytelling.',
  );
  final _gstController = TextEditingController(text: '03AABCR1234F1Z8');

  // Step 5 State: Subscription Plans (3, 6, 12 Months)
  String _selectedPlan = '6_months'; // '3_months', '6_months', '12_months'
  bool _isSubscriptionPaid = false;
  String _selectedPaymentMethod = 'UPI';
  final List<Map<String, dynamic>> _subscriptionPlans = [
    {
      'id': '3_months',
      'name': '3 Months Plan',
      'duration': '3 Months',
      'months': 3,
      'price': 2999,
      'monthlyRate': 1000,
      'tagline': 'Quarterly partner access to start receiving leads',
      'badge': 'STARTER',
      'color': const Color(0xFF6B7280),
      'icon': Icons.calendar_today_rounded,
      'features': [
        'Verified Vendor Profile badge for 3 months',
        '25 Verified Client Leads / month',
        'Direct WhatsApp & Call inquiries',
        'Upload up to 15 Portfolio photos',
        'Standard category search ranking',
        'Real-time inquiry dashboard & SMS alerts',
      ],
    },
    {
      'id': '6_months',
      'name': '6 Months Plan',
      'duration': '6 Months',
      'months': 6,
      'price': 4999,
      'monthlyRate': 833,
      'tagline': 'High-growth package for wedding season',
      'badge': 'MOST POPULAR',
      'savings': 'SAVE 15%',
      'isPopular': true,
      'color': AppColors.primary,
      'icon': Icons.stars_rounded,
      'features': [
        'Verified Partner Badge with Priority Star',
        '60 High-Intent Client Leads / month',
        'Priority Search & Category Placement',
        'Unlimited Portfolio photos & 4K videos',
        'Featured in "Top Recommended Vendors"',
        'Direct customer quotation generator',
        'Dedicated WhatsApp account manager',
      ],
    },
    {
      'id': '12_months',
      'name': '12 Months Plan',
      'duration': '12 Months (1 Year)',
      'months': 12,
      'price': 8999,
      'monthlyRate': 749,
      'tagline': 'Full year dominance & maximum client bookings',
      'badge': 'BEST VALUE',
      'savings': 'SAVE 25%',
      'isPopular': false,
      'color': const Color(0xFF8B1A2E),
      'icon': Icons.diamond_rounded,
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
    },
  ];

  Map<String, dynamic> _getSelectedPlan() {
    return _subscriptionPlans.firstWhere(
      (p) => p['id'] == _selectedPlan,
      orElse: () => _subscriptionPlans[1],
    );
  }

  int _getPlanPrice(Map<String, dynamic> plan) {
    return (plan['price'] as int?) ?? 4999;
  }

  // Step 3 State: Documents (Bank details removed per user instruction)
  final Map<String, bool> _documentUploaded = {
    'Aadhaar / Passport': true,
    'Business Registration Certificate': true,
    'Address Proof (Electricity Bill / Rent)': true,
    'GST Certificate (Optional)': true,
  };

  // Step 4 State: Review
  bool _agreedToTerms = true;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    if (widget.initialCategory != null &&
        widget.initialCategory!.trim().isNotEmpty) {
      _selectedCategory = widget.initialCategory!.trim();
    }
    

    if (widget.initialBusinessName != null &&
        widget.initialBusinessName!.trim().isNotEmpty) {
      _businessNameController.text = widget.initialBusinessName!.trim();
    }
    if (widget.initialOwnerName != null &&
        widget.initialOwnerName!.trim().isNotEmpty) {
      _ownerNameController.text = widget.initialOwnerName!.trim();
    }
    if (widget.initialPhone != null &&
        widget.initialPhone!.trim().isNotEmpty) {
      _mobileController.text = widget.initialPhone!.trim();
    }
    if (widget.initialEmail != null &&
        widget.initialEmail!.trim().isNotEmpty) {
      _emailController.text = widget.initialEmail!.trim();
    }
    if (widget.initialExperience != null &&
        widget.initialExperience!.trim().isNotEmpty) {
      _experience = widget.initialExperience!.trim();
    }
  }

  @override
  void dispose() {
    _searchTypeController.dispose();
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 5) {
      if (!_isSubscriptionPaid) {
        _showPaymentSheet();
        return;
      }
      _submitRegistration();
      return;
    }
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    } else {
      _submitRegistration();
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _submitRegistration() {
    Navigator.of(context).pushReplacement(
      FadeScaleRoute(
        page: VendorSubmittedScreen(
          businessName: _businessNameController.text.isEmpty
              ? 'Royal Click Studio'
              : _businessNameController.text,
          businessType: _selectedCategory,
          ownerName: _ownerNameController.text.isEmpty
              ? 'Aman Verma'
              : _ownerNameController.text,
        ),
      ),
    );
  }
  // Helper to open Buy Subscription Modal
  void _showPaymentSheet() {
    final plan = _getSelectedPlan();
    final price = _getPlanPrice(plan);
    bool isProcessing = false;

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
                        'Secure Checkout',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        'Riwaaz Partner Membership',
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
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${plan['name']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          '₹$price',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GST (18% Included)',
                          style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
                        ),
                        Text(
                          'Inclusive',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Payable Amount',
                          style: TextStyle(
                            fontSize: 14,
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

              // Payment Modes
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

              // Pay Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : () async {
                          final nav = Navigator.of(ctx);
                          final messenger = ScaffoldMessenger.of(context);
                          setSheetState(() => isProcessing = true);
                          await Future.delayed(const Duration(milliseconds: 900));
                          if (!mounted) return;
                          setState(() => _isSubscriptionPaid = true);
                          nav.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Payment Successful! ${plan['name']} activated.',
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isProcessing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Pay ₹$price Securely',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary, size: 20),
          onPressed: _prevStep,
        ),
        title: Text(
          _getStepTitle(),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cream.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '$_currentStep/$_totalSteps',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: _currentStep / _totalSteps,
              backgroundColor: AppColors.lightGrey,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 3,
            ),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: _buildCurrentStepView(),
              ),
            ),

            // Bottom Continue Section
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 1:
        return 'Choose Business Type';
      case 2:
        return 'Basic Information';
      case 3:
        return 'Documents';
      case 4:
        return 'Review Application';
      case 5:
        return 'Subscription Plan';
      default:
        return 'Vendor Registration';
    }
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 1:
        return _buildStep1ChooseType();
      case 2:
        return _buildStep2BasicInfo();
      case 3:
        return _buildStep3Documents();
      case 4:
        return _buildStep4ReviewSubmit();
      case 5:
        return _buildStep5SubscriptionPlan();
      default:
        return const SizedBox.shrink();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 1: CHOOSE BUSINESS TYPE
  // ─────────────────────────────────────────────────────────────
  Widget _buildStep1ChooseType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'I am a',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          '(Select your business type)',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),

        // Unified Search Type Bar
        AppSearchBar(
          controller: _searchTypeController,
          hintText: 'Search business type...',
          onChanged: (_) => setState(() {}),
        ),

        const SizedBox(height: 18),

        // 3-Column Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemCount: _businessTypes.length,
          itemBuilder: (context, index) {
            final type = _businessTypes[index];
            final isSelected = _selectedCategory == type.title;
            final query = _searchTypeController.text.toLowerCase().trim();
            if (query.isNotEmpty &&
                !type.title.toLowerCase().contains(query) &&
                !type.desc.toLowerCase().contains(query)) {
              return const SizedBox.shrink();
            }

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = type.title;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? type.bgColor : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? type.color
                        : AppColors.grey.withValues(alpha: 0.22),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? type.color.withValues(alpha: 0.18)
                          : Colors.black.withValues(alpha: 0.04),
                      blurRadius: isSelected ? 10 : 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ServiceIconWrap(
                      item: type,
                      size: 52,
                      iconSize: 24,
                      borderRadius: 14,
                      isSelected: isSelected,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      type.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? type.color : AppColors.black,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  // ─────────────────────────────────────────────────────────────
  // STEP 2: BASIC INFO
  // ─────────────────────────────────────────────────────────────
  Widget _buildStep2BasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Owner Full Name (moved UP)
        _buildFormField(
          label: 'Owner / Representative Full Name',
          hint: 'e.g. Aman Verma',
          controller: _ownerNameController,
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 16),

        // 2. Business / Studio Name
        _buildFormField(
          label: 'Business / Studio Name',
          hint: 'e.g. Royal Click Studio',
          controller: _businessNameController,
          icon: Icons.business_outlined,
        ),
        const SizedBox(height: 16),

        // 3. Years of Experience
        const Text(
          'Years of Experience',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: _experienceOptions.map((exp) {
            final isSel = _experience == exp;
            return ChoiceChip(
              label: Text(exp),
              selected: isSel,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.offWhite,
              labelStyle: TextStyle(
                color: isSel ? AppColors.white : AppColors.black,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              onSelected: (_) => setState(() => _experience = exp),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // 4. Business Description (made bigger)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Business Description',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            Text(
              '${_descriptionController.text.length}/500',
              style: TextStyle(
                fontSize: 11,
                color: _descriptionController.text.length > 500
                    ? AppColors.error
                    : AppColors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 5,
            maxLength: 500,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Describe your wedding services, studio style, expertise, years in industry, and specialties...',
              hintStyle: TextStyle(color: AppColors.grey, fontSize: 13),
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(14),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 5. Business Address / City
        _buildFormField(
          label: 'Business Address / City',
          hint: 'e.g. SCO 142, Sector 70, Mohali, Punjab',
          controller: _addressController,
          icon: Icons.location_on_outlined,
          maxLines: 2,
        ),

        const SizedBox(height: 16),

        // 6. GST Number (Optional) - added in Basic Info
        _buildFormField(
          label: 'GST Number (Optional)',
          hint: 'Enter GST number (e.g. 03AABCR1234F1Z8)',
          controller: _gstController,
          icon: Icons.receipt_long_outlined,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 3: DOCUMENTS
  // ─────────────────────────────────────────────────────────────
  Widget _buildStep3Documents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Verification Documents',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'Documents help verify your account and build trust with clients',
          style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
        ),
        const SizedBox(height: 16),
        ..._documentUploaded.entries.map((entry) {
          final isUploaded = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUploaded
                    ? AppColors.success.withValues(alpha: 0.4)
                    : AppColors.grey.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isUploaded
                      ? Icons.check_circle_rounded
                      : Icons.description_outlined,
                  color: isUploaded ? AppColors.success : AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  isUploaded ? 'Uploaded ✓' : 'Pending',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isUploaded ? AppColors.success : AppColors.grey,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 4: REVIEW APPLICATION
  // ─────────────────────────────────────────────────────────────
  Widget _buildStep4ReviewSubmit() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_turned_in_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review Your Application',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Please verify your details before proceeding to plan selection',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Card 1: Business Profile
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2D6C7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Business Profile',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 13),
                        SizedBox(width: 4),
                        Text(
                          'Verified Draft',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildReviewInfoRow('Business Name', _businessNameController.text),
              _buildReviewInfoRow('Owner / Contact', _ownerNameController.text),
              _buildReviewInfoRow('Primary Category', _selectedCategory),
              _buildReviewInfoRow('Experience', _experience),
              if (_descriptionController.text.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.offWhite,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEFE6DC)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About / Description:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _descriptionController.text.trim(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.black,
                          height: 1.35,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Card 2: Location & Compliance
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2D6C7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Location & Tax Compliance',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildReviewInfoRow(
                'City / Address',
                _addressController.text.trim().isNotEmpty
                    ? _addressController.text.trim()
                    : 'Chandigarh & Tricity',
              ),
              _buildReviewInfoRow(
                'GSTIN Number',
                _gstController.text.trim().isNotEmpty
                    ? _gstController.text.trim()
                    : 'Not Provided (Exempt)',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Card 3: Contact Details
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2D6C7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.contact_mail_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Contact Verification',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'Mobile Number',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.darkGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '+91 ${_mobileController.text}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF2E7D32),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'Email Address',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.darkGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            _emailController.text,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF2E7D32),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Card 4: Uploaded Documents (Bank details removed)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2D6C7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.folder_shared_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Uploaded Documents (${_documentUploaded.length})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._documentUploaded.keys.map((docName) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF2E7D32),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          docName,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Ready',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Card 5: Terms Agreement
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _agreedToTerms,
                onChanged: (v) => setState(() => _agreedToTerms = v ?? true),
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'I confirm that all details and submitted documents are authentic and accurate as per Riwaaz Vendor Partnership Guidelines.',
                  style: TextStyle(fontSize: 12, color: AppColors.darkGrey, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.darkGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }


  // ─────────────────────────────────────────────────────────────
  // STEP 5: SUBSCRIPTION PLAN
  // ─────────────────────────────────────────────────────────────
  Widget _buildStep5SubscriptionPlan() {
    final activePlan = _getSelectedPlan();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Header
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose Partner Plan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Plans designed for $_selectedCategory partners',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Select your partnership duration (3, 6, or 12 Months) to get verified, receive real-time client leads, and activate your vendor profile on Riwaaz.',
          style: TextStyle(fontSize: 12.5, color: AppColors.darkGrey, height: 1.4),
        ),
        const SizedBox(height: 18),

        // Plans List (3 Months, 6 Months, 12 Months)
        ..._subscriptionPlans.map((plan) {
          final isSelected = _selectedPlan == plan['id'];
          final price = _getPlanPrice(plan);
          final isPopular = plan['isPopular'] == true;
          final savings = plan['savings'] as String?;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPlan = plan['id'] as String;
                _isSubscriptionPaid = false;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : isPopular
                          ? AppColors.primary.withValues(alpha: 0.35)
                          : AppColors.grey.withValues(alpha: 0.25),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPopular)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star_rounded, size: 14, color: AppColors.cream),
                          SizedBox(width: 4),
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
                        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.diamond_rounded, size: 14, color: AppColors.cream),
                          const SizedBox(width: 4),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: (plan['color'] as Color).withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    plan['icon'] as IconData,
                                    color: plan['color'] as Color,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          plan['name'] as String,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: (plan['color'] as Color).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(6),
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
                                    Text(
                                      plan['tagline'] as String,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.darkGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.grey.withValues(alpha: 0.5),
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
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
                            const SizedBox(width: 8),
                            Text(
                              '(₹${plan['monthlyRate']}/mo)',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        // Features
                        ...((plan['features'] as List<String>).map((feat) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
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
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _selectedPlan = plan['id'] as String;
                                _isSubscriptionPaid = false;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.primary.withValues(alpha: 0.5),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              isSelected ? 'Selected Plan ✓' : 'Select ${plan['name']}',
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
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
          );
        }),


        const SizedBox(height: 10),

        // Buy / Status Card
        if (_isSubscriptionPaid)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.4), width: 1.2),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${activePlan['name']} Active',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Payment Successful • Txn ID: RWZ-2025-9842',
                            style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _submitRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Complete Registration', style: TextStyle(fontWeight: FontWeight.w700)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }




  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    IconData? icon,
    TextInputType? keyboardType,
    String? prefixText,
    int maxLines = 1,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.grey, fontSize: 13),
              prefixIcon: icon != null
                  ? Icon(icon, color: AppColors.primary, size: 18)
                  : null,
              prefixText: prefixText,
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, color: AppColors.grey)
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    String buttonText;
    if (_currentStep == 5) {
      final activePlan = _getSelectedPlan();
      final activePrice = _getPlanPrice(activePlan);
      buttonText = _isSubscriptionPaid
          ? 'Complete Registration'
          : 'Buy ${activePlan['name']} (₹$activePrice)';
    } else if (_currentStep == 4) {
      buttonText = 'Proceed to Plan Selection';
    } else {
      buttonText = 'Continue';
    }

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
