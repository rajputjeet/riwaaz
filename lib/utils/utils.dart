import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';

abstract class Utils {
  static void showSnackBar(
    String? message, {
    bool isError = false,
    String? title,
  }) {
    if (message == null || message.trim().isEmpty) return;

    if (Get.context == null && Get.overlayContext == null) {
      debugPrint("SnackBar: $message");
      return;
    }

    try {
      Get.closeAllSnackbars();
      Get.rawSnackbar(
        titleText: title != null
            ? Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              )
            : null,
        messageText: Text(
          message,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w500,
            fontSize: 13,
            height: 1.35,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        borderRadius: 10,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        icon: Icon(
          isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
          color: AppColors.white,
          size: 22,
        ),
      );
    } catch (_) {
      // Fallback if GetContext not ready
      debugPrint("SnackBar: $message");
    }
  }

  static void showLoader({String message = 'Please wait...'}) {
    if (Get.context == null && Get.overlayContext == null) return;
    try {
      if (Get.isDialogOpen == true) return;
      Get.dialog(
        PopScope(
          canPop: false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } catch (_) {}
  }

  static void hideLoader() {
    try {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    } catch (_) {}
  }

  static String capsF(String? text) {
    if (text == null || text.isEmpty) return "";
    return "${text[0].toUpperCase()}${text.substring(1)}";
  }
}
