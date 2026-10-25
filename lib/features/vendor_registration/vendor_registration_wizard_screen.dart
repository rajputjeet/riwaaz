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
import '../../data/api_provider/vendor_api_provider.dart';
import '../../shared/widgets/app_search_bar.dart';
import '../../shared/widgets/service_categories_bar.dart';
import '../../utils/helper/storage_helper.dart';
import '../../utils/utils.dart';
import 'controllers/vendor_registration_controller.dart';
import '../auth/controllers/auth_controller.dart';
import '../auth/vendor_signup_screen.dart';
import 'vendor_submitted_screen.dart';
import 'vendor_subscription_checkout_flow.dart';

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
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _addressUrlController = TextEditingController();

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

  List<Map<String, dynamic>> get _availablePlans {
    if (_vendorController.subscriptionPlans.isNotEmpty) {
      return _vendorController.subscriptionPlans.map((sub) {
        final id = sub.id ?? '';
        final name = sub.displayName;
        final duration = sub.durationLabel;
        final months =
            sub.durationInMonths ??
            (duration.contains('12')
                ? 12
                : (duration.contains('6')
                      ? 6
                      : (duration.contains('3') ? 3 : 1)));
        final price = sub.planPrice;
        final monthlyRate = months > 0 ? (price / months).round() : price;
        final desc = sub.description?.trim() ?? '';
        final isPopular =
            months == 6 ||
            name.toLowerCase().contains('gold') ||
            name.toLowerCase().contains('popular');
        final isBestValue =
            months == 12 ||
            name.toLowerCase().contains('royal') ||
            name.toLowerCase().contains('platinum');
        final badge = isPopular
            ? 'MOST POPULAR'
            : (isBestValue ? 'BEST VALUE' : (months == 1 ? 'STARTER' : 'PRO'));
        final color = isPopular
            ? AppColors.primary
            : (isBestValue ? const Color(0xFF790D16) : const Color(0xFF6B7280));
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
          'savings': isBestValue ? 'SAVE 25%' : (isPopular ? 'SAVE 15%' : null),
          'isPopular': isPopular,
          'color': color,
          'icon': icon,
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

  // Step 3 State: Documents & KYC with real ImagePickers
  String? _aadharPath; // Aadhaar Card (Front)
  String? _aadharBackPath; // Aadhaar Card (Back)
  String? _liveSelfiePath; // Live Selfie verification photo
  String? _panPath;
  String? _businessCertPath;
  String? _addressProofPath;
  String? _gstDocPath;
  bool _showStep2ValidationErrors = false;
  bool _showDocValidationErrors = false;
  final ImagePicker _imagePicker = ImagePicker();

  List<String> _getMissingRequiredDocs() {
    final List<String> missing = [];
    if (_liveSelfiePath == null || _liveSelfiePath!.trim().isEmpty) {
      missing.add('Live Selfie');
    }
    if (_aadharPath == null || _aadharPath!.trim().isEmpty) {
      missing.add('Aadhaar Card (Front)');
    }
    if (_aadharBackPath == null || _aadharBackPath!.trim().isEmpty) {
      missing.add('Aadhaar Card (Back)');
    }
    if (_panPath == null || _panPath!.trim().isEmpty) {
      missing.add('PAN Card');
    }
    return missing;
  }

  int _getUploadedRequiredDocsCount() {
    int count = 0;
    if (_liveSelfiePath != null && _liveSelfiePath!.trim().isNotEmpty) count++;
    if (_aadharPath != null && _aadharPath!.trim().isNotEmpty) count++;
    if (_aadharBackPath != null && _aadharBackPath!.trim().isNotEmpty) count++;
    if (_panPath != null && _panPath!.trim().isNotEmpty) count++;
    return count;
  }

  Future<void> _captureLiveSelfie() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (picked != null) {
        setState(() {
          _liveSelfiePath = picked.path;
          if (_getMissingRequiredDocs().isEmpty) {
            _showDocValidationErrors = false;
          }
        });
        if (mounted) {
          Utils.showSuccess('Live selfie captured successfully!');
        }
      }
    } catch (e) {
      if (mounted) Utils.showError('Could not capture selfie: $e');
    }
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
          if (key == 'aadhar' || key == 'aadharFront')
            _aadharPath = picked.path;
          if (key == 'aadharBack') _aadharBackPath = picked.path;
          if (key == 'liveSelfie') _liveSelfiePath = picked.path;
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
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        color: AppColors.primary,
                      ),
                      label: const Text(
                        'Camera',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                      icon: const Icon(
                        Icons.photo_library_rounded,
                        color: AppColors.white,
                      ),
                      label: const Text(
                        'Gallery',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
            categoryName.toLowerCase().contains(
              c.name?.toLowerCase().trim() ?? '',
            ) ||
            (c.name != null &&
                categoryName.toLowerCase().contains(
                  c.name!.toLowerCase().trim(),
                )),
      );
      if (match != null && match.id != null) {
        _vendorController.selectedCategoryId.value = match.id!;
        _vendorController.selectedCategoryName.value =
            match.name ?? categoryName;
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
            (p.durationInMonths != null &&
                planId.contains('${p.durationInMonths}')) ||
            (p.type != null && planId.contains(p.type!.split(' ').first)) ||
            (p.title != null &&
                p.title!.toLowerCase().contains(planId.toLowerCase())),
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
            c.name?.toLowerCase().trim() ==
                _selectedCategory.toLowerCase().trim() ||
            _selectedCategory.toLowerCase().contains(
              c.name?.toLowerCase().trim() ?? '',
            ) ||
            (c.name != null &&
                _selectedCategory.toLowerCase().contains(
                  c.name!.toLowerCase().trim(),
                )),
      );
      if (match != null && match.id != null) return match.id!;
    }
    return '';
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
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'pincode': _pincodeController.text.trim(),
      'addressUrl': _addressUrlController.text.trim(),
      'experience': _experience,
      'description': _descriptionController.text.trim(),
      'gstNumber': _gstController.text.trim(),
      'aadharPath': _aadharPath,
      'aadharBackPath': _aadharBackPath,
      'liveSelfiePath': _liveSelfiePath,
      'panPath': _panPath,
      'businessCertPath': _businessCertPath,
      'addressProofPath': _addressProofPath,
      'gstDocPath': _gstDocPath,
      'selectedPlan': _selectedPlan,
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

    Utils.showInfo('Saving your application and documents...');

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
          : (StorageHelper().getUserAddress() ??
                'SCO 142, Sector 70, Mohali, Punjab'),
      addressUrl: _addressUrlController.text.trim().isNotEmpty
          ? _addressUrlController.text.trim()
          : null,
      city: _cityController.text.trim().isNotEmpty
          ? _cityController.text.trim()
          : (StorageHelper().getUserCity() ?? 'Mohali'),
      state: _stateController.text.trim().isNotEmpty
          ? _stateController.text.trim()
          : (StorageHelper().getUserState() ?? 'Punjab'),
      pincode: _pincodeController.text.trim().isNotEmpty
          ? _pincodeController.text.trim()
          : (StorageHelper().getUserPincode() ?? '160071'),
      gstNumber: _gstController.text.trim(),
      categoryId: categoryId,
      categoryName: _selectedCategory,
      aadharFile: _aadharPath,
      aadharFrontFile: _aadharPath,
      aadharBackFile: _aadharBackPath,
      liveSelfieFile: _liveSelfiePath,
      panFile: _panPath,
      businessCertFile: _businessCertPath,
      addressProofFile: _addressProofPath,
      gstDocFile: _gstDocPath,
      isPreliminaryUpload: true,
    );

    if (!mounted) return;

    if (res.isSuccess == true) {
      Utils.showSuccess('Your profile details and documents were saved.');
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
          final existing = serverPlans.firstWhereOrNull(
            (p) => p.id == _selectedPlan,
          );
          if (existing == null) {
            final preferred =
                serverPlans.firstWhereOrNull(
                  (p) =>
                      p.durationInMonths == 6 || p.type?.contains('6') == true,
                ) ??
                serverPlans.first;
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
      if (draft['category'] != null &&
          (draft['category'] as String).isNotEmpty) {
        _selectedCategory = draft['category'] as String;
      }
      _businessNameController.text = (draft['businessName'] as String?) ?? '';
      _ownerNameController.text = (draft['ownerName'] as String?) ?? '';
      _mobileController.text = (draft['mobile'] as String?) ?? '';
      _emailController.text = (draft['email'] as String?) ?? '';
      _addressController.text =
          (draft['address'] as String?)?.trim().isNotEmpty == true
          ? (draft['address'] as String).trim()
          : (storage.getUserAddress() ?? '');
      _cityController.text =
          (draft['city'] as String?)?.trim().isNotEmpty == true
          ? (draft['city'] as String).trim()
          : (storage.getUserCity() ?? '');
      _stateController.text =
          (draft['state'] as String?)?.trim().isNotEmpty == true
          ? (draft['state'] as String).trim()
          : (storage.getUserState() ?? '');
      _pincodeController.text =
          (draft['pincode'] as String?)?.trim().isNotEmpty == true
          ? (draft['pincode'] as String).trim()
          : (storage.getUserPincode() ?? '');
      _addressUrlController.text = (draft['addressUrl'] as String?) ?? '';
      _experience = (draft['experience'] as String?) ?? '5+ Years';
      _descriptionController.text = (draft['description'] as String?) ?? '';
      _gstController.text = (draft['gstNumber'] as String?) ?? '';
      _aadharPath = draft['aadharPath'] as String?;
      _aadharBackPath = draft['aadharBackPath'] as String?;
      _liveSelfiePath = draft['liveSelfiePath'] as String?;
      _panPath = draft['panPath'] as String?;
      _businessCertPath = draft['businessCertPath'] as String?;
      _addressProofPath = draft['addressProofPath'] as String?;
      _gstDocPath = draft['gstDocPath'] as String?;
      _selectedPlan = (draft['selectedPlan'] as String?) ?? '6_months';
      // Local drafts can restore selections, never proof of purchase.

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
      _mobileController.text = (widget.initialPhone?.trim().isNotEmpty == true)
          ? widget.initialPhone!
          : (storage.getUserMobile() ?? '');
      _emailController.text = (widget.initialEmail?.trim().isNotEmpty == true)
          ? widget.initialEmail!
          : (storage.getUserEmail() ?? '');
      if (widget.initialExperience?.trim().isNotEmpty == true) {
        _experience = widget.initialExperience!.trim();
      }
      if (_addressController.text.trim().isEmpty) {
        final savedAddr = storage.getUserAddress();
        if (savedAddr != null && savedAddr.isNotEmpty) {
          _addressController.text = savedAddr;
        }
      }
      if (_cityController.text.trim().isEmpty) {
        final savedCity = storage.getUserCity();
        if (savedCity != null && savedCity.isNotEmpty) {
          _cityController.text = savedCity;
        }
      }
      if (_stateController.text.trim().isEmpty) {
        final savedState = storage.getUserState();
        if (savedState != null && savedState.isNotEmpty) {
          _stateController.text = savedState;
        }
      }
      if (_pincodeController.text.trim().isEmpty) {
        final savedPincode = storage.getUserPincode();
        if (savedPincode != null && savedPincode.isNotEmpty) {
          _pincodeController.text = savedPincode;
        }
      }
    }

    // Auto-save draft on any text keystroke
    for (final c in [
      _businessNameController,
      _ownerNameController,
      _mobileController,
      _emailController,
      _addressController,
      _cityController,
      _stateController,
      _pincodeController,
      _addressUrlController,
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
      _cityController,
      _stateController,
      _pincodeController,
      _addressUrlController,
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
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _addressUrlController.dispose();
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
      final city = _cityController.text.trim();
      final state = _stateController.text.trim();
      final pincode = _pincodeController.text.trim();

      final List<String> missingFields = [];
      if (ownerName.length < 2)
        missingFields.add('Owner Full Name (min 2 chars)');
      if (businessName.length < 2)
        missingFields.add('Business / Studio Name (min 2 chars)');
      if (_experience.trim().isEmpty) missingFields.add('Years of Experience');
      if (desc.length < 10)
        missingFields.add('Business Description (min 10 chars)');
      if (address.length < 3)
        missingFields.add('Street Address / Locality (min 3 chars)');
      if (city.length < 2) missingFields.add('City (min 2 chars)');
      if (state.length < 2) missingFields.add('State (min 2 chars)');
      if (pincode.length < 4) missingFields.add('PIN Code (min 4 chars)');

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

      // Persist latest address details into storage
      final storage = StorageHelper();
      storage.saveUserAddress(address);
      storage.saveUserCity(city);
      storage.saveUserState(state);
      storage.saveUserPincode(pincode);
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
        Utils.showError(
          'Please upload all required verification documents first.',
        );
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
        await _showPaymentSheet();
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
    if (_currentStep > 1) {
      setState(() => _currentStep--);
      _persistCurrentDraft();
    } else {
      _persistCurrentDraft();
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(
          context,
        ).pushReplacement(FadeScaleRoute(page: const VendorSignupScreen()));
      }
    }
  }

  void _submitRegistration() async {
    if (_vendorController.isSubmitting.value) return;
    if (!_isSubscriptionPaid) {
      Utils.showError('Complete your plan purchase before submitting.');
      return;
    }

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

    try {
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
            : (StorageHelper().getUserAddress() ??
                  'SCO 142, Sector 70, Mohali, Punjab'),
        addressUrl: _addressUrlController.text.trim().isNotEmpty
            ? _addressUrlController.text.trim()
            : null,
        city: _cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : (StorageHelper().getUserCity() ?? 'Mohali'),
        state: _stateController.text.trim().isNotEmpty
            ? _stateController.text.trim()
            : (StorageHelper().getUserState() ?? 'Punjab'),
        pincode: _pincodeController.text.trim().isNotEmpty
            ? _pincodeController.text.trim()
            : (StorageHelper().getUserPincode() ?? '160071'),
        gstNumber: _gstController.text.trim(),
        categoryId: categoryId,
        categoryName: _selectedCategory,
        aadharFile: _aadharPath,
        aadharFrontFile: _aadharPath,
        aadharBackFile: _aadharBackPath,
        liveSelfieFile: _liveSelfiePath,
        panFile: _panPath,
        businessCertFile: _businessCertPath,
        addressProofFile: _addressProofPath,
        gstDocFile: _gstDocPath,
        isPreliminaryUpload: false,
      );

      if (!mounted) return;

      if (res.isSuccess == true ||
          _vendorController.isDraftSavedOnServer.value) {
        final nav = Navigator.of(context);
        // Clear local draft upon final submission
        await StorageHelper().clearVendorDraft();
        await StorageHelper().saveVendorOnboardingCompleted(true);

        nav.pushReplacement(
          FadeScaleRoute(
            page: VendorSubmittedScreen(
              businessName: _businessNameController.text.trim().isNotEmpty
                  ? _businessNameController.text.trim()
                  : 'Royal Click Studio',
              businessType: _selectedCategory,
              ownerName: _ownerNameController.text.trim().isNotEmpty
                  ? _ownerNameController.text.trim()
                  : 'Partner',
              applicationId:
                  res.data?.applicationId ??
                  StorageHelper().getApplicationId() ??
                  'WDV12345678',
            ),
          ),
        );
      } else {
        Utils.showError(
          res.message ??
              res.error ??
              'Failed to submit application. Please try again.',
        );
      }
    } catch (e) {
      if (mounted) {
        Utils.showError('An error occurred during submission: $e');
      }
    }
  }

  Future<void> _showPaymentSheet() async {
    final plan = _getSelectedPlan();
    if (plan == null) {
      Utils.showError(
        'Please wait for plans to load, or select a plan to continue.',
      );
      return;
    }

    final paymentCompleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => VendorSubscriptionCouponScreen(
          plan: plan,
          onPay: (paymentMethod, couponCode, transactionId) async {
            final planId = plan['id']?.toString() ?? '';
            if (planId.isEmpty ||
                planId.startsWith('3_') ||
                planId.startsWith('6_') ||
                planId.startsWith('12_')) {
              Utils.showError(
                'Subscription plan ID is missing. Please reload plans.',
              );
              return false;
            }
            final result = await VendorApiProvider().buyPlan(
              subscriptionPlanId: planId,
              paymentMethod: paymentMethod == 'Net banking'
                  ? 'NetBanking'
                  : paymentMethod,
              couponCode: couponCode,
              transactionId: transactionId,
            );
            if (!mounted) return false;
            if (result.isSuccess == true) {
              return true;
            }
            Utils.showError(
              result.message ??
                  result.error ??
                  'Plan purchase failed. Please try again.',
            );
            return false;
          },
        ),
      ),
    );
    if (!mounted || paymentCompleted != true) return;

    setState(() => _isSubscriptionPaid = true);
    Utils.showSuccess('Subscription activated successfully: ${plan['name']}.');
    _submitRegistration();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _prevStep();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary,
              size: 20,
            ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cream.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.4),
                    ),
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
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
                minHeight: 3,
              ),

              // Step Content
              Expanded(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  children: [_buildCurrentStepView()],
                ),
              ),

              // Bottom Continue Section
              _buildBottomBar(),
            ],
          ),
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

        Obx(() {
          final isCatLoading =
              (Get.isRegistered<CategoryController>() &&
                  (CategoryController.to.isLoading.value ||
                      (!CategoryController.to.isLoaded.value &&
                          CategoryController.to.categories.isEmpty))) ||
              _vendorController.isLoading.value;

          if (isCatLoading) {
            return const _VendorCategoryShimmerGrid();
          }

          if (_businessTypes.isEmpty) {
            return Center(
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
                    const Icon(
                      Icons.storefront_outlined,
                      size: 36,
                      color: AppColors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No categories available',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Vendor categories will appear here when available.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () async {
                        if (Get.isRegistered<CategoryController>()) {
                          await CategoryController.to.fetchCategories(
                            forceRefresh: true,
                          );
                          if (mounted) setState(() {});
                        }
                      },
                      icon: const Icon(
                        Icons.refresh_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      label: const Text(
                        'Retry Loading',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final query = _searchTypeController.text.toLowerCase().trim();
          final filteredTypes = query.isEmpty
              ? _businessTypes
              : _businessTypes
                    .where(
                      (t) =>
                          t.title.toLowerCase().contains(query) ||
                          t.desc.toLowerCase().contains(query),
                    )
                    .toList();

          if (filteredTypes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Text(
                  'No business types match "$query"',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.grey,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 14,
              childAspectRatio: 0.82,
            ),
            itemCount: filteredTypes.length,
            itemBuilder: (context, index) {
              final type = filteredTypes[index];
              final isSelected = _selectedCategory == type.title;

              return AnimatedTapWidget(
                onTap: () {
                  setState(() {
                    _selectedCategory = type.title;
                  });
                  _syncCategory(type.title);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ServiceIconWrap(
                          item: type,
                          size: 84,
                          iconSize: 64,
                          borderRadius: 18,
                          isSelected: isSelected,
                        ),
                        if (isSelected)
                          Positioned(
                            top: -3,
                            right: -3,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      type.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFF2C2424),
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 2: BASIC INFO
  // ─────────────────────────────────────────────────────────────
  Widget _buildStep2BasicInfo() {
    final ownerNameErr =
        _showStep2ValidationErrors &&
            _ownerNameController.text.trim().length < 2
        ? 'Please enter owner / representative name (min 2 characters)'
        : null;
    final businessNameErr =
        _showStep2ValidationErrors &&
            _businessNameController.text.trim().length < 2
        ? 'Please enter business / studio name (min 2 characters)'
        : null;
    final descErr =
        _showStep2ValidationErrors &&
            _descriptionController.text.trim().length < 10
        ? 'Please describe your services (min 10 characters)'
        : null;
    final addressErr =
        _showStep2ValidationErrors && _addressController.text.trim().length < 3
        ? 'Please enter street address / locality (min 3 characters)'
        : null;
    final cityErr =
        _showStep2ValidationErrors && _cityController.text.trim().length < 2
        ? 'Please enter city'
        : null;
    final stateErr =
        _showStep2ValidationErrors && _stateController.text.trim().length < 2
        ? 'Please enter state'
        : null;
    final pincodeErr =
        _showStep2ValidationErrors && _pincodeController.text.trim().length < 4
        ? 'Please enter valid PIN code'
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
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          maxLength: 500,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            hintText:
                'Describe your wedding services, studio style, expertise, years in industry, and specialties...',
            hintStyle: const TextStyle(color: AppColors.grey, fontSize: 13),
            counterText: '',
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: descErr != null
                    ? AppColors.error
                    : AppColors.grey.withValues(alpha: 0.3),
                width: descErr != null ? 1.4 : 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: descErr != null
                    ? AppColors.error
                    : AppColors.grey.withValues(alpha: 0.3),
                width: descErr != null ? 1.4 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: descErr != null ? AppColors.error : AppColors.primary,
                width: 1.5,
              ),
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

        // 5. Street Address / Locality
        _buildFormField(
          label: 'Business Address',
          hint: 'Shop / Plot / Studio No., Street, Landmark',
          controller: _addressController,
          icon: Icons.home_work_outlined,
          isRequired: true,
          errorText: addressErr,
        ),

        const SizedBox(height: 16),

        // 6. City (Full Width / Prominent)
        _buildFormField(
          label: 'City',
          hint: 'e.g. Mumbai',
          controller: _cityController,
          icon: Icons.location_city_rounded,
          isRequired: true,
          errorText: cityErr,
        ),

        const SizedBox(height: 16),

        // 7. State & PIN Code (Half & Half)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildFormField(
                label: 'State',
                hint: 'e.g. Maharashtra',
                controller: _stateController,
                icon: Icons.map_outlined,
                isRequired: true,
                errorText: stateErr,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFormField(
                label: 'PIN Code',
                hint: 'e.g. 400001',
                controller: _pincodeController,
                icon: Icons.pin_drop_outlined,
                keyboardType: TextInputType.number,
                isRequired: true,
                errorText: pincodeErr,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 8. Map / Google Maps Location URL (Optional)
        _buildFormField(
          label: 'Map Location URL (Optional)',
          hint: 'Paste your Google Maps link',
          controller: _addressUrlController,
          icon: Icons.map_rounded,
          keyboardType: TextInputType.url,
          isRequired: false,
        ),

        const SizedBox(height: 16),

        // 9. GST Number (Optional)
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
    final isMissingError =
        _showDocValidationErrors && isRequired && !isSelected;
    final fileName = isSelected ? filePath.split(RegExp(r'[\\/]')).last : null;
    final statusLabel = isSelected
        ? 'UPLOADED'
        : (isMissingError ? 'MISSING' : (isRequired ? 'REQUIRED' : 'OPTIONAL'));
    final statusColor = isSelected
        ? AppColors.success
        : (isRequired ? AppColors.error : AppColors.darkGrey);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isMissingError
            ? const Color(0xFFFFF8F8)
            : (isSelected ? const Color(0xFFFCFFFD) : AppColors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppColors.success.withValues(alpha: 0.32)
              : (isMissingError
                    ? AppColors.error
                    : AppColors.grey.withValues(alpha: 0.18)),
          width: isMissingError ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.success.withValues(alpha: 0.05)
                : (isMissingError
                      ? AppColors.error.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.025)),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDocumentSourceSheet(key, title),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isSelected)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 54,
                          height: 54,
                          child: Image.file(
                            File(filePath),
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              color: AppColors.success.withValues(alpha: 0.08),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.description_outlined,
                                color: AppColors.success,
                                size: 25,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: isMissingError
                              ? AppColors.error.withValues(alpha: 0.08)
                              : AppColors.primary.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          isMissingError ? Icons.error_outline_rounded : icon,
                          color: isMissingError
                              ? AppColors.error
                              : AppColors.primary,
                          size: 26,
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                              color: isMissingError
                                  ? AppColors.error
                                  : AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isSelected && fileName != null
                                ? _shortenFileName(fileName)
                                : (isMissingError
                                      ? 'Upload this required document to continue'
                                      : subtitle),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.3,
                              color: isSelected
                                  ? AppColors.success
                                  : (isMissingError
                                        ? AppColors.error
                                        : AppColors.darkGrey),
                              fontWeight: isSelected || isMissingError
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.35,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.success.withValues(alpha: 0.08)
                            : AppColors.primary.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.success.withValues(alpha: 0.25)
                              : AppColors.primary.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected
                                ? Icons.edit_outlined
                                : Icons.upload_file_outlined,
                            size: 15,
                            color: isSelected
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isSelected ? 'Change file' : 'Upload document',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                          ),
                        ],
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

  Widget _buildLiveSelfiePickerCard() {
    final isSelected = _liveSelfiePath != null && _liveSelfiePath!.isNotEmpty;
    final isMissingError = _showDocValidationErrors && !isSelected;

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
                    : AppColors.grey.withValues(alpha: 0.3)),
          width: isSelected || isMissingError ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.success.withValues(alpha: 0.12)
                      : (isMissingError
                            ? AppColors.error.withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.08)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.face_retouching_natural_rounded,
                  color: isSelected
                      ? AppColors.success
                      : (isMissingError ? AppColors.error : AppColors.primary),
                  size: 20,
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
                          'Live Selfie Verification',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.success.withValues(alpha: 0.12)
                                : (isMissingError
                                      ? AppColors.error
                                      : AppColors.error.withValues(alpha: 0.1)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isSelected ? 'VERIFIED' : 'REQUIRED',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                              color: isSelected
                                  ? AppColors.success
                                  : (isMissingError
                                        ? Colors.white
                                        : AppColors.error),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isSelected
                          ? 'Live portrait selfie captured with camera'
                          : (isMissingError
                                ? 'Live selfie is required for admin verification'
                                : 'Take a clear front-camera photo of vendor owner'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isSelected
                            ? AppColors.success
                            : (isMissingError
                                  ? AppColors.error
                                  : AppColors.darkGrey),
                        fontWeight: isSelected || isMissingError
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isSelected) ...[
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.success, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.file(
                      File(_liveSelfiePath!),
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Live Selfie Attached ✓',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _shortenFileName(
                          _liveSelfiePath!.split(RegExp(r'[\\/]')).last,
                        ),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _captureLiveSelfie,
                  icon: const Icon(Icons.camera_alt_outlined, size: 14),
                  label: const Text(
                    'Retake',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _captureLiveSelfie,
                icon: const Icon(
                  Icons.camera_front_rounded,
                  color: AppColors.white,
                  size: 18,
                ),
                label: const Text(
                  'Open Camera & Take Live Selfie',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMissingError
                      ? AppColors.error
                      : AppColors.primary,
                  elevation: 1,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
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
                      : (_showDocValidationErrors
                            ? AppColors.error
                            : AppColors.primary),
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
                      : (_showDocValidationErrors
                            ? AppColors.error
                            : AppColors.primary),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          allUploaded
              ? 'All required documents and KYC verification attached. You can proceed to review.'
              : 'Aadhaar Card (Front & Back), Live Selfie, and PAN Card are required for verification.',
          style: TextStyle(
            fontSize: 12.5,
            color: _showDocValidationErrors && !allUploaded
                ? AppColors.error
                : AppColors.darkGrey,
            fontWeight: _showDocValidationErrors && !allUploaded
                ? FontWeight.w600
                : FontWeight.normal,
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
                  : (_showDocValidationErrors
                        ? AppColors.error
                        : AppColors.primary),
            ),
            minHeight: 5,
          ),
        ),
        const SizedBox(height: 18),
        _buildLiveSelfiePickerCard(),
        _buildDocPickerCard(
          key: 'aadhar',
          title: 'Aadhaar Card (Front)',
          subtitle: 'Clear photo of front side of Aadhaar card',
          filePath: _aadharPath,
          isRequired: true,
          icon: Icons.badge_outlined,
        ),
        _buildDocPickerCard(
          key: 'aadharBack',
          title: 'Aadhaar Card (Back)',
          subtitle: 'Clear photo of back side showing address',
          filePath: _aadharBackPath,
          isRequired: true,
          icon: Icons.contact_page_outlined,
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
          title: 'Business Registration / MSME (Optional)',
          subtitle: 'Trade certificate or incorporation',
          filePath: _businessCertPath,
          isRequired: false,
          icon: Icons.apartment_outlined,
        ),
        _buildDocPickerCard(
          key: 'addressProof',
          title: 'Address Proof (Optional)',
          subtitle: 'Electricity bill, rent agreement',
          filePath: _addressProofPath,
          isRequired: false,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF2E7D32),
                          size: 13,
                        ),
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
              _buildReviewInfoRow(
                'Business Name',
                _businessNameController.text,
              ),
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

        // Card 2: Business Address & Tax Details
        Builder(
          builder: (context) {
            final storage = StorageHelper();
            final authUser = Get.isRegistered<AuthController>()
                ? Get.find<AuthController>().currentUser.value
                : null;

            final displayAddress = _addressController.text.trim().isNotEmpty
                ? _addressController.text.trim()
                : (storage.getUserAddress() ??
                      authUser?.address ??
                      'Not Provided');
            final displayCity = _cityController.text.trim().isNotEmpty
                ? _cityController.text.trim()
                : (storage.getUserCity() ?? authUser?.city ?? 'Not Provided');
            final displayState = _stateController.text.trim().isNotEmpty
                ? _stateController.text.trim()
                : (storage.getUserState() ?? authUser?.state ?? 'Not Provided');
            final displayPincode = _pincodeController.text.trim().isNotEmpty
                ? _pincodeController.text.trim()
                : (storage.getUserPincode() ??
                      authUser?.pincode ??
                      'Not Provided');
            final displayMapUrl = _addressUrlController.text.trim();

            final addressParts = [
              if (displayAddress.isNotEmpty && displayAddress != 'Not Provided')
                displayAddress,
              if (displayCity.isNotEmpty && displayCity != 'Not Provided')
                displayCity,
              if (displayState.isNotEmpty && displayState != 'Not Provided')
                displayState,
              if (displayPincode.isNotEmpty && displayPincode != 'Not Provided')
                displayPincode,
            ];

            return Container(
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
                        'Business Address',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentStep = 2;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                color: AppColors.primary,
                                size: 12,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Formatted Complete Address Box
                  if (addressParts.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: AppColors.offWhite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEFE6DC)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Complete Address',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkGrey,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  addressParts.join(', '),
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  _buildReviewInfoRow('Business Address', displayAddress),
                  _buildReviewInfoRow('City', displayCity),
                  _buildReviewInfoRow('State', displayState),
                  _buildReviewInfoRow('PIN Code', displayPincode),
                  if (displayMapUrl.isNotEmpty)
                    _buildReviewInfoRow(
                      'Map Location Link',
                      displayMapUrl,
                      isLink: true,
                    ),
                  _buildReviewInfoRow(
                    'GSTIN Number',
                    _gstController.text.trim().isNotEmpty
                        ? _gstController.text.trim()
                        : 'Not Provided (Exempt)',
                  ),
                ],
              ),
            );
          },
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
                {
                  'name': 'Live Selfie Verification',
                  'path': _liveSelfiePath,
                  'req': true,
                },
                {
                  'name': 'Aadhaar Card (Front)',
                  'path': _aadharPath,
                  'req': true,
                },
                {
                  'name': 'Aadhaar Card (Back)',
                  'path': _aadharBackPath,
                  'req': true,
                },
                {'name': 'PAN Card', 'path': _panPath, 'req': true},
                {
                  'name': 'Business Registration',
                  'path': _businessCertPath,
                  'req': false,
                },
                {
                  'name': 'Address Proof',
                  'path': _addressProofPath,
                  'req': false,
                },
                {'name': 'GST Certificate', 'path': _gstDocPath, 'req': false},
              ].map((doc) {
                final hasPath =
                    doc['path'] != null && (doc['path'] as String).isNotEmpty;
                final fileName = hasPath
                    ? (doc['path'] as String).split(RegExp(r'[\\/]')).last
                    : null;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    children: [
                      Icon(
                        hasPath
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: hasPath
                            ? const Color(0xFF2E7D32)
                            : AppColors.grey,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: hasPath
                                ? const Color(0xFFE8F5E9)
                                : AppColors.cream,
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
                                const Icon(
                                  Icons.attachment_rounded,
                                  size: 11,
                                  color: Color(0xFF2E7D32),
                                ),
                                const SizedBox(width: 3),
                              ],
                              Flexible(
                                child: Text(
                                  hasPath
                                      ? (fileName != null
                                            ? _shortenFileName(fileName)
                                            : 'Uploaded ✓')
                                      : (doc['req'] == true
                                            ? 'Default'
                                            : 'Optional'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: hasPath
                                        ? const Color(0xFF2E7D32)
                                        : AppColors.darkGrey,
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
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.darkGrey,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewInfoRow(
    String label,
    String value, {
    bool isLink = false,
  }) {
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
              maxLines: isLink ? 2 : 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isLink ? const Color(0xFF1E88E5) : AppColors.black,
                decoration: isLink
                    ? TextDecoration.underline
                    : TextDecoration.none,
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
    final nameWithoutExt = dotIndex != -1
        ? fileName.substring(0, dotIndex)
        : fileName;
    if (nameWithoutExt.length > 7) {
      return '${nameWithoutExt.substring(0, 6)}...$ext';
    }
    return fileName;
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 5: SUBSCRIPTION PLAN
  // ─────────────────────────────────────────────────────────────
  Widget _buildStep5SubscriptionPlan() {
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
                  const Text(
                    'Select your partnership duration',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

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
                    'Loading subscription plans...',
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
                border: Border.all(
                  color: AppColors.grey.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    color: AppColors.darkGrey,
                    size: 36,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No subscription plans are available right now.',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Please try again in a moment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.darkGrey, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: () => _vendorController.fetchSubscriptions(
                      forceRefresh: true,
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Try Again'),
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
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(14),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: AppColors.cream,
                              ),
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
                            color: Color(0xFF790D16),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.diamond_rounded,
                                size: 14,
                                color: AppColors.cream,
                              ),
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
                                          color: (plan['color'] as Color)
                                              .withValues(alpha: 0.12),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    plan['name'] as String,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: AppColors.black,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        (plan['color'] as Color)
                                                            .withValues(
                                                              alpha: 0.12,
                                                            ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    plan['badge'] as String,
                                                    style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color:
                                                          plan['color']
                                                              as Color,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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
                            if ((plan['tagline'] as String?)?.isNotEmpty ==
                                true) ...[
                              Text(
                                plan['tagline'] as String,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.darkGrey,
                                  height: 1.4,
                                ),
                              ),
                            ],
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
                                        : AppColors.primary.withValues(
                                            alpha: 0.5,
                                          ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  isSelected
                                      ? 'Selected Plan ✓'
                                      : 'Select ${plan['name']}',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.primary,
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
              if (isRequired && !label.toLowerCase().contains('optional'))
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
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: (_) {
            if (_showStep2ValidationErrors) {
              setState(() {});
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.grey, fontSize: 13),
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: hasError ? AppColors.error : AppColors.primary,
                    size: 20,
                  )
                : null,
            prefixText: prefixText,
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: AppColors.grey)
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.error
                    : AppColors.grey.withValues(alpha: 0.3),
                width: hasError ? 1.4 : 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.error
                    : AppColors.grey.withValues(alpha: 0.3),
                width: hasError ? 1.4 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 1.4),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
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
          ? 'Submitting Application...'
          : (activePlan != null
                ? 'Buy $planName (₹$activePrice)'
                : 'Choose a Plan');
    } else if (_currentStep == 4) {
      buttonText = 'Save Details & View Plans';
    } else if (_currentStep == 3) {
      final uploadedCount = _getUploadedRequiredDocsCount();
      buttonText = uploadedCount == 4
          ? 'Continue to Review (4/4 Uploaded ✓)'
          : 'Upload Documents ($uploadedCount/4)';
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
            child: Obx(() {
              final isSubmitting = _vendorController.isSubmitting.value;
              return ElevatedButton(
                onPressed: isSubmitting ? null : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Submitting...',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      )
                    : Row(
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
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Shimmer loading placeholder for vendor category selection (3-column grid)
class _VendorCategoryShimmerGrid extends StatefulWidget {
  const _VendorCategoryShimmerGrid();

  @override
  State<_VendorCategoryShimmerGrid> createState() =>
      _VendorCategoryShimmerGridState();
}

class _VendorCategoryShimmerGridState extends State<_VendorCategoryShimmerGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        final shimmerGradient = LinearGradient(
          begin: Alignment(-2.0 + (4.0 * _shimmerController.value), -0.3),
          end: Alignment(-1.0 + (4.0 * _shimmerController.value), 0.3),
          colors: const [
            Color(0xFFEBEBEB),
            Color(0xFFF8F8F8),
            Color(0xFFEBEBEB),
          ],
          stops: const [0.1, 0.5, 0.9],
        );

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 14,
            childAspectRatio: 0.82,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category icon box shimmer
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: shimmerGradient,
                    border: Border.all(
                      color: AppColors.grey.withValues(alpha: 0.12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Title line 1 shimmer
                Container(
                  width: (index % 2 == 0) ? 64 : 74,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: shimmerGradient,
                  ),
                ),
                const SizedBox(height: 4),
                // Title line 2 shimmer
                Container(
                  width: (index % 3 == 0) ? 46 : 38,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: shimmerGradient,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
