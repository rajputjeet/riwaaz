import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../utils/helper/storage_helper.dart';
import '../vendor_registration/controllers/vendor_registration_controller.dart';

class VendorVerificationScreen extends StatefulWidget {
  const VendorVerificationScreen({super.key});

  @override
  State<VendorVerificationScreen> createState() =>
      _VendorVerificationScreenState();
}

class _VendorVerificationScreenState extends State<VendorVerificationScreen> {
  late final VendorRegistrationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<VendorRegistrationController>()
        ? Get.find<VendorRegistrationController>()
        : Get.put(VendorRegistrationController());
    _controller.fetchApplicationStatus();
  }

  @override
  Widget build(BuildContext context) {
    final storage = StorageHelper();
    final businessName = storage.getUserName()?.trim();

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
          'Verification Status',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => _controller.fetchApplicationStatus(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Gold Verification Badge Hero Card
              Obx(() {
                final liveAppId = _controller.applicationData.value?.applicationId;
                final savedId = storage.getApplicationId();
                final appId = (liveAppId != null && liveAppId.trim().isNotEmpty)
                    ? liveAppId.trim()
                    : ((savedId != null && savedId.trim().isNotEmpty && savedId != 'RWZ-2026-8841')
                        ? savedId.trim()
                        : 'IN VERIFICATION');

                final appStatus = _controller.currentStatus.value;
                final isVerified = _controller.isVerified.value;
                final isApproved = isVerified || appStatus == 'Approved' || appStatus == 'Active';
                final isRejected = appStatus == 'Rejected';

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF6B1D28)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold, width: 2),
                        ),
                        child: Icon(
                          isApproved
                              ? Icons.verified_rounded
                              : (isRejected
                                  ? Icons.cancel_rounded
                                  : Icons.hourglass_top_rounded),
                          color: AppColors.gold,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isApproved
                            ? '100% Verified Partner'
                            : (isRejected
                                ? 'Application Declined'
                                : 'Application Under Review'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(businessName != null && businessName.isNotEmpty) ? businessName : 'Partner'} • Partner ID: $appId',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.cream,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isApproved
                              ? AppColors.success
                              : (isRejected ? AppColors.error : AppColors.warning),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isApproved
                              ? 'STATUS: ACTIVE & TRUSTED'
                              : 'STATUS: ${appStatus.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 20),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'VERIFIED CREDENTIALS & AUDIT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.darkGrey,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Doc cards — status badge strictly reflects live server approval status
              Obx(() {
                final appStatus = _controller.currentStatus.value;
                final isVerified = _controller.isVerified.value;
                final isApproved =
                    isVerified || appStatus == 'Approved' || appStatus == 'Active';
                final isRejected = appStatus == 'Rejected';

                return Column(
                  children: [
                    _buildDocCard(
                      icon: Icons.badge_outlined,
                      title: 'Government Identity Proof',
                      subtitle: 'Aadhaar & PAN card of registered owner',
                      idNumber: isApproved ? 'UIDAI-VERIFIED' : 'KYC-PENDING',
                      isApproved: isApproved,
                      isRejected: isRejected,
                      date: isApproved
                          ? 'Verified by Admin'
                          : (isRejected
                              ? 'Requires re-upload'
                              : 'Under admin review'),
                    ),
                    _buildDocCard(
                      icon: Icons.receipt_long_outlined,
                      title: 'Business Registration & Tax',
                      subtitle: 'GSTIN / MSME trade certification',
                      idNumber: isApproved ? 'REG-VERIFIED' : 'TAX-PENDING',
                      isApproved: isApproved,
                      isRejected: isRejected,
                      date: isApproved
                          ? 'Valid Partner Listing'
                          : (isRejected
                              ? 'Verification declined'
                              : 'Pending document audit'),
                    ),
                    _buildDocCard(
                      icon: Icons.handshake_outlined,
                      title: 'Direct Settlement Agreement',
                      subtitle:
                          'Pay In Person policy & zero platform commission',
                      idNumber: isApproved
                          ? 'DIRECT-ACTIVE'
                          : 'AGREEMENT-PENDING',
                      isApproved: isApproved,
                      isRejected: isRejected,
                      date: isApproved
                          ? 'Signed & active'
                          : (isRejected ? 'Declined' : 'Pending activation'),
                    ),
                    _buildDocCard(
                      icon: Icons.camera_enhance_outlined,
                      title: 'Studio Gear & Deliverables Audit',
                      subtitle:
                          'Professional photography & cinema equipment check',
                      idNumber:
                          isApproved ? 'GEAR-AUDIT-PASS' : 'AUDIT-PENDING',
                      isApproved: isApproved,
                      isRejected: isRejected,
                      date: isApproved
                          ? 'Audited by Widoora QA'
                          : (isRejected ? 'Audit failed' : 'Audit in queue'),
                    ),
                  ],
                );
              }),

            const SizedBox(height: 20),

            // Benefits Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Partner Verification Perks:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Verified Gold badge displayed on search cards\n'
                    '• Priority ranking in Chandigarh and Punjab regional filters\n'
                    '• 100% Direct in-person client payments with zero platform commission\n'
                    '• Instant client connection with direct Call & WhatsApp unlocked on acceptance',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.darkGrey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildDocCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String idNumber,
    required bool isApproved,
    bool isRejected = false,
    required String date,
  }) {
    final statusText = isApproved
        ? 'Approved ✓'
        : (isRejected ? 'Rejected ✗' : 'Pending');
    final statusBg = isApproved
        ? AppColors.successLight
        : (isRejected
            ? AppColors.error.withValues(alpha: 0.12)
            : const Color(0xFFFEF3C7));
    final statusColor = isApproved
        ? AppColors.success
        : (isRejected ? AppColors.error : const Color(0xFFD97706));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Ref: $idNumber',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
