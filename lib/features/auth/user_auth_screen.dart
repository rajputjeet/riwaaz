import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/app_animations.dart';
import '../wedding_details/wedding_details_screen.dart';
import '../shell/main_shell.dart';
import '../vendor_registration/vendor_welcome_screen.dart';

class UserAuthScreen extends StatefulWidget {
  final bool initialIsLogin;
  const UserAuthScreen({super.key, this.initialIsLogin = true});

  @override
  State<UserAuthScreen> createState() => _UserAuthScreenState();
}

class _UserAuthScreenState extends State<UserAuthScreen> {
  late bool _isLogin;
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _usePhoneAuth = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.initialIsLogin;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isLoading = false);

    // If new user signing up, go through wedding details onboarding; else directly to MainShell
    if (!_isLogin) {
      Navigator.of(context).pushReplacement(
        FadeScaleRoute(page: const WeddingDetailsScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        FadeScaleRoute(page: const MainShell(initialIndex: 0)),
      );
    }
  }

  void _skipAsGuest() {
    Navigator.of(context).pushReplacement(
      FadeScaleRoute(page: const MainShell(initialIndex: 0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _skipAsGuest,
            child: const Text(
              'Skip as Guest',
              style: TextStyle(
                color: AppColors.goldDark,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header logo & title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: AppColors.gold,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isLogin ? 'Welcome Back!' : 'Create Couple Account',
                      style: AppTextStyles.headlineLarge.copyWith(
                        fontSize: 22,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLogin
                          ? 'Sign in to access your wedding plan & bookings'
                          : 'Join millions of couples planning their dream wedding',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Segmented Tab Switcher: Login / Sign Up
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isLogin
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: _isLogin
                                    ? AppColors.white
                                    : AppColors.darkGrey,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isLogin
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: !_isLogin
                                    ? AppColors.white
                                    : AppColors.darkGrey,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Auth Type Toggle (Phone / Email)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Phone OTP'),
                    selected: _usePhoneAuth,
                    onSelected: (val) => setState(() => _usePhoneAuth = true),
                    selectedColor: AppColors.gold.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: _usePhoneAuth
                          ? AppColors.primaryDark
                          : AppColors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    backgroundColor: AppColors.white,
                    side: BorderSide(
                      color: _usePhoneAuth
                          ? AppColors.gold
                          : AppColors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Email & Password'),
                    selected: !_usePhoneAuth,
                    onSelected: (val) => setState(() => _usePhoneAuth = false),
                    selectedColor: AppColors.gold.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: !_usePhoneAuth
                          ? AppColors.primaryDark
                          : AppColors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    backgroundColor: AppColors.white,
                    side: BorderSide(
                      color: !_usePhoneAuth
                          ? AppColors.gold
                          : AppColors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Form fields
              if (!_isLogin) ...[
                _buildTextField(
                  label: 'Full Name',
                  hint: 'e.g. Rahul & Priya',
                  icon: Icons.person_outline_rounded,
                  controller: _nameController,
                ),
                const SizedBox(height: 16),
              ],

              if (_usePhoneAuth) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mobile Number',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey.withValues(alpha: 0.5),
                              borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(12)),
                            ),
                            child: const Text(
                              '+91 🇮🇳',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: 'Enter 10-digit mobile number',
                                hintStyle: TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                _buildTextField(
                  label: 'Email Address',
                  hint: 'Enter your email',
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  icon: Icons.lock_outline_rounded,
                  controller: _passwordController,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  onToggleObscure: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ],

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          _isLogin
                              ? (_usePhoneAuth ? 'Send OTP' : 'Login')
                              : 'Create Account & Continue',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // 1-Tap Demo User Login Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      FadeScaleRoute(page: const MainShell(initialIndex: 0)),
                    );
                  },
                  icon: const Icon(Icons.flash_on_rounded,
                      color: AppColors.primary, size: 18),
                  label: const Text(
                    '1-Tap Demo Login (Simran & Rahul)',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppColors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppColors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Social Login
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _skipAsGuest,
                      icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                      label: const Text('Google'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.black,
                        side: BorderSide(
                          color: AppColors.grey.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _skipAsGuest,
                      icon: const Icon(Icons.apple_rounded, size: 22),
                      label: const Text('Apple'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.black,
                        side: BorderSide(
                          color: AppColors.grey.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Vendor Cross Link
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cream.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Are you a wedding vendor or service provider?',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.darkGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            FadeScaleRoute(
                                page: const VendorWelcomeScreen()),
                          );
                        },
                        child: const Text(
                          'Register or Login as Riwaaz Vendor →',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
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
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.grey.withValues(alpha: 0.3),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.grey,
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: AppColors.grey,
                        size: 20,
                      ),
                      onPressed: onToggleObscure,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
