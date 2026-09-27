import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/api_provider/api_constant.dart';

/// Luxury Cached Image View with support for:
/// - Remote URLs (https:// / http://) via [CachedNetworkImage]
/// - Relative server paths (e.g. `/uploads/...`) auto-resolved with [ApiConstants.baseUrl]
/// - Local assets (e.g. `assets/...`)
/// - Circular / rounded corner clipping
/// - Shimmer / smooth placeholder
/// - Graceful fallback icons and assets on failure or empty URL
class CachedImageView extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool isCircle;
  final String? fallbackAsset;
  final IconData? fallbackIcon;
  final Color? iconColor;
  final double? iconSize;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final ColorFilter? colorFilter;
  final Alignment alignment;

  const CachedImageView({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.isCircle = false,
    this.fallbackAsset,
    this.fallbackIcon,
    this.iconColor,
    this.iconSize,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.border,
    this.boxShadow,
    this.colorFilter,
    this.alignment = Alignment.center,
  });

  /// Resolves any relative URL to an absolute URL using [ApiConstants.baseUrl]
  static String resolveUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final trimmed = raw.trim();
    if (trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('assets/')) {
      return trimmed;
    }
    final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$base$path';
  }

  @override
  Widget build(BuildContext context) {
    final cleanUrl = resolveUrl(imageUrl);

    Widget imageContent;

    if (cleanUrl.isEmpty) {
      imageContent = _buildFallback();
    } else if (cleanUrl.startsWith('assets/')) {
      imageContent = Image.asset(
        cleanUrl,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        color: colorFilter != null ? null : null,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    } else {
      imageContent = CachedNetworkImage(
        imageUrl: cleanUrl,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        fadeInDuration: const Duration(milliseconds: 250),
        fadeOutDuration: const Duration(milliseconds: 200),
        placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
        errorWidget: (context, url, error) => errorWidget ?? _buildFallback(),
      );
    }

    if (colorFilter != null) {
      imageContent = ColorFiltered(
        colorFilter: colorFilter!,
        child: imageContent,
      );
    }

    Widget container;

    if (isCircle) {
      container = Container(
        width: width,
        height: height ?? width,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? Colors.transparent,
          border: border,
          boxShadow: boxShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: imageContent,
      );
    } else if (borderRadius != null) {
      container = Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: backgroundColor ?? Colors.transparent,
          border: border,
          boxShadow: boxShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: imageContent,
      );
    } else if (border != null || boxShadow != null || backgroundColor != null) {
      container = Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          border: border,
          boxShadow: boxShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: imageContent,
      );
    } else {
      container = imageContent;
    }

    return container;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? AppColors.greyLight.withValues(alpha: 0.35),
      child: Center(
        child: SizedBox(
          width: (width != null && width! < 40) ? 14 : 20,
          height: (height != null && height! < 40) ? 14 : 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              iconColor ?? AppColors.gold.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    if (fallbackAsset != null && fallbackAsset!.isNotEmpty) {
      return Image.asset(
        fallbackAsset!,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
      );
    }
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? AppColors.greyLight.withValues(alpha: 0.25),
      child: Center(
        child: Icon(
          fallbackIcon ?? Icons.image_outlined,
          color: iconColor ?? AppColors.grey,
          size: iconSize ??
              ((width != null && width! < 40)
                  ? (width! * 0.55)
                  : 24),
        ),
      ),
    );
  }
}
