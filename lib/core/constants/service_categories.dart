import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';

/// Represents a wedding service / vendor category in Widoora.
class ServiceCategoryItem {
  final int id;
  final String? serverId;
  final String title;
  final IconData icon;
  final String? iconUrl;
  final String colorClass;
  final Color color;
  final Color bgColor;
  final String desc;

  const ServiceCategoryItem({
    required this.id,
    this.serverId,
    required this.title,
    required this.icon,
    this.iconUrl,
    required this.colorClass,
    required this.color,
    required this.bgColor,
    required this.desc,
  });

  bool get hasServerIcon => iconUrl != null && iconUrl!.trim().isNotEmpty;

  ServiceCategoryItem copyWith({
    int? id,
    String? serverId,
    String? title,
    IconData? icon,
    String? iconUrl,
    String? colorClass,
    Color? color,
    Color? bgColor,
    String? desc,
  }) {
    return ServiceCategoryItem(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      iconUrl: iconUrl ?? this.iconUrl,
      colorClass: colorClass ?? this.colorClass,
      color: color ?? this.color,
      bgColor: bgColor ?? this.bgColor,
      desc: desc ?? this.desc,
    );
  }

  static ServiceCategoryItem? findLocalMatch(String name) {
    final lower = name.toLowerCase().trim();
    for (final item in kServiceCategories) {
      final itemLower = item.title.toLowerCase().trim();
      if (itemLower == lower ||
          itemLower.contains(lower) ||
          lower.contains(itemLower)) {
        return item;
      }
    }
    return null;
  }

  factory ServiceCategoryItem.fromCategoryModel(CategoryModel model, {int index = 0}) {
    final name = (model.name ?? '').trim();
    final match = findLocalMatch(name);

    if (match != null) {
      return match.copyWith(
        id: int.tryParse(model.id ?? '') ?? match.id,
        serverId: model.id,
        title: name.isNotEmpty ? name : match.title,
        iconUrl: model.iconUrl,
        desc: (model.desc != null && model.desc!.trim().isNotEmpty)
            ? model.desc!.trim()
            : match.desc,
      );
    }

    const palette = [
      (Color(0xFFD97706), Color(0xFFFFFBEB), Icons.apartment_rounded),
      (Color(0xFFE11D48), Color(0xFFFFF1F2), Icons.auto_awesome_rounded),
      (Color(0xFF059669), Color(0xFFF0FDF4), Icons.front_hand_rounded),
      (Color(0xFFEA580C), Color(0xFFFFF7ED), Icons.restaurant_rounded),
      (Color(0xFF7C3AED), Color(0xFFF5F3FF), Icons.local_florist_rounded),
      (Color(0xFF2563EB), Color(0xFFEFF6FF), Icons.camera_alt_rounded),
      (Color(0xFF0D9488), Color(0xFFF0FDFA), Icons.music_note_rounded),
      (Color(0xFFDC2626), Color(0xFFFEF2F2), Icons.local_bar_rounded),
    ];
    final p = palette[index % palette.length];

    return ServiceCategoryItem(
      id: int.tryParse(model.id ?? '') ?? (100 + index),
      serverId: model.id,
      title: name.isNotEmpty ? name : 'Category ${index + 1}',
      icon: p.$3,
      iconUrl: model.iconUrl,
      colorClass: 'cat-dynamic',
      color: p.$1,
      bgColor: p.$2,
      desc: model.desc ?? 'Professional wedding and event services.',
    );
  }
}

/// 15 distinct service categories with curated colors, soft-tinted backgrounds,
/// and matching icons matching `.service-icon-wrap`.
const List<ServiceCategoryItem> kServiceCategories = [
  ServiceCategoryItem(
    id: 1,
    title: 'Banquet Halls & Hotels',
    icon: Icons.apartment_rounded,
    colorClass: 'cat-hotel',
    color: Color(0xFFD97706), // Amber Gold
    bgColor: Color(0xFFFFFBEB),
    desc: 'Venues and banquet spaces for every event size.',
  ),
  ServiceCategoryItem(
    id: 3,
    title: 'Makeup & Hair',
    icon: Icons.auto_awesome_rounded,
    colorClass: 'cat-makeup',
    color: Color(0xFFE11D48), // Rose Pink
    bgColor: Color(0xFFFFF1F2),
    desc: 'Professional styling for your special day.',
  ),
  ServiceCategoryItem(
    id: 4,
    title: 'Mehndi Artists',
    icon: Icons.front_hand_rounded,
    colorClass: 'cat-mehndi',
    color: Color(0xFF059669), // Emerald Green
    bgColor: Color(0xFFF0FDF4),
    desc: 'Intricate henna designs for all occasions.',
  ),
  ServiceCategoryItem(
    id: 5,
    title: 'Catering',
    icon: Icons.restaurant_rounded,
    colorClass: 'cat-catering',
    color: Color(0xFFEA580C), // Sunset Orange
    bgColor: Color(0xFFFFF7ED),
    desc: 'Customized food and menus for your event.',
  ),
  ServiceCategoryItem(
    id: 2,
    title: 'Photography & Videography',
    icon: Icons.camera_alt_rounded,
    colorClass: 'cat-photo',
    color: Color(0xFF4338CA), // Royal Indigo
    bgColor: Color(0xFFEEF2FF),
    desc: 'Capture every important moment beautifully.',
  ),
  ServiceCategoryItem(
    id: 6,
    title: 'Decor & Flora',
    icon: Icons.local_florist_rounded,
    colorClass: 'cat-decor',
    color: Color(0xFFF43F5E), // Coral Rose
    bgColor: Color(0xFFFFF1F2),
    desc: 'Transform your venue into the perfect setting.',
  ),
  ServiceCategoryItem(
    id: 7,
    title: 'DJ & Sound',
    icon: Icons.music_note_rounded,
    colorClass: 'cat-dj',
    color: Color(0xFF7C3AED), // Electric Purple
    bgColor: Color(0xFFF5F3FF),
    desc: 'Keep your guests dancing all night long.',
  ),
  ServiceCategoryItem(
    id: 8,
    title: 'Live Bands',
    icon: Icons.queue_music_rounded,
    colorClass: 'cat-band',
    color: Color(0xFFDC2626), // Ruby Crimson
    bgColor: Color(0xFFFEF2F2),
    desc: 'Live music performances for unforgettable events.',
  ),
  ServiceCategoryItem(
    id: 9,
    title: 'Wedding Cars',
    icon: Icons.directions_car_rounded,
    colorClass: 'cat-car',
    color: Color(0xFF0284C7), // Sky Azure
    bgColor: Color(0xFFF0F9FF),
    desc: 'Luxury car rentals for your arrival and departure.',
  ),
  ServiceCategoryItem(
    id: 10,
    title: 'Bridal & Groom Dresses',
    icon: Icons.checkroom_rounded,
    colorClass: 'cat-dress',
    color: Color(0xFFC026D3), // Fuchsia / Magenta
    bgColor: Color(0xFFFDF4FF),
    desc: 'Beautiful attire for the bride and groom.',
  ),
  ServiceCategoryItem(
    id: 11,
    title: 'Jaggo Group',
    icon: Icons.celebration_rounded,
    colorClass: 'cat-jaggo',
    color: Color(0xFFB45309), // Festive Brass / Gold
    bgColor: Color(0xFFFEFCE8),
    desc: 'Traditional Jaggo troupe for authentic celebrations.',
  ),
  ServiceCategoryItem(
    id: 12,
    title: 'Turban Group',
    icon: Icons.workspace_premium_rounded,
    colorClass: 'cat-turban',
    color: Color(0xFF9333EA), // Regal Purple
    bgColor: Color(0xFFFAF5FF),
    desc: 'Traditional and stylish turbans for groom and family.',
  ),
  ServiceCategoryItem(
    id: 13,
    title: 'Invitation Cards',
    icon: Icons.mark_email_read_rounded,
    colorClass: 'cat-card',
    color: Color(0xFF0D9488), // Mint Teal
    bgColor: Color(0xFFF0FDFA),
    desc: 'Beautiful and customized event invitations.',
  ),
  ServiceCategoryItem(
    id: 14,
    title: 'Jewellers',
    icon: Icons.diamond_rounded,
    colorClass: 'cat-jewel',
    color: Color(0xFF2563EB), // Sparkling Sapphire
    bgColor: Color(0xFFEFF6FF),
    desc: 'Exquisite jewelry for your special day.',
  ),
  ServiceCategoryItem(
    id: 15,
    title: 'Tent Houses',
    icon: Icons.holiday_village_rounded,
    colorClass: 'cat-tent',
    color: Color(0xFFC2410C), // Terracotta
    bgColor: Color(0xFFFFF7ED),
    desc: 'Elegant tents and outdoor setups for events.',
  ),
];
