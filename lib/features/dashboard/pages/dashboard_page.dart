import 'package:flutter/material.dart';
import 'package:office_management/core/utils/responsive.dart';
import 'package:office_management/features/dashboard/pages/desktop_layout.dart';
import 'package:office_management/features/dashboard/pages/mobile_layout.dart';
import 'package:office_management/features/dashboard/pages/tablet_layout.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  bool _extended = false; // Add this state variable
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: MobileLayout(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        searchController: _searchController,
      ),
      tablet: TabletLayout(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        searchController: _searchController,
      ),
      desktop: DesktopLayout(
        selectedIndex: _selectedIndex,
        extended: _extended,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        onMenuButtonPressed: () {
          setState(() {
            _extended = !_extended;
          });
        },
        searchController: _searchController,
      ),
    );
  }
}
