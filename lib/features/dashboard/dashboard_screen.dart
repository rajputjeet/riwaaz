import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/category_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/utils/app_animations.dart';
import '../../data/api_provider/ad_api_provider.dart';
import '../../data/api_provider/vendor_api_provider.dart';
import '../../data/models/user_model.dart';
import '../../shared/widgets/cached_image_view.dart';
import '../../shared/widgets/service_categories_bar.dart';
import '../explore/explore_screen.dart';
import '../notifications/customer_notifications_screen.dart';
import '../service_listing/service_listing_screen.dart';
import '../shell/main_shell.dart';
import '../vendor_detail/vendor_detail_screen.dart';

/// Standalone Dashboard screen wrapper that launches MainShell at tab index 0
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainShell(initialIndex: 0);
  }
}

/// Body-only dashboard widget — no Scaffold, no BottomNav.
/// Owned by [MainShell] which provides the surrounding Scaffold + nav.
class DashboardBody extends StatefulWidget {
  final void Function(int tabIndex)? onNavigateTab;

  const DashboardBody({super.key, this.onNavigateTab});

  @override
  State<DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<DashboardBody> {
  late final PageController _bannersPageController;
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;

  final AdApiProvider _adApi = AdApiProvider();
  final VendorApiProvider _vendorApi = VendorApiProvider();
  List<UserModel> _featuredVendors = [];
  bool _isLoadingVendors = true;

  final Set<String> _wishlistedVendors = <String>{};

  // Banners matching the reference screenshot design (top cards exception)
  final List<_HomeBannerItem> _banners = const [
    _HomeBannerItem(
      title: 'Make Your\nDream Wedding\nHappen',
      buttonText: 'Explore Now',
      image: AppImages.weddingHero,
      targetCategory: 'Photographers & Videographers',
    ),
    _HomeBannerItem(
      title: 'Grand Palace Venues\n& Royal Mandaps',
      buttonText: 'View Venues',
      image: AppImages.onboardingMandap,
      targetCategory: 'Venues',
    ),
    _HomeBannerItem(
      title: 'Bridal Glamour\n& Haute Couture',
      buttonText: 'Book Artists',
      image: AppImages.exploreDecoration,
      targetCategory: 'Bridal Makeup & Hair',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bannersPageController = PageController();
    _startBannerAutoScroll();
    _fetchFeaturedVendors();
    if (Get.isRegistered<CategoryController>()) {
      final catCtrl = CategoryController.to;
      if (!catCtrl.isLoaded.value && !catCtrl.isLoading.value) {
        catCtrl.fetchCategories();
      }
    }
  }

  Future<void> _fetchFeaturedVendors() async {
    if (!mounted) return;
    setState(() => _isLoadingVendors = true);

    try {
      // 1. Try active sponsored vendors first
      final adRes = await _adApi.getActiveSponsoredVendors();
      if (adRes.isSuccess == true &&
          adRes.data != null &&
          adRes.data!.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _featuredVendors = adRes.data!;
          _isLoadingVendors = false;
        });
        return;
      }

      // 2. Fall back to live verified vendors list API
      final vendorRes = await _vendorApi.getVendorsList();
      if (!mounted) return;
      setState(() {
        if (vendorRes.isSuccess == true && vendorRes.data != null) {
          _featuredVendors = vendorRes.data!;
        } else {
          _featuredVendors = [];
        }
        _isLoadingVendors = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _featuredVendors = [];
        _isLoadingVendors = false;
      });
    }
  }

  void _startBannerAutoScroll() {
    if (!kIsWeb) {
      try {
        if (Platform.environment.containsKey('FLUTTER_TEST')) return;
      } catch (_) {}
    }
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_bannersPageController.hasClients || _banners.isEmpty) return;
      final nextIndex = (_currentBannerIndex + 1) % _banners.length;
      _bannersPageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannersPageController.dispose();
    super.dispose();
  }

  List<_FeaturedVendorItem> get _featuredVendorsList {
    return _featuredVendors
        .map((u) => _FeaturedVendorItem.fromUserModel(u))
        .toList();
  }

  void _navigateToExplore() {
    if (widget.onNavigateTab != null) {
      widget.onNavigateTab!(1);
    } else {
      Navigator.of(context).push(
        FadeScaleRoute(
          page: const ServiceListingScreen(
            category: 'Photographers & Videographers',
            showBottomNav: false,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _buildTopBar(),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSearchBar(),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  _fetchFeaturedVendors(),
                  if (Get.isRegistered<CategoryController>())
                    CategoryController.to.fetchCategories(forceRefresh: true),
                ]);
              },
              color: AppColors.primary,
              backgroundColor: AppColors.white,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBannersSection(),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildCategoriesSection(),
                    ),
                    const SizedBox(height: 6),
                    _buildFeaturedVendorsSection(),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Top branding bar: "WIDOORA" royal wordmark + Notification bell
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                AppImages.widooraLogo,
                height: 48,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'W',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'WIDOORA',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF6B1426),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                FadeScaleRoute(
                  page: const CustomerNotificationsScreen(),
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    size: 24,
                    color: AppColors.darkGrey,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
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
  }

  /// Search bar matching reference screenshot
  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: _navigateToExplore,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFEADBCE), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, size: 20, color: Color(0xFF8A8A8A)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search vendors, categories, services...',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: const Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hero dummy banners carousel with overlay text and "Explore Now →"
  Widget _buildBannersSection() {
    return Column(
      children: [
        SizedBox(
          height: 175,
          child: PageView.builder(
            controller: _bannersPageController,
            itemCount: _banners.length,
            onPageChanged: (i) {
              setState(() => _currentBannerIndex = i);
            },
            itemBuilder: (context, index) {
              final b = _banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedImageView(
                        imageUrl: b.image,
                        fit: BoxFit.cover,
                        backgroundColor: AppColors.cream,
                        fallbackIcon: Icons.celebration_rounded,
                      ),
                      // Gradient overlay for elegant contrast
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withValues(alpha: 0.72),
                              Colors.black.withValues(alpha: 0.40),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.58, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        top: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              b.title,
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                                height: 1.15,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 14),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  FadeScaleRoute(
                                    page: ServiceListingScreen(
                                      category: b.targetCategory ??
                                          'Photographers & Videographers',
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      b.buttonText,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 13,
                                      color: AppColors.black,
                                    ),
                                  ],
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
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            final isActive = _currentBannerIndex == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 18 : 6,
              height: 5,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : const Color(0xFFD6C8BC),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Categories 2x4 grid with "& More" option using real categories from CategoryController
  Widget _buildCategoriesSection() {
    if (!Get.isRegistered<CategoryController>()) {
      return const SizedBox.shrink();
    }

    final catCtrl = CategoryController.to;

    return Obx(() {
      if (catCtrl.isLoading.value && catCtrl.serviceCategories.isEmpty) {
        return _buildCategoriesSkeleton();
      }

      final realCats = catCtrl.serviceCategories;
      if (realCats.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
              width: 0.8,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.category_outlined,
                size: 32,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'No categories available right now',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 6),
              TextButton.icon(
                onPressed: () => catCtrl.fetchCategories(forceRefresh: true),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Refresh'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        );
      }

      final bool hasMore = realCats.length >= 5;
      final int itemCount = hasMore ? 6 : realCats.length;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 2,
          childAspectRatio: 0.89,
        ),
        itemBuilder: (context, index) {
          final isMoreButton = hasMore && index == 5;

          if (isMoreButton) {
            return AnimatedTapWidget(
              onTap: () {
                if (widget.onNavigateTab != null) {
                  widget.onNavigateTab!(1);
                } else {
                  Navigator.of(context).push(
                    FadeScaleRoute(page: const ExploreScreen()),
                  );
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.045),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.more_horiz_rounded,
                        size: 60,
                        color: Color(0xFF790D16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '& More',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C2424),
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            );
          }

          final cat = realCats[index];
          return AnimatedTapWidget(
            onTap: () {
              Navigator.of(context).push(
                FadeScaleRoute(
                  page: ServiceListingScreen(
                    category: cat.title,
                    showBottomNav: false,
                  ),
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ServiceIconWrap(
                  item: cat,
                  size: 84,
                  iconSize: 64,
                  borderRadius: 18,
                  isSelected: false,
                ),
                const SizedBox(height: 2),
                Text(
                  cat.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C2424),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildCategoriesSkeleton() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 2,
        childAspectRatio: 0.89,
      ),
      itemBuilder: (context, index) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  width: 0.8,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.category_outlined,
                  size: 30,
                  color: AppColors.primary.withValues(alpha: 0.20),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 52,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Featured Vendors section with "See All" and horizontal cards
  Widget _buildFeaturedVendorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Featured Vendors',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                  letterSpacing: 0.2,
                ),
              ),
              GestureDetector(
                onTap: _navigateToExplore,
                child: Text(
                  'See All',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF790D16),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoadingVendors)
          _buildFeaturedVendorsSkeleton()
        else if (_featuredVendorsList.isEmpty)
          _buildEmptyFeaturedVendors()
        else
          SizedBox(
            height: 220,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _featuredVendorsList.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final v = _featuredVendorsList[index];
                final isWishlisted = _wishlistedVendors.contains(v.id);

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      FadeScaleRoute(
                        page: VendorDetailScreen(
                          vendorName: v.name,
                          location: v.location,
                          rating: v.rating,
                          reviews: v.reviews,
                          startingPrice: v.startingPrice,
                          category: v.category,
                          imageUrl: v.image,
                          vendorModel: v.vendorModel,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 180,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFEADBCE),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image with Heart Wishlist Button
                        Stack(
                          children: [
                            CachedImageView(
                              imageUrl: v.image,
                              width: 180,
                              height: 118,
                              fit: BoxFit.cover,
                              fallbackIcon: Icons.storefront_rounded,
                              iconColor: AppColors.gold,
                              backgroundColor: AppColors.cream,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isWishlisted) {
                                      _wishlistedVendors.remove(v.id);
                                    } else {
                                      _wishlistedVendors.add(v.id);
                                    }
                                  });
                                },
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.white.withValues(alpha: 0.92),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.12),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isWishlisted
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: isWishlisted
                                        ? const Color(0xFFE11D48)
                                        : const Color(0xFF757575),
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Details
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                v.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 15,
                                    color: Color(0xFFF59E0B),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${v.rating.toStringAsFixed(1)} ',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  Text(
                                    '(${v.reviews})',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: const Color(0xFF757575),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                v.startingPrice > 0
                                    ? '${v.location} • ₹${_formatPrice(v.startingPrice)}'
                                    : '${v.location} • View Packages',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: const Color(0xFF757575),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFeaturedVendorsSkeleton() {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return Container(
            width: 180,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFEADBCE),
                width: 0.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 180,
                  height: 118,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.storefront_outlined,
                      size: 32,
                      color: AppColors.primary.withValues(alpha: 0.25),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 110,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 60,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 90,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyFeaturedVendors() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEADBCE),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Featured Vendors',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Explore wedding vendors by category above',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: const Color(0xFF757575),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _fetchFeaturedVendors,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    if (price >= 100000) {
      final l = price / 100000;
      return '${l.toStringAsFixed(l.truncateToDouble() == l ? 0 : 1)} Lakh';
    } else if (price >= 1000) {
      final k = price / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k';
    }
    return price.toString();
  }
}

class _HomeBannerItem {
  final String title;
  final String buttonText;
  final String image;
  final String? targetCategory;

  const _HomeBannerItem({
    required this.title,
    required this.buttonText,
    required this.image,
    this.targetCategory,
  });
}

class _FeaturedVendorItem {
  final String id;
  final String name;
  final String category;
  final String location;
  final double rating;
  final int reviews;
  final int startingPrice;
  final String image;
  final UserModel vendorModel;

  const _FeaturedVendorItem({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.startingPrice,
    required this.image,
    required this.vendorModel,
  });

  factory _FeaturedVendorItem.fromUserModel(UserModel u) {
    final prof = u.vendorProfile;
    final name = (prof?.businessName != null &&
            prof!.businessName!.trim().isNotEmpty)
        ? prof.businessName!.trim()
        : (u.fullName != null && u.fullName!.trim().isNotEmpty
            ? u.fullName!.trim()
            : 'Verified Specialist');

    String cat = '';
    if (prof?.services != null && prof!.services!.isNotEmpty) {
      cat = prof.services!.first.toString();
    } else if (prof?.adTitle != null && prof!.adTitle!.trim().isNotEmpty) {
      cat = prof.adTitle!.trim();
    } else {
      cat = 'Wedding Specialist';
    }

    final loc = (prof?.city != null && prof!.city!.trim().isNotEmpty)
        ? prof.city!.trim()
        : (prof?.businessAddress != null &&
                prof!.businessAddress!.trim().isNotEmpty
            ? prof.businessAddress!.trim()
            : 'Punjab');

    int price = 0;
    final pkgs = prof?.packages;
    if (pkgs != null && pkgs.isNotEmpty) {
      for (final p in pkgs) {
        if (p is Map && p['price'] != null) {
          final val = int.tryParse(p['price'].toString()) ?? 0;
          if (val > 0 && (price == 0 || val < price)) {
            price = val;
          }
        }
      }
    }

    String img = '';
    if (u.profileImgUrl != null && u.profileImgUrl!.trim().isNotEmpty) {
      img = u.profileImgUrl!.trim();
    } else {
      final port = prof?.portfolio;
      if (port != null && port.isNotEmpty) {
        final item = port.first;
        if (item is String && item.trim().isNotEmpty) {
          img = item.trim();
        } else if (item is Map && item['url'] != null) {
          img = item['url'].toString().trim();
        }
      }
    }

    return _FeaturedVendorItem(
      id: u.id ?? name,
      name: name,
      category: cat,
      location: loc,
      rating: 4.9,
      reviews: 115,
      startingPrice: price,
      image: img,
      vendorModel: u,
    );
  }
}
