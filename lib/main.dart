import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'controllers/category_controller.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'utils/helper/storage_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageHelper.init();

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

