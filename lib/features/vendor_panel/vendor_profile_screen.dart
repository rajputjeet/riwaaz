import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/utils/app_animations.dart';
import '../../utils/helper/storage_helper.dart';
import '../auth/unified_login_screen.dart';
import 'vendor_packages_screen.dart';
import 'vendor_portfolio_screen.dart';
import 'vendor_subscription_plan_screen.dart';
import 'vendor_edit_profile_screen.dart';
import 'vendor_verification_screen.dart';

class VendorProfileScreen extends StatelessWidget {
  const VendorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.primary, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text(
          'Business Profile',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () {
              Navigator.of(context).push(
                FadeScaleRoute(
                  page: const VendorEditProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Vendor Profile Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.gold,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            AppImages.vendorRoyalClick,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              color: AppColors.primary,
                              child: const Icon(Icons.camera_alt,
                                  color: AppColors.white, size: 36),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified_rounded,
                              color: AppColors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${StorageHelper().getUserName()?.trim().isNotEmpty == true ? StorageHelper().getUserName()! : 'Your Business'} 👑',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Wedding Photography & Cinematography',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.star_rounded,
                              color: AppColors.gold, size: 18),
                          SizedBox(width: 4),
                          Text(
                            '4.9',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        '(84 reviews)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Verified Partner',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'BUSINESS MANAGEMENT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Profile Options Menu
            _buildMenuItem(
              icon: Icons.workspace_premium_rounded,
              iconColor: AppColors.goldDark,
              title: 'Vendor Membership Plans',
              subtitle: '6 Months Plan Active • 3, 6 & 12 Month Plans',
              onTap: () => Navigator.of(context).push(
                FadeScaleRoute(page: const VendorSubscriptionPlanScreen()),
              ),
            ),
            _buildMenuItem(
              icon: Icons.inventory_2_outlined,
              title: 'My Pricing Packages',
              subtitle: '3 active packages',
              onTap: () => Navigator.of(context).push(
                FadeScaleRoute(page: const VendorPackagesScreen()),
              ),
            ),
            _buildMenuItem(
              icon: Icons.photo_library_outlined,
              title: 'Portfolio & Media',
              subtitle: '12 photos, 4 videos',
              onTap: () => Navigator.of(context).push(
                FadeScaleRoute(page: const VendorPortfolioScreen()),
              ),
            ),
            _buildMenuItem(
              icon: Icons.handshake_outlined,
              title: 'In-Person Settlements',
              subtitle: 'Direct client payment • Zero platform deductions',
              onTap: () => _showDirectSettlementSheet(context),
            ),
            _buildMenuItem(
              icon: Icons.verified_user_outlined,
              title: 'Verification Status',
              subtitle: 'Documents approved ✓',
              onTap: () {
                Navigator.of(context).push(
                  FadeScaleRoute(
                    page: const VendorVerificationScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'LEGAL & POLICIES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
            const SizedBox(height: 10),

            _buildMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Vendor data protection & listing privacy',
              onTap: () => _showPrivacyPolicySheet(context),
            ),
            _buildMenuItem(
              icon: Icons.gavel_rounded,
              title: 'Terms & Conditions',
              subtitle: 'Partner agreement & direct settlement terms',
              onTap: () => _showTermsAndConditionsSheet(context),
            ),

            const SizedBox(height: 28),

            // ─── BOTTOM ACTIONS (LOGOUT & DELETE ACCOUNT) ───────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout_rounded,
                    color: AppColors.primary, size: 18),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
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

            const SizedBox(height: 12),

            Center(
              child: TextButton.icon(
                onPressed: () => _showDeleteAccountDialog(context),
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red, size: 16),
                label: const Text(
                  'Delete Account',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),

            const SizedBox(height: 8),
            Center(
              child: Text(
                'Riwaaz Vendor Partner v1.0.4 • Direct Celebrations Marketplace',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.grey.withValues(alpha: 0.8),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: const [
                      Icon(Icons.privacy_tip_rounded,
                          color: AppColors.primary, size: 24),
                      SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Vendor Privacy Policy',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, color: AppColors.darkGrey),
                ),
              ],
            ),
            const Text(
              'Last Updated: September 2026 • Riwaaz Partner Privacy',
              style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
            const Divider(height: 24),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildPolicySection(
                    icon: Icons.shield_rounded,
                    title: '1. Commitment to Partner Privacy',
                    content:
                        'Riwaaz values our vendor partners. We collect only necessary business data required to display your services, portfolio, and connect you with event hosts.',
                  ),
                  _buildPolicySection(
                    icon: Icons.storefront_rounded,
                    title: '2. Business Profile & Portfolio Assets',
                    content:
                        'We display your business details, portfolio photographs, videos, package pricing, and verified credentials to help potential clients discover and book your services.',
                  ),
                  _buildPolicySection(
                    icon: Icons.handshake_rounded,
                    title: '3. Direct In-Person Settlements & No Commission',
                    content:
                        'Riwaaz does not collect platform commissions from your event fees, nor do we process client booking funds. Clients settle 100% of agreed fees directly with you in person. We do not store your bank credentials.',
                  ),
                  _buildPolicySection(
                    icon: Icons.phone_forwarded_rounded,
                    title: '4. Direct Client Coordination via Call & WhatsApp',
                    content:
                        'The application does not support built-in chat. Once you accept an incoming booking request, the client\'s direct contact numbers (Call & WhatsApp) are unlocked so you can coordinate event logistics directly.',
                  ),
                  _buildPolicySection(
                    icon: Icons.lock_outline_rounded,
                    title: '5. Data Security & Storage',
                    content:
                        'All partner information and uploaded portfolio media are encrypted and stored securely. We never sell vendor partner contact numbers or business data to unauthorized third parties.',
                  ),
                  _buildPolicySection(
                    icon: Icons.delete_forever_rounded,
                    title: '6. Partner Rights & Account Deletion',
                    content:
                        'You maintain complete control over your business listing. You can update your packages anytime or permanently delete your vendor account and all portfolio data directly from your profile settings.',
                  ),
                  _buildPolicySection(
                    icon: Icons.contact_support_rounded,
                    title: '7. Partner Support & Grievances',
                    content:
                        'For inquiries regarding your listings, verification, or data privacy, contact our vendor relations team at partner-support@riwaazweddings.in.',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTermsAndConditionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: const [
                      Icon(Icons.gavel_rounded,
                          color: AppColors.primary, size: 24),
                      SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Vendor Terms & Conditions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, color: AppColors.darkGrey),
                ),
              ],
            ),
            const Text(
              'Last Updated: September 2026 • Partner Service Agreement',
              style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
            const Divider(height: 24),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildPolicySection(
                    icon: Icons.handshake_outlined,
                    title: '1. Vendor Partner Agreement',
                    content:
                        'By creating a vendor profile or purchasing a membership plan on Riwaaz, you agree to these Vendor Terms and Conditions and represent that you are an authorized representative of your business.',
                  ),
                  _buildPolicySection(
                    icon: Icons.verified_rounded,
                    title: '2. Profile & Media Authenticity',
                    content:
                        'Vendors agree to upload only original portfolio photos, genuine pricing packages, and accurate service descriptions. Misrepresentation may result in profile de-listing.',
                  ),
                  _buildPolicySection(
                    icon: Icons.payments_outlined,
                    title: '3. Direct In-Person Settlements & Zero Commission',
                    content:
                        'Riwaaz is an event discovery marketplace. All client bookings are contracted and paid directly between you and the client in person (cash, UPI, or bank transfer). Riwaaz does not deduct commission from your client payments.',
                  ),
                  _buildPolicySection(
                    icon: Icons.phone_forwarded_rounded,
                    title: '4. Direct Contact & Booking Fulfillment',
                    content:
                        'When you accept a client\'s booking request, direct Call & WhatsApp contact details are unlocked. Vendors agree to provide punctual, professional, and courteous service as agreed with the client.',
                  ),
                  _buildPolicySection(
                    icon: Icons.event_repeat_rounded,
                    title: '5. Rescheduling & Cancellation Terms',
                    content:
                        'Rescheduling, cancellation terms, and advance retainers are handled directly between you and the client according to your business policy. Riwaaz is not liable for client disputes or refunds.',
                  ),
                  _buildPolicySection(
                    icon: Icons.workspace_premium_rounded,
                    title: '6. Membership Plans & Subscriptions',
                    content:
                        'Vendor membership plans grant directory exposure, listing priority, and verified badge for the chosen duration (3, 6, or 12 months). Plans are non-refundable once activated.',
                  ),
                  _buildPolicySection(
                    icon: Icons.person_remove_rounded,
                    title: '7. Account Termination & Deletion',
                    content:
                        'Vendors may permanently terminate their account at any time. Upon deletion, your business profile, portfolio media, verified status, and booking history will be permanently erased.',
                  ),
                  _buildPolicySection(
                    icon: Icons.balance_rounded,
                    title: '8. Governing Law & Jurisdiction',
                    content:
                        'These terms are governed by the laws of India, subject to the jurisdiction of courts in Chandigarh.',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actionsOverflowButtonSpacing: 8,
        title: Row(
          children: const [
            Icon(Icons.logout_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Expanded(
              child: Text('Log Out', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of your vendor account? You can sign back in anytime.',
          style: TextStyle(fontSize: 14, color: AppColors.darkGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.darkGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                FadeScaleRoute(page: const UnifiedLoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actionsOverflowButtonSpacing: 8,
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Delete Account',
                style: TextStyle(fontWeight: FontWeight.w800, color: Colors.red),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action is irreversible. All your vendor data will be permanently erased:',
              style: TextStyle(fontSize: 13, color: AppColors.black),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('• Business profile, verified badge & reviews',
                      style: TextStyle(fontSize: 12, color: Colors.red)),
                  SizedBox(height: 4),
                  Text('• Portfolio photos, media & service packages',
                      style: TextStyle(fontSize: 12, color: Colors.red)),
                  SizedBox(height: 4),
                  Text('• Active vendor membership plan & remaining days',
                      style: TextStyle(fontSize: 12, color: Colors.red)),
                  SizedBox(height: 4),
                  Text('• Client booking records & incoming requests',
                      style: TextStyle(fontSize: 12, color: Colors.red)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Are you sure you want to permanently delete your vendor account?',
              style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Account',
                style: TextStyle(color: AppColors.darkGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Your vendor account has been deleted successfully.'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).pushAndRemoveUntil(
                FadeScaleRoute(page: const UnifiedLoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.darkGrey,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor ?? AppColors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: AppColors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: AppColors.grey),
      ),
    );
  }

  void _showDirectSettlementSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.handshake_rounded,
                      color: AppColors.success, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Direct In-Person Settlement',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        'Zero platform commissions or bank payout delays',
                        style: TextStyle(fontSize: 12, color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.grey.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Direct Settlement Policy:',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Direct Transactions: Customers pay you directly in cash, UPI, or bank transfer on the event day.',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGrey,
                        height: 1.4),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '• No Bank Payout Delays: Riwaaz does not hold escrow or bank payouts. 100% of the client payment belongs directly to you.',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGrey,
                        height: 1.4),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '• Zero Commissions: You keep 100% of your earnings.',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGrey,
                        height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Understood'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
