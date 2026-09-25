import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/service_categories.dart';
import '../../core/utils/app_animations.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../vendor_detail/vendor_detail_screen.dart';
import '../shell/main_shell.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/app_search_bar.dart';

class ServiceListingScreen extends StatefulWidget {
  final String category;

  const ServiceListingScreen({
    super.key,
    this.category = 'Photography & Videography',
  });

  @override
  State<ServiceListingScreen> createState() => _ServiceListingScreenState();
}

class _ServiceListingScreenState extends State<ServiceListingScreen>
    with SingleTickerProviderStateMixin {
  final int _navIndex = 1;
  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _listController;

  final List<String> _filters = ['All', 'Price: Low to High', 'Top Rated'];

  late String _currentCategory;
  late List<_VendorData> _vendors;

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.category;
    _vendors = _getCategoryVendors(_currentCategory);
    _searchFocusNode.addListener(() {
      setState(() {});
    });
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
    if (catLower == 'all' ||
        catLower == 'all categories' ||
        catLower == 'all vendors') {
      return _getAllVendors();
    }
    if (catLower.contains('decor') || catLower.contains('flora')) {
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
    } else if (catLower.contains('hotel') ||
        catLower.contains('banquet') ||
        catLower.contains('hall') ||
        catLower.contains('resort')) {
      return [
        _VendorData(
          name: 'Heritage Haveli Resort & Palace',
          location: 'Mohali, Punjab',
          rating: 4.9,
          reviews: 420,
          startingPrice: 250000,
          isWishlisted: true,
          imagePath: AppImages.weddingHero,
        ),
        _VendorData(
          name: 'The Grand Palace Resort & Convention',
          location: 'Chandigarh',
          rating: 4.8,
          reviews: 380,
          startingPrice: 350000,
          isWishlisted: false,
          imagePath: AppImages.vendorRoyalClick,
        ),
      ];
    } else if (catLower.contains('makeup') || catLower.contains('hair')) {
      return [
        _VendorData(
          name: 'Glamour Glow by Simran',
          location: 'Chandigarh',
          rating: 4.9,
          reviews: 215,
          startingPrice: 22000,
          isWishlisted: true,
          imagePath: AppImages.vendorMemories,
        ),
        _VendorData(
          name: 'Studio 99 Bridal Lounge',
          location: 'Mohali',
          rating: 4.8,
          reviews: 160,
          startingPrice: 18000,
          isWishlisted: false,
          imagePath: AppImages.vendorRoyalClick,
        ),
      ];
    } else if (catLower.contains('mehndi')) {
      return [
        _VendorData(
          name: 'Geetanjali Henna & Bridal Art',
          location: 'Chandigarh',
          rating: 4.9,
          reviews: 195,
          startingPrice: 7500,
          isWishlisted: true,
          imagePath: AppImages.vendorCandid,
        ),
        _VendorData(
          name: 'Royal Rajasthani Mehndi Studio',
          location: 'Amritsar',
          rating: 4.8,
          reviews: 145,
          startingPrice: 6000,
          isWishlisted: false,
          imagePath: AppImages.exploreDecoration,
        ),
      ];
    } else if (catLower.contains('dj') || catLower.contains('sound')) {
      return [
        _VendorData(
          name: 'DJ Sandy Beats & Sound System',
          location: 'Chandigarh',
          rating: 4.9,
          reviews: 280,
          startingPrice: 35000,
          isWishlisted: true,
          imagePath: AppImages.vendorLensArt,
        ),
        _VendorData(
          name: 'Bass & Dhol Live DJ Stage',
          location: 'Ludhiana',
          rating: 4.8,
          reviews: 175,
          startingPrice: 28000,
          isWishlisted: false,
          imagePath: AppImages.vendorShutter,
        ),
      ];
    } else if (catLower.contains('band') || catLower.contains('live')) {
      return [
        _VendorData(
          name: 'The Punjabi Virsa Live Symphony Band',
          location: 'Chandigarh',
          rating: 4.9,
          reviews: 140,
          startingPrice: 75000,
          isWishlisted: true,
          imagePath: AppImages.vendorRoyalClick,
        ),
        _VendorData(
          name: 'Soulful Sufi & Brass Ensemble',
          location: 'Patiala',
          rating: 4.8,
          reviews: 95,
          startingPrice: 55000,
          isWishlisted: false,
          imagePath: AppImages.vendorMemories,
        ),
      ];
    } else if (catLower.contains('dress') ||
        catLower.contains('bridal') ||
        catLower.contains('groom')) {
      return [
        _VendorData(
          name: 'Royal Libas Bridal Couture',
          location: 'Chandigarh',
          rating: 4.9,
          reviews: 340,
          startingPrice: 65000,
          isWishlisted: true,
          imagePath: AppImages.vendorCandid,
        ),
        _VendorData(
          name: 'Maharaja Sherwani & Royal Wear',
          location: 'Ludhiana',
          rating: 4.8,
          reviews: 210,
          startingPrice: 42000,
          isWishlisted: false,
          imagePath: AppImages.vendorLensArt,
        ),
      ];
    } else if (catLower.contains('jaggo')) {
      return [
        _VendorData(
          name: 'Desi Jaggo Dhol Troupe Punjab',
          location: 'Mohali',
          rating: 4.9,
          reviews: 185,
          startingPrice: 25000,
          isWishlisted: true,
          imagePath: AppImages.exploreDecoration,
        ),
        _VendorData(
          name: 'Jashan-E-Jaggo Traditional Troupe',
          location: 'Amritsar',
          rating: 4.8,
          reviews: 130,
          startingPrice: 22000,
          isWishlisted: false,
          imagePath: AppImages.vendorRoyalClick,
        ),
      ];
    } else if (catLower.contains('turban')) {
      return [
        _VendorData(
          name: 'Shahi Dastar & Turban Bandi',
          location: 'Amritsar',
          rating: 4.9,
          reviews: 310,
          startingPrice: 5000,
          isWishlisted: true,
          imagePath: AppImages.vendorMemories,
        ),
        _VendorData(
          name: 'Royal Pagri & Safa Stylists',
          location: 'Chandigarh',
          rating: 4.8,
          reviews: 190,
          startingPrice: 4500,
          isWishlisted: false,
          imagePath: AppImages.vendorShutter,
        ),
      ];
    } else if (catLower.contains('card') || catLower.contains('invit')) {
      return [
        _VendorData(
          name: 'Royal Scroll & Box Wedding Cards',
          location: 'Chandigarh',
          rating: 4.9,
          reviews: 230,
          startingPrice: 150,
          isWishlisted: true,
          imagePath: AppImages.vendorCandid,
        ),
        _VendorData(
          name: 'Kalyan Digital & Laser Invitations',
          location: 'Ludhiana',
          rating: 4.8,
          reviews: 175,
          startingPrice: 95,
          isWishlisted: false,
          imagePath: AppImages.exploreCatering,
        ),
      ];
    } else if (catLower.contains('jewel')) {
      return [
        _VendorData(
          name: 'Kalyan Heritage Bridal Jewellers',
          location: 'Chandigarh',
          rating: 4.9,
          reviews: 410,
          startingPrice: 150000,
          isWishlisted: true,
          imagePath: AppImages.vendorRoyalClick,
        ),
        _VendorData(
          name: 'Amritsari Kundan & Polki Jewellers',
          location: 'Amritsar',
          rating: 4.8,
          reviews: 285,
          startingPrice: 110000,
          isWishlisted: false,
          imagePath: AppImages.vendorLensArt,
        ),
      ];
    } else if (catLower.contains('tent')) {
      return [
        _VendorData(
          name: 'Grand Shehnai Tent & Shamiana',
          location: 'Mohali',
          rating: 4.9,
          reviews: 240,
          startingPrice: 120000,
          isWishlisted: true,
          imagePath: AppImages.weddingHero,
        ),
        _VendorData(
          name: 'Royal Canopy & Luxury Tents',
          location: 'Chandigarh',
          rating: 4.8,
          reviews: 160,
          startingPrice: 180000,
          isWishlisted: false,
          imagePath: AppImages.exploreDecoration,
        ),
      ];
    } else {
      // Default / Photography & Videography
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

  List<_VendorData> _getAllVendors() {
    return [
      // Photography & Videography
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
        name: 'LensArt Studio',
        location: 'Amritsar',
        rating: 4.8,
        reviews: 265,
        startingPrice: 32000,
        isWishlisted: false,
        imagePath: AppImages.vendorLensArt,
      ),
      // Decoration & Stage
      _VendorData(
        name: 'Grand Stage Crafters & AV Tech',
        location: 'Ludhiana',
        rating: 4.9,
        reviews: 190,
        startingPrice: 55000,
        isWishlisted: true,
        imagePath: AppImages.vendorCandid,
      ),
      _VendorData(
        name: 'Royal Mandap & Floral Decor',
        location: 'Chandigarh',
        rating: 4.9,
        reviews: 240,
        startingPrice: 45000,
        isWishlisted: false,
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
      // Catering & Food
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
      // DJ & Sound System
      _VendorData(
        name: 'DJ Sandy Beats & Sound System',
        location: 'Chandigarh',
        rating: 4.9,
        reviews: 280,
        startingPrice: 35000,
        isWishlisted: true,
        imagePath: AppImages.vendorLensArt,
      ),
      _VendorData(
        name: 'Bass & Dhol Live DJ Stage',
        location: 'Ludhiana',
        rating: 4.8,
        reviews: 175,
        startingPrice: 28000,
        isWishlisted: false,
        imagePath: AppImages.vendorShutter,
      ),
      // Venues & Banquets
      _VendorData(
        name: 'Heritage Haveli Resort & Palace',
        location: 'Mohali, Punjab',
        rating: 4.9,
        reviews: 420,
        startingPrice: 250000,
        isWishlisted: true,
        imagePath: AppImages.weddingHero,
      ),
      _VendorData(
        name: 'The Grand Palace Resort & Convention',
        location: 'Chandigarh',
        rating: 4.8,
        reviews: 380,
        startingPrice: 350000,
        isWishlisted: false,
        imagePath: AppImages.vendorRoyalClick,
      ),
      // Luxury Cars
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
      // Makeup & Hair
      _VendorData(
        name: 'Glamour Glow by Simran',
        location: 'Chandigarh',
        rating: 4.9,
        reviews: 215,
        startingPrice: 22000,
        isWishlisted: true,
        imagePath: AppImages.vendorMemories,
      ),
      _VendorData(
        name: 'Studio 99 Bridal Lounge',
        location: 'Mohali',
        rating: 4.8,
        reviews: 160,
        startingPrice: 18000,
        isWishlisted: false,
        imagePath: AppImages.vendorRoyalClick,
      ),
      // Mehndi Art
      _VendorData(
        name: 'Geetanjali Henna & Bridal Art',
        location: 'Chandigarh',
        rating: 4.9,
        reviews: 195,
        startingPrice: 7500,
        isWishlisted: true,
        imagePath: AppImages.vendorCandid,
      ),
      _VendorData(
        name: 'Royal Rajasthani Mehndi Studio',
        location: 'Amritsar',
        rating: 4.8,
        reviews: 145,
        startingPrice: 6000,
        isWishlisted: false,
        imagePath: AppImages.exploreDecoration,
      ),
      // Live Symphony & Bands
      _VendorData(
        name: 'The Punjabi Virsa Live Symphony Band',
        location: 'Chandigarh',
        rating: 4.9,
        reviews: 140,
        startingPrice: 75000,
        isWishlisted: true,
        imagePath: AppImages.vendorRoyalClick,
      ),
      _VendorData(
        name: 'Soulful Sufi & Brass Ensemble',
        location: 'Patiala',
        rating: 4.8,
        reviews: 95,
        startingPrice: 55000,
        isWishlisted: false,
        imagePath: AppImages.vendorMemories,
      ),
      // Bridal & Groom Wear
      _VendorData(
        name: 'Royal Libas Bridal Couture',
        location: 'Chandigarh',
        rating: 4.9,
        reviews: 340,
        startingPrice: 65000,
        isWishlisted: true,
        imagePath: AppImages.vendorCandid,
      ),
      _VendorData(
        name: 'Maharaja Sherwani & Royal Wear',
        location: 'Ludhiana',
        rating: 4.8,
        reviews: 210,
        startingPrice: 42000,
        isWishlisted: false,
        imagePath: AppImages.vendorLensArt,
      ),
      // Jewellery
      _VendorData(
        name: 'Kalyan Heritage Bridal Jewellers',
        location: 'Chandigarh',
        rating: 4.9,
        reviews: 410,
        startingPrice: 150000,
        isWishlisted: true,
        imagePath: AppImages.vendorRoyalClick,
      ),
      _VendorData(
        name: 'Amritsari Kundan & Polki Jewellers',
        location: 'Amritsar',
        rating: 4.8,
        reviews: 285,
        startingPrice: 110000,
        isWishlisted: false,
        imagePath: AppImages.vendorLensArt,
      ),
      // Tents & Shamiana
      _VendorData(
        name: 'Grand Shehnai Tent & Shamiana',
        location: 'Mohali',
        rating: 4.9,
        reviews: 240,
        startingPrice: 120000,
        isWishlisted: true,
        imagePath: AppImages.weddingHero,
      ),
      _VendorData(
        name: 'Royal Canopy & Luxury Tents',
        location: 'Chandigarh',
        rating: 4.8,
        reviews: 160,
        startingPrice: 180000,
        isWishlisted: false,
        imagePath: AppImages.exploreDecoration,
      ),
      // Dhol & Jaggo
      _VendorData(
        name: 'Desi Jaggo Dhol Troupe Punjab',
        location: 'Mohali',
        rating: 4.9,
        reviews: 185,
        startingPrice: 25000,
        isWishlisted: true,
        imagePath: AppImages.exploreDecoration,
      ),
      // Turban & Pagri
      _VendorData(
        name: 'Shahi Dastar & Turban Bandi',
        location: 'Amritsar',
        rating: 4.9,
        reviews: 310,
        startingPrice: 5000,
        isWishlisted: true,
        imagePath: AppImages.vendorMemories,
      ),
      // Invitations
      _VendorData(
        name: 'Royal Scroll & Box Wedding Cards',
        location: 'Chandigarh',
        rating: 4.9,
        reviews: 230,
        startingPrice: 150,
        isWishlisted: true,
        imagePath: AppImages.vendorCandid,
      ),
    ];
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _listController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    var displayedVendors = _vendors.where((v) {
      if (query.isEmpty) return true;
      return v.name.toLowerCase().contains(query) ||
          v.location.toLowerCase().contains(query);
    }).toList();

    // Apply quick filters
    if (_selectedFilter == 1) {
      // Price: low to high
      displayedVendors.sort((a, b) => a.startingPrice.compareTo(b.startingPrice));
    } else if (_selectedFilter == 2) {
      // Rating: high to low
      displayedVendors.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildCategoryFilterBar(),
          _buildFilterRow(),
          Expanded(
            child: displayedVendors.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBF4ED),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFE5D5C5)),
                            ),
                            child: const Icon(Icons.search_off_rounded,
                                size: 30, color: AppColors.primary),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No vendors match "$query"',
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _currentCategory.toLowerCase() == 'all'
                                ? 'Try searching for another vendor name or location'
                                : 'Try searching for another name or location in $_currentCategory',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.grey,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 8),
                            ),
                            child: const Text('Clear Search',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: displayedVendors.length,
                    itemBuilder: (context, i) {
                      return _buildVendorCard(displayedVendors[i]);
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

  Widget _buildCategoryFilterBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAF2E9),
        border: Border(
          bottom: BorderSide(color: Color(0xFFEADBCE), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: kServiceCategories.length + 1,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            if (i == 0) {
              final isSelected = _currentCategory.toLowerCase() == 'all';
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentCategory = 'All';
                    _vendors = _getCategoryVendors('All');
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          )
                        : null,
                    color: isSelected ? null : AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFFD4AF37).withValues(alpha: 0.45),
                      width: isSelected ? 1.4 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.grid_view_rounded,
                        size: 14,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'All',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF2A160F),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final cat = kServiceCategories[i - 1];
            final isSelected =
                _currentCategory.toLowerCase() == cat.title.toLowerCase();
            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentCategory = cat.title;
                  _vendors = _getCategoryVendors(cat.title);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [cat.color, cat.color.withValues(alpha: 0.85)],
                        )
                      : null,
                  color: isSelected ? null : cat.bgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? cat.color
                        : cat.color.withValues(alpha: 0.35),
                    width: isSelected ? 1.4 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: cat.color.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.icon,
                        size: 14,
                        color: isSelected ? Colors.white : cat.color),
                    const SizedBox(width: 5),
                    Text(
                      cat.title.split(' & ').first,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF2A160F),
                      ),
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

  Widget _buildHeader() {
    final isAll = _currentCategory.toLowerCase() == 'all';
    final activeCat = isAll
        ? const ServiceCategoryItem(
            id: 0,
            title: 'All Vendors',
            icon: Icons.grid_view_rounded,
            colorClass: 'cat-all',
            color: AppColors.primary,
            bgColor: Color(0xFFFBF4ED),
            desc: 'Browse all wedding, party, and event vendors.',
          )
        : kServiceCategories.firstWhere(
            (c) => c.title.toLowerCase() == _currentCategory.toLowerCase(),
            orElse: () => kServiceCategories.first,
          );

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
        border: const Border(
          bottom: BorderSide(color: Color(0xFFEADBCE), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF380C1D).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              // Top Navigation Row with Category Details Centered
              Row(
                children: [
                  // Back Button (Left)
                  AnimatedTapWidget(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF3EB),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFEADBCE)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 19,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  // Centered Category Name & Details
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: activeCat.bgColor,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: activeCat.color.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Icon(
                                activeCat.icon,
                                size: 13,
                                color: activeCat.color,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                isAll ? 'All Vendors' : _currentCategory,
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                  letterSpacing: 0.2,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_vendors.length} Verified Vendors',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Mirror spacer to balance back button and guarantee perfect horizontal centering
                  const SizedBox(width: 38),
                ],
              ),

              const SizedBox(height: 12),

              // Unified Luxury Search Bar with instant tap highlight & pristine rounded corners
              AppSearchBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                hintText: 'Search in ${_currentCategory.toLowerCase()}...',
                onChanged: (val) => setState(() {}),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
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
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? const LinearGradient(
                          colors: [Color(0xFF5E1B33), Color(0xFF380C1D)],
                        )
                      : null,
                  color: isActive ? null : const Color(0xFFF7EFE6),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primary
                        : const Color(0xFFE5D5C6),
                    width: 1.1,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFF380C1D).withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (i == 0)
                      Icon(Icons.tune_rounded,
                          size: 12,
                          color: isActive ? Colors.white : AppColors.primary)
                    else if (i == 1)
                      Icon(Icons.payments_rounded,
                          size: 12,
                          color: isActive ? Colors.white : const Color(0xFFD97706))
                    else
                      Icon(Icons.star_rounded,
                          size: 13,
                          color: isActive ? Colors.white : const Color(0xFFD97706)),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        color: isActive ? Colors.white : const Color(0xFF1A1A1A),
                        fontSize: 11.5,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w600,
                      ),
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD97706), Color(0xFFB45309)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, size: 12, color: Colors.white),
                          SizedBox(width: 3),
                          Text(
                            'Top Rated',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
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
                        vendor.startingPrice >= 1000
                            ? '₹${(vendor.startingPrice / 1000).toStringAsFixed(0)}K onwards'
                            : '₹${vendor.startingPrice} onwards',
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
