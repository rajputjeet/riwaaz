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
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Simulated: Added new media to portfolio!'),
              duration: Duration(seconds: 1),
            ),
          );
        },
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
}
