import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'utils/helper/storage_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageHelper.init();

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

  runApp(const RiwaazApp());
}

class RiwaazApp extends StatelessWidget {
  const RiwaazApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Riwaaz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

typedef ShaadiHubApp = RiwaazApp;
typedef RwaazApp = RiwaazApp;

