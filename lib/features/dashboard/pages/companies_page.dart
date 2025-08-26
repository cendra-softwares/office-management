import 'package:flutter/material.dart';
import 'package:office_management/core/services/supabase_service.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:office_management/features/dashboard/widgets/company_creation_dialog.dart';

class CompaniesPage extends StatefulWidget {
  const CompaniesPage({super.key});

  @override
  State<CompaniesPage> createState() => _CompaniesPageState();
}

class _CompaniesPageState extends State<CompaniesPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _companies = [];
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await _fetchCompanies();
    await _fetchUsers();
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

  Future<void> _fetchUsers() async {
    final users = await SupabaseService().fetchUsersForDropdown();
    if (mounted) {
      setState(() {
        _users = users;
      });
    }
  }

  Future<void> _changeOwner(String companyId, String newOwnerId) async {
    final success = await SupabaseService().updateCompanyOwner(
      companyId: companyId,
      newOwnerId: newOwnerId,
    );
    if (success != null) {
      // Refresh companies after successful update
      _fetchCompanies();
    } else {
      // Handle error, e.g., show a toast or dialog
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Error'),
            description: const Text('Failed to change company owner.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final headings = ['Company', 'Status', 'Owner', 'Active', 'Actions'];

    return Scaffold(
      appBar: AppBar(title: const Text('Companies')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('All Companies', style: theme.textTheme.h2),
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
                ),
                const ShadSeparator.horizontal(
                  thickness: 1,
                  color: Colors.grey,
                ),
                Expanded(
                  child: ShadCard(
                    width: double.infinity, // Make the card take full width
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
                            columnSpanExtent: (index) {
                              // Adjust column widths for better aesthetics
                              if (index == 0) {
                                return const FixedTableSpanExtent(200);
                              } // Company
                              if (index == 1) {
                                return const FixedTableSpanExtent(120);
                              } // Status
                              if (index == 2) {
                                return const FixedTableSpanExtent(180);
                              } // Owner
                              if (index == 3) {
                                return const FixedTableSpanExtent(80);
                              } // Active
                              return const RemainingTableSpanExtent(); // Actions
                            },
                            builder: (context, index) {
                              final company = _companies[index.row];
                              final owner = company['owner'];
                              final ownerName = owner is Map
                                  ? owner['full_name']
                                  : 'N/A';

                              if (index.column == 4) {
                                // Actions column
                                return ShadTableCell(
                                  child: ShadSelect<String>(
                                    placeholder: const Text('Change Owner'),
                                    options: _users.map((user) {
                                      return ShadOption(
                                        value: user['id'] as String,
                                        child: Text(
                                          user['full_name'] as String,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (newOwnerId) {
                                      if (newOwnerId != null) {
                                        _changeOwner(
                                          company['id'] as String,
                                          newOwnerId,
                                        );
                                      }
                                    },
                                    selectedOptionBuilder: (context, value) {
                                      return Text(value ?? 'Change Owner');
                                    },
                                  ),
                                );
                              }

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
    );
  }
}
