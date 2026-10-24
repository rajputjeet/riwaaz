import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/service_categories.dart';
import '../../core/utils/app_animations.dart';
import '../../core/services/wishlist_service.dart';
import '../../data/api_provider/vendor_api_provider.dart';
import '../../data/models/user_model.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../vendor_detail/vendor_detail_screen.dart';
import '../shell/main_shell.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/category_controller.dart';
import '../../shared/widgets/app_search_bar.dart';
import '../../shared/widgets/vendor_image_view.dart';

class ServiceListingScreen extends StatefulWidget {
  final String category;
  final bool showBottomNav;

  const ServiceListingScreen({
    super.key,
    this.category = 'All',
    this.showBottomNav = false,
  });

  @override
  State<ServiceListingScreen> createState() => _ServiceListingScreenState();
}

class _ServiceListingScreenState extends State<ServiceListingScreen>
    with SingleTickerProviderStateMixin {
  final int _navIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _listController;

  late String _currentCategory;
  List<_VendorData> _vendors = [];
  bool _isLoading = true;
  final VendorApiProvider _vendorApi = VendorApiProvider();

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.category;
    _fetchVendors();
    WishlistService.instance.ensureLoaded();

    _searchFocusNode.addListener(() {
      setState(() {});
    });
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  /// Fetches real vendors dynamically from live backend API:
  /// GET /api/ad/active-vendors (optionally filtered by ?categoryId=[ID])
  Future<void> _fetchVendors() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      String? categoryId;
      final isAll =
          _currentCategory.toLowerCase() == 'all' ||
          _currentCategory.toLowerCase() == 'all categories' ||
          _currentCategory.toLowerCase() == 'all vendors';

      if (!isAll && Get.isRegistered<CategoryController>()) {
        final resolved = CategoryController.to.resolveCategoryId(
          _currentCategory,
        );
        if (resolved.isNotEmpty &&
            RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(resolved)) {
          categoryId = resolved;
        }
      }

      final res = await _vendorApi.getVendorsList(categoryId: categoryId);

      if (!mounted) return;

      if (res.isSuccess == true && res.data != null) {
        var list = res.data!.map((u) => _VendorData.fromUserModel(u)).toList();

        // If a specific category was selected and server returned vendors,
        // also apply category-match filtering locally if needed
        if (!isAll && list.isNotEmpty) {
          final lowerCat = _currentCategory.toLowerCase();
          final filtered = list.where((v) {
            final matchesCat =
                v.category != null &&
                (v.category!.toLowerCase().contains(lowerCat) ||
                    lowerCat.contains(v.category!.toLowerCase()));
            final matchesProfile =
                v.userModel?.vendorProfile?.services?.any(
                  (s) =>
                      s.toLowerCase().contains(lowerCat) ||
                      lowerCat.contains(s.toLowerCase()),
                ) ??
                false;
            return matchesCat || matchesProfile;
          }).toList();
          if (filtered.isNotEmpty) {
            list = filtered;
          }
        }

        setState(() {
          _isLoading = false;
          _vendors = list;
        });
      } else {
        setState(() {
          _isLoading = false;
          _vendors = [];
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _vendors = [];
      });
    }
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildCategoryFilterBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchVendors,
              color: AppColors.primary,
              backgroundColor: AppColors.white,
              child: _isLoading
                  ? _buildVendorsLoadingSkeleton()
                  : displayedVendors.isEmpty
                  ? _buildEmptyState(query)
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: displayedVendors.length,
                      itemBuilder: (context, i) {
                        return _buildVendorCard(displayedVendors[i]);
                      },
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.showBottomNav
          ? AppBottomNav(
              currentIndex: _navIndex,
              onTap: (i) {
                if (i == 1) {
                  Navigator.pop(context);
                } else {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => MainShell(initialIndex: i),
                    ),
                    (route) => false,
                  );
                }
              },
            )
          : null,
    );
  }

  Widget _buildEmptyState(String query) {
    if (query.isNotEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.12),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF4ED),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE5D5C5)),
                    ),
                    child: const Icon(
                      Icons.search_off_rounded,
                      size: 34,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No vendors match "$query"',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentCategory.toLowerCase() == 'all'
                        ? 'Try searching for another vendor name or location'
                        : 'Try searching for another name or location in $_currentCategory',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 18),
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
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      'Clear Search',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final isAll = _currentCategory.toLowerCase() == 'all';

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEADBCE), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF2E9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFEADBCE),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.storefront_outlined,
                    size: 34,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Verified Vendors Yet',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF26050E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isAll
                      ? 'No active vendors are currently available. As new vendors join and activate their profiles, they will appear here.'
                      : 'There are currently no verified vendors registered in "$_currentCategory". Check back soon as new vendors get onboarded!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.darkGrey,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _fetchVendors,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text(
                        'Refresh',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                    if (!isAll)
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentCategory = 'All';
                          });
                          _fetchVendors();
                        },
                        icon: const Icon(Icons.grid_view_rounded, size: 16),
                        label: const Text(
                          'Browse All Categories',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVendorsLoadingSkeleton() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.grey.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.greyLight.withValues(alpha: 0.45),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 140,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.greyLight.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 50,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.greyLight.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 90,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.greyLight.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 80,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.greyLight.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryFilterBar() {
    final categories = Get.isRegistered<CategoryController>()
        ? CategoryController.to.serviceCategories
        : <ServiceCategoryItem>[];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAF2E9),
        border: Border(bottom: BorderSide(color: Color(0xFFEADBCE), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: categories.length + 1,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            if (i == 0) {
              final isSelected = _currentCategory.toLowerCase() == 'all';
              return GestureDetector(
                onTap: () {
                  if (_currentCategory.toLowerCase() != 'all') {
                    setState(() {
                      _currentCategory = 'All';
                    });
                    _fetchVendors();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFFEADBCE),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'All',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFF555555),
                      ),
                    ),
                  ),
                ),
              );
            }

            final cat = categories[i - 1];
            final isSelected =
                _currentCategory.toLowerCase() == cat.title.toLowerCase();
            return GestureDetector(
              onTap: () {
                if (_currentCategory.toLowerCase() != cat.title.toLowerCase()) {
                  setState(() {
                    _currentCategory = cat.title;
                  });
                  _fetchVendors();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFEADBCE),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    cat.title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFF555555),
                    ),
                  ),
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

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFFFFFDFC), Color(0xFFFAF2E9)],
        ),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFEADBCE), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
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
                        Text(
                          isAll ? 'All Vendors' : _currentCategory,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isLoading
                              ? 'Loading Vendors...'
                              : '${_vendors.length} Verified Vendors',
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
                  // Mirror spacer to balance back button
                  const SizedBox(width: 38),
                ],
              ),

              const SizedBox(height: 12),

              // Unified Search Bar
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

  Widget _buildVendorCard(_VendorData vendor) {
    return AnimatedTapWidget(
      onTap: () {
        Navigator.of(context).push(
          SlidePageRoute(
            page: VendorDetailScreen(
              vendorName: vendor.name,
              location: vendor.location,
              vendorModel: vendor.userModel,
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
                        VendorImageView(
                          imageUrl: vendor.imagePath,
                          fit: BoxFit.cover,
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
                  child: AnimatedBuilder(
                    animation: WishlistService.instance,
                    builder: (context, _) {
                      final wishlist = WishlistService.instance;
                      final isSaved = wishlist.isSaved(vendor.id);
                      return AnimatedTapWidget(
                        onTap:
                            vendor.id.isEmpty || wishlist.isToggling(vendor.id)
                            ? null
                            : () => wishlist.toggleVendor(
                                vendor.id,
                                vendor: vendor.userModel,
                              ),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSaved ? Icons.favorite : Icons.favorite_border,
                            color: isSaved ? AppColors.primary : AppColors.grey,
                            size: 16,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Sponsored badge
                if (vendor.userModel?.isFeatured == true ||
                    (vendor.userModel?.vendorProfile?.isAdActive == true) ||
                    (vendor.userModel?.adBadge != null &&
                        vendor.userModel!.adBadge!.isNotEmpty))
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.workspace_premium_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            vendor.userModel?.adBadge != null &&
                                    vendor.userModel!.adBadge!.isNotEmpty
                                ? vendor.userModel!.adBadge!
                                : 'SPONSORED',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (vendor.experience.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 135),
                          child: Text(
                            '${vendor.experience} experience',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (vendor.location.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            vendor.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
  final String id;
  final String name;
  final String location;
  final String experience;
  final String imagePath;
  final String? category;
  final UserModel? userModel;

  const _VendorData({
    required this.id,
    required this.name,
    required this.location,
    required this.experience,
    required this.imagePath,
    this.category,
    this.userModel,
  });

  factory _VendorData.fromUserModel(UserModel user) {
    final profile = user.vendorProfile;
    final bName =
        (profile?.businessName != null &&
            profile!.businessName!.trim().isNotEmpty)
        ? profile.businessName!.trim()
        : (user.fullName != null && user.fullName!.trim().isNotEmpty
              ? user.fullName!.trim()
              : 'Wedding Vendor Partner');

    final loc =
        [
              profile?.businessAddress,
              user.address,
              profile?.city ?? user.city,
              profile?.state ?? user.state,
            ]
            .map((part) => part?.trim() ?? '')
            .where((part) => part.isNotEmpty)
            .toSet()
            .join(', ');
    final rawExperience = profile?.yearsOfExperience?.trim() ?? '';
    final experience = RegExp(r'^\d+(\.\d+)?$').hasMatch(rawExperience)
        ? '$rawExperience years'
        : rawExperience;

    final img = user.vendorCardImageUrl ?? '';

    final services = profile?.services;
    final categoryStr = (services != null && services.isNotEmpty)
        ? services.join(', ')
        : (profile?.adTitle ?? '');

    return _VendorData(
      id: user.id ?? '',
      name: bName,
      location: loc,
      experience: experience,
      imagePath: img,
      category: categoryStr,
      userModel: user,
    );
  }
}
