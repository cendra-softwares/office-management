import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:office_management/core/services/supabase_service.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:office_management/features/dashboard/widgets/company_creation_dialog.dart';

class SuperAdminDashboardPage extends StatefulWidget {
  const SuperAdminDashboardPage({super.key});

  @override
  State<SuperAdminDashboardPage> createState() =>
      _SuperAdminDashboardPageState();
}

class _SuperAdminDashboardPageState extends State<SuperAdminDashboardPage> {
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    print('Current user in dashboard: ${user?.id}');
    print('Current user email in dashboard: ${user?.email}');
    if (user != null) {
      try {
        final userProfile = await SupabaseService().getUserProfile(user.id);
        print('User profile: $userProfile');
        if (userProfile != null) {
          setState(() {
            _userRole = userProfile['role'] as String?;
            print('User role set to: $_userRole');
            _isLoading = false;
          });
        } else {
          // Handle case where user profile is not found
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        // Handle error
        print('Error fetching user role: $e');
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Dashboard'),
        actions: [
          ShadButton(
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
      body: Center(
        child: ShadCard(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Welcome to the Super Admin Dashboard!'),
              if (_isLoading)
                SizedBox.square(
                  dimension: 24.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: ShadTheme.of(context).colorScheme.primary,
                  ),
                )
              else if (user != null) ...[
                const SizedBox(height: 16),
                Text('Email: ${user.email}'),
                if (_userRole != null) ...[
                  const SizedBox(height: 8),
                  Text('Role: $_userRole'),
                  const SizedBox(height: 16),
                  ShadButton(
                    child: const Text('Create Company'),
                    onPressed: () {
                      showShadDialog(
                        context: context,
                        builder: (context) => const CompanyCreationDialog(),
                      );
                    },
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
