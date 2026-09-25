import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/service_categories.dart';
import '../../core/utils/app_animations.dart';
import '../../features/service_listing/service_listing_screen.dart';

/// Reusable squircle icon wrap matching `.service-icon-wrap`
/// - Width/Height: 72px (or custom size)
/// - BorderRadius: 18px
/// - Soft tinted background matching the category
/// - Distinct colorful icon with soft shadow
class ServiceIconWrap extends StatelessWidget {
  final ServiceCategoryItem item;
  final double size;
  final double iconSize;
  final double borderRadius;
  final bool isSelected;

  const ServiceIconWrap({
    super.key,
    required this.item,
    this.size = 70,
    this.iconSize = 30,
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
        child: Icon(
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
class ServiceCategoriesHorizontalBar extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<ServiceCategoryItem>? onCategorySelected;
  final bool showHeader;

  const ServiceCategoriesHorizontalBar({
    super.key,
    this.selectedCategory,
    this.onCategorySelected,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
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
                    '15 Services',
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
            height: 108,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: kServiceCategories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final cat = kServiceCategories[index];
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
                    width: 86,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ServiceIconWrap(
                          item: cat,
                          size: 62,
                          iconSize: 26,
                          borderRadius: 16,
                          isSelected: isSelected,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 12,
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
