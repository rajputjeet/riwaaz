import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class VendorPackagesScreen extends StatefulWidget {
  const VendorPackagesScreen({super.key});

  @override
  State<VendorPackagesScreen> createState() => _VendorPackagesScreenState();
}

class _VendorPackagesScreenState extends State<VendorPackagesScreen> {
  final List<Map<String, dynamic>> _packages = [
    {
      'name': 'Basic Silver Plan',
      'price': '₹25,000',
      'deliverables':
          '1 Traditional Photographer • 10 Edited Photos • 1 Printed Album (20 pages)',
      'isActive': true,
      'bookingsCount': 8,
      'duration': 'Single Event (4-6 Hours)',
    },
    {
      'name': 'Standard Gold Plan',
      'price': '₹45,000',
      'deliverables':
          '2 Photographers • 1 Cinematic Videographer • Luxury Album • 25 High-Res Edited Photos',
      'isActive': true,
      'bookingsCount': 14,
      'duration': 'Full Day (8-10 Hours)',
    },
    {
      'name': 'Royal Diamond Platinum Plan',
      'price': '₹75,000',
      'deliverables':
          'Full Crew • 4K Drone Shoot • Cinematic Teaser • 2 Luxury Albums • Raw Footage Drive • Pre-Wedding',
      'isActive': true,
      'bookingsCount': 5,
      'duration': 'Multi-Day (2 Days Coverage)',
    },
  ];

  final List<String> _planPresets = [
    'Basic Silver Plan',
    'Standard Gold Plan',
    'Royal Diamond Plan',
    'Grand Destination Plan',
    'Pre-Wedding Special Plan',
  ];

  final List<String> _quickPrices = [
    '₹25,000',
    '₹45,000',
    '₹65,000',
    '₹85,000',
    '₹1,20,000',
  ];

  final List<String> _availableInclusions = [
    '4K Drone Shoot',
    'Cinematic 3-Min Teaser',
    'Traditional Video Coverage',
    '2 Candid Photographers',
    'Luxury Hardbound Album',
    'Pre-Wedding Studio Shoot',
    'Raw Footage USB Drive',
    'Live YouTube/Facebook Streaming',
    'Instant Digital Preview (24 Hrs)',
  ];

  void _showAddEditPackageSheet({int? editIndex}) {
    final isEditing = editIndex != null;
    final nameCtrl = TextEditingController(
      text: isEditing ? _packages[editIndex]['name'] : 'Royal Diamond Plan',
    );
    final priceCtrl = TextEditingController(
      text: isEditing ? _packages[editIndex]['price'] : '₹65,000',
    );
    final durationCtrl = TextEditingController(
      text: isEditing
          ? (_packages[editIndex]['duration'] ?? 'Full Day Coverage')
          : 'Full Day (8-10 Hours)',
    );

    final selectedInclusions = <String>{
      if (!isEditing) ...[
        '4K Drone Shoot',
        'Cinematic 3-Min Teaser',
        '2 Candid Photographers',
        'Luxury Hardbound Album',
      ] else if (_packages[editIndex]['deliverables'] != null)
        ...(_packages[editIndex]['deliverables'] as String)
            .split('•')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty),
    };

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

                  // Quick Presets
                  const Text(
                    'Choose Template / Preset',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _planPresets.map((preset) {
                        final isSelected = nameCtrl.text == preset;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(preset),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            backgroundColor: AppColors.offWhite,
                            onSelected: (_) {
                              setSheetState(() {
                                nameCtrl.text = preset;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Plan Name
                  const Text(
                    'Package Name',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. Royal Diamond Plan',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Price Field
                  const Text(
                    'Package Price (₹)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: priceCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. ₹65,000',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _quickPrices.map((qp) {
                      return ActionChip(
                        label: Text(qp),
                        backgroundColor: AppColors.offWhite,
                        labelStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                        onPressed: () {
                          setSheetState(() {
                            priceCtrl.text = qp;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 14),

                  // Duration
                  const Text(
                    'Service Duration',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: durationCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. Full Day (8-10 Hours)',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Deliverables Checkbox Grid
                  const Text(
                    'Select Deliverables / Inclusions',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableInclusions.map((inclusion) {
                      final hasIt = selectedInclusions.contains(inclusion);
                      return FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasIt
                                  ? Icons.check_circle_rounded
                                  : Icons.add_circle_outline_rounded,
                              size: 14,
                              color:
                                  hasIt ? AppColors.white : AppColors.darkGrey,
                            ),
                            const SizedBox(width: 4),
                            Text(inclusion),
                          ],
                        ),
                        selected: hasIt,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.offWhite,
                        labelStyle: TextStyle(
                          color: hasIt ? AppColors.white : AppColors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (selected) {
                          setSheetState(() {
                            if (selected) {
                              selectedInclusions.add(inclusion);
                            } else {
                              selectedInclusions.remove(inclusion);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Save / Publish Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty ||
                            priceCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter package name & price'),
                            ),
                          );
                          return;
                        }

                        final deliverableStr = selectedInclusions.isNotEmpty
                            ? selectedInclusions.join(' • ')
                            : 'Standard deliverables included with customized coverage.';

                        setState(() {
                          final item = {
                            'name': nameCtrl.text.trim(),
                            'price': priceCtrl.text.trim().startsWith('₹')
                                ? priceCtrl.text.trim()
                                : '₹${priceCtrl.text.trim()}',
                            'deliverables': deliverableStr,
                            'isActive': true,
                            'bookingsCount': 0,
                            'duration': durationCtrl.text.trim().isNotEmpty
                                ? durationCtrl.text.trim()
                                : 'Full Day Coverage',
                          };

                          if (isEditing) {
                            _packages[editIndex] = item;
                          } else {
                            _packages.add(item);
                          }
                        });

                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEditing
                                  ? 'Package "${nameCtrl.text}" updated!'
                                  : 'New package "${nameCtrl.text}" published to your profile!',
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
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
      body: _packages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined,
                      size: 64, color: AppColors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No Packages Created Yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Create pricing packages to attract wedding clients',
                    style: TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _packages.addAll([
                              {
                                'name': 'Basic Silver Plan',
                                'price': '₹25,000',
                                'deliverables':
                                    '1 Traditional Photographer • 10 Edited Photos • 1 Printed Album (20 pages)',
                                'isActive': true,
                                'bookingsCount': 8,
                                'duration': 'Single Event (4-6 Hours)',
                              },
                              {
                                'name': 'Standard Gold Plan',
                                'price': '₹45,000',
                                'deliverables':
                                    '2 Photographers • 1 Cinematic Videographer • Luxury Album • 25 High-Res Edited Photos',
                                'isActive': true,
                                'bookingsCount': 14,
                                'duration': 'Full Day (8-10 Hours)',
                              },
                              {
                                'name': 'Royal Diamond Platinum Plan',
                                'price': '₹75,000',
                                'deliverables':
                                    'Full Crew • 4K Drone Shoot • Cinematic Teaser • 2 Luxury Albums • Raw Footage Drive • Pre-Wedding',
                                'isActive': true,
                                'bookingsCount': 5,
                                'duration': 'Multi-Day (2 Days Coverage)',
                              },
                            ]);
                          });
                        },
                        icon: const Icon(Icons.auto_awesome_rounded),
                        label: const Text('Load Demo Packages'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () => _showAddEditPackageSheet(),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Custom'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1.2,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _packages.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
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
                                onPressed: () {
                                  setState(() => _packages.removeAt(index));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Package removed'),
                                    ),
                                  );
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
                        pkg['price'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '⏱ Duration: ${pkg['duration'] ?? "Full Event Coverage"}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.darkGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.offWhite,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          pkg['deliverables'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.darkGrey,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
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
