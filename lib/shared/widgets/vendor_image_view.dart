import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'cached_image_view.dart';

class VendorImageView extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const VendorImageView({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    final placeholder = VendorImagePlaceholder();
    if (url == null || url.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: placeholder,
        ),
      );
    }

    return CachedImageView(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      errorWidget: placeholder,
    );
  }
}

class VendorImagePlaceholder extends StatelessWidget {
  final bool showLabel;

  const VendorImagePlaceholder({super.key, this.showLabel = true});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canShowLabel = showLabel &&
            constraints.maxHeight >= 90 &&
            constraints.maxWidth >= 130;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF8F2), Color(0xFFF8EAE7)],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: -24,
                right: -18,
                child: _SoftCircle(size: 92, color: Color(0x22C87578)),
              ),
              Positioned(
                bottom: -32,
                left: -22,
                child: _SoftCircle(size: 104, color: Color(0x22D7A879)),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: canShowLabel ? 54 : 44,
                      height: canShowLabel ? 54 : 44,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: AppColors.primary,
                        size: 27,
                      ),
                    ),
                    if (canShowLabel) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Vendor photo coming soon',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.darkGrey,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SoftCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
