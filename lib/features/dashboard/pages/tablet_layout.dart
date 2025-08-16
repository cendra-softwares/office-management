import 'package:flutter/material.dart';
import 'package:office_management/features/dashboard/pages/dashboard_main_content.dart';
import 'package:office_management/features/dashboard/widgets/nav_widget.dart';

class TabletLayout extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final TextEditingController searchController;

  const TabletLayout({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: SizedBox(
                    height: 40,
                    child: Image.asset('assets/images/Logo.png'),
                  ),
                ),
                const Spacer(),
                Expanded(
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
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  ),
                  child: NavRail(
                    extended: false,
                    selectedIndex: selectedIndex,
                    onDestinationSelected: onDestinationSelected,
                  ),
                ),
                Expanded(
                  child: selectedIndex == 0
                      ? const DashboardMainContent()
                      : Center(
                          child: Text(
                            'Selected Index: $selectedIndex',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}