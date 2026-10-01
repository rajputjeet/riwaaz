import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/category_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/service_categories.dart';
import '../../core/utils/app_animations.dart';
import '../../features/service_listing/service_listing_screen.dart';
import 'cached_image_view.dart';

/// Reusable squircle icon wrap matching `.service-icon-wrap`
/// - Width/Height: 70px (or custom size)
/// - BorderRadius: 18px
/// - Soft tinted background matching the category
/// - Dynamic server icon image via [CachedImageView] with graceful fallback to IconData
class ServiceIconWrap extends StatelessWidget {
  final ServiceCategoryItem item;
  final double size;
  final double iconSize;
  final double borderRadius;
  final bool isSelected;

  const ServiceIconWrap({
    super.key,
    required this.item,
    this.size = 74,
    this.iconSize = 44,
    this.borderRadius = 18,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: item.bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: isSelected
            ? Border.all(color: item.color, width: 2.2)
            : Border.all(color: item.color.withValues(alpha: 0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isSelected ? 0.25 : 0.14),
            blurRadius: isSelected ? 16 : 12,
            offset: const Offset(0, 4),
          ),
          if (isSelected)
            BoxShadow(
              color: item.color.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Center(
        child: item.hasServerIcon
            ? CachedImageView(
                imageUrl: item.iconUrl,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
                fallbackIcon: item.icon,
                iconColor: item.color,
                iconSize: iconSize,
              )
            : Icon(
                item.icon,
                color: item.color,
                size: iconSize,
              ),
      ),
    );
  }
}

/// Horizontal scroll bar for categories with royal dark maroon background
/// directly matching the reference screenshot.
/// Dynamically updates from [CategoryController] with server icons.
class ServiceCategoriesHorizontalBar extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<ServiceCategoryItem>? onCategorySelected;
  final bool showHeader;
  final List<ServiceCategoryItem>? customCategories;

  const ServiceCategoriesHorizontalBar({
    super.key,
    this.selectedCategory,
    this.onCategorySelected,
    this.showHeader = true,
    this.customCategories,
  });

  @override
  Widget build(BuildContext context) {
    if (customCategories != null) {
      return _buildBar(context, customCategories!);
    }

    final categoryCtrl = Get.isRegistered<CategoryController>()
        ? CategoryController.to
        : null;

    if (categoryCtrl == null) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final categories = categoryCtrl.serviceCategories;
      final isLoading = categoryCtrl.isLoading.value;

      if (isLoading && categories.isEmpty) {
        return _buildLoadingBar();
      }

      if (categories.isEmpty) {
        return const SizedBox.shrink();
      }

      return _buildBar(context, categories);
    });
  }

  Widget _buildLoadingBar() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF26050E),
            Color(0xFF1E040B),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 128,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          separatorBuilder: (context, index) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 50,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBar(BuildContext context, List<ServiceCategoryItem> categories) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF26050E), // Deep royal maroon
            Color(0xFF1E040B),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Browse Categories',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${categories.length} Services',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.goldLight.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            height: 128,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategory == cat.title;

                return GestureDetector(
                  onTap: () {
                    if (onCategorySelected != null) {
                      onCategorySelected!(cat);
                    } else {
                      Navigator.of(context).push(
                        FadeScaleRoute(
                          page: ServiceListingScreen(category: cat.title),
                        ),
                      );
                    }
                  },
                  child: SizedBox(
                    width: 92,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ServiceIconWrap(
                          item: cat,
                          size: 74,
                          iconSize: 46,
                          borderRadius: 18,
                          isSelected: isSelected,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 12.5,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected
                                ? AppColors.goldLight
                                : AppColors.white.withValues(alpha: 0.95),
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
