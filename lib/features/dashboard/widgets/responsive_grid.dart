import 'package:flutter/material.dart';
import 'package:office_management/core/utils/responsive.dart';
import 'package:office_management/features/dashboard/widgets/project_card_widget.dart';

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.isMobile(context)
            ? 1
            : Responsive.isTablet(context)
                ? 2
                : 4,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 3 / 3,
      ),
      itemBuilder: (context, index) {
        return const ProjectCardWidget();
      },
    );
  }
}