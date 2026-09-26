import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_animations.dart';
import 'controllers/auth_controller.dart';
import 'login_screen.dart';
import 'vendor_otp_verification_screen.dart';

class VendorSignupScreen extends StatefulWidget {
  const VendorSignupScreen({super.key});

  @override
  State<VendorSignupScreen> createState() => _VendorSignupScreenState();
}

class _VendorSignupScreenState extends State<VendorSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    final businessName = _nameController.text.trim();
    final res = await authController.signUp(
      fullName: businessName.isNotEmpty ? businessName : 'Royal Click Studio',
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      roleId: 4, // 4 = Vendor Partner
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res.isSuccess == true) {
      Navigator.of(context).push(
        FadeScaleRoute(
          page: VendorOtpVerificationScreen(
            businessName: businessName.isNotEmpty ? businessName : 'Royal Click Studio',
            ownerName: businessName.isNotEmpty ? businessName : 'Royal Click Studio',
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            initialOtp: res.data?.otp,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'RIWAAZ PARTNER',
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 24,
                ),
                child: IntrinsicHeight(
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
                  'Register as a vendor on Riwaaz & connect with thousands of couples planning events',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.darkGrey,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),

                // Business Name / Owner Name
                _buildFieldLabel('Business / Studio Name'),
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  decoration: _buildInputDecoration(
                    hintText: 'e.g. Royal Click Studio',
                    prefixIcon: Icons.storefront_outlined,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter business name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Business Email
                _buildFieldLabel('Business Email Address'),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration(
                    hintText: 'e.g. contact@royalclick.com',
                    prefixIcon: Icons.email_outlined,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter email address';
                    }
                    if (!val.contains('@') || !val.contains('.')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Mobile Number
                _buildFieldLabel('Mobile Number (For Verification)'),
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
                const SizedBox(height: 18),

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
                const SizedBox(height: 18),

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
                // Spacer pushes Continue button and Log In link to the bottom
                const Spacer(),
                const SizedBox(height: 24),

                // Continue Button
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
                                'Continue to Verification',
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
                const SizedBox(height: 18),

                // Terms disclaimer
                Center(
                  child: Text(
                    'By continuing, you agree to Riwaaz Partner Terms, Commission Policy & Code of Conduct.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: AppColors.grey,
                      height: 1.4,
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
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  },
),
),
);
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7, left: 2),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
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
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }
}
