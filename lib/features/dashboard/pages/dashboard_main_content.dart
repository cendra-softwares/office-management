import 'package:flutter/material.dart';
import 'package:office_management/core/theme/app_colors.dart';
import 'package:office_management/features/dashboard/widgets/responsive_grid.dart';

class DashboardMainContent extends StatelessWidget {
  const DashboardMainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        ),
        child: const ResponsiveGrid(),
      ),
    );
  }
}
