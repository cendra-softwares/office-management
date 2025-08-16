import 'package:flutter/material.dart';
import 'package:office_management/features/dashboard/widgets/nav_widget.dart';
import 'package:office_management/features/dashboard/pages/dashboard_main_content.dart';

class MobileLayout extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final TextEditingController searchController;

  const MobileLayout({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Image.asset('assets/images/Logo.png', height: 40),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: SearchBar(
              controller: searchController,
              hintText: 'Search...',
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0.0),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              onChanged: (value) {
                // Handle search input changes
              },
            ),
          ),
        ),
      ),
      body: selectedIndex == 0
          ? const DashboardMainContent()
          : Center(
              child: Text(
                'Selected Index: $selectedIndex',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
      drawer: NavDrawer(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
      ),
    );
  }
}
