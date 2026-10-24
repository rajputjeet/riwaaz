import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/wishlist_service.dart';
import '../../data/models/user_model.dart';
import '../../shared/widgets/vendor_image_view.dart';
import '../vendor_detail/vendor_detail_screen.dart';

class SavedVendorsScreen extends StatefulWidget {
  const SavedVendorsScreen({super.key});

  @override
  State<SavedVendorsScreen> createState() => _SavedVendorsScreenState();
}

class _SavedVendorsScreenState extends State<SavedVendorsScreen> {
  WishlistService get _wishlist => WishlistService.instance;

  @override
  void initState() {
    super.initState();
    _wishlist.refreshSavedVendors();
  }

  String _vendorName(UserModel vendor) {
    final businessName = vendor.vendorProfile?.businessName?.trim();
    if (businessName?.isNotEmpty == true) return businessName!;
    final name = vendor.fullName?.trim();
    return name?.isNotEmpty == true ? name! : 'Vendor';
  }

  String _vendorLocation(UserModel vendor) {
    return [
          vendor.vendorProfile?.businessAddress,
          vendor.address,
          vendor.vendorProfile?.city ?? vendor.city,
          vendor.vendorProfile?.state ?? vendor.state,
        ]
        .map((value) => value?.trim() ?? '')
        .where((value) => value.isNotEmpty)
        .toSet()
        .join(', ');
  }

  Future<void> _confirmClearAll() async {
    if (_wishlist.savedVendors.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear saved vendors?'),
        content: const Text(
          'This will remove all vendors from your saved list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _wishlist.clearAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Saved Vendors'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.black,
        elevation: 0,
        actions: [
          AnimatedBuilder(
            animation: _wishlist,
            builder: (context, _) => _wishlist.savedVendors.isEmpty
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: _wishlist.isLoading ? null : _confirmClearAll,
                    child: const Text('Clear all'),
                  ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _wishlist,
        builder: (context, _) {
          if (_wishlist.isLoading && _wishlist.savedVendors.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (_wishlist.error != null && _wishlist.savedVendors.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _wishlist.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.darkGrey),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _wishlist.refreshSavedVendors,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_wishlist.savedVendors.isEmpty) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _wishlist.refreshSavedVendors,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 130),
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 54,
                    color: AppColors.grey,
                  ),
                  SizedBox(height: 14),
                  Center(
                    child: Text(
                      'No saved vendors yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Tap the heart on a vendor to save them here.',
                      style: TextStyle(color: AppColors.darkGrey),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _wishlist.refreshSavedVendors,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _wishlist.savedVendors.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final vendor = _wishlist.savedVendors[index];
                final name = _vendorName(vendor);
                final location = _vendorLocation(vendor);
                final imageUrl = vendor.vendorCardImageUrl ?? '';
                final vendorId = vendor.id ?? '';

                return Material(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VendorDetailScreen(
                          vendorName: name,
                          location: location,
                          vendorModel: vendor,
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.grey.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Row(
                        children: [
                          VendorImageView(
                            imageUrl: imageUrl,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black,
                                  ),
                                ),
                                if (location.isNotEmpty) ...[
                                  const SizedBox(height: 5),
                                  Text(
                                    location,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.darkGrey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Remove from saved vendors',
                            onPressed:
                                vendorId.isEmpty ||
                                    _wishlist.isToggling(vendorId)
                                ? null
                                : () => _wishlist.toggleVendor(
                                    vendorId,
                                    vendor: vendor,
                                  ),
                            icon: const Icon(
                              Icons.favorite_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
