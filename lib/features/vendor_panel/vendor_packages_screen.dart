import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/api_provider/user_api_provider.dart';
import '../../data/api_provider/vendor_api_provider.dart';
import '../../shared/widgets/app_states.dart';
import '../../utils/utils.dart';

class VendorPackagesScreen extends StatefulWidget {
  const VendorPackagesScreen({super.key});

  @override
  State<VendorPackagesScreen> createState() => _VendorPackagesScreenState();
}

class _VendorPackagesScreenState extends State<VendorPackagesScreen> {
  final _userApi = UserApiProvider();
  final _vendorApi = VendorApiProvider();
  final List<Map<String, dynamic>> _packages = [];
  bool _isLoading = true;
  bool _isNoInternet = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    setState(() {
      _isLoading = true;
      _isNoInternet = false;
      _errorMessage = null;
    });

    try {
      final res = await _userApi.getProfile();
      if (!mounted) return;
      if (res.isSuccess == true && res.data != null) {
        final rawPkgs = res.data!.vendorProfile?.packages;
        final List<Map<String, dynamic>> loaded = [];
        if (rawPkgs != null) {
          for (final p in rawPkgs) {
            if (p is Map) {
              final rawDesc = p['description']?.toString() ?? '';
              final features = (p['features'] as List?)?.map((e) => e.toString()).toList() ?? [];
              final description = rawDesc.isNotEmpty
                  ? rawDesc
                  : (features.isNotEmpty ? features.join(' • ') : '');
              loaded.add({
                'id': (p['_id'] ?? p['id'])?.toString() ?? '',
                'title': p['title']?.toString() ?? p['name']?.toString() ?? 'Package Plan',
                'name': p['title']?.toString() ?? p['name']?.toString() ?? 'Package Plan',
                'price': '₹${p['price']?.toString() ?? '0'}',
                'priceNum': p['price'],
                'description': description,
                'deliverables': description,
              });
            }
          }
        }
        setState(() {
          _packages.clear();
          _packages.addAll(loaded);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = res.message ?? 'Failed to load packages';
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
          _errorMessage = 'Could not load packages. Please check connection.';
        }
        _isLoading = false;
      });
    }
  }

  void _showAddEditPackageSheet({int? editIndex}) {
    final isEditing = editIndex != null;
    final titleCtrl = TextEditingController(
      text: isEditing
          ? (_packages[editIndex]['title'] ?? _packages[editIndex]['name'] ?? '')
          : '',
    );
    final priceCtrl = TextEditingController(
      text: isEditing
          ? (_packages[editIndex]['priceNum']?.toString() ??
              _packages[editIndex]['price']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '')
          : '',
    );
    final descCtrl = TextEditingController(
      text: isEditing
          ? (_packages[editIndex]['description'] ?? _packages[editIndex]['deliverables'] ?? '')
          : '',
    );

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
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                            isEditing
                                ? 'Edit Package Plan'
                                : 'Create Package Plan',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Text(
                            'Define pricing, deliverables and perks for couples',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.darkGrey,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // 1. Package Title
                  const Text(
                    'Package Title',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. Royal Diamond Plan',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. Package Price
                  const Text(
                    'Package Price (₹)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g. 65000',
                      prefixText: '₹ ',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. Package Description
                  const Text(
                    'Package Description',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          'e.g. 4K Drone Shoot • Cinematic 3-Min Teaser • 2 Candid Photographers • Luxury Hardbound Album',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Save / Publish Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final title = titleCtrl.text.trim();
                        final priceStr = priceCtrl.text.trim();
                        final desc = descCtrl.text.trim();

                        if (title.isEmpty || priceStr.isEmpty) {
                          Utils.showError('Please enter package title & price');
                          return;
                        }

                        final priceNum = int.tryParse(priceStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

                        final features = desc.contains('•')
                            ? desc
                                .split('•')
                                .map((s) => s.trim())
                                .where((s) => s.isNotEmpty)
                                .toList()
                            : (desc.isNotEmpty ? [desc] : <String>[]);

                        final body = {
                          'title': title,
                          'price': priceNum,
                          'description': desc,
                          'features': features,
                        };

                        Navigator.pop(ctx);
                        Utils.showInfo(isEditing ? 'Updating package...' : 'Publishing package...');

                        try {
                          final res = isEditing
                              ? await _vendorApi.editPackage(_packages[editIndex]['id'] ?? '', body)
                              : await _vendorApi.addPackage(body);

                          if (!mounted) return;
                          if (res.isSuccess == true) {
                            Utils.showSuccess(isEditing
                                ? 'Package "$title" updated!'
                                : 'Package "$title" published!');
                            _fetchPackages();
                          } else {
                            Utils.showError(res.message ?? 'Operation failed');
                          }
                        } catch (e) {
                          if (!mounted) return;
                          Utils.showError('Network error: $e');
                        }
                      },
                      icon: const Icon(Icons.check_circle_outline_rounded,
                          size: 18),
                      label: Text(
                        isEditing
                            ? 'Update Package Plan'
                            : 'Publish Package Plan',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
          'My Packages & Plans',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.primary, size: 26),
            onPressed: () => _showAddEditPackageSheet(),
          ),
        ],
      ),
      body: _isLoading
          ? const AppLoadingState(message: 'Loading your packages...')
          : _isNoInternet
              ? AppNoInternetState(onRetry: _fetchPackages)
              : _errorMessage != null
                  ? AppErrorState(message: _errorMessage!, onRetry: _fetchPackages)
                  : _packages.isEmpty
                      ? AppEmptyState(
                          icon: Icons.inventory_2_outlined,
                          title: 'No Packages Created Yet',
                          subtitle:
                              'Create pricing packages to attract wedding clients. Packages will appear directly on your public profile.',
                          actionLabel: 'Create First Package',
                          onAction: () => _showAddEditPackageSheet(),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchPackages,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _packages.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final pkg = _packages[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.16),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            pkg['name'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.black,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined,
                                                  color: AppColors.darkGrey, size: 20),
                                              onPressed: () => _showAddEditPackageSheet(
                                                  editIndex: index),
                                              constraints: const BoxConstraints(),
                                              padding: const EdgeInsets.all(4),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.delete_outline_rounded,
                                                  color: AppColors.error,
                                                  size: 20),
                                              onPressed: () async {
                                                final pkgId = pkg['id']?.toString() ?? '';
                                                if (pkgId.isNotEmpty) {
                                                  final res = await _vendorApi.deletePackage(pkgId);
                                                  if (!context.mounted) return;
                                                  if (res.isSuccess == true) {
                                                    Utils.showSuccess('Package removed');
                                                    _fetchPackages();
                                                  } else {
                                                    Utils.showError(res.message ?? 'Failed to delete package');
                                                  }
                                                } else {
                                                  setState(() => _packages.removeAt(index));
                                                }
                                              },
                                              constraints: const BoxConstraints(),
                                              padding: const EdgeInsets.all(4),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      pkg['price'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    if ((pkg['description'] ?? pkg['deliverables'] ?? '').toString().isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.offWhite,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          pkg['description'] ?? pkg['deliverables'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: AppColors.darkGrey,
                                            height: 1.45,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
      bottomNavigationBar: Container(
        color: AppColors.white,
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => _showAddEditPackageSheet(),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Another Package Plan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
