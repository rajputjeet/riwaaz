import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/app_animations.dart';
import '../service_listing/service_listing_screen.dart';
import '../vendor_detail/vendor_detail_screen.dart';
import '../shell/main_shell.dart';
import '../notifications/customer_notifications_screen.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/service_categories.dart';
import '../../shared/widgets/service_categories_bar.dart';
import '../../shared/widgets/app_search_bar.dart';

/// Standalone Explore screen wrapper that launches MainShell at tab index 1
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainShell(initialIndex: 1);
  }
}

/// The body widget for the Explore tab inside [MainShell].
class ExploreBody extends StatefulWidget {
  const ExploreBody({super.key});

  @override
  State<ExploreBody> createState() => _ExploreBodyState();
}

class _ExploreBodyState extends State<ExploreBody> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _buildSearchHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  FadeInWidget(
                    delay: const Duration(milliseconds: 150),
                    child: _buildServiceGrid(),
                  ),
                  const SizedBox(height: 14),
                  FadeInWidget(
                    delay: const Duration(milliseconds: 250),
                    child: _buildFeaturedSection(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFFDFC),
            Color(0xFFFAF2E9),
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFEADBCE), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF380C1D).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title, Notification
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Our Services',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF26050E),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                // Notification Button with active ping
                AnimatedTapWidget(
                  onTap: () {
                    Navigator.of(context).push(
                      FadeScaleRoute(
                        page: const CustomerNotificationsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF3EB),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFEADBCE),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_outlined,
                          size: 20,
                          color: AppColors.primaryDark,
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE11D48),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Unified Luxury Search Bar with instant tap highlight & pristine rounded corners
            AppSearchBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              hintText: 'Search vendors for parties, birthdays, weddings, corporate...',
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceGrid() {
    final query = _searchController.text.trim().toLowerCase();
    final displayedCategories = query.isEmpty
        ? kServiceCategories
        : kServiceCategories
            .where((c) =>
                c.title.toLowerCase().contains(query) ||
                c.desc.toLowerCase().contains(query))
            .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Browse Categories', style: AppTextStyles.headlineSmall),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 8,
              childAspectRatio: 0.90,
            ),
            itemCount: displayedCategories.length,
            itemBuilder: (context, i) {
              final cat = displayedCategories[i];

              return FadeInWidget(
                delay: Duration(milliseconds: 15 * i),
                child: AnimatedTapWidget(
                  onTap: () {
                    Navigator.of(context).push(
                      SlidePageRoute(
                        page: ServiceListingScreen(
                          category: cat.title,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.grey.withValues(alpha: 0.22),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ServiceIconWrap(
                          item: cat,
                          size: 46,
                          iconSize: 22,
                          borderRadius: 12,
                          isSelected: false,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          cat.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection() {
    final featuredVendors = [
      (
        'Royal Click Studio',
        'Photography & Videography',
        'Chandigarh',
        '4.9',
        320,
        '₹35,000 onwards',
        AppImages.vendorRoyalClick,
      ),
      (
        'Royal Mandap & Floral Decor',
        'Decor & Flora',
        'Chandigarh',
        '4.9',
        240,
        '₹45,000 onwards',
        AppImages.exploreDecoration,
      ),
      (
        'Heritage Haveli Resort & Palace',
        'Banquet Halls & Hotels',
        'Mohali',
        '4.9',
        420,
        '₹2,50,000 onwards',
        AppImages.weddingHero,
      ),
      (
        'Audi A8 & Vintage Car Rentals',
        'Wedding Cars',
        'Chandigarh',
        '4.8',
        155,
        '₹15,000 onwards',
        AppImages.exploreWeddingCar,
      ),
      (
        'Flavours of Punjab Caterers',
        'Catering',
        'Chandigarh',
        '4.9',
        310,
        '₹850 onwards',
        AppImages.exploreCatering,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Featured Vendors', style: AppTextStyles.headlineSmall),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    SlidePageRoute(
                      page: const ServiceListingScreen(
                          category: 'Photography & Videography'),
                    ),
                  );
                },
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Vertical list of featured vendors
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: featuredVendors.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final v = featuredVendors[index];
              return _buildVerticalFeaturedCard(
                name: v.$1,
                category: v.$2,
                location: v.$3,
                rating: v.$4,
                reviews: v.$5,
                price: v.$6,
                imagePath: v.$7,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalFeaturedCard({
    required String name,
    required String category,
    required String location,
    required String rating,
    required int reviews,
    required String price,
    required String imagePath,
  }) {
    return AnimatedTapWidget(
      onTap: () {
        Navigator.of(context).push(
          SlidePageRoute(
            page: VendorDetailScreen(
              vendorName: name,
              location: location,
              rating: double.tryParse(rating) ?? 4.9,
              reviews: reviews,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image with badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    height: 145,
                    width: double.infinity,
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.primaryDark,
                        child: const Icon(Icons.image_rounded,
                            color: Colors.white54, size: 36),
                      ),
                    ),
                  ),
                ),
                // Gradient for contrast
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.45),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // "FEATURED" pill
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.workspace_premium_rounded,
                            size: 12, color: AppColors.goldLight),
                        SizedBox(width: 4),
                        Text(
                          'FEATURED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Rating badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 13, color: AppColors.gold),
                        const SizedBox(width: 3),
                        Text(
                          rating,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          ' ($reviews)',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Vendor Details Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                size: 12, color: AppColors.grey),
                            const SizedBox(width: 2),
                            Text(
                              location,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.darkGrey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(
                                color: AppColors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.darkGrey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.chevron_right_rounded,
                            size: 16, color: AppColors.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
