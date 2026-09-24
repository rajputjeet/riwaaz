import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/utils/app_animations.dart';
import 'login_screen.dart';
import 'user_signup_screen.dart';
import 'vendor_signup_screen.dart';

/// The primary entry screen after Splash.
/// Shows two Register buttons (User & Vendor) and a footer Login link.
class UnifiedLoginScreen extends StatelessWidget {
  const UnifiedLoginScreen({super.key});

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

          // ─── Ambient royal glow & palace arch behind couple ──────────────
          Positioned(
            top: size.height * 0.08,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: size.width * 0.82,
                height: size.width * 0.82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.14),
                      AppColors.secondary.withValues(alpha: 0.04),
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
                width: size.width * 0.78,
                height: size.width * 0.95,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(size.width * 0.39),
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

          // ─── Wedding Couple Illustration ─────────────────────────────────
          Positioned(
            top: size.height * 0.08,
            bottom: size.height * 0.29,
            left: 20,
            right: 20,
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.78, 0.98],
                  colors: [
                    Colors.white,
                    Colors.white,
                    Colors.transparent,
                  ],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                AppImages.riwaazCouple,
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  AppImages.weddingHero,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // ─── Bottom Dark Gradient Shade for Text Readability ──────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: size.height * 0.46,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.28, 0.60, 1.0],
                  colors: [
                    Colors.transparent,
                    const Color(0xFF1E040E).withValues(alpha: 0.75),
                    const Color(0xFF19030B).withValues(alpha: 0.96),
                    const Color(0xFF14020A),
                  ],
                ),
              ),
            ),
          ),

          // ─── Foreground Content ──────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Top-Left brand mark (Clean RIWAAZ text without R round logo)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        'RIWAAZ',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                          letterSpacing: 3.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ─── Bottom Actions Panel ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Title
                      Text(
                        'Join Riwaaz',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 34,
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
                          color: AppColors.secondary.withValues(alpha: 0.88),
                          height: 1.45,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ─── BUTTON 1: Register as User ─────────────────────
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
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                            shadowColor: Colors.black.withValues(alpha: 0.35),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.favorite_rounded,
                                  size: 18, color: AppColors.primary),
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

                      // ─── BUTTON 2: Register as Vendor ────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              FadeScaleRoute(
                                  page: const VendorSignupScreen()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.05),
                            side: BorderSide(
                              color:
                                  AppColors.secondary.withValues(alpha: 0.75),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.storefront_rounded,
                                  size: 18, color: AppColors.secondary),
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

                      // ─── FOOTER: Already have an account? Login ──────────
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              FadeScaleRoute(page: const LoginScreen()),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: AppColors.secondary
                                      .withValues(alpha: 0.8),
                                ),
                                children: const [
                                  TextSpan(text: 'Already have an account? '),
                                  TextSpan(
                                    text: 'Login',
                                    style: TextStyle(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w800,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
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
        ],
      ),
    );
  }
}
