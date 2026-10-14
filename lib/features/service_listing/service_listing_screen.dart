import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/service_categories.dart';
import '../../core/utils/app_animations.dart';
import '../../data/api_provider/ad_api_provider.dart';
import '../../data/api_provider/vendor_api_provider.dart';
import '../../data/models/user_model.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../vendor_detail/vendor_detail_screen.dart';
import '../shell/main_shell.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/category_controller.dart';
import '../../shared/widgets/app_search_bar.dart';
import '../../shared/widgets/cached_image_view.dart';

class ServiceListingScreen extends StatefulWidget {
  final String category;

  const ServiceListingScreen({
    super.key,
    this.category = 'Photographers & Videographers',
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
  List<_VendorData> _vendors = [];
  bool _isLoading = true;
  String? _errorMessage;
  final VendorApiProvider _vendorApi = VendorApiProvider();

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.category;
    _fetchVendors();

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

  /// Fetches real vendors dynamically from live backend API:
  /// GET /api/ad/active-vendors (optionally filtered by ?categoryId=<ID>)
  Future<void> _fetchVendors() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      String? categoryId;
      final isAll = _currentCategory.toLowerCase() == 'all' ||
          _currentCategory.toLowerCase() == 'all categories' ||
          _currentCategory.toLowerCase() == 'all vendors';

      if (!isAll && Get.isRegistered<CategoryController>()) {
        final resolved =
            CategoryController.to.resolveCategoryId(_currentCategory);
        if (resolved.isNotEmpty &&
            RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(resolved)) {
          categoryId = resolved;
        }
      }

      final res =
          await _vendorApi.getVendorsList(categoryId: categoryId);

      if (!mounted) return;

      if (res.isSuccess == true && res.data != null) {
        var list =
            res.data!.map((u) => _VendorData.fromUserModel(u)).toList();

        // If a specific category was selected and server returned vendors,
        // also apply category-match filtering locally if needed
        if (!isAll && list.isNotEmpty) {
          final lowerCat = _currentCategory.toLowerCase();
          final filtered = list.where((v) {
            final matchesCat = v.category != null &&
                (v.category!.toLowerCase().contains(lowerCat) ||
                    lowerCat.contains(v.category!.toLowerCase()));
            final matchesProfile = v.userModel?.vendorProfile?.services?.any(
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
          _errorMessage = res.message ?? res.error;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _vendors = [];
        _errorMessage = e.toString();
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
                              horizontal: 16, vertical: 8),
                          itemCount: displayedVendors.length,
                          itemBuilder: (context, i) {
                            return _buildVendorCard(displayedVendors[i]);
                          },
                        ),
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
                          horizontal: 22, vertical: 10),
                    ),
                    child: const Text(
                      'Clear Search',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
              border: Border.all(
                color: const Color(0xFFEADBCE),
                width: 1.2,
              ),
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
                            horizontal: 20, vertical: 10),
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
                              horizontal: 18, vertical: 10),
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
        border: Border(
          bottom: BorderSide(color: Color(0xFFEADBCE), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: SizedBox(
        height: 48,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          )
                        : null,
                    color: isSelected ? null : AppColors.white,
                    borderRadius: BorderRadius.circular(22),
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
                        size: 20,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'All',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.darkGrey,
                        ),
                      ),
                    ],
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        )
                      : null,
                  color: isSelected ? null : AppColors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.grey.withValues(alpha: 0.3),
                    width: isSelected ? 1.5 : 1,
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
                    cat.hasServerIcon
                        ? CachedImageView(
                            imageUrl: cat.iconUrl,
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,
                            fallbackIcon: cat.icon,
                            iconColor: isSelected ? Colors.white : AppColors.primary,
                          )
                        : Icon(cat.icon,
                            size: 26,
                            color: isSelected ? Colors.white : AppColors.primary),
                    const SizedBox(width: 7),
                    Text(
                      cat.title.split(' & ').first,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppColors.darkGrey,
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
    final categories = Get.isRegistered<CategoryController>()
        ? CategoryController.to.serviceCategories
        : <ServiceCategoryItem>[];

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
        : (categories.firstWhereOrNull(
                (c) => c.title.toLowerCase() == _currentCategory.toLowerCase()) ??
            ServiceCategoryItem(
              id: 0,
              title: _currentCategory,
              icon: Icons.storefront_rounded,
              colorClass: 'cat-custom',
              color: AppColors.primary,
              bgColor: const Color(0xFFFBF4ED),
              desc: 'Vendors in $_currentCategory',
            ));

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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: activeCat.bgColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: activeCat.color.withValues(alpha: 0.35),
                                ),
                              ),
                              child: activeCat.hasServerIcon
                                  ? Center(
                                      child: CachedImageView(
                                        imageUrl: activeCat.iconUrl,
                                        width: 22,
                                        height: 22,
                                        fit: BoxFit.contain,
                                        fallbackIcon: activeCat.icon,
                                        iconColor: activeCat.color,
                                      ),
                                    )
                                  : Icon(
                                      activeCat.icon,
                                      size: 22,
                                      color: activeCat.color,
                                    ),
                            ),
                            const SizedBox(width: 8),
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

  Widget _buildFilterRow() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
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
                  gradient: isActive ? AppColors.primaryGradient : null,
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
                            color: AppColors.primary.withValues(alpha: 0.25),
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
              category: vendor.category,
              imageUrl: vendor.imagePath,
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
                        CachedImageView(
                          imageUrl: vendor.imagePath,
                          fit: BoxFit.cover,
                          fallbackIcon: Icons.camera_alt_rounded,
                          iconColor: Colors.white54,
                          iconSize: 40,
                          backgroundColor: AppColors.primaryDark,
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
                // Badge (Sponsored / Featured or Top Rated)
                if (vendor.userModel?.isFeatured == true ||
                    (vendor.userModel?.vendorProfile?.isAdActive == true) ||
                    (vendor.userModel?.adBadge != null &&
                        vendor.userModel!.adBadge!.isNotEmpty))
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.workspace_premium_rounded,
                              size: 12, color: Colors.white),
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
                  )
                else if (vendor.isWishlisted || vendor.rating >= 4.8)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
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
                          const Icon(Icons.star_rounded,
                              size: 12, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            vendor.rating >= 4.8 ? 'Top Rated' : 'Verified Partner',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
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
                        vendor.startingPrice > 0
                            ? (vendor.startingPrice >= 1000
                                ? '₹${(vendor.startingPrice / 1000).toStringAsFixed(0)}K onwards'
                                : '₹${vendor.startingPrice} onwards')
                            : 'Starting price on request',
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
  final String id;
  final String name;
  final String location;
  final double rating;
  final int reviews;
  final int startingPrice;
  final bool isWishlisted;
  final String imagePath;
  final String? category;
  final UserModel? userModel;

  const _VendorData({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.startingPrice,
    required this.isWishlisted,
    required this.imagePath,
    this.category,
    this.userModel,
  });

  factory _VendorData.fromUserModel(UserModel user) {
    final profile = user.vendorProfile;
    final bName = (profile?.businessName != null &&
            profile!.businessName!.trim().isNotEmpty)
        ? profile.businessName!.trim()
        : (user.fullName != null && user.fullName!.trim().isNotEmpty
            ? user.fullName!.trim()
            : 'Wedding Vendor Partner');

    final loc = (profile?.city != null && profile!.city!.trim().isNotEmpty)
        ? profile.city!.trim()
        : 'Punjab';

    int price = 0;
    if (profile?.packages != null && profile!.packages!.isNotEmpty) {
      final firstPkg = profile.packages!.first;
      if (firstPkg is Map && firstPkg['price'] != null) {
        price = int.tryParse(firstPkg['price'].toString()) ?? 0;
      }
    }

    String img = '';
    if (user.profileImgUrl != null && user.profileImgUrl!.trim().isNotEmpty) {
      img = user.profileImgUrl!.trim();
    } else if (profile?.portfolio != null && profile!.portfolio!.isNotEmpty) {
      img = profile.portfolio!.first.toString();
    } else {
      img = AppImages.vendorRoyalClick;
    }

    final categoryStr =
        (profile?.services != null && profile!.services!.isNotEmpty)
            ? profile!.services!.join(', ')
            : (profile?.adTitle ?? '');

    return _VendorData(
      id: user.id ?? '',
      name: bName,
      location: loc,
      rating: 4.9,
      reviews: 120,
      startingPrice: price,
      isWishlisted: false,
      imagePath: img,
      category: categoryStr,
      userModel: user,
    );
  }
}
