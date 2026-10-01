import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/category_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/service_categories.dart';
import '../../core/utils/app_animations.dart';
import '../../shared/widgets/app_search_bar.dart';
import '../../shared/widgets/cached_image_view.dart';
import '../../utils/helper/storage_helper.dart';
import '../../utils/utils.dart';
import 'controllers/vendor_registration_controller.dart';
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

  List<ServiceCategoryItem> get _businessTypes {
    if (Get.isRegistered<CategoryController>() &&
        CategoryController.to.serviceCategories.isNotEmpty) {
      return CategoryController.to.serviceCategories;
    }
    if (_vendorController.categories.isNotEmpty) {
      return _vendorController.categories
          .map((cat) => ServiceCategoryItem.fromCategoryModel(cat))
          .toList();
    }
    return const [];
  }

  // Step 2 State: Basic Info — pre-filled from storage in initState
  final _businessNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  // Step 3 State: Business Details
  String _experience = '5+ Years';
  final List<String> _experienceOptions = [
    '1-2 Years',
    '3-5 Years',
    '5+ Years',
    '10+ Years',
  ];

  final _descriptionController = TextEditingController();
  final _gstController = TextEditingController();

  // Step 5 State: Subscription Plans (fetched dynamically from /api/subscription/list)
  String _selectedPlan = '6_months'; // will hold selected plan _id
  bool _isSubscriptionPaid = false;
  String _selectedPaymentMethod = 'UPI';


  List<Map<String, dynamic>> get _availablePlans {
    if (_vendorController.subscriptionPlans.isNotEmpty) {
      return _vendorController.subscriptionPlans.map((sub) {
        final id = sub.id ?? '';
        final name = sub.displayName;
        final duration = sub.type ??
            (sub.durationInMonths != null
                ? '${sub.durationInMonths} Months'
                : 'Membership');
        final months = sub.durationInMonths ??
            (duration.contains('12')
                ? 12
                : (duration.contains('6')
                    ? 6
                    : (duration.contains('3') ? 3 : 1)));
        final price = sub.planPrice;
        final monthlyRate = months > 0 ? (price / months).round() : price;
        final desc =
            (sub.description != null && sub.description!.trim().isNotEmpty)
                ? sub.description!.trim()
                : 'Vendor partner membership plan on Widoora';
        final isPopular = months == 6 ||
            name.toLowerCase().contains('gold') ||
            name.toLowerCase().contains('popular');
        final isBestValue = months == 12 ||
            name.toLowerCase().contains('royal') ||
            name.toLowerCase().contains('platinum');
        final badge = isPopular
            ? 'MOST POPULAR'
            : (isBestValue
                ? 'BEST VALUE'
                : (months == 1 ? 'STARTER' : 'PRO'));
        final color = isPopular
            ? AppColors.primary
            : (isBestValue
                ? const Color(0xFF8B1A2E)
                : const Color(0xFF6B7280));
        final icon = isPopular
            ? Icons.stars_rounded
            : (isBestValue
                ? Icons.diamond_rounded
                : Icons.calendar_today_rounded);

        return {
          'id': id,
          'name': name,
          'duration': duration,
          'months': months,
          'price': price,
          'monthlyRate': monthlyRate,
          'tagline': desc,
          'badge': badge,
          'savings':
              isBestValue ? 'SAVE 25%' : (isPopular ? 'SAVE 15%' : null),
          'isPopular': isPopular,
          'color': color,
          'icon': icon,
          'features': [
            'Verified Vendor Profile badge for $duration',
            'Direct Bride & Groom Leads & WhatsApp inquiries',
            'Portfolio & packages showcase on Widoora',
            'Real-time inquiry dashboard & lead alerts',
            '0% Commission on client bookings',
          ],
        };
      }).toList();
    }
    return const [];
  }

  Map<String, dynamic>? _getSelectedPlan() {
    final plans = _availablePlans;
    if (plans.isEmpty) return null;
    return plans.firstWhere(
      (p) => p['id'] == _selectedPlan,
      orElse: () => plans.firstWhere(
        (p) => p['isPopular'] == true,
        orElse: () => plans.first,
      ),
    );
  }

  int _getPlanPrice(Map<String, dynamic>? plan) {
    if (plan == null) return 0;
    return (plan['price'] as int?) ?? 0;
  }

  // Step 3 State: Documents with real ImagePickers
  String? _aadharPath;
  String? _panPath;
  String? _businessCertPath;
  String? _addressProofPath;
  String? _gstDocPath;
  bool _showStep2ValidationErrors = false;
  bool _showDocValidationErrors = false;
  final ImagePicker _imagePicker = ImagePicker();

  List<String> _getMissingRequiredDocs() {
    final List<String> missing = [];
    if (_aadharPath == null || _aadharPath!.trim().isEmpty) {
      missing.add('Aadhaar / ID Proof');
    }
    if (_panPath == null || _panPath!.trim().isEmpty) {
      missing.add('PAN Card');
    }
    if (_businessCertPath == null || _businessCertPath!.trim().isEmpty) {
      missing.add('Business Registration / MSME');
    }
    if (_addressProofPath == null || _addressProofPath!.trim().isEmpty) {
      missing.add('Address Proof');
    }
    return missing;
  }

  int _getUploadedRequiredDocsCount() {
    int count = 0;
    if (_aadharPath != null && _aadharPath!.trim().isNotEmpty) count++;
    if (_panPath != null && _panPath!.trim().isNotEmpty) count++;
    if (_businessCertPath != null && _businessCertPath!.trim().isNotEmpty) count++;
    if (_addressProofPath != null && _addressProofPath!.trim().isNotEmpty) count++;
    return count;
  }

  Future<void> _pickDocumentImage(String key, ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (picked != null) {
        setState(() {
          if (key == 'aadhar') _aadharPath = picked.path;
          if (key == 'pan') _panPath = picked.path;
          if (key == 'businessCert') _businessCertPath = picked.path;
          if (key == 'addressProof') _addressProofPath = picked.path;
          if (key == 'gstDoc') _gstDocPath = picked.path;

          if (_getMissingRequiredDocs().isEmpty) {
            _showDocValidationErrors = false;
          }
        });
        if (mounted) {
          Utils.showSuccess('Document selected: ${picked.name}');
        }
      }
    } catch (e) {
      if (mounted) {
        Utils.showError('Could not pick document: $e');
      }
    }
  }

  void _showDocumentSourceSheet(String key, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Upload $title',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select a clear photo or document from your device',
                style: TextStyle(fontSize: 13, color: AppColors.darkGrey),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _pickDocumentImage(key, ImageSource.camera);
                      },
                      icon: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                      label: const Text('Camera', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _pickDocumentImage(key, ImageSource.gallery);
                      },
                      icon: const Icon(Icons.photo_library_rounded, color: AppColors.white),
                      label: const Text('Gallery', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Step 4 State: Review
  bool _agreedToTerms = true;

  late final VendorRegistrationController _vendorController;

  void _syncCategory(String categoryName) {
    if (Get.isRegistered<CategoryController>()) {
      final id = CategoryController.to.resolveCategoryId(categoryName);
      if (id.isNotEmpty) {
        _vendorController.selectedCategoryId.value = id;
        _vendorController.selectedCategoryName.value = categoryName;
        return;
      }
    }
    if (_vendorController.categories.isNotEmpty) {
      final match = _vendorController.categories.firstWhereOrNull(
        (c) =>
            c.name?.toLowerCase().trim() == categoryName.toLowerCase().trim() ||
            categoryName.toLowerCase().contains(c.name?.toLowerCase().trim() ?? '') ||
            (c.name != null &&
                categoryName.toLowerCase().contains(c.name!.toLowerCase().trim())),
      );
      if (match != null && match.id != null) {
        _vendorController.selectedCategoryId.value = match.id!;
        _vendorController.selectedCategoryName.value = match.name ?? categoryName;
        return;
      }
    }
  }

  void _syncPlan(String planId) {
    _vendorController.selectedSubscriptionPlanId.value = planId;
    if (_vendorController.subscriptionPlans.isNotEmpty) {
      final match = _vendorController.subscriptionPlans.firstWhereOrNull(
        (p) =>
            p.id == planId ||
            (p.durationInMonths != null && planId.contains('${p.durationInMonths}')) ||
            (p.type != null && planId.contains(p.type!.split(' ').first)) ||
            (p.title != null && p.title!.toLowerCase().contains(planId.toLowerCase())),
      );
      if (match != null && match.id != null) {
        _vendorController.selectedSubscriptionPlanId.value = match.id!;
      }
    }
  }

  String _resolveCategoryId() {
    String categoryId = _vendorController.selectedCategoryId.value;
    if (categoryId.isNotEmpty) return categoryId;
    if (Get.isRegistered<CategoryController>()) {
      final id = CategoryController.to.resolveCategoryId(_selectedCategory);
      if (id.isNotEmpty) return id;
    }
    if (_vendorController.categories.isNotEmpty) {
      final match = _vendorController.categories.firstWhereOrNull(
        (c) =>
            c.name?.toLowerCase().trim() == _selectedCategory.toLowerCase().trim() ||
            _selectedCategory.toLowerCase().contains(c.name?.toLowerCase().trim() ?? '') ||
            (c.name != null &&
                _selectedCategory.toLowerCase().contains(c.name!.toLowerCase().trim())),
      );
      if (match != null && match.id != null) return match.id!;
    }
    return '';
  }

  String _resolvePlanId() {
    String planId = _vendorController.selectedSubscriptionPlanId.value;
    if (planId.isNotEmpty &&
        planId != '6_months' &&
        planId != '3_months' &&
        planId != '12_months') {
      return planId;
    }
    if (_selectedPlan.isNotEmpty &&
        _selectedPlan != '6_months' &&
        _selectedPlan != '3_months' &&
        _selectedPlan != '12_months') {
      _vendorController.selectedSubscriptionPlanId.value = _selectedPlan;
      return _selectedPlan;
    }
    if (_vendorController.subscriptionPlans.isNotEmpty) {
      final prefix = _selectedPlan.split('_').first;
      final match = _vendorController.subscriptionPlans.firstWhereOrNull(
        (p) =>
            p.id == _selectedPlan ||
            (p.durationInMonths != null && _selectedPlan.contains('${p.durationInMonths}')) ||
            (p.type != null && _selectedPlan.contains(p.type!.split(' ').first)) ||
            (p.title != null && p.title!.toLowerCase().contains(prefix.toLowerCase())),
      );
      if (match != null && match.id != null && match.id!.isNotEmpty) {
        _vendorController.selectedSubscriptionPlanId.value = match.id!;
        return match.id!;
      }
      final firstId = _vendorController.subscriptionPlans.first.id;
      if (firstId != null && firstId.isNotEmpty) {
        _vendorController.selectedSubscriptionPlanId.value = firstId;
        return firstId;
      }
    }
    return _selectedPlan;
  }

  void _persistCurrentDraft() {
    StorageHelper().saveVendorDraft({
      'step': _currentStep,
      'category': _selectedCategory,
      'categoryId': _vendorController.selectedCategoryId.value,
      'businessName': _businessNameController.text.trim(),
      'ownerName': _ownerNameController.text.trim(),
      'mobile': _mobileController.text.trim(),
      'email': _emailController.text.trim(),
      'address': _addressController.text.trim(),
      'experience': _experience,
      'description': _descriptionController.text.trim(),
      'gstNumber': _gstController.text.trim(),
      'aadharPath': _aadharPath,
      'panPath': _panPath,
      'businessCertPath': _businessCertPath,
      'addressProofPath': _addressProofPath,
      'gstDocPath': _gstDocPath,
      'selectedPlan': _selectedPlan,
      'isSubscriptionPaid': _isSubscriptionPaid,
    });
  }

  Future<void> _uploadVendorDetailsToServer() async {
    final missing = _getMissingRequiredDocs();
    if (missing.isNotEmpty) {
      setState(() {
        _currentStep = 3;
        _showDocValidationErrors = true;
      });
      Utils.showError(
        'Cannot save details: Required verification documents missing (${missing.join(', ')}).',
      );
      return;
    }

    final categoryId = _resolveCategoryId();
    final planId = _resolvePlanId();

    Utils.showInfo('Saving application & documents to server...');

    final res = await _vendorController.submitApplication(
      ownerName: _ownerNameController.text.trim().isNotEmpty
          ? _ownerNameController.text.trim()
          : (StorageHelper().getUserName() ?? 'Partner'),
      businessName: _businessNameController.text.trim().isNotEmpty
          ? _businessNameController.text.trim()
          : (StorageHelper().getUserName() ?? 'Royal Click Studio'),
      yearsOfExperience: _experience,
      businessDescription: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : 'Professional wedding services and premium deliverables on Widoora.',
      businessAddress: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : 'SCO 142, Sector 70, Mohali, Punjab',
      city: 'Mohali',
      gstNumber: _gstController.text.trim(),
      categoryId: categoryId,
      categoryName: _selectedCategory,
      subscriptionPlanId: planId,
      aadharFile: _aadharPath,
      panFile: _panPath,
      businessCertFile: _businessCertPath,
      addressProofFile: _addressProofPath,
      gstDocFile: _gstDocPath,
      isPreliminaryUpload: true,
    );

    if (!mounted) return;

    if (res.isSuccess == true) {
      Utils.showSuccess('Profile details & documents uploaded to server!');
    }
  }

  @override
  void initState() {
    super.initState();
    _vendorController = Get.isRegistered<VendorRegistrationController>()
        ? Get.find<VendorRegistrationController>()
        : Get.put(VendorRegistrationController());

    _vendorController.fetchCategories().then((_) {
      if (mounted) {
        _syncCategory(_selectedCategory);
        setState(() {});
      }
    });
    _vendorController.fetchSubscriptions().then((_) {
      if (mounted) {
        if (_vendorController.subscriptionPlans.isNotEmpty) {
          final serverPlans = _vendorController.subscriptionPlans;
          final existing = serverPlans.firstWhereOrNull((p) => p.id == _selectedPlan);
          if (existing == null) {
            final preferred = serverPlans.firstWhereOrNull(
              (p) => p.durationInMonths == 6 || p.type?.contains('6') == true,
            ) ?? serverPlans.first;
            if (preferred.id != null) {
              _selectedPlan = preferred.id!;
            }
          }
        }
        _syncPlan(_selectedPlan);
        setState(() {});
      }
    });

    final storage = StorageHelper();
    final draft = storage.getVendorDraft();

    if (draft != null) {
      _currentStep = (draft['step'] as int?) ?? widget.initialStep;
      if (draft['category'] != null && (draft['category'] as String).isNotEmpty) {
        _selectedCategory = draft['category'] as String;
      }
      _businessNameController.text = (draft['businessName'] as String?) ?? '';
      _ownerNameController.text = (draft['ownerName'] as String?) ?? '';
      _mobileController.text = (draft['mobile'] as String?) ?? '';
      _emailController.text = (draft['email'] as String?) ?? '';
      _addressController.text = (draft['address'] as String?) ?? '';
      _experience = (draft['experience'] as String?) ?? '5+ Years';
      _descriptionController.text = (draft['description'] as String?) ?? '';
      _gstController.text = (draft['gstNumber'] as String?) ?? '';
      _aadharPath = draft['aadharPath'] as String?;
      _panPath = draft['panPath'] as String?;
      _businessCertPath = draft['businessCertPath'] as String?;
      _addressProofPath = draft['addressProofPath'] as String?;
      _gstDocPath = draft['gstDocPath'] as String?;
      _selectedPlan = (draft['selectedPlan'] as String?) ?? '6_months';
      _isSubscriptionPaid = (draft['isSubscriptionPaid'] as bool?) ?? false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Utils.showInfo('Restored your saved application progress');
        }
      });
    } else {
      _currentStep = widget.initialStep;
      if (widget.initialCategory != null &&
          widget.initialCategory!.trim().isNotEmpty) {
        _selectedCategory = widget.initialCategory!.trim();
      }
      _businessNameController.text =
          (widget.initialBusinessName?.trim().isNotEmpty == true)
              ? widget.initialBusinessName!
              : (storage.getUserName() ?? '');
      _ownerNameController.text =
          (widget.initialOwnerName?.trim().isNotEmpty == true)
              ? widget.initialOwnerName!
              : (storage.getUserName() ?? '');
      _mobileController.text =
          (widget.initialPhone?.trim().isNotEmpty == true)
              ? widget.initialPhone!
              : (storage.getUserMobile() ?? '');
      _emailController.text =
          (widget.initialEmail?.trim().isNotEmpty == true)
              ? widget.initialEmail!
              : (storage.getUserEmail() ?? '');
      if (widget.initialExperience?.trim().isNotEmpty == true) {
        _experience = widget.initialExperience!.trim();
      }
    }

    // Auto-save draft on any text keystroke
    for (final c in [
      _businessNameController,
      _ownerNameController,
      _mobileController,
      _emailController,
      _addressController,
      _descriptionController,
      _gstController,
    ]) {
      c.addListener(_persistCurrentDraft);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _businessNameController,
      _ownerNameController,
      _mobileController,
      _emailController,
      _addressController,
      _descriptionController,
      _gstController,
    ]) {
      c.removeListener(_persistCurrentDraft);
    }
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

  void _nextStep() async {
    _persistCurrentDraft();

    if (_currentStep == 1) {
      if (_selectedCategory.trim().isEmpty) {
        Utils.showError('Please select your business category to continue.');
        return;
      }
    }

    if (_currentStep == 2) {
      final ownerName = _ownerNameController.text.trim();
      final businessName = _businessNameController.text.trim();
      final desc = _descriptionController.text.trim();
      final address = _addressController.text.trim();

      final List<String> missingFields = [];
      if (ownerName.length < 2) missingFields.add('Owner Full Name (min 2 chars)');
      if (businessName.length < 2) missingFields.add('Business / Studio Name (min 2 chars)');
      if (_experience.trim().isEmpty) missingFields.add('Years of Experience');
      if (desc.length < 10) missingFields.add('Business Description (min 10 chars)');
      if (address.length < 5) missingFields.add('Business Address / City (min 5 chars)');

      if (missingFields.isNotEmpty) {
        setState(() {
          _showStep2ValidationErrors = true;
        });
        Utils.showError(
          'Please fill in all mandatory basic details:\n• ${missingFields.join('\n• ')}',
          duration: const Duration(seconds: 4),
        );
        return;
      }
    }

    // Step 3 Validation: Required documents CANNOT be skipped
    if (_currentStep == 3) {
      final missing = _getMissingRequiredDocs();
      if (missing.isNotEmpty) {
        setState(() {
          _showDocValidationErrors = true;
        });
        Utils.showError(
          'Vendor cannot skip required verification documents:\n• ${missing.join('\n• ')}',
          duration: const Duration(seconds: 4),
        );
        return;
      }
    }

    // When on Step 4 (Review Application) moving to Step 5 (Subscription Plan):
    // UPLOAD DETAILS TO SERVER RIGHT NOW before buying plan!
    if (_currentStep == 4) {
      final missing = _getMissingRequiredDocs();
      if (missing.isNotEmpty) {
        setState(() {
          _currentStep = 3;
          _showDocValidationErrors = true;
        });
        Utils.showError('Please upload all required verification documents first.');
        return;
      }
      await _uploadVendorDetailsToServer();
      if (!mounted) return;
      setState(() => _currentStep = 5);
      _persistCurrentDraft();
      return;
    }

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
      _persistCurrentDraft();
    } else {
      _submitRegistration();
    }
  }

  void _prevStep() {
    _persistCurrentDraft();
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _submitRegistration() async {
    final missing = _getMissingRequiredDocs();
    if (missing.isNotEmpty) {
      setState(() {
        _currentStep = 3;
        _showDocValidationErrors = true;
      });
      Utils.showError(
        'Cannot submit: Required verification documents missing (${missing.join(', ')}).',
      );
      return;
    }

    final categoryId = _resolveCategoryId();
    final planId = _resolvePlanId();

    final res = await _vendorController.submitApplication(
      ownerName: _ownerNameController.text.trim().isNotEmpty
          ? _ownerNameController.text.trim()
          : (StorageHelper().getUserName() ?? 'Partner'),
      businessName: _businessNameController.text.trim().isNotEmpty
          ? _businessNameController.text.trim()
          : (StorageHelper().getUserName() ?? 'Royal Click Studio'),
      yearsOfExperience: _experience,
      businessDescription: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : 'Professional wedding services and premium deliverables on Widoora.',
      businessAddress: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : 'SCO 142, Sector 70, Mohali, Punjab',
      city: 'Mohali',
      gstNumber: _gstController.text.trim(),
      categoryId: categoryId,
      categoryName: _selectedCategory,
      subscriptionPlanId: planId,
      aadharFile: _aadharPath,
      panFile: _panPath,
      businessCertFile: _businessCertPath,
      addressProofFile: _addressProofPath,
      gstDocFile: _gstDocPath,
      isPreliminaryUpload: false,
    );

    // Clear local draft upon final submission
    await StorageHelper().clearVendorDraft();

    if (!mounted) return;

    if (res.isSuccess == true || _vendorController.isDraftSavedOnServer.value) {
      Navigator.of(context).pushReplacement(
        FadeScaleRoute(
          page: VendorSubmittedScreen(
            businessName: _businessNameController.text.trim().isNotEmpty
                ? _businessNameController.text.trim()
                : 'Royal Click Studio',
            businessType: _selectedCategory,
            ownerName: _ownerNameController.text.trim().isNotEmpty
                ? _ownerNameController.text.trim()
                : 'Partner',
            applicationId: res.data?.applicationId ??
                StorageHelper().getApplicationId() ??
                'WDV12345678',
          ),
        ),
      );
    }
  }
  void _showPaymentSheet() {
    final plan = _getSelectedPlan();
    if (plan == null) {
      Utils.showError('Please wait for active plans to load, or select a plan to continue.');
      return;
    }
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
                        'Widoora Partner Membership',
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
                          setSheetState(() => isProcessing = true);
                          await Future.delayed(const Duration(milliseconds: 900));
                          if (!mounted) return;
                          setState(() => _isSubscriptionPaid = true);
                          nav.pop();
                          Utils.showSuccess('Payment Successful! ${plan['name']} activated.');
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
                      '256-Bit SSL Encrypted • Powered by Widoora Pay',
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

        if (Get.isRegistered<CategoryController>() &&
            CategoryController.to.isLoading.value) ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            ),
          ),
        ] else if (_businessTypes.isEmpty) ...[
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.storefront_outlined, size: 36, color: AppColors.grey),
                  const SizedBox(height: 8),
                  Text(
                    'No categories available from server',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Vendor categories will appear here once loaded from the server.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () async {
                      if (Get.isRegistered<CategoryController>()) {
                        await CategoryController.to.fetchCategories(forceRefresh: true);
                        if (mounted) setState(() {});
                      }
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.primary),
                    label: const Text(
                      'Retry Loading',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          // 3-Column Grid
          GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 12,
            childAspectRatio: 0.76,
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
                _syncCategory(type.title);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
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
                    if (type.hasServerIcon)
                      CachedImageView(
                        imageUrl: type.iconUrl,
                        width: 52,
                        height: 52,
                        fit: BoxFit.contain,
                        fallbackIcon: type.icon,
                        iconColor: type.color,
                        iconSize: 48,
                      )
                    else
                      Icon(
                        type.icon,
                        color: type.color,
                        size: 48,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      type.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 13,
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
      ],
    );
  }
  // ─────────────────────────────────────────────────────────────
  // STEP 2: BASIC INFO
  // ─────────────────────────────────────────────────────────────
  Widget _buildStep2BasicInfo() {
    final ownerNameErr = _showStep2ValidationErrors && _ownerNameController.text.trim().length < 2
        ? 'Please enter owner / representative name (min 2 characters)'
        : null;
    final businessNameErr = _showStep2ValidationErrors && _businessNameController.text.trim().length < 2
        ? 'Please enter business / studio name (min 2 characters)'
        : null;
    final descErr = _showStep2ValidationErrors && _descriptionController.text.trim().length < 10
        ? 'Please describe your services (min 10 characters)'
        : null;
    final addressErr = _showStep2ValidationErrors && _addressController.text.trim().length < 5
        ? 'Please enter complete business address / city (min 5 characters)'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Owner Full Name (moved UP)
        _buildFormField(
          label: 'Owner / Representative Full Name',
          hint: 'e.g. Aman Verma',
          controller: _ownerNameController,
          icon: Icons.person_outline_rounded,
          isRequired: true,
          errorText: ownerNameErr,
        ),
        const SizedBox(height: 16),

        // 2. Business / Studio Name
        _buildFormField(
          label: 'Business / Studio Name',
          hint: 'e.g. Royal Click Studio',
          controller: _businessNameController,
          icon: Icons.business_outlined,
          isRequired: true,
          errorText: businessNameErr,
        ),
        const SizedBox(height: 16),

        // 3. Years of Experience
        RichText(
          text: const TextSpan(
            text: 'Years of Experience',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
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
            RichText(
              text: const TextSpan(
                text: 'Business Description',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
                children: [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
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
            border: Border.all(
              color: descErr != null
                  ? AppColors.error
                  : AppColors.grey.withValues(alpha: 0.3),
              width: descErr != null ? 1.4 : 1.0,
            ),
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
        if (descErr != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              descErr,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // 5. Business Address / City
        _buildFormField(
          label: 'Business Address / City',
          hint: 'e.g. SCO 142, Sector 70, Mohali, Punjab',
          controller: _addressController,
          icon: Icons.location_on_outlined,
          maxLines: 2,
          isRequired: true,
          errorText: addressErr,
        ),

        const SizedBox(height: 16),

        // 6. GST Number (Optional) - added in Basic Info
        _buildFormField(
          label: 'GST Number (Optional)',
          hint: 'Enter GST number (e.g. 03AABCR1234F1Z8)',
          controller: _gstController,
          icon: Icons.receipt_long_outlined,
          isRequired: false,
        ),
      ],
    );
  }

  Widget _buildDocPickerCard({
    required String key,
    required String title,
    required String subtitle,
    required String? filePath,
    required bool isRequired,
    required IconData icon,
  }) {
    final isSelected = filePath != null && filePath.isNotEmpty;
    final isMissingError = _showDocValidationErrors && isRequired && !isSelected;
    final fileName = isSelected ? filePath.split(RegExp(r'[\\/]')).last : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isMissingError ? const Color(0xFFFFF6F6) : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? AppColors.success.withValues(alpha: 0.6)
              : (isMissingError
                  ? AppColors.error
                  : AppColors.grey.withValues(alpha: 0.25)),
          width: isSelected || isMissingError ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.success.withValues(alpha: 0.08)
                : (isMissingError
                    ? AppColors.error.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.03)),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDocumentSourceSheet(key, title),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                if (isSelected)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 48,
                      height: 48,
                      color: AppColors.cream,
                      child: Image.file(
                        File(filePath),
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 26,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isMissingError
                          ? AppColors.error.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isMissingError ? Icons.error_outline_rounded : icon,
                      color: isMissingError ? AppColors.error : AppColors.primary,
                      size: 24,
                    ),
                  ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: isMissingError ? AppColors.error : AppColors.black,
                              ),
                            ),
                          ),
                          if (isRequired) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.success.withValues(alpha: 0.12)
                                    : (isMissingError
                                        ? AppColors.error
                                        : AppColors.error.withValues(alpha: 0.1)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isSelected
                                    ? 'ATTACHED ✓'
                                    : (isMissingError ? 'REQUIRED *' : 'REQUIRED'),
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                  color: isSelected
                                      ? AppColors.success
                                      : (isMissingError ? Colors.white : AppColors.error),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isSelected
                            ? (fileName != null ? _shortenFileName(fileName) : 'Uploaded')
                            : (isMissingError ? 'Please upload this required document' : subtitle),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isSelected
                              ? AppColors.success
                              : (isMissingError ? AppColors.error : AppColors.darkGrey),
                          fontWeight: isSelected || isMissingError ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.success.withValues(alpha: 0.12)
                        : (isMissingError
                            ? AppColors.error.withValues(alpha: 0.12)
                            : AppColors.primary.withValues(alpha: 0.08)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.success.withValues(alpha: 0.5)
                          : (isMissingError
                              ? AppColors.error.withValues(alpha: 0.6)
                              : AppColors.primary.withValues(alpha: 0.3)),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : (isMissingError ? Icons.warning_amber_rounded : Icons.upload_file_rounded),
                        size: 13,
                        color: isSelected
                            ? AppColors.success
                            : (isMissingError ? AppColors.error : AppColors.primary),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isSelected
                            ? 'Selected ✓'
                            : (isMissingError ? 'Upload *' : 'Upload'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.success
                              : (isMissingError ? AppColors.error : AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 3: DOCUMENTS
  // ─────────────────────────────────────────────────────────────
  Widget _buildStep3Documents() {
    final uploadedCount = _getUploadedRequiredDocsCount();
    final allUploaded = uploadedCount == 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Upload Verification Documents',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: allUploaded
                    ? AppColors.success.withValues(alpha: 0.12)
                    : (_showDocValidationErrors
                        ? AppColors.error.withValues(alpha: 0.12)
                        : AppColors.primary.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: allUploaded
                      ? AppColors.success
                      : (_showDocValidationErrors ? AppColors.error : AppColors.primary),
                  width: 1.2,
                ),
              ),
              child: Text(
                '$uploadedCount/4 Required',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: allUploaded
                      ? AppColors.success
                      : (_showDocValidationErrors ? AppColors.error : AppColors.primary),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          allUploaded
              ? 'All 4 required documents attached. You can proceed to review.'
              : 'All 4 required documents (Aadhaar, PAN, Business & Address Proof) must be uploaded to continue. Skipping is not permitted.',
          style: TextStyle(
            fontSize: 12.5,
            color: _showDocValidationErrors && !allUploaded ? AppColors.error : AppColors.darkGrey,
            fontWeight: _showDocValidationErrors && !allUploaded ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 12),
        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: uploadedCount / 4,
            backgroundColor: AppColors.greyLight.withValues(alpha: 0.5),
            valueColor: AlwaysStoppedAnimation<Color>(
              allUploaded
                  ? AppColors.success
                  : (_showDocValidationErrors ? AppColors.error : AppColors.primary),
            ),
            minHeight: 5,
          ),
        ),
        const SizedBox(height: 18),
        _buildDocPickerCard(
          key: 'aadhar',
          title: 'Aadhaar / ID Proof',
          subtitle: 'Government ID card of owner',
          filePath: _aadharPath,
          isRequired: true,
          icon: Icons.badge_outlined,
        ),
        _buildDocPickerCard(
          key: 'pan',
          title: 'PAN Card',
          subtitle: 'Owner or business PAN card',
          filePath: _panPath,
          isRequired: true,
          icon: Icons.credit_card_outlined,
        ),
        _buildDocPickerCard(
          key: 'businessCert',
          title: 'Business Registration / MSME',
          subtitle: 'Trade certificate or incorporation',
          filePath: _businessCertPath,
          isRequired: true,
          icon: Icons.apartment_outlined,
        ),
        _buildDocPickerCard(
          key: 'addressProof',
          title: 'Address Proof',
          subtitle: 'Electricity bill, rent agreement',
          filePath: _addressProofPath,
          isRequired: true,
          icon: Icons.receipt_long_outlined,
        ),
        _buildDocPickerCard(
          key: 'gstDoc',
          title: 'GST Certificate (Optional)',
          subtitle: 'GSTIN document if registered',
          filePath: _gstDocPath,
          isRequired: false,
          icon: Icons.verified_outlined,
        ),
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
                    'Uploaded Documents (5)',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...[
                {'name': 'Aadhaar / ID Proof', 'path': _aadharPath, 'req': true},
                {'name': 'PAN Card', 'path': _panPath, 'req': true},
                {'name': 'Business Registration', 'path': _businessCertPath, 'req': true},
                {'name': 'Address Proof', 'path': _addressProofPath, 'req': true},
                {'name': 'GST Certificate', 'path': _gstDocPath, 'req': false},
              ].map((doc) {
                final hasPath = doc['path'] != null && (doc['path'] as String).isNotEmpty;
                final fileName = hasPath ? (doc['path'] as String).split(RegExp(r'[\\/]')).last : null;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    children: [
                      Icon(
                        hasPath ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        color: hasPath ? const Color(0xFF2E7D32) : AppColors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          doc['name'] as String,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 130),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: hasPath ? const Color(0xFFE8F5E9) : AppColors.cream,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: hasPath
                                  ? const Color(0xFFA5D6A7)
                                  : AppColors.grey.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasPath) ...[
                                const Icon(Icons.attachment_rounded, size: 11, color: Color(0xFF2E7D32)),
                                const SizedBox(width: 3),
                              ],
                              Flexible(
                                child: Text(
                                  hasPath
                                      ? (fileName != null ? _shortenFileName(fileName) : 'Uploaded ✓')
                                      : (doc['req'] == true ? 'Default' : 'Optional'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: hasPath ? const Color(0xFF2E7D32) : AppColors.darkGrey,
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
                  'I confirm that all details and submitted documents are authentic and accurate as per Widoora Vendor Partnership Guidelines.',
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

  String _shortenFileName(String fileName) {
    if (fileName.length <= 14) return fileName;
    final dotIndex = fileName.lastIndexOf('.');
    final ext = dotIndex != -1 ? fileName.substring(dotIndex) : '';
    final nameWithoutExt = dotIndex != -1 ? fileName.substring(0, dotIndex) : fileName;
    if (nameWithoutExt.length > 7) {
      return '${nameWithoutExt.substring(0, 6)}...$ext';
    }
    return fileName;
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
          'Select your partnership duration (3, 6, or 12 Months) to get verified, receive real-time client leads, and activate your vendor profile on Widoora.',
          style: TextStyle(fontSize: 12.5, color: AppColors.darkGrey, height: 1.4),
        ),
        const SizedBox(height: 14),

        // Server Sync Confirmation Banner
        Container(
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF86EFAC)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.cloud_done_rounded, color: Color(0xFF16A34A), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Details & Documents Saved to Server',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15803D),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Your business profile has been securely registered on our server. Select a plan below to activate instant client bookings.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF166534),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Plans List (Fetched dynamically from /api/subscription/list)
        Obx(() {
          final isLoading = _vendorController.isLoading.value;
          final plans = _availablePlans;

          if (isLoading && plans.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36),
              alignment: Alignment.center,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Loading live subscription plans from server...',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.darkGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          if (plans.isEmpty) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.cloud_off_rounded, color: AppColors.darkGrey, size: 36),
                  const SizedBox(height: 8),
                  const Text(
                    'No active plans returned by server',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap below to reload dynamic subscription plans from http://192.168.1.100:5174/api/subscription/list',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.darkGrey, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: () => _vendorController.fetchSubscriptions(forceRefresh: true),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Retry Fetching Plans'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: plans.map((plan) {
              final isSelected = _selectedPlan == plan['id'];
              final price = _getPlanPrice(plan);
              final isPopular = plan['isPopular'] == true;
              final savings = plan['savings'] as String?;
              final status = (plan['status'] as String?) ?? 'Active';

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPlan = plan['id'] as String;
                    _isSubscriptionPaid = false;
                  });
                  _syncPlan(plan['id'] as String);
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
                                Expanded(
                                  child: Row(
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
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    plan['name'] as String,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w800,
                                                      color: AppColors.black,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
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
                                                const SizedBox(width: 4),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.success.withValues(alpha: 0.12),
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  child: Text(
                                                    '● $status',
                                                    style: const TextStyle(
                                                      fontSize: 8.5,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.success,
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
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
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
                                  _syncPlan(plan['id'] as String);
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
            }).toList(),
          );
        }),


        const SizedBox(height: 10),

        // Buy / Status Card
        if (_isSubscriptionPaid && activePlan != null)
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
                          Text(
                            'Payment Successful • Plan ID: ${activePlan['id']}',
                            style: const TextStyle(fontSize: 12, color: AppColors.darkGrey),
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
    bool isRequired = false,
    String? errorText,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : AppColors.grey.withValues(alpha: 0.3),
              width: hasError ? 1.4 : 1.0,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: (_) {
              if (_showStep2ValidationErrors) {
                setState(() {});
              }
            },
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.grey, fontSize: 13),
              prefixIcon: icon != null
                  ? Icon(icon, color: hasError ? AppColors.error : AppColors.primary, size: 18)
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
        if (hasError) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomBar() {
    String buttonText;
    if (_currentStep == 5) {
      final activePlan = _getSelectedPlan();
      final activePrice = _getPlanPrice(activePlan);
      final planName = activePlan?['name'] ?? 'Plan';
      buttonText = _isSubscriptionPaid
          ? 'Complete Registration'
          : (activePlan != null
              ? 'Buy $planName (₹$activePrice)'
              : 'Choose a Plan');
    } else if (_currentStep == 4) {
      buttonText = 'Save Details & View Plans';
    } else if (_currentStep == 3) {
      final uploadedCount = _getUploadedRequiredDocsCount();
      buttonText = uploadedCount == 4
          ? 'Continue to Review (4/4 Uploaded ✓)'
          : 'Upload Required Documents ($uploadedCount/4)';
    } else {
      buttonText = 'Continue';
    }

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
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
          if (_currentStep == 5) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: TextButton(
                onPressed: _submitRegistration,
                child: const Text(
                  'Skip Plan for Now & Finish Application',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
