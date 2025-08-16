import 'package:flutter/material.dart';
import 'package:office_management/core/theme/app_colors.dart';
import 'package:office_management/features/dashboard/widgets/project_card_widget.dart';

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
        child: GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 3 / 2,
          ),
          itemCount: 6, // Display 6 cards for demonstration
          itemBuilder: (context, index) {
            return const ProjectCardWidget();
          },
        ),
      ),
    );
  }
}
