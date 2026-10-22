import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppConfirmationDialog extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String title;
  final String? message;
  final Widget? customContent;
  final String confirmLabel;
  final String cancelLabel;
  final Color? confirmColor;
  final bool isDestructive;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const AppConfirmationDialog({
    super.key,
    required this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    required this.title,
    this.message,
    this.customContent,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.confirmColor,
    this.isDestructive = false,
    required this.onConfirm,
    this.onCancel,
  });

  static Future<bool?> show({
    required BuildContext context,
    required IconData icon,
    Color? iconColor,
    Color? iconBackgroundColor,
    required String title,
    String? message,
    Widget? customContent,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    Color? confirmColor,
    bool isDestructive = false,
    FutureOr<void> Function()? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AppConfirmationDialog(
        icon: icon,
        iconColor: iconColor,
        iconBackgroundColor: iconBackgroundColor,
        title: title,
        message: message,
        customContent: customContent,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmColor: confirmColor,
        isDestructive: isDestructive,
        onConfirm: () async {
          Navigator.of(ctx).pop(true);
          if (onConfirm != null) {
            await onConfirm();
          }
        },
        onCancel: () {
          Navigator.of(ctx).pop(false);
          if (onCancel != null) {
            onCancel();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ??
        (isDestructive ? AppColors.error : AppColors.primary);
    final effectiveIconBg = iconBackgroundColor ??
        effectiveIconColor.withValues(alpha: 0.1);
    final effectiveConfirmColor = confirmColor ??
        (isDestructive ? AppColors.error : AppColors.primary);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top circular icon badge
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: effectiveIconBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18.5,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
                letterSpacing: -0.3,
              ),
            ),

            // Optional subtitle / message
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.darkGrey,
                  height: 1.45,
                ),
              ),
            ],

            // Optional custom content (e.g. details card / bullet points)
            if (customContent != null) ...[
              const SizedBox(height: 14),
              customContent!,
            ],

            const SizedBox(height: 22),

            // Action buttons row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel ?? () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: AppColors.grey.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: AppColors.offWhite,
                    ),
                    child: Text(
                      cancelLabel,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: effectiveConfirmColor,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
