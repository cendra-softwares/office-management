import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:office_management/core/services/supabase_service.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:office_management/features/dashboard/pages/companies_page.dart';
import 'package:office_management/features/dashboard/pages/users_page.dart';
import 'package:office_management/features/dashboard/widgets/hover_card.dart';

class SuperAdminDashboardPage extends StatefulWidget {
  const SuperAdminDashboardPage({super.key});

  @override
  State<SuperAdminDashboardPage> createState() =>
      _SuperAdminDashboardPageState();
}

class _SuperAdminDashboardPageState extends State<SuperAdminDashboardPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final userProfile = await SupabaseService().getUserProfile(user.id);
        if (userProfile != null && mounted) {
          setState(() {});
        }
      } catch (e) {
        print('Error fetching user role: $e');
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Dashboard'),
        actions: [
          ShadButton.ghost(
            child: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SizedBox(
                width: 400,
                height: 200,
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(24),
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  children: [
                    HoverCard(
                      title: Text('Companies', style: theme.textTheme.h4),
                      description: const Text('View and manage companies'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CompaniesPage(),
                          ),
                        );
                      },
                      child: const Center(
                        child: Icon(Icons.business, size: 48),
                      ),
                    ),
                    HoverCard(
                      title: Text('Users', style: theme.textTheme.h4),
                      description: const Text('View and manage users'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const UsersPage(),
                          ),
                        );
                      },
                      child: const Center(child: Icon(Icons.people, size: 48)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
