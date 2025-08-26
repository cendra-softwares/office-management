import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:office_management/core/services/supabase_service.dart';

class CompanyCreationDialog extends StatefulWidget {
  const CompanyCreationDialog({super.key});

  @override
  State<CompanyCreationDialog> createState() => _CompanyCreationDialogState();
}

class _CompanyCreationDialogState extends State<CompanyCreationDialog> {
  final _companyNameController = TextEditingController();
  String? _selectedOwnerId;
  String? _selectedStatus = 'trialing'; // Default status
  bool _isActive = true; // Default is_active
  String? _companyNameError;
  String? _ownerError;
  String? _statusError;

  // For owner dropdown search
  String _ownerSearchValue = '';
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> get _filteredUsers {
    if (_ownerSearchValue.isEmpty) {
      return _allUsers;
    }
    return _allUsers.where((user) {
      final fullName = user['full_name'] as String?;
      return fullName != null &&
          fullName.toLowerCase().contains(_ownerSearchValue.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final users = await SupabaseService().fetchUsersForDropdown();
    setState(() {
      _allUsers = users;
    });
  }

  bool _validateInputs() {
    setState(() {
      _companyNameError = null;
      _ownerError = null;
      _statusError = null;
    });

    bool isValid = true;

    if (_companyNameController.text.trim().isEmpty) {
      setState(() {
        _companyNameError = 'Please enter a company name';
      });
      isValid = false;
    }

    if (_selectedOwnerId == null || _selectedOwnerId!.isEmpty) {
      setState(() {
        _ownerError = 'Please select an owner';
      });
      isValid = false;
    }

    if (_selectedStatus == null || _selectedStatus!.isEmpty) {
      setState(() {
        _statusError = 'Please select a status';
      });
      isValid = false;
    }

    return isValid;
  }

  void _saveCompany() async {
    if (_validateInputs()) {
      // Show a loading indicator or disable the button to prevent multiple submissions
      // For simplicity, we'll just print a message
      print('Creating company...');
      print('Company name: ${_companyNameController.text.trim()}');
      print('Owner ID: $_selectedOwnerId');
      print('Status: $_selectedStatus');
      print('Is Active: $_isActive');

      final company = await SupabaseService().createCompany(
        name: _companyNameController.text.trim(),
        ownerId: _selectedOwnerId!,
        status: _selectedStatus!,
        isActive: _isActive,
        trialEndDate: DateTime.now().add(
          const Duration(days: 30),
        ), // Example: set trial end date to 30 days from now
      );

      if (company != null) {
        print('Company created successfully: $company');
        // Close the dialog
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } else {
        // Handle error
        print('Failed to create company');
        // Optionally, show an error message to the user
      }
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadDialog(
      title: const Text('Create New Company'),
      description: const Text('Enter the details for the new company.'),
      actions: [
        ShadButton.outline(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ShadButton(child: const Text('Create'), onPressed: _saveCompany),
      ],
      child: Container(
        width: 375,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 16,
          children: [
            // Company Name Input
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Company Name',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.small,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShadInput(
                        placeholder: const Text('Enter company name'),
                        controller: _companyNameController,
                      ),
                      if (_companyNameError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            _companyNameError!,
                            style: TextStyle(
                              color: theme.colorScheme.destructive,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            // Owner Dropdown with Search
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Owner',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.small,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: ShadSelect<String>.withSearch(
                    minWidth: 180.0,
                    maxWidth: 350.0,
                    placeholder: const Text('Select owner...'),
                    onSearchChanged: (value) =>
                        setState(() => _ownerSearchValue = value),
                    searchPlaceholder: const Text('Search owner'),
                    onChanged: (value) {
                      setState(() {
                        _selectedOwnerId = value;
                        // Clear error when a value is selected
                        if (_ownerError != null && value != null) {
                          _ownerError = null;
                        }
                      });
                    },
                    // Remove incorrect 'validator' parameter
                    options: [
                      if (_filteredUsers.isEmpty)
                        const ShadOption(
                          value: '',
                          child: Text('No users found'),
                        ),
                      ..._filteredUsers.map((user) {
                        final userId = user['id'] as String?;
                        final fullName = user['full_name'] as String?;
                        return ShadOption(
                          value: userId ?? '',
                          child: Text(fullName ?? 'No name'),
                        );
                      }).toList(),
                    ],
                    selectedOptionBuilder: (context, value) {
                      if (value == null || value.isEmpty) {
                        return const Text('Select owner');
                      }
                      final selectedUser = _allUsers.firstWhere(
                        (user) => user['id'] == value,
                        orElse: () => <String, dynamic>{},
                      );
                      return Text(
                        selectedUser['full_name'] as String? ?? 'Select owner',
                      );
                    },
                  ),
                ),
              ],
            ),
            // Status Dropdown
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Status',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.small,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShadSelect<String>(
                        placeholder: const Text('Select status'),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                            // Clear error when a value is selected
                            if (_statusError != null && value != null) {
                              _statusError = null;
                            }
                          });
                        },
                        // Remove incorrect 'validator' parameter
                        options: const [
                          ShadOption(
                            value: 'trialing',
                            child: Text('Trialing'),
                          ),
                          ShadOption(value: 'active', child: Text('Active')),
                          ShadOption(value: 'expired', child: Text('Expired')),
                          ShadOption(
                            value: 'canceled',
                            child: Text('Canceled'),
                          ),
                        ],
                        selectedOptionBuilder: (context, value) => Text(
                          value != null
                              ? value.split('').first.toUpperCase() +
                                    value.substring(1)
                              : 'Select status',
                        ),
                      ),
                      if (_statusError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            _statusError!,
                            style: TextStyle(
                              color: theme.colorScheme.destructive,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            // Is Active Toggle
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Is Active',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.small,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: ShadSwitch(
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
