import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/app_animations.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../../core/services/booking_service.dart';
import '../shell/main_shell.dart';

class VendorDetailScreen extends StatefulWidget {
  final String vendorName;
  final String location;
  final double rating;
  final int reviews;
  final int startingPrice;

  const VendorDetailScreen({
    super.key,
    this.vendorName = 'Royal Click Studio',
    this.location = 'Chandigarh',
    this.rating = 4.9,
    this.reviews = 320,
    this.startingPrice = 35000,
  });

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen>
    with TickerProviderStateMixin {
  final int _navIndex = 1;
  int _selectedTab = 1; // 0=About, 1=Packages, 2=Portfolio, 3=Reviews
  int _selectedPackageIndex = 1; // Default to Standard (popular)
  bool _isWishlisted = false;
  late AnimationController _headerController;
  late ScrollController _scrollController;
  bool _isScrolled = false;

  final List<String> _tabs = ['About', 'Packages', 'Portfolio', 'Reviews'];

  static const List<_PackageData> _vendorPackages = [
    _PackageData(
      'Basic Package',
      25000,
      [
        '1 Photographer',
        '5 Edited Photos',
        '1 Album',
      ],
      AppColors.grey,
    ),
    _PackageData(
      'Standard Package',
      40000,
      [
        '2 Photographers',
        'Candid + Album',
        'Cinematic Video',
      ],
      AppColors.primary,
    ),
    _PackageData(
      'Premium Package',
      70000,
      [
        'Pre-Wedding + Drone',
        'Cinematic Video',
        'Album + 2 Photographers',
      ],
      AppColors.gold,
    ),
  ];

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final scrolled = _scrollController.offset > 200;
      if (scrolled != _isScrolled) {
        setState(() => _isScrolled = scrolled);
      }
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildVendorInfo(),
                    _buildTabBar(),
                    _buildTabContent(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),

          // Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomActionBar(),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: (i) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => MainShell(initialIndex: i)),
            (route) => false,
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor:
          _isScrolled ? AppColors.white : Colors.transparent,
      leading: AnimatedTapWidget(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.darkGrey,
            size: 20,
          ),
        ),
      ),
      actions: [
        AnimatedTapWidget(
          onTap: () => setState(() => _isWishlisted = !_isWishlisted),
          child: Container(
            margin: const EdgeInsets.all(8),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _isWishlisted ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(_isWishlisted),
                color: _isWishlisted ? AppColors.primary : AppColors.grey,
                size: 20,
              ),
            ),
          ),
        ),
        AnimatedTapWidget(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.share_rounded,
              color: AppColors.grey,
              size: 20,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero image — real photo
            Image.asset(
              AppImages.vendorDetailHero,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF6B0F1E),
                      Color(0xFF8B1A2E),
                      Color(0xFF5C0F1E),
                    ],
                  ),
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Colors.white38, size: 60),
              ),
            ),
            // Dark gradient overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.background,
                      AppColors.background.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorInfo() {
    return FadeInWidget(
      child: Container(
        color: AppColors.background,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'RC',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.vendorName,
                        style: AppTextStyles.headlineLarge.copyWith(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.gold, size: 16),
                          const SizedBox(width: 3),
                          Text(
                            '${widget.rating} (${widget.reviews} Reviews)',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              color: AppColors.grey, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            widget.location,
                            style: AppTextStyles.bodySmall,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '250+ Completed',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return FadeInWidget(
      delay: const Duration(milliseconds: 100),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: _tabs.asMap().entries.map((entry) {
            final i = entry.key;
            final tab = entry.value;
            final isActive = _selectedTab == i;
            return Expanded(
              child: AnimatedTapWidget(
                onTap: () => setState(() => _selectedTab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    tab,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isActive ? AppColors.primary : AppColors.grey,
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_selectedTab == 1) return _buildPackages();
    if (_selectedTab == 0) return _buildAbout();
    if (_selectedTab == 2) return _buildPortfolio();
    return _buildReviews();
  }

  Widget _buildPackages() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _vendorPackages.asMap().entries.map((entry) {
          final i = entry.key;
          final pkg = entry.value;
          final isSelected = _selectedPackageIndex == i;
          return FadeInWidget(
            delay: Duration(milliseconds: 100 * i),
            child: _buildPackageCard(
              pkg,
              isPopular: i == 1,
              isSelected: isSelected,
              onSelect: () => setState(() => _selectedPackageIndex = i),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPackageCard(
    _PackageData pkg, {
    required bool isPopular,
    required bool isSelected,
    required VoidCallback onSelect,
  }) {
    return AnimatedTapWidget(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF9FA) : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isPopular
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : const Color(0xFFEEE8DF)),
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.14)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: isSelected ? 14 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Radio indicator
                Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFFD6CBC3),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14)
                      : null,
                ),
                Text(
                  pkg.name,
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontSize: 15.5,
                    color: isSelected ? const Color(0xFF26050E) : AppColors.black,
                  ),
                ),
                const Spacer(),
                if (isPopular)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Popular',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.done_all_rounded,
                            color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Selected',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                '₹${_formatCurrency(pkg.price)}',
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : (pkg.color == AppColors.gold
                          ? AppColors.goldDark
                          : AppColors.primary),
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ...pkg.features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 32),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: isSelected
                          ? AppColors.primary
                          : (isPopular ? AppColors.primary : AppColors.grey),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        f,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13,
                          color: isSelected
                              ? const Color(0xFF2E2620)
                              : AppColors.darkGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Select button pill
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : const Color(0xFFF7F3EE),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFE2D7CC),
                  ),
                ),
                child: Text(
                  isSelected ? '✓ Selected Plan' : 'Select Plan',
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.darkGrey,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About ${widget.vendorName}', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Royal Click Studio is a premium wedding photography and videography service based in Chandigarh. With over 250 successful weddings, we specialise in capturing every precious moment of your special day with artistic excellence.',
            style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolio() {
    final portfolioImages = [
      AppImages.vendorRoyalClick,
      AppImages.vendorMemories,
      AppImages.vendorShutter,
      AppImages.vendorCandid,
      AppImages.vendorLensArt,
      AppImages.weddingHero,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        itemCount: portfolioImages.length,
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            portfolioImages[i],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.primaryDark,
              child: const Icon(Icons.photo_rounded,
                  color: Colors.white54, size: 32),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildReviews() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildReviewCard(
            'Priya Sharma',
            5.0,
            'Absolutely stunning work! Royal Click captured every emotion perfectly. Highly recommend!',
          ),
          _buildReviewCard(
            'Rahul Mehta',
            4.5,
            'Professional team, great quality photos. Delivered on time. Would book again!',
          ),
          _buildReviewCard(
            'Anjali Kapoor',
            5.0,
            'Best wedding photographer in Chandigarh! The candid shots are breathtaking.',
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String name, double rating, String review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(name, style: AppTextStyles.labelLarge),
              const Spacer(),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < rating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: AppColors.gold,
                    size: 14,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review, style: AppTextStyles.bodyMedium.copyWith(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    final selectedPkg = _vendorPackages[_selectedPackageIndex];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Contact Locked Indicator Button
              AnimatedTapWidget(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Direct Call & WhatsApp details unlock once the vendor accepts your booking request.',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.offWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.lock_outline_rounded,
                          size: 16, color: AppColors.darkGrey),
                      SizedBox(width: 6),
                      Text(
                        'Contact\nLocked',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGrey,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Selected Package + Book Button
              Expanded(
                child: AnimatedTapWidget(
                  onTap: () => _showBookingSheet(selectedPkg),
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedPkg.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.goldLight,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                '₹${_formatCurrency(selectedPkg.price)}',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Row(
                          children: [
                            Text(
                              'Book Now',
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Direct Call & WhatsApp contact details will unlock once the vendor accepts your booking',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingSheet(_PackageData pkg) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Confirm Booking', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(
              widget.vendorName,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${pkg.name} — ₹${_formatCurrency(pkg.price)}',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pkg.features.join(' • '),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.grey,
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
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.handshake_rounded,
                      color: AppColors.success, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pay In Person Directly to Vendor',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF166534),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'No online advance or app payment. You settle the package price directly with ${widget.vendorName} in person.',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF15803D),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F6F0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lock_clock_rounded,
                      color: AppColors.goldDark, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Direct Call & WhatsApp Contact Info',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Once ${widget.vendorName} accepts your booking request, their verified phone number will be unlocked for direct Call and WhatsApp coordination.',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.darkGrey,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AnimatedTapWidget(
              onTap: () {
                AppBookingService.instance.createBooking(
                  vendorName: widget.vendorName,
                  category: 'Event Services',
                  package: '${pkg.name} (₹${_formatCurrency(pkg.price)})',
                  total: '₹${_formatCurrency(pkg.price)}',
                  price: pkg.price,
                  clientName: 'Simran & Rahul 💍',
                  clientPhone: '+91 98765 11223',
                  vendorPhone: '+91 98765 43210',
                  date: '28 Dec 2026',
                  time: 'Full Day Event',
                  venue: 'The Oberoi Sukhvilas, New Chandigarh',
                  eventName: 'Grand Royal Vivah',
                  eventType: 'Wedding',
                  eventIcon: Icons.favorite_rounded,
                  eventColor: AppColors.primary,
                  inclusions: pkg.features,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Booking request sent! Direct Call & WhatsApp will unlock once accepted by ${widget.vendorName}. 🎉'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'Confirm Booking (Pay In Person)',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
          ],
        ),
      ),
    );
  }
}

class _PackageData {
  final String name;
  final int price;
  final List<String> features;
  final Color color;

  const _PackageData(this.name, this.price, this.features, this.color);
}
