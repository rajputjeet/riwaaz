import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';

abstract class Utils {
  static void showSnackBar(
    String? message, {
    bool isError = false,
    bool isSuccess = false,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (message == null || message.trim().isEmpty) return;

    final Color bgColor = isError
        ? AppColors.error
        : (isSuccess ? AppColors.success : AppColors.primary);

    final IconData iconData = isError
        ? Icons.error_outline_rounded
        : (isSuccess ? Icons.check_circle_rounded : Icons.info_outline_rounded);

    final String? resolvedTitle = title ?? (isError ? 'Error' : (isSuccess ? 'Success' : null));

    if (Get.context == null && Get.overlayContext == null) {
      debugPrint("SnackBar ($resolvedTitle): $message");
      return;
    }

    try {
      Get.closeAllSnackbars();
      Get.rawSnackbar(
        titleText: resolvedTitle != null
            ? Text(
                resolvedTitle,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
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
            fontWeight: FontWeight.w600,
            fontSize: 13,
            height: 1.35,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        backgroundColor: bgColor,
        borderRadius: 14,
        snackPosition: SnackPosition.TOP,
        snackStyle: SnackStyle.FLOATING,
        duration: duration,
        boxShadows: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        icon: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            iconData,
            color: AppColors.white,
            size: 20,
          ),
        ),
        shouldIconPulse: false,
      );
    } catch (_) {
      debugPrint("SnackBar ($resolvedTitle): $message");
    }
  }

  static void showSuccess(String? message, {String? title, Duration duration = const Duration(seconds: 3)}) {
    showSnackBar(message, isSuccess: true, title: title, duration: duration);
  }

  static void showError(String? message, {String? title, Duration duration = const Duration(seconds: 3)}) {
    showSnackBar(message, isError: true, title: title, duration: duration);
  }

  static void showInfo(String? message, {String? title, Duration duration = const Duration(seconds: 3)}) {
    showSnackBar(message, title: title, duration: duration);
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
