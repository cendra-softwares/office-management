import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:office_management/core/services/supabase_service.dart';

class OwnerChangeDialog extends StatefulWidget {
  const OwnerChangeDialog({
    super.key,
    required this.company,
    required this.onOwnerChanged,
  });

  final Map<String, dynamic> company;
  final VoidCallback onOwnerChanged;

  @override
  State<OwnerChangeDialog> createState() => _OwnerChangeDialogState();
}

class _OwnerChangeDialogState extends State<OwnerChangeDialog> {
  String? _selectedOwnerId;
  String? _ownerError;
  List<Map<String, dynamic>> _allUsers = [];
  String _ownerSearchValue = '';

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
    _selectedOwnerId = widget.company['owner_id'];
  }

  Future<void> _fetchUsers() async {
    final users = await SupabaseService().fetchUsersForDropdown();
    setState(() {
      _allUsers = users;
    });
  }

  bool _validateInputs() {
    setState(() {
      _ownerError = null;
    });

    bool isValid = true;

    if (_selectedOwnerId == null || _selectedOwnerId!.isEmpty) {
      setState(() {
        _ownerError = 'Please select an owner';
      });
      isValid = false;
    }

    return isValid;
  }

  void _saveOwner() async {
    if (_validateInputs()) {
      final success = await SupabaseService().updateCompanyOwner(
        companyId: widget.company['id'] as String,
        newOwnerId: _selectedOwnerId!,
      );

      if (success != null) {
        widget.onOwnerChanged();
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadDialog(
      title: Text('Change Owner for ${widget.company['name']}'),
      description: const Text('Select a new owner for the company.'),
      actions: [
        ShadButton.outline(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ShadButton(onPressed: _saveOwner, child: const Text('Save')),
      ],
      child: Container(
        width: 375,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 16,
          children: [
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
                        if (_ownerError != null && value != null) {
                          _ownerError = null;
                        }
                      });
                    },
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
                      }),
                    ],
                    selectedOptionBuilder: (context, value) {
                      if (value.isEmpty) {
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
            if (_ownerError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  _ownerError!,
                  style: TextStyle(color: theme.colorScheme.destructive),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
