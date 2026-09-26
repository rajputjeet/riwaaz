import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../utils/helper/storage_helper.dart';

class VendorVerificationScreen extends StatelessWidget {
  const VendorVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = StorageHelper();
    final businessName = storage.getUserName()?.trim();
    final appId = storage.getApplicationId() ?? 'RWZ-2026-8841';
    final appStatus = storage.getApplicationStatus() ?? 'Active';
    final isVerified = storage.getIsVerified();

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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Gold Verification Badge Hero Card
            Container(
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
                    child: const Icon(Icons.verified_rounded,
                        color: AppColors.gold, size: 40),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isVerified || appStatus == 'Approved'
                        ? '100% Verified Partner'
                        : 'Application Under Review',
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
                      color: isVerified || appStatus == 'Approved'
                          ? AppColors.success
                          : AppColors.warning,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isVerified || appStatus == 'Approved'
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
            ),

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

            _buildDocCard(
              icon: Icons.badge_outlined,
              title: 'Government Identity Proof',
              subtitle: 'Aadhaar & PAN card of registered owner',
              idNumber: 'UIDAI-XXXX-4921',
              status: 'Approved ✓',
              date: 'Verified on 15 Jan 2026',
            ),

            _buildDocCard(
              icon: Icons.receipt_long_outlined,
              title: 'Business Registration & Tax',
              subtitle: 'GSTIN / MSME trade certification',
              idNumber: '04AABCR8841M1Z5',
              status: 'Approved ✓',
              date: 'Valid till 31 Mar 2027',
            ),

            _buildDocCard(
              icon: Icons.handshake_outlined,
              title: 'Direct Settlement Agreement',
              subtitle: 'Pay In Person policy & zero platform commission',
              idNumber: 'DIRECT-AGR-2026',
              status: 'Certified ✓',
              date: 'Signed & active',
            ),

            _buildDocCard(
              icon: Icons.camera_enhance_outlined,
              title: 'Studio Gear & Deliverables Audit',
              subtitle: '4K Cinema cameras, prime lenses, gimbal gear',
              idNumber: 'GEAR-AUDIT-PASS',
              status: 'Approved ✓',
              date: 'Verified by Riwaaz QA',
            ),

            _buildDocCard(
              icon: Icons.star_half_rounded,
              title: 'Client Trust & Review History',
              subtitle: '4.9 ★ rating across 84 completed weddings',
              idNumber: 'TRUST-TIER-TOP',
              status: 'Top Rated ✓',
              date: 'Updated daily',
            ),

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
                    '• Verified Gold Crown 👑 badge displayed on search cards\n'
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

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Verification documents are up to date!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.refresh_rounded,
                    color: AppColors.primary, size: 18),
                label: const Text(
                  'Request Document Re-audit',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDocCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String idNumber,
    required String status,
    required String date,
  }) {
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
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
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
