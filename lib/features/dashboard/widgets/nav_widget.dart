import 'package:flutter/material.dart';
import 'package:office_management/core/theme/app_colors.dart';

class NavRail extends StatelessWidget {
  final bool extended;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const NavRail({
    super.key,
    required this.extended,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      backgroundColor: AppColors.surfaceWhite,
      useIndicator: false,
      extended: extended,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.none,
      destinations: const <NavigationRailDestination>[
        NavigationRailDestination(
          icon: Icon(Icons.home),
          label: Text('Home', style: TextStyle(fontSize: 25)),
          padding: EdgeInsets.only(bottom: 10),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings),
          label: Text('Settings', style: TextStyle(fontSize: 25)),
          padding: EdgeInsets.only(bottom: 10),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person),
          label: Text('Profile', style: TextStyle(fontSize: 25)),
          padding: EdgeInsets.only(bottom: 10),
        ),
      ],
    );
  }
}

class NavDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const NavDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: (int index) {
        onDestinationSelected(index);
        Navigator.pop(context); // Close the drawer
      },
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Header', style: Theme.of(context).textTheme.headlineMedium),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () {
                  Navigator.pop(context); // Close the drawer
                },
              ),
            ],
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.home),
          label: Text('Home'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.person),
          label: Text('Profile'),
        ),
      ],
    );
  }
}
