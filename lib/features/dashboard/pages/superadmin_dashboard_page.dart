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
  List<Map<String, dynamic>> _companies = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await _fetchUserRole();
    await _fetchCompanies();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCompanies() async {
    final companies = await SupabaseService().fetchAllCompanies();
    if (mounted) {
      setState(() {
        _companies = companies;
      });
    }
  }

  Future<void> _fetchUserRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final userProfile = await SupabaseService().getUserProfile(user.id);
        if (userProfile != null && mounted) {
          setState(() {
            _userRole = userProfile['role'] as String?;
          });
        }
      } catch (e) {
        print('Error fetching user role: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final theme = ShadTheme.of(context);
    final headings = ['Company', 'Status', 'Owner', 'Active'];

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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Companies', style: theme.textTheme.h2),
                      ShadButton(
                        child: const Text('Create Company'),
                        onPressed: () {
                          showShadDialog(
                            context: context,
                            builder: (context) => const CompanyCreationDialog(),
                          ).then((_) => _fetchCompanies());
                        },
                      ),
                    ],
                  ),
                  const ShadSeparator.horizontal(
                    thickness: 1,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400,
                    child: ShadCard(
                      child: _companies.isEmpty
                          ? const Center(child: Text('No companies found.'))
                          : ShadTable(
                              columnCount: headings.length,
                              rowCount: _companies.length,
                              header: (context, column) {
                                return ShadTableCell.header(
                                  child: Text(headings[column]),
                                );
                              },
                              builder: (context, index) {
                                final company = _companies[index.row];
                                final owner = company['owner'];
                                final ownerName =
                                    owner is Map ? owner['full_name'] : 'N/A';

                                final data = [
                                  company['name'],
                                  company['status'],
                                  ownerName,
                                  company['is_active'].toString(),
                                ];
                                return ShadTableCell(
                                  child: Text(data[index.column]),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
