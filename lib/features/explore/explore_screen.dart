import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/app_animations.dart';
import '../service_listing/service_listing_screen.dart';
import '../vendor_detail/vendor_detail_screen.dart';
import '../shell/main_shell.dart';

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
  final int _selectedCategory = 0;

  final List<_ServiceCategory> _categories = [
    _ServiceCategory(Icons.camera_alt_rounded, 'Photography', const Color(0xFF8B1A2E)),
    _ServiceCategory(Icons.videocam_rounded, 'Videography', const Color(0xFF1565C0)),
    _ServiceCategory(Icons.local_florist_rounded, 'Decoration', const Color(0xFF2E7D32)),
    _ServiceCategory(Icons.restaurant_rounded, 'Catering', const Color(0xFFE65100)),
    _ServiceCategory(Icons.location_city_rounded, 'Tent House', const Color(0xFF4527A0)),
    _ServiceCategory(Icons.directions_car_rounded, 'Wedding Car', const Color(0xFF00838F)),
    _ServiceCategory(Icons.checkroom_rounded, 'Bridal Wear', const Color(0xFFAD1457)),
    _ServiceCategory(Icons.face_rounded, 'DJ / Sound', const Color(0xFF558B2F)),
    _ServiceCategory(Icons.diamond_rounded, 'Jewellery', const Color(0xFFD4A017)),
    _ServiceCategory(Icons.celebration_rounded, 'Honeymoon', const Color(0xFF6A1B9A)),
    _ServiceCategory(Icons.fort_rounded, 'Banquet Hall', const Color(0xFF37474F)),
    _ServiceCategory(Icons.more_horiz_rounded, 'More', const Color(0xFF78909C)),
  ];

  @override
  void dispose() {
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
                  const SizedBox(height: 16),
                  FadeInWidget(
                    delay: const Duration(milliseconds: 150),
                    child: _buildServiceGrid(),
                  ),
                  const SizedBox(height: 20),
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
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Explore Services',
                  style: AppTextStyles.headlineMedium,
                ),
                const Spacer(),
                AnimatedTapWidget(
                  onTap: () {},
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Search Bar
            Container(
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search services, vendors...',
                  hintStyle:
                      AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.grey,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Our Services', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, i) {
              final cat = _categories[i];
              return FadeInWidget(
                delay: Duration(milliseconds: 40 * i),
                child: AnimatedTapWidget(
                  onTap: () {
                    Navigator.of(context).push(
                      SlidePageRoute(
                        page: ServiceListingScreen(
                          category: cat.label,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: cat.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: _selectedCategory == i
                              ? Border.all(color: cat.color, width: 2)
                              : null,
                        ),
                        child: Icon(cat.icon, color: cat.color, size: 26),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat.label,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.darkGrey,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('Featured Vendors', style: AppTextStyles.headlineSmall),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    SlidePageRoute(
                      page: const ServiceListingScreen(category: 'All Vendors'),
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
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 190,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildFeaturedCard(
                'Royal Click Studio',
                'Photography',
                '4.9',
                '₹35,000 onwards',
                AppImages.vendorRoyalClick,
              ),
              _buildFeaturedCard(
                'Bloom Decor',
                'Decoration',
                '4.7',
                '₹20,000 onwards',
                AppImages.exploreDecoration,
              ),
              _buildFeaturedCard(
                'Audi A8 Luxury',
                'Wedding Car',
                '4.8',
                '₹8,000/day',
                AppImages.exploreWeddingCar,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(
    String name,
    String category,
    String rating,
    String price,
    String imagePath,
  ) {
    return AnimatedTapWidget(
      onTap: () {
        Navigator.of(context).push(
          SlidePageRoute(
            page: VendorDetailScreen(
              vendorName: name,
              location: 'Chandigarh',
              rating: double.tryParse(rating) ?? 4.9,
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Real image with cover fit
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.primaryDark,
                    child: const Icon(Icons.image_rounded,
                        color: Colors.white54, size: 32),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.labelLarge.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.gold, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

class _ServiceCategory {
  final IconData icon;
  final String label;
  final Color color;
  _ServiceCategory(this.icon, this.label, this.color);
}
