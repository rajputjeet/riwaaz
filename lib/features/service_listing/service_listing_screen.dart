import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/app_animations.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../vendor_detail/vendor_detail_screen.dart';
import '../shell/main_shell.dart';

class ServiceListingScreen extends StatefulWidget {
  final String category;

  const ServiceListingScreen({
    super.key,
    this.category = 'Photography',
  });

  @override
  State<ServiceListingScreen> createState() => _ServiceListingScreenState();
}

class _ServiceListingScreenState extends State<ServiceListingScreen>
    with SingleTickerProviderStateMixin {
  final int _navIndex = 1;
  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _listController;

  final List<String> _filters = ['Location', 'Price', 'Rating', 'Filters'];

  late List<_VendorData> _vendors;

  @override
  void initState() {
    super.initState();
    _vendors = _getCategoryVendors(widget.category);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  List<_VendorData> _getCategoryVendors(String cat) {
    final catLower = cat.toLowerCase();
    if (catLower.contains('decor')) {
      return [
        _VendorData(
          name: 'Royal Mandap & Floral Decor',
          location: 'Chandigarh',
          rating: 4.9,
          reviews: 240,
          startingPrice: 45000,
          isWishlisted: true,
          imagePath: AppImages.exploreDecoration,
        ),
        _VendorData(
          name: 'Flora Magic Events',
          location: 'Mohali',
          rating: 4.8,
          reviews: 180,
          startingPrice: 35000,
          isWishlisted: false,
          imagePath: AppImages.vendorMemories,
        ),
        _VendorData(
          name: 'Grand Stage Crafters',
          location: 'Ludhiana',
          rating: 4.7,
          reviews: 130,
          startingPrice: 55000,
          isWishlisted: false,
          imagePath: AppImages.vendorCandid,
        ),
      ];
    } else if (catLower.contains('cater')) {
      return [
        _VendorData(
          name: 'Flavours of Punjab Caterers',
          location: 'Chandigarh',
          rating: 4.9,
          reviews: 310,
          startingPrice: 850,
          isWishlisted: true,
          imagePath: AppImages.exploreCatering,
        ),
        _VendorData(
          name: 'Royal Feast Banquet Food',
          location: 'Panchkula',
          rating: 4.8,
          reviews: 195,
          startingPrice: 1100,
          isWishlisted: false,
          imagePath: AppImages.vendorRoyalClick,
        ),
      ];
    } else if (catLower.contains('car') || catLower.contains('vehicle')) {
      return [
        _VendorData(
          name: 'Royal Vintage & Luxury Cars',
          location: 'Chandigarh',
          rating: 4.9,
          reviews: 155,
          startingPrice: 15000,
          isWishlisted: true,
          imagePath: AppImages.exploreWeddingCar,
        ),
        _VendorData(
          name: 'Punjab Elite Limousines',
          location: 'Ludhiana',
          rating: 4.7,
          reviews: 98,
          startingPrice: 20000,
          isWishlisted: false,
          imagePath: AppImages.vendorLensArt,
        ),
      ];
    } else if (catLower.contains('venue') ||
        catLower.contains('tent') ||
        catLower.contains('hall')) {
      return [
        _VendorData(
          name: 'Heritage Haveli Resort',
          location: 'Mohali, Punjab',
          rating: 4.9,
          reviews: 420,
          startingPrice: 250000,
          isWishlisted: true,
          imagePath: AppImages.weddingHero,
        ),
        _VendorData(
          name: 'The Grand Palace Resort',
          location: 'Chandigarh',
          rating: 4.8,
          reviews: 380,
          startingPrice: 350000,
          isWishlisted: false,
          imagePath: AppImages.vendorRoyalClick,
        ),
      ];
    } else {
      // Default / Photography
      return [
        _VendorData(
          name: 'Royal Click Studio',
          location: 'Chandigarh',
          rating: 4.9,
          reviews: 320,
          startingPrice: 35000,
          isWishlisted: true,
          imagePath: AppImages.vendorRoyalClick,
        ),
        _VendorData(
          name: 'Memories Forever',
          location: 'Mohali',
          rating: 4.8,
          reviews: 210,
          startingPrice: 28000,
          isWishlisted: false,
          imagePath: AppImages.vendorMemories,
        ),
        _VendorData(
          name: 'Shutter Magic',
          location: 'Ludhiana',
          rating: 4.7,
          reviews: 185,
          startingPrice: 22000,
          isWishlisted: false,
          imagePath: AppImages.vendorShutter,
        ),
        _VendorData(
          name: 'Candid Clicks',
          location: 'Patiala',
          rating: 4.6,
          reviews: 150,
          startingPrice: 18000,
          isWishlisted: false,
          imagePath: AppImages.vendorCandid,
        ),
        _VendorData(
          name: 'LensArt Studio',
          location: 'Amritsar',
          rating: 4.8,
          reviews: 265,
          startingPrice: 32000,
          isWishlisted: false,
          imagePath: AppImages.vendorLensArt,
        ),
      ];
    }
  }

  @override
  void dispose() {
    _listController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterRow(),
          Expanded(
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _vendors.length,
              itemBuilder: (context, i) {
                return _buildVendorCard(_vendors[i]);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: (i) {
          if (i == 1) {
            Navigator.pop(context);
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => MainShell(initialIndex: i)),
              (route) => false,
            );
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  AnimatedTapWidget(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.category,
                    style: AppTextStyles.headlineMedium,
                  ),
                  const Spacer(),
                  AnimatedTapWidget(
                    onTap: () {},
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        size: 18,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedTapWidget(
                    onTap: () {},
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.grid_view_rounded,
                        size: 18,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _searchController,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Search ${widget.category.toLowerCase()}...',
                    hintStyle:
                        AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.grey,
                      size: 18,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: _filters.asMap().entries.map((entry) {
          final i = entry.key;
          final label = entry.value;
          final isActive = _selectedFilter == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedTapWidget(
              onTap: () => setState(() => _selectedFilter = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: isActive ? AppColors.white : AppColors.darkGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.expand_more,
                      size: 14,
                      color: isActive ? AppColors.white : AppColors.grey,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVendorCard(_VendorData vendor) {
    return AnimatedTapWidget(
      onTap: () {
        Navigator.of(context).push(
          SlidePageRoute(
            page: VendorDetailScreen(
              vendorName: vendor.name,
              location: vendor.location,
              rating: vendor.rating,
              reviews: vendor.reviews,
              startingPrice: vendor.startingPrice,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          vendor.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.primaryDark,
                            child: const Icon(Icons.camera_alt_rounded,
                                color: Colors.white54, size: 40),
                          ),
                        ),
                        // Subtle dark overlay at the bottom for badge readability
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
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
                      ],
                    ),
                  ),
                ),

                // Wishlist button
                Positioned(
                  top: 10,
                  right: 10,
                  child: AnimatedTapWidget(
                    onTap: () {},
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        vendor.isWishlisted
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: vendor.isWishlisted
                            ? AppColors.primary
                            : AppColors.grey,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                // Badge
                if (vendor.isWishlisted)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Top Rated',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vendor.name,
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const Icon(Icons.star_rounded,
                          color: AppColors.gold, size: 16),
                      const SizedBox(width: 3),
                      Text(
                        vendor.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        ' (${vendor.reviews})',
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: AppColors.grey, size: 13),
                      const SizedBox(width: 2),
                      Text(
                        vendor.location,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        '₹${(vendor.startingPrice / 1000).toStringAsFixed(0)}K onwards',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
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

class _VendorData {
  final String name;
  final String location;
  final double rating;
  final int reviews;
  final int startingPrice;
  final bool isWishlisted;
  final String imagePath;

  const _VendorData({
    required this.name,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.startingPrice,
    required this.isWishlisted,
    required this.imagePath,
  });
}
