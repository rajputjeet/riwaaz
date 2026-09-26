import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';

class VendorPortfolioScreen extends StatefulWidget {
  const VendorPortfolioScreen({super.key});

  @override
  State<VendorPortfolioScreen> createState() => _VendorPortfolioScreenState();
}

class _VendorPortfolioScreenState extends State<VendorPortfolioScreen> {
  int _selectedTab = 0; // 0 = Photos, 1 = Videos, 2 = Albums

  final List<String> _photos = [
    AppImages.vendorRoyalClick,
    AppImages.vendorMemories,
    AppImages.vendorShutter,
    AppImages.vendorCandid,
    AppImages.vendorLensArt,
    AppImages.exploreDecoration,
    AppImages.exploreWeddingCar,
    AppImages.exploreCatering,
    AppImages.weddingHero,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Portfolio & Gallery',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadMediaSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_photo_alternate_rounded,
            color: AppColors.white),
        label: const Text(
          'Upload Media',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // Segmented Tabs
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text('Photos (${_photos.length})'),
                  selected: _selectedTab == 0,
                  onSelected: (val) => setState(() => _selectedTab = 0),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color:
                        _selectedTab == 0 ? AppColors.white : AppColors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  backgroundColor: AppColors.offWhite,
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text('Cinematic Videos (4)'),
                  selected: _selectedTab == 1,
                  onSelected: (val) => setState(() => _selectedTab = 1),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color:
                        _selectedTab == 1 ? AppColors.white : AppColors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  backgroundColor: AppColors.offWhite,
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text('Albums (3)'),
                  selected: _selectedTab == 2,
                  onSelected: (val) => setState(() => _selectedTab = 2),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color:
                        _selectedTab == 2 ? AppColors.white : AppColors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  backgroundColor: AppColors.offWhite,
                ),
              ],
            ),
          ),

          // Gallery Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.0,
              ),
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        _photos[index],
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: AppColors.cream,
                          child: const Icon(Icons.image,
                              color: AppColors.gold),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: AppColors.white,
                            size: 14,
                          ),
                        ),
                      ),
                      if (_selectedTab == 1)
                        const Center(
                          child: Icon(
                            Icons.play_circle_filled_rounded,
                            color: AppColors.white,
                            size: 36,
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
    );
  }

  void _showUploadMediaSheet(BuildContext context) {
    String mediaType = 'Photo';
    String eventType = 'Wedding & Gala';
    final titleController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Upload Showcase Media',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Add high-resolution photos or cinematic reels to your portfolio',
                  style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
                ),
                const SizedBox(height: 16),

                // Media Type Selector
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Photo (High-Res)')),
                        selected: mediaType == 'Photo',
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: mediaType == 'Photo'
                              ? AppColors.white
                              : AppColors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        onSelected: (s) {
                          if (s) setSheetState(() => mediaType = 'Photo');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Cinematic Video')),
                        selected: mediaType == 'Video',
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: mediaType == 'Video'
                              ? AppColors.white
                              : AppColors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        onSelected: (s) {
                          if (s) setSheetState(() => mediaType = 'Video');
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Shoot Title (e.g. Royal Anand Karaj at Haveli)',
                    prefixIcon: const Icon(Icons.title_rounded,
                        color: AppColors.primary, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Category selector
                DropdownButtonFormField<String>(
                  initialValue: eventType,
                  decoration: InputDecoration(
                    labelText: 'Event Category',
                    prefixIcon: const Icon(Icons.category_rounded,
                        color: AppColors.primary, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    'Wedding & Gala',
                    'Pre-Wedding Shoot',
                    'Sangeet & Mehendi',
                    'Reception Night',
                  ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) {
                    if (val != null) setSheetState(() => eventType = val);
                  },
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _photos.insert(0, AppImages.vendorRoyalClick);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Media uploaded to portfolio successfully!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Add to Showcase'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
