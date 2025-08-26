import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:office_management/core/services/supabase_service.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:office_management/features/dashboard/widgets/hover_card.dart';
import 'package:office_management/features/dashboard/pages/projects_page.dart';
import 'package:office_management/features/dashboard/widgets/subscription_status_dialog.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = true;
  bool _isAuthorized = false;
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _companyData;

  @override
  void initState() {
    super.initState();
    _fetchUserRoleAndCompany();
  }

  Future<void> _fetchUserRoleAndCompany() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final userProfile = await SupabaseService().getUserProfile(user.id);
        if (userProfile != null) {
          setState(() {
            _userProfile = userProfile;
            _isAuthorized = userProfile['role'] == 'owner';
          });

          // Fetch company data if user has a company_id
          final companyId = userProfile['company_id'];
          if (companyId != null) {
            final companyData = await _fetchCompanyData(companyId);
            if (companyData != null && mounted) {
              setState(() {
                _companyData = companyData;
              });

              // Show subscription status dialog if needed
              _showSubscriptionStatusDialog(companyData);
            }
          }
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

  Future<Map<String, dynamic>?> _fetchCompanyData(String companyId) async {
    try {
      final response = await Supabase.instance.client
          .from('companies')
          .select()
          .eq('id', companyId)
          .single();
      return response;
    } catch (e) {
      print('Error fetching company data: $e');
      return null;
    }
  }

  Future<void> _showSubscriptionStatusDialog(
    Map<String, dynamic> companyData,
  ) async {
    // Only show dialog if needed based on company status or is_active
    final status = companyData['status'] as String?;
    final isActive = companyData['is_active'] as bool?;

    if (status == 'trialing' ||
        status == 'canceled' ||
        status == 'expired' ||
        isActive == false) {
      // Use WidgetsBinding.instance.addPostFrameCallback to ensure the dialog is shown after the build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showShadDialog(
            context: context,
            builder: (context) => SubscriptionStatusDialog(
              companyData: companyData,
              onLogout: _logout,
            ),
          );
        }
      });
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isAuthorized) {
      return const Scaffold(
        body: Center(
          child: Text(
            'You are not authorized to view this page.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        actions: [
          ShadButton.ghost(onPressed: _logout, child: const Icon(Icons.logout)),
        ],
      ),
      body: Center(
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
                title: Text('Projects', style: theme.textTheme.h4),
                description: const Text('View and manage projects'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProjectsPage(),
                    ),
                  );
                },
                child: const Center(child: Icon(Icons.assignment, size: 48)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
