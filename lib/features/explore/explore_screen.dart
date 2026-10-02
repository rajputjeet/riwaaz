import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/app_animations.dart';
import '../service_listing/service_listing_screen.dart';
import '../vendor_detail/vendor_detail_screen.dart';
import '../shell/main_shell.dart';
import '../notifications/customer_notifications_screen.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/category_controller.dart';
import '../../core/constants/service_categories.dart';
import '../../data/api_provider/ad_api_provider.dart';
import '../../data/models/user_model.dart';
import '../../shared/widgets/cached_image_view.dart';
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
  final AdApiProvider _adApi = AdApiProvider();

  List<UserModel> _sponsoredVendors = [];
  bool _isLoadingVendors = true;

  @override
  void initState() {
    super.initState();
    _fetchSponsoredVendors();
    _searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  Future<void> _fetchSponsoredVendors() async {
    if (mounted) {
      setState(() {
        _isLoadingVendors = true;
      });
    }
    try {
      final res = await _adApi.getActiveSponsoredVendors();
      if (mounted) {
        setState(() {
          _isLoadingVendors = false;
          if (res.isSuccess == true && res.data != null) {
            _sponsoredVendors = res.data!;
          } else {
            _sponsoredVendors = [];
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingVendors = false;
          _sponsoredVendors = [];
        });
      }
    }
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
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  _fetchSponsoredVendors(),
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
    final categoryCtrl = Get.isRegistered<CategoryController>()
        ? CategoryController.to
        : Get.put(CategoryController(), permanent: true);

    return Obx(() {
      final query = _searchController.text.trim().toLowerCase();
      final allCategories = categoryCtrl.serviceCategories;
      final isLoading = categoryCtrl.isLoading.value;

      if (isLoading && allCategories.isEmpty) {
        return _buildCategoriesLoadingSkeleton();
      }

      if (allCategories.isEmpty) {
        return _buildEmptyCategories(categoryCtrl);
      }

      return _buildServiceGridContent(allCategories, query);
    });
  }

  Widget _buildCategoriesLoadingSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Browse Categories', style: AppTextStyles.headlineSmall),
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                ),
              ),
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
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.grey.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.greyLight.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 60,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.greyLight.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCategories(CategoryController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.category_outlined, size: 36, color: AppColors.grey),
            const SizedBox(height: 8),
            Text(
              'No categories available from server',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Categories will appear here once loaded from the server.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => ctrl.fetchCategories(forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.primary),
              label: const Text(
                'Refresh Categories',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceGridContent(List<ServiceCategoryItem> source, String query) {
    final displayedCategories = query.isEmpty
        ? source
        : source
            .where((c) =>
                c.title.toLowerCase().contains(query) ||
                c.desc.toLowerCase().contains(query))
            .toList();

    if (displayedCategories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Browse Categories', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 16),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No categories match "$query"',
                  style: const TextStyle(color: AppColors.grey),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Browse Categories', style: AppTextStyles.headlineSmall),
              if (Get.isRegistered<CategoryController>() &&
                  CategoryController.to.isLoading.value)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.78,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ServiceIconWrap(
                        item: cat,
                        size: 88,
                        iconSize: 54,
                        borderRadius: 22,
                        isSelected: false,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                          height: 1.15,
                        ),
                      ),
                    ],
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
    final query = _searchController.text.trim().toLowerCase();
    final displayedSponsored = query.isEmpty
        ? _sponsoredVendors
        : _sponsoredVendors.where((v) {
            final bName = v.vendorProfile?.businessName?.toLowerCase() ?? '';
            final fName = v.fullName?.toLowerCase() ?? '';
            final city = v.vendorProfile?.city?.toLowerCase() ?? '';
            final adT = v.vendorProfile?.adTitle?.toLowerCase() ?? '';
            final badge = (v.adBadge ?? v.vendorProfile?.adBadge)?.toLowerCase() ?? '';
            return bName.contains(query) ||
                fName.contains(query) ||
                city.contains(query) ||
                adT.contains(query) ||
                badge.contains(query);
          }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Featured & Sponsored', style: AppTextStyles.headlineSmall),
              if (_sponsoredVendors.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD97706),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_sponsoredVendors.length} Active',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              if (_isLoadingVendors)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                  ),
                )
              else
                IconButton(
                  onPressed: _fetchSponsoredVendors,
                  icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.primary),
                  tooltip: 'Refresh Sponsored Vendors',
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 8),

          if (_isLoadingVendors && _sponsoredVendors.isEmpty)
            _buildFeaturedLoadingSkeleton()
          else if (displayedSponsored.isEmpty)
            _buildEmptyFeaturedVendors(query.isNotEmpty)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedSponsored.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final v = displayedSponsored[index];
                final name = v.vendorProfile?.businessName ?? v.fullName ?? 'Sponsored Partner';
                final loc = v.vendorProfile?.city ?? 'Punjab';
                final badge = v.adBadge ?? v.vendorProfile?.adBadge ?? v.vendorProfile?.adTitle ?? 'SPONSORED';
                final priority = v.adPriority ?? v.vendorProfile?.adPriority ?? (index + 1);
                final daysLeft = v.vendorProfile?.adDaysLeft;
                final duration = v.vendorProfile?.adDuration;
                final category = (v.vendorProfile?.services != null && v.vendorProfile!.services!.isNotEmpty)
                    ? v.vendorProfile!.services!.join(', ')
                    : (v.vendorProfile?.adTitle ?? 'Wedding Vendor Partner');

                String priceText = 'Featured Partner';
                if (v.vendorProfile?.packages != null && v.vendorProfile!.packages!.isNotEmpty) {
                  final firstPkg = v.vendorProfile!.packages!.first;
                  if (firstPkg is Map && firstPkg['price'] != null) {
                    priceText = '₹${firstPkg['price']} onwards';
                  }
                }

                final img = (v.profileImgUrl != null && v.profileImgUrl!.isNotEmpty)
                    ? v.profileImgUrl!
                    : AppImages.vendorRoyalClick;

                return _buildVerticalFeaturedCard(
                  name: name,
                  category: category,
                  location: loc,
                  rating: '4.9',
                  reviews: 180 + (priority <= 3 ? (4 - priority) * 35 : 10),
                  price: priceText,
                  imagePath: img,
                  isSponsored: true,
                  adBadgeText: badge,
                  adPriority: priority,
                  adDaysLeft: daysLeft,
                  adDuration: duration,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyFeaturedVendors(bool isSearch) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEADBCE),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFFAF2E9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearch ? Icons.search_off_rounded : Icons.campaign_outlined,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isSearch ? 'No Sponsored Vendors Found' : 'No Featured Vendors Right Now',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF26050E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isSearch
                ? 'No active sponsored vendors match your search.'
                : 'Active sponsored vendors and featured partners will appear here once campaigns run.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              if (isSearch) {
                _searchController.clear();
                setState(() {});
              } else {
                _fetchSponsoredVendors();
              }
            },
            icon: Icon(
              isSearch ? Icons.clear_rounded : Icons.refresh_rounded,
              size: 16,
              color: AppColors.primary,
            ),
            label: Text(
              isSearch ? 'Clear Search' : 'Refresh Featured',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedLoadingSkeleton() {
    return Column(
      children: List.generate(2, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          height: 220,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grey.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.greyLight.withValues(alpha: 0.4),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 14,
                              width: 140,
                              decoration: BoxDecoration(
                                color: AppColors.greyLight.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 10,
                              width: 90,
                              decoration: BoxDecoration(
                                color: AppColors.greyLight.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 32,
                        width: 65,
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(8),
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
    bool isSponsored = true,
    String? adBadgeText,
    int? adPriority,
    int? adDaysLeft,
    String? adDuration,
  }) {
    final badgeUpper = (adBadgeText ?? '').toUpperCase();
    final is1Week = badgeUpper.contains('1 WEEK') || badgeUpper.contains('PLATINUM');
    final is3Days = badgeUpper.contains('3 DAYS') || badgeUpper.contains('SPOTLIGHT');
    final is1Day = badgeUpper.contains('1 DAY') || badgeUpper.contains('BOOST');

    final LinearGradient badgeGradient = is1Week
        ? const LinearGradient(colors: [Color(0xFFD97706), Color(0xFFB45309)])
        : is3Days
            ? const LinearGradient(colors: [Color(0xFFEA580C), Color(0xFFC2410C)])
            : is1Day
                ? const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFBE123C)])
                : const LinearGradient(colors: [Color(0xFFEAB308), Color(0xFFCA8A04)]);

    final IconData badgeIcon = is1Week
        ? Icons.workspace_premium_rounded
        : is3Days
            ? Icons.star_rounded
            : is1Day
                ? Icons.bolt_rounded
                : Icons.stars_rounded;

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
                    height: 150,
                    width: double.infinity,
                    child: CachedImageView(
                      imageUrl: imagePath,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.storefront_rounded,
                      iconColor: Colors.white54,
                      iconSize: 36,
                      backgroundColor: AppColors.primaryDark,
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
                          Colors.black.withValues(alpha: 0.50),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // "FEATURED" / "SPONSORED" badge + optional Priority #1
                Positioned(
                  top: 10,
                  left: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: isSponsored ? badgeGradient : null,
                          color: isSponsored ? null : AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              badgeIcon,
                              size: 13,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              adBadgeText ?? (isSponsored ? 'SPONSORED' : 'FEATURED'),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (adPriority != null && adPriority == 1) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.trending_up_rounded, size: 12, color: Colors.white),
                              SizedBox(width: 3),
                              Text(
                                '#1 TOP',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Rating & Days Left badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (adDaysLeft != null && adDaysLeft > 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer_outlined, size: 11, color: Color(0xFFFDE68A)),
                              const SizedBox(width: 3),
                              Text(
                                '${adDaysLeft}d left',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                      Container(
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
                    ],
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
                        Row(
                          children: [
                            Text(
                              price,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            if (adDuration != null && adDuration.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  adDuration,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ),
                            ],
                          ],
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
