import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_animations.dart';
import '../../shared/widgets/app_support_sheet.dart';
import '../../utils/helper/storage_helper.dart';
import '../../utils/utils.dart';
import '../vendor_registration/vendor_registration_wizard_screen.dart';
import 'controllers/auth_controller.dart';
import 'login_screen.dart';

class VendorSignupScreen extends StatefulWidget {
  const VendorSignupScreen({super.key});

  @override
  State<VendorSignupScreen> createState() => _VendorSignupScreenState();
}

class _VendorSignupScreenState extends State<VendorSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _agreedToTerms = false;
  bool _termsError = false;

  @override
  void initState() {
    super.initState();
    final storage = StorageHelper();
    final draft = storage.getVendorDraft();
    if (draft != null) {
      if ((draft['businessName'] as String?)?.isNotEmpty == true) {
        _businessNameController.text = draft['businessName'] as String;
      }
      if ((draft['ownerName'] as String?)?.isNotEmpty == true) {
        _ownerNameController.text = draft['ownerName'] as String;
      }
      if ((draft['email'] as String?)?.isNotEmpty == true) {
        _emailController.text = draft['email'] as String;
      }
      if ((draft['mobile'] as String?)?.isNotEmpty == true) {
        _phoneController.text = draft['mobile'] as String;
      }
      if ((draft['address'] as String?)?.isNotEmpty == true) {
        _addressController.text = draft['address'] as String;
      }
      if ((draft['city'] as String?)?.isNotEmpty == true) {
        _cityController.text = draft['city'] as String;
      }
      if ((draft['state'] as String?)?.isNotEmpty == true) {
        _stateController.text = draft['state'] as String;
      }
      if ((draft['pincode'] as String?)?.isNotEmpty == true) {
        _pincodeController.text = draft['pincode'] as String;
      }
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleContinue() async {
    if (!_formKey.currentState!.validate()) {
      if (!_agreedToTerms) setState(() => _termsError = true);
      return;
    }

    if (!_agreedToTerms) {
      setState(() => _termsError = true);
      Utils.showError(
        'Please accept the Terms & Conditions and Privacy Policy to continue',
      );
      return;
    }

    final businessName = _businessNameController.text.trim();
    final ownerName = _ownerNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final city = _cityController.text.trim();
    final state = _stateController.text.trim();
    final pincode = _pincodeController.text.trim();
    final password = _passwordController.text;

    final storage = StorageHelper();
    // If vendor already signed up in this session, navigate directly without duplicate signup error
    if (storage.getIsLoggedIn() == true &&
        (storage.getUserEmail()?.trim().toLowerCase() == email.toLowerCase() ||
            storage.getUserMobile()?.trim() == phone)) {
      Navigator.of(context).push(
        FadeScaleRoute(
          page: const VendorRegistrationWizardScreen(initialStep: 1),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    final res = await authController.signUpAndSignIn(
      fullName: ownerName.isNotEmpty ? ownerName : businessName,
      businessName: businessName,
      email: email,
      phone: phone,
      password: password,
      roleId: 3, // 3 = Vendor Partner
      address: address,
      city: city,
      state: state,
      pincode: pincode.isNotEmpty ? pincode : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res.isSuccess == true) {
      final storage = StorageHelper();
      await storage.saveVendorOnboardingCompleted(false);
      await storage.saveVendorDraft({
        'step': 1,
        'businessName': businessName,
        'ownerName': ownerName,
        'email': email,
        'mobile': phone,
        'address': address,
        'city': city,
        'state': state,
        'pincode': pincode,
      });

      Utils.showSuccess(
        'Welcome, $businessName! Your account has been created.',
        title: 'Account Created',
      );

      if (!mounted) return;
      Navigator.of(context).push(
        FadeScaleRoute(
          page: const VendorRegistrationWizardScreen(initialStep: 1),
        ),
      );
    }
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: _handleBack,
          ),
        title: Text(
          'WIDOORA PARTNER',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 2.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Heading
                Text(
                  'Grow Your Business',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Register your business on Widoora and setup your partner storefront to reach clients',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.darkGrey,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),

                // SECTION 1: BUSINESS DETAILS
                _buildSectionHeader(
                  title: 'Business Information',
                  icon: Icons.storefront_rounded,
                ),
                const SizedBox(height: 14),

                // Business / Studio Name
                _buildFieldLabel('Business / Studio Name'),
                TextFormField(
                  controller: _businessNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _buildInputDecoration(
                    hintText: 'e.g. Royal Click Studio',
                    prefixIcon: Icons.business_rounded,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter business name';
                    }
                    if (val.trim().length < 2) {
                      return 'Business name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Owner Name
                _buildFieldLabel('Owner / Contact Person Name'),
                TextFormField(
                  controller: _ownerNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _buildInputDecoration(
                    hintText: 'e.g. Amit Verma',
                    prefixIcon: Icons.person_outline_rounded,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter owner / contact person name';
                    }
                    if (val.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Business Email
                _buildFieldLabel('Business Email Address (Optional)',
                    isRequired: false),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration(
                    hintText: 'e.g. contact@royalclick.com',
                    prefixIcon: Icons.email_outlined,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return null;
                    if (!val.contains('@') || !val.contains('.')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Mobile Number
                _buildFieldLabel('Mobile Number'),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  buildCounter: (context,
                          {required currentLength,
                          required isFocused,
                          maxLength}) =>
                      null,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: _buildInputDecoration(
                    hintText: '98765 43210',
                    prefixIcon: Icons.phone_outlined,
                    prefixWidget: Padding(
                      padding: const EdgeInsets.only(left: 14, right: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.phone_outlined,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '+91',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 1,
                            height: 20,
                            color: const Color(0xFFD8CCBE),
                          ),
                        ],
                      ),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter mobile number';
                    }
                    final clean = val.replaceAll(RegExp(r'\D'), '');
                    if (clean.length < 10) {
                      return 'Please enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // SECTION 2: LOCATION & ADDRESS

                // Studio / Business Address
                _buildFieldLabel('Street Address / Locality'),
                TextFormField(
                  controller: _addressController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _buildInputDecoration(
                    hintText: 'Shop / Plot / Studio No., Street, Landmark',
                    prefixIcon: Icons.home_work_outlined,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your studio / business address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // City
                _buildFieldLabel('City'),
                TextFormField(
                  controller: _cityController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _buildInputDecoration(
                    hintText: 'e.g. Mumbai',
                    prefixIcon: Icons.location_city_rounded,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Enter city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // State & PIN Code Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('State'),
                          TextFormField(
                            controller: _stateController,
                            textCapitalization: TextCapitalization.words,
                            decoration: _buildInputDecoration(
                              hintText: 'e.g. Maharashtra',
                              prefixIcon: Icons.map_outlined,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Enter state';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('PIN Code'),
                          TextFormField(
                            controller: _pincodeController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            buildCounter: (context,
                                    {required currentLength,
                                    required isFocused,
                                    maxLength}) =>
                                null,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            decoration: _buildInputDecoration(
                              hintText: 'e.g. 400001',
                              prefixIcon: Icons.pin_drop_outlined,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter PIN code';
                              }
                              if (val.trim().length != 6) {
                                return 'PIN code must be 6 digits';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Password
                _buildFieldLabel('Create Account Password'),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.white,
                    hintText: 'Create secure password (min 6 characters)',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: AppColors.grey,
                      fontSize: 13.5,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: AppColors.grey,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2D6C7)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2D6C7)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please create a password';
                    }
                    if (val.trim().length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password
                _buildFieldLabel('Confirm Password'),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.white,
                    hintText: 'Re-enter your password',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: AppColors.grey,
                      fontSize: 13.5,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_reset_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: AppColors.grey,
                        size: 20,
                      ),
                      onPressed: () => setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2D6C7)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2D6C7)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (val != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Mandatory Terms & Conditions Checkbox
                _buildTermsCheckbox(),
                const SizedBox(height: 16),

                // Register Business Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 3,
                      shadowColor: AppColors.primary.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Register Business & Continue',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Already a partner? Log In
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already a registered partner? ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            FadeScaleRoute(
                              page: const LoginScreen(initialIsVendor: true),
                            ),
                          );
                        },
                        child: Text(
                          'Log In',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    String? badge,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Text(
              badge,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = true}) {
    final bool effectiveRequired =
        isRequired && !label.toLowerCase().contains('optional');
    return Padding(
      padding: const EdgeInsets.only(bottom: 7, left: 2),
      child: RichText(
        text: TextSpan(
          text: label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
          children: [
            if (effectiveRequired)
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
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    IconData? prefixIcon,
    Widget? prefixWidget,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.white,
      hintText: hintText,
      hintStyle: GoogleFonts.plusJakartaSans(
        color: AppColors.grey,
        fontSize: 13.5,
      ),
      prefixIcon: prefixWidget ??
          (prefixIcon != null
              ? Icon(prefixIcon, color: AppColors.primary, size: 20)
              : null),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2D6C7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2D6C7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _agreedToTerms = !_agreedToTerms;
              if (_agreedToTerms) _termsError = false;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _agreedToTerms,
                    onChanged: (val) {
                      setState(() {
                        _agreedToTerms = val ?? false;
                        if (_agreedToTerms) _termsError = false;
                      });
                    },
                    activeColor: AppColors.primary,
                    checkColor: AppColors.white,
                    side: BorderSide(
                      color: _termsError
                          ? AppColors.error
                          : const Color(0xFFC4B29E),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: _termsError ? AppColors.error : AppColors.black,
                        height: 1.35,
                      ),
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: GestureDetector(
                            onTap: () => AppSupportSheet.showTermsOfServiceSheet(
                              context,
                              type: 'terms',
                            ),
                            child: Text(
                              'Terms & Conditions',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: ' & '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: GestureDetector(
                            onTap: () => AppSupportSheet.showTermsOfServiceSheet(
                              context,
                              type: 'privacy',
                            ),
                            child: Text(
                              'Privacy Policy',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary,
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
        if (_termsError)
          Padding(
            padding: const EdgeInsets.only(left: 32, top: 4),
            child: Text(
              'Please accept the Terms & Conditions to register',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
