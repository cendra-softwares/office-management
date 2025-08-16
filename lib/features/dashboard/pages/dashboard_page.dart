import 'package:flutter/material.dart';
import 'package:office_management/features/dashboard/pages/dashboard_main_content.dart';
import 'package:office_management/features/dashboard/widgets/nav_widget.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Desktop/Tablet layout with NavigationRail
          return Scaffold(
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(_extended ? Icons.menu_open : Icons.menu),
                        onPressed: () {
                          setState(() {
                            _extended = !_extended;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 25),
                        child: SizedBox(
                          height: 40,
                          child: Image.asset('assets/images/Logo.png'),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 400,
                        child: SearchBar(
                          controller: _searchController,
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
                          extended: _extended,
                          selectedIndex: _selectedIndex,
                          onDestinationSelected: (int index) {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: _selectedIndex == 0
                            ? const DashboardMainContent()
                            : Center(
                                child: Text(
                                  'Selected Index: $_selectedIndex',
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
        } else {
          // Mobile layout with NavigationDrawer
          return Scaffold(
            body: Row(
              // Wrap body in a Row to allow for drawer opening button
              children: [
                Builder(
                  builder: (context) {
                    return IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    );
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 80,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              SizedBox(width: 25),
                              Image.asset('assets/images/Logo.png'),
                              const Spacer(),
                              SizedBox(
                                width: 300,
                                child: SearchBar(
                                  controller: _searchController,
                                  hintText: 'Search...',
                                  leading: const Icon(Icons.search),
                                  elevation: const WidgetStatePropertyAll(0.0),
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
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
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Selected Index: $_selectedIndex',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            drawer: NavDrawer(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          );
        }
      },
    );
  }
}
