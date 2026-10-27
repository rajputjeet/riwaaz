import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'data/injector.dart';
import 'controllers/category_controller.dart';
import 'core/constants/app_colors.dart';
import 'core/services/booking_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/login_screen.dart';
import 'features/splash/splash_screen.dart';
import 'utils/utils.dart';
import 'utils/helper/storage_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageHelper.init();
  Injector.onAccountRevoked = (message) async {
    final roleId = StorageHelper().getRoleId();
    if (Get.isRegistered<AuthController>()) {
      await Get.find<AuthController>().clearLocalSession();
    } else {
      await StorageHelper().clearAllData();
      AppBookingService.instance.clearAll();
    }
    Get.offAll(() => LoginScreen(initialIsVendor: roleId == 3 || roleId == 4));
    Utils.showSnackBar(
      message,
      isError: true,
      title: 'Account unavailable',
      duration: const Duration(seconds: 5),
    );
  };

  // Initialize global category controller
  Get.put(CategoryController(), permanent: true);

  // Force portrait orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(const WidooraApp());
}

class WidooraApp extends StatelessWidget {
  const WidooraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Widoora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

typedef RiwaazApp = WidooraApp;
typedef ShaadiHubApp = WidooraApp;
typedef RwaazApp = WidooraApp;

