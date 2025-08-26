import 'package:flutter/material.dart';
import 'package:office_management/core/services/supabase_service.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:office_management/features/dashboard/widgets/user_edit_dialog.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await _fetchUsers(sortBy: 'full_name', ascending: true);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUsers({
    String sortBy = 'full_name',
    bool ascending = true,
  }) async {
    final users = await SupabaseService().fetchAllUsers(
      sortBy: sortBy,
      ascending: ascending,
    );
    if (mounted) {
      setState(() {
        _users = users;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final headings = ['Full Name', 'Role', 'Company', 'Contact Phone', 'Active', 'Actions'];

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
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
                      Text('All Users', style: theme.textTheme.h2),
                    ],
                  ),
                ),
                const ShadSeparator.horizontal(
                  thickness: 1,
                  color: Colors.grey,
                ),
                Expanded(
                  child: ShadCard(
                    width: double.infinity,
                    child: _users.isEmpty
                        ? const Center(child: Text('No users found.'))
                        : DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ShadTable(
                              columnCount: headings.length,
                              rowCount: _users.length,
                              header: (context, column) {
                                return ShadTableCell.header(
                                  alignment: Alignment.center,
                                  child: headings[column] == 'Actions'
                                      ? Text(headings[column])
                                      : GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (_sortColumnIndex == column) {
                                                _sortAscending =
                                                    !_sortAscending;
                                              } else {
                                                _sortColumnIndex = column;
                                                _sortAscending = true;
                                              }
                                              final sortBy =
                                                  headings[column] == 'Full Name'
                                                  ? 'full_name'
                                                  : headings[column] == 'Role'
                                                  ? 'role'
                                                  : headings[column] == 'Company'
                                                  ? 'company_id'
                                                  : headings[column] == 'Contact Phone'
                                                  ? 'contact_phone'
                                                  : headings[column].toLowerCase() ==
                                                      'active'
                                                  ? 'is_active'
                                                  : headings[column]
                                                      .toLowerCase();
                                              _fetchUsers(
                                                sortBy: sortBy,
                                                ascending: _sortAscending,
                                              );
                                            });
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  headings[column],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                              if (_sortColumnIndex == column)
                                                Icon(
                                                  _sortAscending
                                                      ? Icons.arrow_upward
                                                      : Icons.arrow_downward,
                                                  size: 16,
                                                ),
                                            ],
                                          ),
                                        ),
                                );
                              },
                              columnSpanExtent: (index) {
                                // Adjust column widths for better aesthetics
                                if (index == 0) {
                                  return const FixedTableSpanExtent(200);
                                } // Full Name
                                if (index == 1) {
                                  return const FixedTableSpanExtent(120);
                                } // Role
                                if (index == 2) {
                                  return const FixedTableSpanExtent(180);
                                } // Company
                                if (index == 3) {
                                  return const FixedTableSpanExtent(150);
                                } // Contact Phone
                                if (index == 4) {
                                  return const FixedTableSpanExtent(80);
                                } // Active
                                return const RemainingTableSpanExtent(); // Actions
                              },
                              builder: (context, index) {
                                final user = _users[index.row];
                                final company = user['company'];
                                final companyName = company is Map
                                    ? company['name']
                                    : 'N/A';

                                if (index.column == 5) {
                                  // Actions column
                                  return ShadTableCell(
                                    alignment: Alignment.center,
                                    child: ShadButton.ghost(
                                      child: const Icon(LucideIcons.pencil),
                                      onPressed: () {
                                        showShadDialog(
                                          context: context,
                                          builder: (context) =>
                                              UserEditDialog(
                                                user: user,
                                                onUserUpdated: _fetchUsers,
                                              ),
                                        );
                                      },
                                    ),
                                  );
                                }

                                final data = [
                                  user['full_name'] ?? 'N/A',
                                  user['role'] ?? 'N/A',
                                  companyName,
                                  user['contact_phone'] ?? 'N/A',
                                  (user['is_active'] ?? true).toString(),
                                ];
                                return ShadTableCell(
                                  alignment: Alignment.center,
                                  child: Text(data[index.column]),
                                );
                              },
                            ),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}