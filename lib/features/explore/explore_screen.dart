import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/app_animations.dart';
import '../../core/services/notification_service.dart';
import '../service_listing/service_listing_screen.dart';
import '../shell/main_shell.dart';
import '../notifications/customer_notifications_screen.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/category_controller.dart';
import '../../core/constants/service_categories.dart';
import '../../shared/widgets/service_categories_bar.dart';
import '../../shared/widgets/app_states.dart';
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
            child: RefreshIndicator(
              onRefresh: () async {
                if (Get.isRegistered<CategoryController>()) {
                  await CategoryController.to.fetchCategories(
                    forceRefresh: true,
                  );
                }
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
                    const SizedBox(height: 12),
                    FadeInWidget(
                      delay: const Duration(milliseconds: 150),
                      child: _buildServiceGrid(),
                    ),
                    const SizedBox(height: 14),
                    FadeInWidget(
                      delay: const Duration(milliseconds: 300),
                      child: _buildNeedMoreServicesSection(),
                    ),
                    const SizedBox(height: 28),
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
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
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
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF6B1426),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // Notification Button with active ping
                AnimatedTapWidget(
                  onTap: () {
                    Navigator.of(context).push(
                      FadeScaleRoute(page: const CustomerNotificationsScreen()),
                    );
                  },
                  child: AnimatedBuilder(
                    animation: NotificationService.instance,
                    builder: (context, _) {
                      final unread = NotificationService.instance.unreadCount;
                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 10,
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
                            if (unread > 0)
                              Positioned(
                                top: 5,
                                right: 3,
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE11D48),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    unread > 99 ? '99+' : '$unread',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Unified Luxury Search Bar with instant tap highlight & pristine rounded corners
            AppSearchBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              hintText: 'Search services and categories...',
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
          Text('Browse Categories', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 2,
              childAspectRatio: 0.89,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ShimmerTile(width: 84, height: 84, borderRadius: 18),
                  const SizedBox(height: 2),
                  const ShimmerTile(width: 52, height: 10, borderRadius: 5),
                ],
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
            const Icon(
              Icons.category_outlined,
              size: 36,
              color: AppColors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              'No categories available',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Categories will appear here when available.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.grey),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => ctrl.fetchCategories(forceRefresh: true),
              icon: const Icon(
                Icons.refresh_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              label: const Text(
                'Refresh Categories',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceGridContent(
    List<ServiceCategoryItem> source,
    String query,
  ) {
    final displayedCategories = query.isEmpty
        ? source
        : source
              .where(
                (c) =>
                    c.title.toLowerCase().contains(query) ||
                    c.desc.toLowerCase().contains(query),
              )
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
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 2,
              childAspectRatio: 0.89,
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
                        page: ServiceListingScreen(category: cat.title),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ServiceIconWrap(
                        item: cat,
                        size: 84,
                        iconSize: 64,
                        borderRadius: 18,
                        isSelected: false,
                        loadingPlaceholder: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: const ShimmerTile(
                            width: 64,
                            height: 64,
                            borderRadius: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cat.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C2424),
                          height: 1.1,
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

  /// 'Need more services for your event' banner section
  Widget _buildNeedMoreServicesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Need more services for your event? ✨',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Book DJs, Caterers, Decorators, Luxury Cars & More',
              style: TextStyle(fontSize: 11, color: AppColors.darkGrey),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    FadeScaleRoute(
                      page: const ServiceListingScreen(category: 'All'),
                    ),
                  );
                },
                icon: const Icon(Icons.explore_rounded, size: 16),
                label: const Text('Explore All Vendors'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
