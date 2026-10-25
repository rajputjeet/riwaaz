import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/app_animations.dart';
import '../../core/services/wishlist_service.dart';
import '../../data/api_provider/vendor_api_provider.dart';
import '../../data/models/user_model.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../../core/services/booking_service.dart';
import '../../shared/widgets/cached_image_view.dart';
import '../../shared/widgets/portfolio_video_player.dart';
import '../../shared/widgets/vendor_image_view.dart';
import '../shell/main_shell.dart';
import '../../utils/utils.dart';

class VendorDetailScreen extends StatefulWidget {
  final String vendorName;
  final String location;
  final UserModel? vendorModel;
  final String? vendorId;

  const VendorDetailScreen({
    super.key,
    this.vendorName = 'Verified Vendor Partner',
    this.location = 'Punjab',
    this.vendorModel,
    this.vendorId,
  });

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen>
    with TickerProviderStateMixin {
  final VendorApiProvider _vendorApi = VendorApiProvider();
  late UserModel? _vendorModel;
  final int _navIndex = 1;
  int _selectedTab = 0; // 0=About, 1=Services, 2=Packages, 3=Portfolio
  int? _selectedPackageIndex;
  int? _selectedServiceIndex;
  late AnimationController _headerController;
  late ScrollController _scrollController;
  bool _isScrolled = false;

  final List<String> _tabs = ['About', 'Services', 'Packages', 'Portfolio'];

  int? _parseOfferingPrice(dynamic value) {
    if (value is num) return value.round();
    if (value is Map) {
      return _parseOfferingPrice(value['amount'] ?? value['price']);
    }
    final digits = value?.toString().replaceAll(RegExp(r'[^0-9-]'), '');
    return int.tryParse(digits ?? '');
  }

  List<_PackageData> get _activePackages {
    if (_vendorModel?.vendorProfile?.packages != null &&
        _vendorModel!.vendorProfile!.packages!.isNotEmpty) {
      final list = <_PackageData>[];
      for (final p in _vendorModel!.vendorProfile!.packages!) {
        if (p is Map) {
          final title =
              p['name']?.toString() ??
              p['title']?.toString() ??
              'Service Package';
          final price = _parseOfferingPrice(p['price'] ?? p['amount']) ?? 0;
          List<String> inclusions = [];
          if (p['features'] is List) {
            inclusions = (p['features'] as List)
                .map((e) => e.toString())
                .toList();
          } else if (p['services'] is List) {
            inclusions = (p['services'] as List)
                .map((e) => e.toString())
                .toList();
          } else if (p['description'] != null) {
            inclusions = [p['description'].toString()];
          }
          list.add(
            _PackageData(
              title,
              price,
              inclusions,
              list.isEmpty
                  ? AppColors.grey
                  : (list.length == 1 ? AppColors.primary : AppColors.gold),
            ),
          );
        }
      }
      if (list.isNotEmpty) return list;
    }

    return const [];
  }

  List<Map<String, dynamic>> get _activeServices {
    final services = _vendorModel?.vendorProfile?.services ?? const [];
    return services
        .map((service) {
          if (service is Map) return Map<String, dynamic>.from(service);
          if (service is String && service.trim().isNotEmpty) {
            return <String, dynamic>{'title': service.trim()};
          }
          return <String, dynamic>{};
        })
        .where((service) => service.isNotEmpty)
        .toList();
  }

  _PackageData? get _selectedBookingOffering {
    final packageIndex = _selectedPackageIndex;
    final packages = _activePackages;
    if (packageIndex != null && packageIndex < packages.length) {
      return packages[packageIndex];
    }

    final serviceIndex = _selectedServiceIndex;
    final services = _activeServices;
    if (serviceIndex == null || serviceIndex >= services.length) return null;

    final service = services[serviceIndex];
    final title = (service['title'] ?? service['name'] ?? '').toString().trim();
    final description = (service['description'] ?? '').toString().trim();
    final price =
        _parseOfferingPrice(
          service['startingPrice'] ?? service['price'] ?? service['amount'],
        ) ??
        0;
    return _PackageData(
      title,
      price,
      description.isEmpty ? const [] : [description],
      AppColors.primary,
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  String? get _maskedVendorPhone {
    final phone = _vendorModel?.mobile?.trim();
    if (phone == null || phone.isEmpty) return null;

    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return null;

    final countryCodeLength = digits.length > 10 ? digits.length - 10 : 0;
    final countryCode = countryCodeLength > 0
        ? '+${digits.substring(0, countryCodeLength)} '
        : '';
    final localNumber = countryCodeLength > 0
        ? digits.substring(countryCodeLength)
        : digits;
    final visibleDigits = (localNumber.length + 1) ~/ 2;
    final maskedDigits = List.filled(
      localNumber.length - visibleDigits,
      'X',
    ).join();

    return '$countryCode${localNumber.substring(0, visibleDigits)}$maskedDigits';
  }

  @override
  void initState() {
    super.initState();
    _vendorModel = widget.vendorModel;
    _fetchVendorDetail();
    WishlistService.instance.ensureLoaded();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
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

  Future<void> _fetchVendorDetail() async {
    final vendorId = widget.vendorId ?? _vendorModel?.id;
    if (vendorId == null || vendorId.isEmpty) return;

    final response = await _vendorApi.getVendorDetail(vendorId);
    if (!mounted || response.isSuccess != true || response.data == null) return;
    setState(() => _vendorModel = response.data);
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
    final bannerUrl = _vendorModel?.bannerImgUrl?.trim();

    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: _isScrolled ? AppColors.white : Colors.transparent,
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
        AnimatedBuilder(
          animation: WishlistService.instance,
          builder: (context, _) {
            final wishlist = WishlistService.instance;
            final vendorId = _vendorModel?.id ?? '';
            final isWishlisted = wishlist.isSaved(vendorId);
            return AnimatedTapWidget(
              onTap: vendorId.isEmpty || wishlist.isToggling(vendorId)
                  ? null
                  : () => wishlist.toggleVendor(vendorId, vendor: _vendorModel),
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
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey(isWishlisted),
                    color: isWishlisted ? AppColors.primary : AppColors.grey,
                    size: 20,
                  ),
                ),
              ),
            );
          },
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
            if (bannerUrl?.isNotEmpty == true)
              CachedImageView(
                imageUrl: bannerUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorWidget: const ColoredBox(color: AppColors.primaryDark),
              )
            else
              const VendorImagePlaceholder(showLabel: false),
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
    final maskedPhone = _maskedVendorPhone;
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedImageView(
                    imageUrl: _vendorModel?.profileImgUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.person_rounded,
                    iconColor: AppColors.white,
                    backgroundColor: AppColors.primary,
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
                      if (maskedPhone != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone_rounded,
                              color: AppColors.primary,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              maskedPhone,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.darkGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.location_on_rounded,
                              color: AppColors.grey,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              widget.location,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall,
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
    if (_selectedTab == 0) return _buildAbout();
    if (_selectedTab == 1) return _buildServices();
    if (_selectedTab == 2) return _buildPackages();
    return _buildPortfolio();
  }

  Widget _buildPackages() {
    final pkgs = _activePackages;
    if (pkgs.isEmpty) {
      return _buildEmptyProfileSection(
        icon: Icons.inventory_2_outlined,
        title: 'Packages coming soon',
        message: "This vendor hasn't added any packages yet. Please check back later.",
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: pkgs.asMap().entries.map((entry) {
          final i = entry.key;
          final pkg = entry.value;
          final isSelected =
              _selectedPackageIndex == i && _selectedServiceIndex == null;
          return FadeInWidget(
            delay: Duration(milliseconds: 100 * i),
            child: _buildPackageCard(
              pkg,
              isPopular: false,
              isSelected: isSelected,
              onSelect: () => setState(() {
                if (isSelected) {
                  _selectedPackageIndex = null;
                  _selectedServiceIndex = null;
                } else {
                  _selectedPackageIndex = i;
                  _selectedServiceIndex = null;
                }
              }),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildServices() {
    final services = _activeServices;
    if (services.isEmpty) {
      return _buildEmptyProfileSection(
        icon: Icons.auto_awesome_outlined,
        title: 'Services coming soon',
        message: "This vendor hasn't listed any services yet. Please check back later.",
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: services.asMap().entries.map((entry) {
          final index = entry.key;
          final service = entry.value;
          final title = (service['title'] ?? service['name'] ?? 'Service')
              .toString()
              .trim();
          final description = (service['description'] ?? '').toString().trim();
          final price = _parseOfferingPrice(
            service['startingPrice'] ?? service['price'] ?? service['amount'],
          );
          final isSelected =
              _selectedServiceIndex == index && _selectedPackageIndex == null;

          return AnimatedTapWidget(
            onTap: () => setState(() {
              if (isSelected) {
                _selectedServiceIndex = null;
                _selectedPackageIndex = null;
              } else {
                _selectedServiceIndex = index;
                _selectedPackageIndex = null;
              }
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFF9FA) : AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFFEADBCE),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title, style: AppTextStyles.headlineSmall),
                      ),
                      if (isSelected)
                        const Text(
                          'Selected',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: AppTextStyles.bodyMedium.copyWith(height: 1.45),
                    ),
                  ],
                  if (price != null && price > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Starting at ₹${_formatCurrency(price)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyProfileSection({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 25),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.darkGrey,
                height: 1.45,
              ),
            ),
          ],
        ),
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
                Expanded(
                  child: Text(
                    pkg.name,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontSize: 15.5,
                      color: isSelected
                          ? const Color(0xFF26050E)
                          : AppColors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isPopular)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
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
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Selected',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.zero,
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
                padding: const EdgeInsets.only(bottom: 6),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbout() {
    final profile = _vendorModel?.vendorProfile;
    final bio =
        (profile?.businessDescription ??
                _vendorModel?.about ??
                _vendorModel?.bio ??
                '')
            .trim();
    final details = <String>[
      if (profile?.businessAddress?.trim().isNotEmpty == true)
        profile!.businessAddress!.trim(),
      if ([
        profile?.city,
        profile?.state,
      ].where((value) => value != null && value.trim().isNotEmpty).isNotEmpty)
        [
          profile?.city,
          profile?.state,
        ].where((value) => value != null && value.trim().isNotEmpty).join(', '),
      if (profile?.yearsOfExperience?.trim().isNotEmpty == true)
        profile!.yearsOfExperience!.trim(),
      if (profile?.categoryName?.trim().isNotEmpty == true)
        profile!.categoryName!.trim(),
    ];

    if (bio.isEmpty && details.isEmpty) {
      return _buildEmptyProfileSection(
        icon: Icons.info_outline_rounded,
        title: 'About information coming soon',
        message: "This vendor hasn't added business details yet.",
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About ${widget.vendorName}',
            style: AppTextStyles.headlineSmall,
          ),
          if (bio.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(bio, style: AppTextStyles.bodyMedium.copyWith(height: 1.6)),
          ],
          if (details.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...details.map(
              (detail) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(detail, style: AppTextStyles.bodyMedium),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPortfolio() {
    final rawPortfolio = _vendorModel?.vendorProfile?.portfolio;
    final List<Map<String, String>> portfolioItems = [];

    if (rawPortfolio != null && rawPortfolio.isNotEmpty) {
      for (final item in rawPortfolio) {
        if (item is Map) {
          final url =
              item['url']?.toString() ?? item['fileUrl']?.toString() ?? '';
          final type =
              item['type']?.toString() ??
              (CachedImageView.isVideoUrl(url) ? 'video' : 'image');
          final title = item['title']?.toString() ?? '';
          if (url.isNotEmpty) {
            portfolioItems.add({'type': type, 'url': url, 'title': title});
          }
        } else if (item is String && item.isNotEmpty) {
          portfolioItems.add({
            'type': CachedImageView.isVideoUrl(item) ? 'video' : 'image',
            'url': item,
            'title': '',
          });
        }
      }
    }

    if (portfolioItems.isEmpty) {
      return _buildEmptyProfileSection(
        icon: Icons.photo_library_outlined,
        title: 'Portfolio coming soon',
        message: "This vendor hasn't shared any photos or videos yet.",
      );
    }

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
        itemCount: portfolioItems.length,
        itemBuilder: (_, i) {
          final item = portfolioItems[i];
          final url = item['url'] ?? '';
          final isVideo =
              item['type'] == 'video' || CachedImageView.isVideoUrl(url);
          final rawThumb = (item['thumbnail'] ?? item['thumbnailUrl'] ?? '')
              .toString();
          final thumbUrl = CachedImageView.isVideoUrl(rawThumb) ? '' : rawThumb;
          final title = item['title'] ?? '';

          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isVideo
                ? PortfolioVideoThumbnail(
                    videoUrl: url,
                    title: title,
                    thumbnailUrl: thumbUrl.isNotEmpty ? thumbUrl : null,
                  )
                : GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: const EdgeInsets.all(12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedImageView(
                            imageUrl: url,
                            fit: BoxFit.contain,
                            fallbackIcon: Icons.image_rounded,
                            iconColor: Colors.white54,
                            backgroundColor: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    child: CachedImageView(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.photo_rounded,
                      iconColor: Colors.white54,
                      iconSize: 32,
                      backgroundColor: AppColors.primaryDark,
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildBottomActionBar() {
    final selectedOffering = _selectedBookingOffering;
    if (selectedOffering == null) return const SizedBox.shrink();

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
          const Text(
            'Contact Details will unlock once your booking is accepted',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Contact Locked Indicator Button
              AnimatedTapWidget(
                onTap: () {
                  Utils.showInfo(
                    'Direct Call & WhatsApp details unlock once the vendor accepts your booking request.',
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
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 16,
                        color: AppColors.darkGrey,
                      ),
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
                  onTap: () => _showBookingSheet(selectedOffering),
                  child: Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
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
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedOffering.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.goldLight,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                '₹${_formatCurrency(selectedOffering.price)}',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  height: 1.15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Book Now',
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showBookingSheet(_PackageData pkg) async {
    final vendorId = _vendorModel?.id?.trim();
    if (vendorId == null || vendorId.isEmpty) {
      Utils.showError('This vendor cannot be booked right now.');
      return;
    }

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingRequestSheet(
        vendorId: vendorId,
        vendorName: widget.vendorName,
        vendorEmail: _vendorModel?.email,
        category: _vendorModel?.vendorProfile?.categoryName ?? 'Event Services',
        offering: pkg,
      ),
    );
    if (submitted == true && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MainShell(initialIndex: 3),
        ),
        (route) => false,
      );
    }
  }
}

class _PackageData {
  final String name;
  final int price;
  final List<String> features;
  final Color color;

  const _PackageData(this.name, this.price, this.features, this.color);
}

class _BookingRequestSheet extends StatefulWidget {
  final String vendorId;
  final String vendorName;
  final String? vendorEmail;
  final String category;
  final _PackageData offering;

  const _BookingRequestSheet({
    required this.vendorId,
    required this.vendorName,
    this.vendorEmail,
    required this.category,
    required this.offering,
  });

  @override
  State<_BookingRequestSheet> createState() => _BookingRequestSheetState();
}

class _BookingRequestSheetState extends State<_BookingRequestSheet> {
  final TextEditingController _locationController = TextEditingController();
  DateTime? _eventDate;
  TimeOfDay? _eventTime;
  int _step = 0;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? today,
      firstDate: today,
      lastDate: DateTime(today.year + 5),
      helpText: 'Select event date',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _eventDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _eventTime ?? const TimeOfDay(hour: 18, minute: 0),
      helpText: 'Select event time',
    );
    if (time != null) setState(() => _eventTime = time);
  }

  String _dateLabel(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String _apiDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  void _continueToConfirmation() {
    if (_eventDate == null || _eventTime == null) {
      setState(
        () => _errorMessage = 'Select the event date and time to continue.',
      );
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Enter the event location to continue.');
      return;
    }
    setState(() {
      _errorMessage = null;
      _step = 1;
    });
  }

  Future<void> _submitBooking() async {
    final date = _eventDate;
    final time = _eventTime;
    final location = _locationController.text.trim();
    if (date == null || time == null || location.isEmpty || _isSubmitting)
      return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    final response = await AppBookingService.instance.createBooking(
      vendorId: widget.vendorId,
      vendorName: widget.vendorName,
      vendorEmail: widget.vendorEmail,
      category: widget.category,
      serviceName: widget.offering.name,
      eventDate: _apiDate(date),
      eventTime: time.format(context),
      eventLocation: location,
      price: widget.offering.price,
      inclusions: widget.offering.features,
    );
    if (!mounted) return;
    if (response.isSuccess == true && response.data != null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _isSubmitting = false;
      _errorMessage = response.message ?? 'Unable to send booking request.';
    });
  }

  Widget _selectionTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.22)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 11, color: AppColors.grey),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          SizedBox(
            width: 74,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offering = widget.offering;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: FractionallySizedBox(
        heightFactor: 0.72,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                if (_step == 1) {
                                  setState(() => _step = 0);
                                } else {
                                  Navigator.of(context).pop(false);
                                }
                              },
                        icon: Icon(
                          _step == 1
                              ? Icons.arrow_back_rounded
                              : Icons.close_rounded,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              _step == 0 ? 'Event details' : 'Confirm booking',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.black,
                              ),
                            ),
                            Text(
                              'Step ${_step + 1} of 2',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: _step == 0
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.vendorName,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _selectionTile(
                              icon: Icons.calendar_month_rounded,
                              title: 'Event date',
                              value: _eventDate == null
                                  ? 'Choose a date'
                                  : _dateLabel(_eventDate!),
                              onTap: _pickDate,
                            ),
                            const SizedBox(height: 10),
                            _selectionTile(
                              icon: Icons.schedule_rounded,
                              title: 'Event time',
                              value:
                                  _eventTime?.format(context) ??
                                  'Choose a time',
                              onTap: _pickTime,
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Event location',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _locationController,
                              textCapitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.done,
                              minLines: 2,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'Enter venue name and address',
                                filled: true,
                                fillColor: AppColors.white,
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(bottom: 32),
                                  child: Icon(
                                    Icons.location_on_outlined,
                                    color: AppColors.primary,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.grey.withValues(
                                      alpha: 0.22,
                                    ),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.grey.withValues(
                                      alpha: 0.22,
                                    ),
                                  ),
                                ),
                              ),
                              onChanged: (_) {
                                if (_errorMessage != null)
                                  setState(() => _errorMessage = null);
                              },
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Review your request',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.gold.withValues(alpha: 0.28),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.inventory_2_rounded,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          offering.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.black,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '₹${AppBookingService.formatIndianCurrency(offering.price)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (offering.features.isNotEmpty) ...[
                                    const SizedBox(height: 7),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        offering.features.join(' • '),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.darkGrey,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const Divider(height: 22),
                                  _detailRow(
                                    Icons.storefront_outlined,
                                    'Vendor',
                                    widget.vendorName,
                                  ),
                                  _detailRow(
                                    Icons.calendar_month_rounded,
                                    'Date',
                                    _dateLabel(_eventDate!),
                                  ),
                                  _detailRow(
                                    Icons.schedule_rounded,
                                    'Time',
                                    _eventTime!.format(context),
                                  ),
                                  _detailRow(
                                    Icons.location_on_outlined,
                                    'Location',
                                    _locationController.text.trim(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF9FA),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Vendor contact details unlock after the vendor accepts your booking.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.darkGrey,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : (_step == 0
                              ? _continueToConfirmation
                              : _submitBooking),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _step == 0
                                ? 'Continue to confirm'
                                : 'Confirm booking request',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
