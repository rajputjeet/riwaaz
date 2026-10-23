import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_images.dart';
import '../../core/utils/app_animations.dart';
import '../../data/api_provider/setting_api_provider.dart';
import '../../utils/helper/storage_helper.dart';
import '../onboarding/onboarding_screen.dart';
import '../shell/main_shell.dart';
import '../vendor_panel/vendor_shell.dart';
import '../vendor_registration/vendor_registration_wizard_screen.dart';
import '../vendor_registration/vendor_verification_tracker_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _pulseController;
  late final AnimationController _textController;
  late final AnimationController _loadingController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _pulseScale;
  late final Animation<double> _textOpacity;
  late final Animation<double> _loadingAnimation;

  bool _hasNavigated = false;

  static const Color _goldAccent = Color(0xFFD4AF37);
  static const Color _goldProgress = Color(0xFFE8C570);

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // Logo entrance
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // Subtle gentle pulse for emblem halo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Text fade entrance
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // Luxury loading bar animation
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    );
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOutCubic),
    );

    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Fetch latest verified platform settings and cache to prefs in background
    SettingApiProvider().fetchAndCacheSettings();

    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    try {
      await _loadingController.forward();
    } catch (_) {}
    if (!mounted || _hasNavigated) return;

    _navigateToDestination();
  }

  void _navigateToDestination() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    final storage = StorageHelper();
    final isLoggedIn = storage.getIsLoggedIn();
    final token = storage.getAccessToken();

    if (isLoggedIn == true && token != null && token.isNotEmpty) {
      final roleId = storage.getRoleId();
      if (roleId == 3 || roleId == 4) {
        final isVerified = storage.getIsVerified();
        final isOnboardingCompleted = storage.getVendorOnboardingCompleted();
        final draft = storage.getVendorDraft();
        final appStatus = storage.getApplicationStatus();

        // 1. If vendor registered but has not completed/submitted onboarding wizard:
        // Always resume directly from where they left the registration process!
        if (!isOnboardingCompleted || draft != null) {
          final draftStep = (draft?['step'] as int?) ?? 1;
          Navigator.of(context).pushReplacement(
            FadeScaleRoute(
              page: VendorRegistrationWizardScreen(initialStep: draftStep),
            ),
          );
          return;
        }

        // 2. If vendor completed the onboarding wizard but is awaiting admin review:
        if (!isVerified ||
            appStatus == 'Under Review' ||
            appStatus == 'Pending' ||
            appStatus == 'Submitted') {
          Navigator.of(context).pushReplacement(
            FadeScaleRoute(page: const VendorVerificationTrackerScreen()),
          );
          return;
        }

        // 3. Fully verified vendor with active dashboard access
        Navigator.of(context).pushReplacement(
          FadeScaleRoute(page: const VendorShell(initialIndex: 0)),
        );
      } else {
        Navigator.of(context).pushReplacement(
          FadeScaleRoute(page: const MainShell(initialIndex: 0)),
        );
      }
      return;
    }

    Navigator.of(context).pushReplacement(
      FadeScaleRoute(page: const OnboardingScreen()),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF8),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToDestination, // Allow tapping to proceed immediately
        child: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            final w = constraints.maxWidth;
            // Prominent logo size matching Figma reference (increased size)
            final logoSize = (w * 0.49).clamp(185.0, 215.0);
            // Photo begins right below tagline so full image is visible
            final photoTop = h * 0.36;

            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. Warm Cream Base Background
                Container(
                  color: const Color(0xFFFFFDF8),
                ),

                // 2. Full Couple Walking Photo (Clear & Unobstructed, no heavy overlay)
                Positioned(
                  top: photoTop,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Image.asset(
                    AppImages.onboardingWalkCouple,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      AppImages.weddingHero,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),

                // 3. Soft Top Feather (Sky smoothly fades into cream top)
                Positioned(
                  top: photoTop,
                  left: 0,
                  right: 0,
                  height: 60,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFFFDF8),
                          Color(0x00FFFDF8),
                        ],
                      ),
                    ),
                  ),
                ),

                // 4. Rich Maroon Bottom Gradient Overlay (Matches Figma reference)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: h * 0.40,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.42, 0.76, 1.0],
                        colors: [
                          Colors.transparent,
                          const Color(0xFF45040E).withValues(alpha: 0.35),
                          const Color(0xFF4E0511).withValues(alpha: 0.85),
                          const Color(0xFF38020A).withValues(alpha: 0.98),
                        ],
                      ),
                    ),
                  ),
                ),

                // 5. Top Section: Large Golden Circle Logo & Cursive Tagline
                SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top Brand Logo — completely transparent (no yellow halo/glow)
                          AnimatedBuilder(
                            animation: Listenable.merge([_logoController, _pulseController]),
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _logoOpacity,
                                child: ScaleTransition(
                                  scale: _logoScale,
                                  child: Transform.scale(
                                    scale: _pulseScale.value,
                                    child: SizedBox(
                                      width: logoSize,
                                      height: logoSize,
                                      child: Image.asset(
                                        AppImages.widooraLogo,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 14),

                          // Cursive Tagline: Plan • Discover • Celebrate
                          FadeTransition(
                            opacity: _logoOpacity,
                            child: Text(
                              'Plan  •  Discover  •  Celebrate',
                              style: GoogleFonts.alexBrush(
                                fontSize: 28,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF2C0B12),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 6. Bottom Section: Heading, Subheading & Loading Bar
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Your Dream Wedding',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Starts Here...',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.95),
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 22),

                            // Sleek Luxury Golden Loading Bar (Retained per request)
                            _buildLoadingBar(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  // Luxury Gold Loading Progress Bar
  Widget _buildLoadingBar() {
    return Container(
      width: 110,
      height: 3.5,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: AnimatedBuilder(
          animation: _loadingAnimation,
          builder: (context, child) {
            return FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _loadingAnimation.value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      _goldAccent,
                      _goldProgress,
                      Colors.white,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: _goldProgress.withValues(alpha: 0.60),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
