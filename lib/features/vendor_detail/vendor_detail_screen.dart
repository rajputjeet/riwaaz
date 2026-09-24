import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/app_animations.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
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
  bool _isWishlisted = false;
  late AnimationController _headerController;
  late ScrollController _scrollController;
  bool _isScrolled = false;

  final List<String> _tabs = ['About', 'Packages', 'Portfolio', 'Reviews'];

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
    final packages = [
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: packages.asMap().entries.map((entry) {
          final i = entry.key;
          final pkg = entry.value;
          return FadeInWidget(
            delay: Duration(milliseconds: 100 * i),
            child: _buildPackageCard(pkg, i == 1),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPackageCard(_PackageData pkg, bool isPopular) {
    return AnimatedTapWidget(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: isPopular
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 2)
              : Border.all(color: const Color(0xFFEEE8DF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  pkg.name,
                  style: AppTextStyles.headlineSmall.copyWith(fontSize: 15),
                ),
                if (isPopular) ...[
                  const Spacer(),
                  Container(
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
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '₹${pkg.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
              style: TextStyle(
                color: pkg.color == AppColors.gold
                    ? AppColors.goldDark
                    : AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            ...pkg.features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: isPopular ? AppColors.primary : AppColors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      f,
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                    ),
                  ],
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
      child: Row(
        children: [
          // Chat
          _buildActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat',
            color: AppColors.darkGrey,
            bgColor: AppColors.lightGrey,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          // Call
          _buildActionButton(
            icon: Icons.phone_rounded,
            label: 'Call',
            color: AppColors.success,
            bgColor: AppColors.successLight,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          // Book Now
          Expanded(
            flex: 2,
            child: AnimatedTapWidget(
              onTap: () => _showBookingSheet(),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Book Now',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return AnimatedTapWidget(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingSheet() {
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
            Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Standard Package — ₹40,000',
                  style: AppTextStyles.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 20),
            AnimatedTapWidget(
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Booking request sent! 🎉'),
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
                    'Confirm Booking',
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

  _PackageData(this.name, this.price, this.features, this.color);
}
