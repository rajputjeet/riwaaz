import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/utils/app_animations.dart';
import '../../shared/widgets/app_support_sheet.dart';
import '../../shared/widgets/cached_image_view.dart';
import 'login_screen.dart';
import 'user_signup_screen.dart';
import 'vendor_signup_screen.dart';

/// The primary entry screen after Splash where user chooses registration type.
/// Features animated Widoora logo with a round white background and luxury golden halo.
class UnifiedLoginScreen extends StatefulWidget {
  const UnifiedLoginScreen({super.key});

  @override
  State<UnifiedLoginScreen> createState() => _UnifiedLoginScreenState();
}

class _UnifiedLoginScreenState extends State<UnifiedLoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          // ─── Background: Royal deep wine gradient ─────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF4A1027), // Top soft wine
                    Color(0xFF380C1D), // Main brand wine
                    Color(0xFF220510), // Deep wine shade
                    Color(0xFF14020A), // Rich dark floor
                  ],
                  stops: [0.0, 0.35, 0.72, 1.0],
                ),
              ),
            ),
          ),

          // ─── Ambient royal glow circles ──────────────────────────────────
          Positioned(
            top: size.height * 0.10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: size.width * 0.85,
                height: size.width * 0.85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.16),
                      AppColors.secondary.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Decorative arched outline ring
          Positioned(
            top: size.height * 0.06,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: size.width * 0.80,
                height: size.width * 0.90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(size.width * 0.40),
                    bottom: const Radius.circular(40),
                  ),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.08),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Soft ambient corner sparkles
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -30,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.03),
              ),
            ),
          ),

          // ─── Foreground Content ──────────────────────────────────────────
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            // ─── Top Support / Help Bar ───────────────────────
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                onPressed: () =>
                                    AppSupportSheet.showForgotPasswordAdminSheet(
                                  context,
                                  isVendor: false,
                                ),
                                icon: const Icon(
                                  Icons.help_outline_rounded,
                                  color: AppColors.secondary,
                                  size: 22,
                                ),
                                tooltip: 'Support & Help',
                              ),
                            ),

                            const Spacer(flex: 2),

                            // ─── Center Animated Logo with Round White BG ─────
                            FadeTransition(
                              opacity: _logoOpacity,
                              child: ScaleTransition(
                                scale: _logoScale,
                                child: _buildAnimatedCenterLogo(),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Brand Name & Tagline
                            SlideTransition(
                              position: _contentSlide,
                              child: FadeTransition(
                                opacity: _logoOpacity,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _buildOrnament(),
                                        const SizedBox(width: 12),
                                        Text(
                                          'WIDOORA',
                                          style: GoogleFonts.cormorantGaramond(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.white,
                                            letterSpacing: 4.0,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.6),
                                                blurRadius: 16,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        _buildOrnament(),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Everything You Need to Make Your Event Special',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.secondary
                                            .withValues(alpha: 0.88),
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const Spacer(flex: 3),

                            // ─── Bottom Actions Panel ─────────────────────────
                            SlideTransition(
                              position: _contentSlide,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Welcome Title
                                  Text(
                                    'Join Widoora',
                                    style: GoogleFonts.cormorantGaramond(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                      height: 1.1,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Plan your dream wedding or grow your wedding business.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5,
                                      color: AppColors.secondary
                                          .withValues(alpha: 0.88),
                                      height: 1.45,
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // ─── BUTTON 1: Register as User ────────────────
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          FadeScaleRoute(
                                              page: const UserSignupScreen()),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.secondary,
                                        foregroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        elevation: 4,
                                        shadowColor: Colors.black
                                            .withValues(alpha: 0.35),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.favorite_rounded,
                                              size: 18,
                                              color: AppColors.primary),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Register as User',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // ─── BUTTON 2: Register as Vendor ───────────────
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          FadeScaleRoute(
                                              page:
                                                  const VendorSignupScreen()),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor:
                                            Colors.white.withValues(alpha: 0.05),
                                        side: BorderSide(
                                          color: AppColors.secondary
                                              .withValues(alpha: 0.75),
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.storefront_rounded,
                                              size: 18,
                                              color: AppColors.secondary),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Register as Vendor',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.secondary,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // ─── FOOTER: Already have an account? Login ─────
                                  Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          FadeScaleRoute(
                                              page: const LoginScreen()),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6),
                                        child: RichText(
                                          text: TextSpan(
                                            style:
                                                GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              color: AppColors.secondary
                                                  .withValues(alpha: 0.8),
                                            ),
                                            children: const [
                                              TextSpan(
                                                  text:
                                                      'Already have an account? '),
                                              TextSpan(
                                                text: 'Login',
                                                style: TextStyle(
                                                  color: AppColors.secondary,
                                                  fontWeight: FontWeight.w800,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor:
                                                      AppColors.secondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Center(
                                    child: TextButton(
                                      onPressed: () => AppSupportSheet
                                          .showForgotPasswordAdminSheet(
                                        context,
                                        isVendor: false,
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                      ),
                                      child: Text(
                                        'Forgot Password? Contact Admin',
                                        style:
                                            GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5,
                                          color: AppColors.secondary
                                              .withValues(alpha: 0.75),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Center animated Widoora logo with round white background and luxury golden halo
  Widget _buildAnimatedCenterLogo() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse =
            math.sin(_pulseController.value * 2 * math.pi) * 0.04 + 1.0;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Ambient outer breathing golden halo
            Transform.scale(
              scale: pulse * 1.08,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            // Outer golden luxury rim
            Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF7D9A0),
                    Color(0xFFC89950),
                    Color(0xFFF3D088),
                    Color(0xFF9E7030),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.35),
                    blurRadius: 28,
                    spreadRadius: 3,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: CachedImageView(
                      imageUrl: AppImages.widooraLogo,
                      fit: BoxFit.contain,
                      fallbackIcon: Icons.favorite_rounded,
                      iconColor: AppColors.gold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrnament() {
    return Row(
      children: List.generate(3, (i) {
        return Container(
          width: 4 + (i * 2.0),
          height: 1.5,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
