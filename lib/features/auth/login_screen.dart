import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_animations.dart';
import '../shell/main_shell.dart';
import '../vendor_panel/vendor_shell.dart';
import 'user_signup_screen.dart';
import 'vendor_signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool initialIsVendor;

  const LoginScreen({
    super.key,
    this.initialIsVendor = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController =
      TextEditingController(text: 'priya.sharma@gmail.com');
  final _passwordController = TextEditingController(text: 'riwaaz@2025');

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate authentication call
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() => _isLoading = false);

    final id = _identifierController.text.trim().toLowerCase();
    // Dynamically detect role based on account / credentials
    final isVendorRole = id.contains('vendor') ||
        id.contains('royal') ||
        id.contains('studio') ||
        id.contains('click') ||
        id.contains('partner') ||
        id.contains('business');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isVendorRole
                    ? 'Welcome back to Riwaaz Partner Portal!'
                    : 'Welcome back to Riwaaz!',
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
        duration: const Duration(milliseconds: 1400),
      ),
    );

    // Redirect to the appropriate flow based on detected role
    if (isVendorRole) {
      Navigator.of(context).pushAndRemoveUntil(
        FadeScaleRoute(page: const VendorShell(initialIndex: 0)),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        FadeScaleRoute(page: const MainShell(initialIndex: 0)),
        (route) => false,
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
          'RIWAAZ',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 2.5,
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
                        const SizedBox(height: 6),

                        // Heading
                        Text(
                          'Welcome Back',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Log in to your account to continue planning your event or managing your services.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: AppColors.darkGrey,
                            height: 1.45,
                          ),
                        ),
                        const Spacer(flex: 3),

                        // Email or Phone field
                        _buildFieldLabel('Email Address or Mobile Number'),
                        TextFormField(
                          controller: _identifierController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.white,
                            hintText:
                                'e.g. priya.sharma@gmail.com or 9876543210',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              color: AppColors.grey,
                              fontSize: 13.5,
                            ),
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2D6C7)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2D6C7)),
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
                              return 'Please enter your email or mobile number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Password field
                        _buildFieldLabel('Password'),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.white,
                            hintText: 'Enter your account password',
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
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2D6C7)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2D6C7)),
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
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),

                        // Forgot password link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Password reset instructions sent to your registered contact.',
                                    style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white),
                                  ),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 8),
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        // Spacer pushes button and register section to the bottom
                        const Spacer(flex: 2),
                        const SizedBox(height: 24),

                        // Login Button at bottom
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              elevation: 3,
                              shadowColor:
                                  AppColors.primary.withValues(alpha: 0.35),
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
                                        'Log In',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward_rounded,
                                          size: 20),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Don't have an account? Sign Up
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: AppColors.darkGrey,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushReplacement(
                                    FadeScaleRoute(
                                      page: const UserSignupScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign Up',
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
                        const SizedBox(height: 10),

                        // Partner registration option
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Are you a vendor? ",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: AppColors.darkGrey,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushReplacement(
                                    FadeScaleRoute(
                                      page: const VendorSignupScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Partner Register',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
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
                        const SizedBox(height: 14),
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
}
