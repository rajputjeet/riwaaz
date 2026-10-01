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
  final List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  bool _isNoInternet = false;
  String? _errorMessage;
  int _selectedFilterIndex = 0; // 0 = All, 1 = Packages, 2 = Services

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  List<Map<String, dynamic>> get _filteredItems {
    if (_selectedFilterIndex == 1) {
      return _items.where((i) => i['type'] == 'package').toList();
    } else if (_selectedFilterIndex == 2) {
      return _items.where((i) => i['type'] == 'service').toList();
    }
    return _items;
  }

  int get _packageCount => _items.where((i) => i['type'] == 'package').length;
  int get _serviceCount => _items.where((i) => i['type'] == 'service').length;

  Future<void> _fetchPackages() async {
    setState(() {
      _isLoading = true;
      _isNoInternet = false;
      _errorMessage = null;
    });

    try {
      final List<Map<String, dynamic>> loaded = [];

      // 1. Try unified endpoint: GET /api/users/vendor/service-package/list
      final res = await _vendorApi.getServicePackageList();

      if (res.isSuccess == true && res.data != null && res.data!.isNotEmpty) {
        for (final p in res.data!) {
          if (p is Map) {
            final rawType = p['type']?.toString().toLowerCase() ?? 'package';
            final rawDesc = p['description']?.toString() ?? '';
            final features = (p['features'] as List?)?.map((e) => e.toString()).toList() ?? [];
            final description = rawDesc.isNotEmpty
                ? rawDesc
                : (features.isNotEmpty ? features.join(' • ') : '');
            final id = (p['_id'] ?? p['id'])?.toString() ?? '';
            final title = p['title']?.toString() ?? p['name']?.toString() ?? 'Offering';
            final price = p['price'];

            loaded.add({
              'id': id,
              'type': rawType == 'service' ? 'service' : 'package',
              'title': title,
              'name': title,
              'price': '₹${price?.toString() ?? '0'}',
              'priceNum': price is num ? price : num.tryParse(price?.toString() ?? '0') ?? 0,
              'description': description,
              'deliverables': description,
            });
          }
        }
      } else {
        // Fallback: Check profile packages
        final profileRes = await _userApi.getProfile();
        if (profileRes.isSuccess == true && profileRes.data != null) {
          final rawPkgs = profileRes.data!.vendorProfile?.packages;
          if (rawPkgs != null) {
            for (final p in rawPkgs) {
              if (p is Map) {
                final rawType = p['type']?.toString().toLowerCase() ?? 'package';
                final rawDesc = p['description']?.toString() ?? '';
                final features = (p['features'] as List?)?.map((e) => e.toString()).toList() ?? [];
                final description = rawDesc.isNotEmpty
                    ? rawDesc
                    : (features.isNotEmpty ? features.join(' • ') : '');
                final id = (p['_id'] ?? p['id'])?.toString() ?? '';
                final title = p['title']?.toString() ?? p['name']?.toString() ?? 'Offering';
                final price = p['price'];

                loaded.add({
                  'id': id,
                  'type': rawType == 'service' ? 'service' : 'package',
                  'title': title,
                  'name': title,
                  'price': '₹${price?.toString() ?? '0'}',
                  'priceNum': price is num ? price : num.tryParse(price?.toString() ?? '0') ?? 0,
                  'description': description,
                  'deliverables': description,
                });
              }
            }
          }
        } else if (res.isSuccess != true) {
          if (!mounted) return;
          setState(() {
            _errorMessage = res.message ?? 'Failed to load services & packages';
            _isLoading = false;
          });
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        _items.clear();
        _items.addAll(loaded);
        _isLoading = false;
      });
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

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    if (isError) {
      Utils.showError(message);
    } else {
      Utils.showSuccess(message);
    }
  }

  void _showAddEditPackageSheet({Map<String, dynamic>? itemToEdit}) {
    final isEditing = itemToEdit != null;
    String selectedType = isEditing
        ? (itemToEdit['type']?.toString().toLowerCase() == 'service' ? 'service' : 'package')
        : (_selectedFilterIndex == 2 ? 'service' : 'package');

    final titleCtrl = TextEditingController(
      text: isEditing ? (itemToEdit['title'] ?? itemToEdit['name'] ?? '') : '',
    );
    final priceCtrl = TextEditingController(
      text: isEditing
          ? (itemToEdit['priceNum']?.toString() ??
              itemToEdit['price']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '')
          : '',
    );
    final descCtrl = TextEditingController(
      text: isEditing
          ? (itemToEdit['description'] ?? itemToEdit['deliverables'] ?? '')
          : '',
    );

    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final isPackage = selectedType == 'package';

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.90,
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing
                                    ? (isPackage ? 'Edit Package Plan' : 'Edit Service')
                                    : (isPackage ? 'Create Package Plan' : 'Add Service'),
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                isPackage
                                    ? 'Bundle deliverables, days & coverage for couples'
                                    : 'Standalone offering or specialized add-on service',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.darkGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // ─── Offering Type Selector ──────────────────────────────
                    const Text(
                      'Offering Type',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        // Package Option
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setSheetState(() => selectedType = 'package');
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isPackage
                                    ? AppColors.primary.withValues(alpha: 0.08)
                                    : AppColors.offWhite,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isPackage
                                      ? AppColors.primary
                                      : AppColors.grey.withValues(alpha: 0.2),
                                  width: isPackage ? 1.8 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: isPackage
                                              ? AppColors.primary
                                              : AppColors.grey
                                                  .withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.inventory_2_rounded,
                                          size: 16,
                                          color: isPackage
                                              ? AppColors.white
                                              : AppColors.darkGrey,
                                        ),
                                      ),
                                      if (isPackage)
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          size: 18,
                                          color: AppColors.primary,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Package',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: isPackage
                                          ? AppColors.primary
                                          : AppColors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Multi-day or bundled plan',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: isPackage
                                          ? AppColors.primary
                                              .withValues(alpha: 0.8)
                                          : AppColors.darkGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Service Option
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setSheetState(() => selectedType = 'service');
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: !isPackage
                                    ? const Color(0xFF0D9488)
                                        .withValues(alpha: 0.08)
                                    : AppColors.offWhite,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: !isPackage
                                      ? const Color(0xFF0D9488)
                                      : AppColors.grey.withValues(alpha: 0.2),
                                  width: !isPackage ? 1.8 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: !isPackage
                                              ? const Color(0xFF0D9488)
                                              : AppColors.grey
                                                  .withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.auto_awesome_rounded,
                                          size: 16,
                                          color: !isPackage
                                              ? AppColors.white
                                              : AppColors.darkGrey,
                                        ),
                                      ),
                                      if (!isPackage)
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          size: 18,
                                          color: Color(0xFF0D9488),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Service',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: !isPackage
                                          ? const Color(0xFF0D9488)
                                          : AppColors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Standalone item or add-on',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: !isPackage
                                          ? const Color(0xFF0D9488)
                                              .withValues(alpha: 0.8)
                                          : AppColors.darkGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // 1. Title Field
                    Text(
                      isPackage ? 'Package Title *' : 'Service Title *',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        hintText: isPackage
                            ? 'e.g. Complete Cinematic Wedding Package'
                            : 'e.g. Pre-Wedding Drone Shoot',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 2. Price Field
                    Text(
                      isPackage ? 'Package Price (₹) *' : 'Service Price (₹) *',
                      style: const TextStyle(
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
                        hintText: isPackage ? 'e.g. 75000' : 'e.g. 15000',
                        prefixText: '₹ ',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 3. Description Field
                    Text(
                      isPackage
                          ? 'Package Deliverables & Description'
                          : 'Service Description & Details',
                      style: const TextStyle(
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
                        hintText: isPackage
                            ? 'e.g. Full coverage of Haldi, Sangeet & Reception with candid photography, drone teasers & luxury album.'
                            : 'e.g. 4K cinematic drone shoot at scenic outdoor locations with edited teaser.',
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
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final title = titleCtrl.text.trim();
                                final priceStr = priceCtrl.text.trim();
                                final desc = descCtrl.text.trim();

                                if (title.isEmpty || priceStr.isEmpty) {
                                  _showFeedback(
                                      'Please enter ${isPackage ? 'package' : 'service'} title and price',
                                      isError: true);
                                  return;
                                }

                                final priceNum = int.tryParse(
                                        priceStr.replaceAll(RegExp(r'[^0-9]'), '')) ??
                                    0;

                                // 4 Core Required/Payload Fields according to Section 18:
                                // title (String), type (String: 'package'|'service'), description (String), price (Number)
                                final body = {
                                  'title': title,
                                  'type': selectedType,
                                  'price': priceNum,
                                  'description': desc,
                                };

                                setSheetState(() => isSubmitting = true);

                                try {
                                  final res = isEditing
                                      ? await _vendorApi.editServicePackage(
                                          itemToEdit['id'] ?? '', body)
                                      : await _vendorApi.addServicePackage(body);

                                  if (!mounted) return;
                                  if (res.isSuccess == true) {
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    final successMsg = res.message?.isNotEmpty == true
                                        ? res.message!
                                        : (isEditing
                                            ? '${isPackage ? 'Package' : 'Service'} "$title" updated!'
                                            : '${isPackage ? 'Package' : 'Service'} "$title" published!');
                                    _showFeedback(successMsg);
                                    _fetchPackages();
                                  } else {
                                    setSheetState(() => isSubmitting = false);
                                    _showFeedback(
                                        res.message ?? 'Operation failed',
                                        isError: true);
                                  }
                                } catch (e) {
                                  if (!mounted) return;
                                  setSheetState(() => isSubmitting = false);
                                  _showFeedback('Network error: $e', isError: true);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPackage
                              ? AppColors.primary
                              : const Color(0xFF0D9488),
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: AppColors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded,
                                      size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    isEditing
                                        ? 'Update ${isPackage ? 'Package' : 'Service'}'
                                        : 'Publish ${isPackage ? 'Package' : 'Service'}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
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
  }

  void _confirmDeleteItem(Map<String, dynamic> item) {
    final isPackage = item['type'] == 'package';
    final name = item['title'] ?? item['name'] ?? (isPackage ? 'Package' : 'Service');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete ${isPackage ? 'Package' : 'Service'}?',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Are you sure you want to remove "$name"? Clients will no longer see this offering on your profile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.darkGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final itemId = item['id']?.toString() ?? '';
              if (itemId.isNotEmpty) {
                final res = await _vendorApi.deleteServicePackage(itemId);
                if (!mounted) return;
                if (res.isSuccess == true) {
                  _showFeedback('Deleted successfully');
                  _fetchPackages();
                } else {
                  _showFeedback(res.message ?? 'Failed to delete', isError: true);
                }
              } else {
                setState(() => _items.remove(item));
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'All', 'count': _items.length},
      {'label': 'Packages', 'count': _packageCount},
      {'label': 'Services', 'count': _serviceCount},
    ];

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          final item = filters[index];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                '${item['label']} (${item['count']})',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.white : AppColors.darkGrey,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.offWhite,
              showCheckmark: false,
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.grey.withValues(alpha: 0.2),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onSelected: (_) {
                setState(() => _selectedFilterIndex = index);
              },
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

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
          'My Packages & Services',
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
          ? const AppLoadingState(message: 'Loading offerings...')
          : _isNoInternet
              ? AppNoInternetState(onRetry: _fetchPackages)
              : _errorMessage != null
                  ? AppErrorState(
                      message: _errorMessage!, onRetry: _fetchPackages)
                  : Column(
                      children: [
                        if (_items.isNotEmpty) _buildFilterChips(),
                        Expanded(
                          child: filtered.isEmpty
                              ? AppEmptyState(
                                  icon: _selectedFilterIndex == 2
                                      ? Icons.auto_awesome_outlined
                                      : Icons.inventory_2_outlined,
                                  title: _selectedFilterIndex == 1
                                      ? 'No Packages Added'
                                      : _selectedFilterIndex == 2
                                          ? 'No Services Added'
                                          : 'No Packages or Services Yet',
                                  subtitle: _selectedFilterIndex == 1
                                      ? 'Create bundled packages to offer complete event coverage to couples.'
                                      : _selectedFilterIndex == 2
                                          ? 'Add standalone services like drone shoot, pre-wedding, or bridal styling.'
                                          : 'Create pricing packages and services to attract wedding clients. They will appear on your public profile.',
                                  actionLabel: _selectedFilterIndex == 2
                                      ? 'Add First Service'
                                      : 'Add First Package',
                                  onAction: () => _showAddEditPackageSheet(
                                    itemToEdit: null,
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _fetchPackages,
                                  child: ListView.separated(
                                    padding: const EdgeInsets.all(16),
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: filtered.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 14),
                                    itemBuilder: (context, index) {
                                      final item = filtered[index];
                                      final isPackage =
                                          item['type'] == 'package';
                                      final desc = (item['description'] ??
                                              item['deliverables'] ??
                                              '')
                                          .toString();

                                      return Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isPackage
                                                ? AppColors.primary
                                                    .withValues(alpha: 0.16)
                                                : const Color(0xFF0D9488)
                                                    .withValues(alpha: 0.16),
                                            width: 1.2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (isPackage
                                                      ? AppColors.primary
                                                      : const Color(0xFF0D9488))
                                                  .withValues(alpha: 0.05),
                                              blurRadius: 10,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Top Row: Type Badge + Actions
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                // Badge
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 3.5),
                                                  decoration: BoxDecoration(
                                                    color: isPackage
                                                        ? AppColors.primary
                                                            .withValues(
                                                                alpha: 0.1)
                                                        : const Color(0xFF0D9488)
                                                            .withValues(
                                                                alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        isPackage
                                                            ? Icons
                                                                .inventory_2_rounded
                                                            : Icons
                                                                .auto_awesome_rounded,
                                                        size: 11.5,
                                                        color: isPackage
                                                            ? AppColors.primary
                                                            : const Color(
                                                                0xFF0D9488),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        isPackage
                                                            ? 'PACKAGE'
                                                            : 'SERVICE',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color: isPackage
                                                              ? AppColors.primary
                                                              : const Color(
                                                                  0xFF0D9488),
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.edit_outlined,
                                                          color: AppColors
                                                              .darkGrey,
                                                          size: 20),
                                                      onPressed: () =>
                                                          _showAddEditPackageSheet(
                                                        itemToEdit: item,
                                                      ),
                                                      constraints:
                                                          const BoxConstraints(),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons
                                                              .delete_outline_rounded,
                                                          color: AppColors.error,
                                                          size: 20),
                                                      onPressed: () =>
                                                          _confirmDeleteItem(
                                                              item),
                                                      constraints:
                                                          const BoxConstraints(),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),

                                            // Title
                                            Text(
                                              item['title'] ?? item['name'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 6),

                                            // Price
                                            Text(
                                              item['price'] ?? '',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w900,
                                                color: isPackage
                                                    ? AppColors.primary
                                                    : const Color(0xFF0D9488),
                                              ),
                                            ),

                                            // Description
                                            if (desc.isNotEmpty) ...[
                                              const SizedBox(height: 10),
                                              Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: AppColors.offWhite,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  desc,
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
                        ),
                      ],
                    ),
      bottomNavigationBar: Container(
        color: AppColors.white,
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => _showAddEditPackageSheet(),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text(
              'Add Service or Package',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
      ),
    );
  }
}
