import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NirvaApp());
}

class NirvaApp extends StatelessWidget {
  const NirvaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NIRVA UMKM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
