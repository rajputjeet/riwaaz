import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/api_provider/user_api_provider.dart';
import '../../data/api_provider/vendor_api_provider.dart';
import '../../shared/widgets/app_states.dart';
import '../../shared/widgets/cached_image_view.dart';
import '../../shared/widgets/portfolio_video_player.dart';
import '../../utils/utils.dart';

class _PortfolioMediaItem {
  final String path;
  final String type; // 'image' or 'video'
  final String fileName;
  String? thumbnailPath;

  _PortfolioMediaItem({
    required this.path,
    required this.type,
    required this.fileName,
  });
}

class VendorPortfolioScreen extends StatefulWidget {
  const VendorPortfolioScreen({super.key});

  @override
  State<VendorPortfolioScreen> createState() => _VendorPortfolioScreenState();
}

class _VendorPortfolioScreenState extends State<VendorPortfolioScreen> {
  int _selectedTab = 0; // 0 = All, 1 = Photos, 2 = Videos
  final _userApi = UserApiProvider();
  final _vendorApi = VendorApiProvider();
  final _imagePicker = ImagePicker();

  final List<Map<String, dynamic>> _portfolioItems = [];
  bool _isLoading = true;
  bool _isNoInternet = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPortfolio();
  }

  Future<void> _fetchPortfolio() async {
    setState(() {
      _isLoading = true;
      _isNoInternet = false;
      _errorMessage = null;
    });

    try {
      final res = await _userApi.getProfile();
      if (!mounted) return;
      if (res.isSuccess == true && res.data != null) {
        final rawPortfolio = res.data!.vendorProfile?.portfolio;
        final List<Map<String, dynamic>> loaded = [];
        if (rawPortfolio != null) {
          for (final item in rawPortfolio) {
            if (item is Map) {
              final rawType = (item['type'] ?? 'image').toString().toLowerCase();
              final imgUrl = item['imageUrl']?.toString() ?? item['url']?.toString() ?? '';
              final isVideo = rawType.contains('video') || CachedImageView.isVideoUrl(imgUrl);
              String thumb = (item['thumbnail'] ??
                      item['thumbnailUrl'] ??
                      item['poster'] ??
                      item['cover'] ??
                      '')
                  .toString();
              if (CachedImageView.isVideoUrl(thumb)) {
                thumb = '';
              }
              loaded.add({
                'id': (item['_id'] ?? item['id'])?.toString() ?? '',
                'imageUrl': imgUrl,
                'thumbnailUrl': thumb,
                'title': item['title']?.toString() ?? '',
                'type': isVideo ? 'video' : 'image',
              });
            } else if (item is String) {
              final isVideo = CachedImageView.isVideoUrl(item);
              loaded.add({
                'id': '',
                'imageUrl': item,
                'thumbnailUrl': '',
                'title': '',
                'type': isVideo ? 'video' : 'image',
              });
            }
          }
        }
        setState(() {
          _portfolioItems.clear();
          _portfolioItems.addAll(loaded);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = res.message ?? 'Failed to load portfolio';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      final str = e.toString().toLowerCase();
      setState(() {
        if (str.contains('socket') || str.contains('network') || str.contains('connection')) {
          _isNoInternet = true;
        } else {
          _errorMessage = 'Could not load portfolio. Please check connection.';
        }
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredItems {
    if (_selectedTab == 1) {
      return _portfolioItems.where((i) => i['type'] == 'image').toList();
    } else if (_selectedTab == 2) {
      return _portfolioItems.where((i) => i['type'] == 'video').toList();
    }
    return _portfolioItems;
  }

  String _shortenFileName(String fileName) {
    if (fileName.length <= 16) return fileName;
    final dotIndex = fileName.lastIndexOf('.');
    final ext = dotIndex != -1 ? fileName.substring(dotIndex) : '';
    final nameWithoutExt = dotIndex != -1 ? fileName.substring(0, dotIndex) : fileName;
    if (nameWithoutExt.length > 9) {
      return '${nameWithoutExt.substring(0, 8)}...$ext';
    }
    return fileName;
  }

  void _confirmDelete(Map<String, dynamic> item) {
    final id = item['id']?.toString() ?? '';
    final isVideo = item['type'] == 'video';

    showDialog(
      context: context,
      builder: (ctx) {
        final dialogNav = Navigator.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Delete Portfolio Item?',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text('Are you sure you want to delete this ${isVideo ? 'video' : 'photo'}?'),
          actions: [
            TextButton(
              onPressed: () => dialogNav.pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.darkGrey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                dialogNav.pop();
                if (id.isNotEmpty) {
                  Utils.showInfo('Deleting item...');
                  final res = await _vendorApi.deletePortfolioItem(id);
                  if (!mounted) return;
                  if (res.isSuccess == true) {
                    Utils.showSuccess('Portfolio item deleted successfully');
                    _fetchPortfolio();
                  } else {
                    Utils.showError(res.message ?? 'Failed to delete item');
                  }
                } else {
                  setState(() => _portfolioItems.remove(item));
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showMediaDetail(Map<String, dynamic> item) {
    final id = item['id']?.toString() ?? '';
    final isVideo = item['type'] == 'video';
    final url = item['imageUrl']?.toString() ?? '';
    final thumbUrl = item['thumbnailUrl']?.toString() ?? '';
    final title = item['title']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: isVideo && url.isNotEmpty
                    ? () {
                        Navigator.pop(ctx);
                        PortfolioVideoPlayer.show(context, videoUrl: url, title: title);
                      }
                    : null,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 10,
                      child: isVideo
                          ? (thumbUrl.isNotEmpty
                              ? CachedImageView(
                                  imageUrl: thumbUrl,
                                  fit: BoxFit.cover,
                                  fallbackIcon: Icons.videocam_rounded,
                                  iconColor: AppColors.gold,
                                  backgroundColor: AppColors.cream,
                                )
                              : Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppColors.primaryDark, Color(0xFF1B2236)],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.movie_creation_outlined,
                                        color: Colors.white30, size: 48),
                                  ),
                                ))
                          : CachedImageView(
                              imageUrl: url,
                              fit: BoxFit.cover,
                              fallbackIcon: Icons.image_rounded,
                              iconColor: AppColors.gold,
                              backgroundColor: AppColors.cream,
                            ),
                    ),
                    if (isVideo)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white70, width: 2),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.5),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isVideo ? 'VIDEO' : 'PHOTO',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (isVideo && thumbUrl.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.image_outlined, size: 12, color: AppColors.goldDark),
                                SizedBox(width: 4),
                                Text(
                                  'Thumbnail Set',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.goldDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    if (title.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (isVideo && id.isNotEmpty) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            try {
                              final f = await _imagePicker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 85,
                                maxWidth: 1920,
                                maxHeight: 1920,
                              );
                              if (f != null) {
                                Utils.showInfo('Updating video thumbnail...');
                                final fd = dio.FormData();
                                fd.files.add(MapEntry('file', await dio.MultipartFile.fromFile(f.path, filename: 'thumb_$id.jpg')));
                                fd.files.add(MapEntry('thumbnail', await dio.MultipartFile.fromFile(f.path, filename: 'thumb_$id.jpg')));
                                fd.fields.add(const MapEntry('type', 'video'));
                                final editRes = await _vendorApi.editPortfolioItem(id, fd);
                                if (editRes.isSuccess == true) {
                                  Utils.showSuccess('Thumbnail updated successfully!');
                                  _fetchPortfolio();
                                } else {
                                  Utils.showError(editRes.message ?? 'Failed to update thumbnail');
                                }
                              }
                            } catch (e) {
                              Utils.showError('Could not update thumbnail: $e');
                            }
                          },
                          icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                          label: Text(thumbUrl.isNotEmpty ? 'Change Video Thumbnail' : 'Add Video Thumbnail'),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _confirmDelete(item);
                        },
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        label: const Text('Delete from Portfolio'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickThumbnailForMediaItem(
    BuildContext context,
    _PortfolioMediaItem item,
    VoidCallback onUpdated,
  ) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Video Cover Thumbnail',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose an eye-catching photo thumbnail for this video',
                style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded,
                      color: AppColors.primary, size: 22),
                ),
                title: const Text('Choose from Gallery',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.grey),
                contentPadding: EdgeInsets.zero,
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  try {
                    final f = await _imagePicker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                      maxWidth: 1920,
                      maxHeight: 1920,
                    );
                    if (f != null) {
                      item.thumbnailPath = f.path;
                      onUpdated();
                    }
                  } catch (e) {
                    Utils.showError('Could not select thumbnail: $e');
                  }
                },
              ),
              const Divider(height: 12),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: AppColors.primary, size: 22),
                ),
                title: const Text('Take with Camera',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.grey),
                contentPadding: EdgeInsets.zero,
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  try {
                    final f = await _imagePicker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 85,
                      maxWidth: 1920,
                      maxHeight: 1920,
                    );
                    if (f != null) {
                      item.thumbnailPath = f.path;
                      onUpdated();
                    }
                  } catch (e) {
                    Utils.showError('Could not take thumbnail photo: $e');
                  }
                },
              ),
              if (item.thumbnailPath != null) ...[
                const Divider(height: 12),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.error, size: 22),
                  ),
                  title: const Text('Remove Thumbnail',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.error)),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    item.thumbnailPath = null;
                    onUpdated();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showMediaSourceDialog({
    required BuildContext context,
    required bool isVideo,
    required Function(List<_PortfolioMediaItem> items) onPicked,
  }) {
    final mediaLabel = isVideo ? 'Video' : 'Photos';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Choose $mediaLabel Source',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isVideo
                    ? 'Pick a video from gallery or record using camera'
                    : 'Select multiple photos from gallery or take a new photo',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.5, color: AppColors.darkGrey),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.of(sheetCtx).pop();
                        try {
                          if (isVideo) {
                            final picked = await _imagePicker.pickVideo(source: ImageSource.camera);
                            if (picked != null) {
                              final name = picked.name.isNotEmpty ? picked.name : picked.path.split(RegExp(r'[\\/]')).last;
                              onPicked([_PortfolioMediaItem(path: picked.path, type: 'video', fileName: name)]);
                            }
                          } else {
                            final picked = await _imagePicker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 85,
                              maxWidth: 1920,
                              maxHeight: 1920,
                            );
                            if (picked != null) {
                              final name = picked.name.isNotEmpty ? picked.name : picked.path.split(RegExp(r'[\\/]')).last;
                              onPicked([_PortfolioMediaItem(path: picked.path, type: 'image', fileName: name)]);
                            }
                          }
                        } catch (e) {
                          Utils.showError('Could not access camera: $e');
                        }
                      },
                      icon: Icon(
                        isVideo ? Icons.videocam_rounded : Icons.camera_alt_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      label: Text(
                        isVideo ? 'Record Video' : 'Take Photo',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.of(sheetCtx).pop();
                        try {
                          if (isVideo) {
                            final picked = await _imagePicker.pickVideo(source: ImageSource.gallery);
                            if (picked != null) {
                              final name = picked.name.isNotEmpty ? picked.name : picked.path.split(RegExp(r'[\\/]')).last;
                              onPicked([_PortfolioMediaItem(path: picked.path, type: 'video', fileName: name)]);
                            }
                          } else {
                            final pickedList = await _imagePicker.pickMultiImage(
                              imageQuality: 85,
                              maxWidth: 1920,
                              maxHeight: 1920,
                            );
                            if (pickedList.isNotEmpty) {
                              final items = pickedList.map((f) {
                                final name = f.name.isNotEmpty ? f.name : f.path.split(RegExp(r'[\\/]')).last;
                                return _PortfolioMediaItem(path: f.path, type: 'image', fileName: name);
                              }).toList();
                              onPicked(items);
                            }
                          }
                        } catch (e) {
                          Utils.showError('Could not pick from gallery: $e');
                        }
                      },
                      icon: Icon(
                        isVideo ? Icons.video_library_rounded : Icons.photo_library_rounded,
                        color: AppColors.white,
                        size: 20,
                      ),
                      label: Text(
                        isVideo ? 'Gallery Video' : 'Gallery (Multi)',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMoreOptionSheet({
    required BuildContext context,
    required Function(List<_PortfolioMediaItem> items) onPicked,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Add More Media',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.black),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.primary, size: 22),
                ),
                title: const Text('Gallery Photos (Multi-Select)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: const Text('Select one or multiple photos from gallery', style: TextStyle(fontSize: 12, color: AppColors.darkGrey)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
                contentPadding: EdgeInsets.zero,
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  try {
                    final list = await _imagePicker.pickMultiImage(imageQuality: 85, maxWidth: 1920, maxHeight: 1920);
                    if (list.isNotEmpty) {
                      final items = list.map((f) {
                        final name = f.name.isNotEmpty ? f.name : f.path.split(RegExp(r'[\\/]')).last;
                        return _PortfolioMediaItem(path: f.path, type: 'image', fileName: name);
                      }).toList();
                      onPicked(items);
                    }
                  } catch (_) {}
                },
              ),
              const Divider(height: 12),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 22),
                ),
                title: const Text('Take Photo with Camera', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: const Text('Capture a live picture from your camera', style: TextStyle(fontSize: 12, color: AppColors.darkGrey)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
                contentPadding: EdgeInsets.zero,
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  try {
                    final f = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 85, maxWidth: 1920, maxHeight: 1920);
                    if (f != null) {
                      final name = f.name.isNotEmpty ? f.name : f.path.split(RegExp(r'[\\/]')).last;
                      onPicked([_PortfolioMediaItem(path: f.path, type: 'image', fileName: name)]);
                    }
                  } catch (_) {}
                },
              ),
              const Divider(height: 12),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.videocam_rounded, color: AppColors.gold, size: 22),
                ),
                title: const Text('Add Video', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: const Text('Pick from gallery or record new video', style: TextStyle(fontSize: 12, color: AppColors.darkGrey)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _showMediaSourceDialog(context: context, isVideo: true, onPicked: onPicked);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUploadMediaSheet(BuildContext context) {
    final List<_PortfolioMediaItem> selectedFiles = [];
    bool isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final sheetNav = Navigator.of(ctx);

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
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
                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upload to Portfolio',
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Text(
                                'Select one or multiple photos and videos to showcase',
                                style: TextStyle(fontSize: 11.5, color: AppColors.darkGrey),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: isUploading ? null : () => sheetNav.pop(),
                          ),
                        ],
                      ),
                      const Divider(height: 20),

                      if (selectedFiles.isEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                          decoration: BoxDecoration(
                            color: AppColors.cream.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              width: 1.4,
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 38,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Add Portfolio Showcase Media',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'You can select multiple photos at once from your gallery',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        _showMediaSourceDialog(
                                          context: ctx,
                                          isVideo: false,
                                          onPicked: (items) {
                                            setSheetState(() => selectedFiles.addAll(items));
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                                      label: const Text('Add Photos', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: AppColors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 13),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        _showMediaSourceDialog(
                                          context: ctx,
                                          isVideo: true,
                                          onPicked: (items) {
                                            setSheetState(() => selectedFiles.addAll(items));
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.video_call_rounded, size: 20, color: AppColors.primary),
                                      label: const Text('Add Video', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary)),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 13),
                                        side: const BorderSide(color: AppColors.primary),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Selected Media',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.black,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${selectedFiles.length}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (!isUploading)
                              TextButton.icon(
                                onPressed: () {
                                  setSheetState(() => selectedFiles.clear());
                                },
                                icon: const Icon(Icons.delete_sweep_rounded, size: 16, color: AppColors.error),
                                label: const Text(
                                  'Clear All',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.error),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Grid of selected media previews
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: selectedFiles.length + (isUploading ? 0 : 1),
                          itemBuilder: (context, index) {
                            if (index == selectedFiles.length) {
                              // "+ Add More" card
                              return InkWell(
                                onTap: isUploading
                                    ? null
                                    : () {
                                        _showAddMoreOptionSheet(
                                          context: ctx,
                                          onPicked: (items) {
                                            setSheetState(() => selectedFiles.addAll(items));
                                          },
                                        );
                                      },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.cream.withValues(alpha: 0.35),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                      style: BorderStyle.solid,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 28),
                                      SizedBox(height: 4),
                                      Text(
                                        'Add More',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final item = selectedFiles[index];
                            final isVid = item.type == 'video';

                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: isVid
                                      ? (item.thumbnailPath != null
                                          ? Image.file(
                                              File(item.thumbnailPath!),
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) => Container(
                                                color: Colors.black87,
                                                child: const Icon(Icons.videocam_rounded, color: AppColors.gold, size: 32),
                                              ),
                                            )
                                          : Container(
                                              color: Colors.black87,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.videocam_rounded,
                                                  color: AppColors.gold,
                                                  size: 32,
                                                ),
                                              ),
                                            ))
                                      : Image.file(
                                          File(item.path),
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Container(
                                            color: AppColors.cream,
                                            child: const Icon(Icons.broken_image_rounded, color: AppColors.darkGrey),
                                          ),
                                        ),
                                ),
                                // Video thumbnail action overlay
                                if (isVid)
                                  Positioned(
                                    bottom: 20,
                                    left: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: isUploading
                                          ? null
                                          : () => _pickThumbnailForMediaItem(
                                                ctx,
                                                item,
                                                () => setSheetState(() {}),
                                              ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: item.thumbnailPath != null
                                              ? AppColors.primary
                                              : Colors.black.withValues(alpha: 0.78),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: item.thumbnailPath != null
                                                ? Colors.white70
                                                : AppColors.gold,
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              item.thumbnailPath != null
                                                  ? Icons.check_circle_rounded
                                                  : Icons.add_photo_alternate_rounded,
                                              size: 11,
                                              color: item.thumbnailPath != null
                                                  ? Colors.white
                                                  : AppColors.gold,
                                            ),
                                            const SizedBox(width: 3),
                                            Flexible(
                                              child: Text(
                                                item.thumbnailPath != null
                                                    ? 'Thumbnail'
                                                    : '+ Thumb',
                                                style: TextStyle(
                                                  color: item.thumbnailPath != null
                                                      ? Colors.white
                                                      : AppColors.gold,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                // Gradient bottom overlay
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.7),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                    child: Text(
                                      isVid ? 'VIDEO' : _shortenFileName(item.fileName),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                // Remove button
                                if (!isUploading)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setSheetState(() => selectedFiles.removeAt(index));
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.65),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Upload Progress if running
                      if (isUploading) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Uploading ${selectedFiles.length} ${selectedFiles.length == 1 ? "item" : "items"}...',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const Text(
                                  'Please wait',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkGrey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: const LinearProgressIndicator(
                                minHeight: 6,
                                backgroundColor: AppColors.cream,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ],

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: (isUploading || selectedFiles.isEmpty)
                              ? null
                              : () async {
                                  setSheetState(() {
                                    isUploading = true;
                                  });

                                  try {
                                    final formData = dio.FormData();

                                    final hasVideo = selectedFiles.any((f) => f.type == 'video');
                                    final hasImage = selectedFiles.any((f) => f.type == 'image');
                                    if (hasVideo && !hasImage) {
                                      formData.fields.add(const MapEntry('type', 'video'));
                                    } else if (hasImage && !hasVideo) {
                                      formData.fields.add(const MapEntry('type', 'image'));
                                    }

                                    // Add single or multiple photos/videos to FormData under 'photos'
                                    for (final item in selectedFiles) {
                                      formData.files.add(
                                        MapEntry(
                                          'photos',
                                          await dio.MultipartFile.fromFile(
                                            item.path,
                                            filename: item.fileName,
                                          ),
                                        ),
                                      );

                                      if (selectedFiles.length == 1) {
                                        formData.files.add(
                                          MapEntry(
                                            'file',
                                            await dio.MultipartFile.fromFile(
                                              item.path,
                                              filename: item.fileName,
                                            ),
                                          ),
                                        );
                                      }

                                      if (item.type == 'video' && item.thumbnailPath != null && item.thumbnailPath!.isNotEmpty) {
                                        formData.files.add(
                                          MapEntry(
                                            'thumbnail',
                                            await dio.MultipartFile.fromFile(
                                              item.thumbnailPath!,
                                              filename: 'thumb_${item.fileName}.jpg',
                                            ),
                                          ),
                                        );
                                        formData.files.add(
                                          MapEntry(
                                            'thumbnails',
                                            await dio.MultipartFile.fromFile(
                                              item.thumbnailPath!,
                                              filename: 'thumb_${item.fileName}.jpg',
                                            ),
                                          ),
                                        );
                                      }
                                    }

                                    final res = await _vendorApi.addPortfolioItem(formData);

                                    if (!mounted) return;

                                    if (res.isSuccess == true) {
                                      sheetNav.pop();
                                      final countText = selectedFiles.length == 1
                                          ? 'Portfolio item uploaded successfully!'
                                          : '${selectedFiles.length} portfolio items uploaded successfully!';
                                      Utils.showSuccess(countText);
                                      _fetchPortfolio();
                                    } else {
                                      setSheetState(() => isUploading = false);
                                      Utils.showError(
                                        res.message ?? res.error ?? 'Failed to upload portfolio media. Please try again.',
                                      );
                                    }
                                  } catch (e) {
                                    if (!mounted) return;
                                    setSheetState(() => isUploading = false);
                                    Utils.showError('Error preparing media upload: $e');
                                  }
                                },
                          icon: isUploading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.cloud_upload_outlined, size: 20),
                          label: Text(
                            isUploading
                                ? 'Uploading ${selectedFiles.length} ${selectedFiles.length == 1 ? 'item' : 'items'}...'
                                : selectedFiles.isEmpty
                                    ? 'Select Media to Upload'
                                    : 'Upload ${selectedFiles.length} ${selectedFiles.length == 1 ? 'Item' : 'Items'} to Portfolio',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            disabledBackgroundColor: AppColors.grey.withValues(alpha: 0.3),
                            disabledForegroundColor: AppColors.darkGrey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final photoCount = _portfolioItems.where((i) => i['type'] == 'image').length;
    final videoCount = _portfolioItems.where((i) => i['type'] == 'video').length;

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
            fontWeight: FontWeight.w800,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_rounded,
                color: AppColors.primary, size: 24),
            onPressed: () => _showUploadMediaSheet(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadMediaSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.cloud_upload_rounded, color: AppColors.white),
        label: const Text(
          'Upload Media',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading
          ? const AppLoadingState(message: 'Loading portfolio showcase...')
          : _isNoInternet
              ? AppNoInternetState(onRetry: _fetchPortfolio)
              : _errorMessage != null
                  ? AppErrorState(message: _errorMessage!, onRetry: _fetchPortfolio)
                  : Column(
                      children: [
                        // Segmented Filter Tabs
                        Container(
                          color: AppColors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              ChoiceChip(
                                label: Text('All (${_portfolioItems.length})'),
                                selected: _selectedTab == 0,
                                onSelected: (val) => setState(() => _selectedTab = 0),
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: _selectedTab == 0 ? AppColors.white : AppColors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                backgroundColor: AppColors.offWhite,
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: Text('Photos ($photoCount)'),
                                selected: _selectedTab == 1,
                                onSelected: (val) => setState(() => _selectedTab = 1),
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: _selectedTab == 1 ? AppColors.white : AppColors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                backgroundColor: AppColors.offWhite,
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: Text('Videos ($videoCount)'),
                                selected: _selectedTab == 2,
                                onSelected: (val) => setState(() => _selectedTab = 2),
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: _selectedTab == 2 ? AppColors.white : AppColors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                backgroundColor: AppColors.offWhite,
                              ),
                            ],
                          ),
                        ),

                        // Gallery Grid or Empty State
                        Expanded(
                          child: _filteredItems.isEmpty
                              ? AppEmptyState(
                                  icon: Icons.photo_library_outlined,
                                  title: _selectedTab == 1
                                      ? 'No Photos Uploaded'
                                      : _selectedTab == 2
                                          ? 'No Videos Uploaded'
                                          : 'No Media Uploaded Yet',
                                  subtitle:
                                      'Showcase your work to attract couples. Upload photos and videos directly to your portfolio.',
                                  actionLabel: 'Upload First Media',
                                  onAction: () => _showUploadMediaSheet(context),
                                )
                              : RefreshIndicator(
                                  onRefresh: _fetchPortfolio,
                                  child: GridView.builder(
                                    padding: const EdgeInsets.all(16),
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 1.0,
                                    ),
                                    itemCount: _filteredItems.length,
                                    itemBuilder: (context, index) {
                                      final item = _filteredItems[index];
                                      final isVideo = item['type'] == 'video';
                                      final url = item['imageUrl']?.toString() ?? '';
                                      final thumbUrl = item['thumbnailUrl']?.toString() ?? '';
                                      final title = item['title']?.toString() ?? '';

                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            if (isVideo)
                                              PortfolioVideoThumbnail(
                                                videoUrl: url,
                                                title: title,
                                                thumbnailUrl: thumbUrl.isNotEmpty ? thumbUrl : null,
                                              )
                                            else
                                              GestureDetector(
                                                onTap: () => _showMediaDetail(item),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: AppColors.offWhite,
                                                    border: Border.all(
                                                      color: AppColors.primary.withValues(alpha: 0.12),
                                                    ),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: CachedImageView(
                                                    imageUrl: url,
                                                    fit: BoxFit.cover,
                                                    fallbackIcon: Icons.image_rounded,
                                                    iconColor: AppColors.gold,
                                                    backgroundColor: AppColors.cream,
                                                  ),
                                                ),
                                              ),

                                            // Quick delete badge (top-right)
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap: () => _confirmDelete(item),
                                                child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withValues(alpha: 0.6),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.delete_outline_rounded,
                                                    color: Colors.white,
                                                    size: 14,
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
                        ),
                      ],
                    ),
    );
  }
}
