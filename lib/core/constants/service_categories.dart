import 'package:flutter/material.dart';

/// Represents a wedding service / vendor category in Riwaaz / ShaadiHub.
class ServiceCategoryItem {
  final int id;
  final String title;
  final IconData icon;
  final String colorClass;
  final Color color;
  final Color bgColor;
  final String desc;

  const ServiceCategoryItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.colorClass,
    required this.color,
    required this.bgColor,
    required this.desc,
  });
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
