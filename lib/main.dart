import 'package:flutter/material.dart';
import 'package:office_management/core/theme/app_colors.dart';
import 'package:office_management/core/theme/typography.dart';
import 'package:office_management/features/dashboard/pages/dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryLavender,
          foregroundColor: AppColors.textInverse,
          titleTextStyle: AppTypography.headline2,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryLavender,
          primary: AppColors.primaryLavender,
          secondary: AppColors.secondaryTeal,
          surface: AppColors.surfaceWhite,
          onPrimary: AppColors.textInverse,
          onSecondary: AppColors.textInverse,
          onSurface: AppColors.textPrimary,
          error: AppColors.error,
          onError: AppColors.textInverse,
        ),
        textTheme: const TextTheme(
          displayLarge: AppTypography.headline1,
          headlineMedium: AppTypography.headline2,
          bodyLarge: AppTypography.body1,
          bodyMedium: AppTypography.body2,
          labelLarge: AppTypography.button,
          bodySmall: AppTypography.caption,
        ),
      ),
      home: const DashboardPage(),
    );
  }
}
