import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:office_management/core/services/supabase_service.dart';

class UserEditDialog extends StatefulWidget {
  const UserEditDialog({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });

  final Map<String, dynamic> user;
  final VoidCallback onUserUpdated;

  @override
  State<UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<UserEditDialog> {
  late String _fullName;
  late String _role;
  late String _contactPhone;
  
  String? _fullNameError;
  String? _roleError;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fullName = widget.user['full_name'] as String? ?? '';
    _role = widget.user['role'] as String? ?? 'member';
    _contactPhone = widget.user['contact_phone'] as String? ?? '';
  }

  bool _validateInputs() {
    setState(() {
      _fullNameError = null;
      _roleError = null;
    });

    bool isValid = true;

    if (_fullName.isEmpty) {
      setState(() {
        _fullNameError = 'Full name is required';
      });
      isValid = false;
    }

    if (_role.isEmpty) {
      setState(() {
        _roleError = 'Role is required';
      });
      isValid = false;
    }

    return isValid;
  }

  void _saveUser() async {
    if (_validateInputs()) {
      setState(() {
        _isLoading = true;
      });

      final updates = <String, dynamic>{
        'full_name': _fullName,
        'role': _role,
        'contact_phone': _contactPhone,
      };

      final success = await SupabaseService().updateUser(
        userId: widget.user['id'] as String,
        updates: updates,
      );

      setState(() {
        _isLoading = false;
      });

      if (success != null) {
        widget.onUserUpdated();
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ShadToaster.of(context).show(
            ShadToast.destructive(
              title: const Text('Error'),
              description: const Text('Failed to update user.'),
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
      title: Text('Edit User: ${widget.user['full_name'] ?? 'Unknown'}'),
      description: const Text('Update user information.'),
      actions: [
        ShadButton.outline(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ShadButton(
          onPressed: _isLoading ? null : _saveUser,
          child: _isLoading ? const CircularProgressIndicator() : const Text('Save'),
        ),
      ],
      child: Container(
        width: 375,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 16,
          children: [
            // Full Name Field
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Full Name',
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
                        placeholder: const Text('Enter full name'),
                        initialValue: _fullName,
                        onChanged: (value) {
                          setState(() {
                            _fullName = value;
                            if (_fullNameError != null && value.isNotEmpty) {
                              _fullNameError = null;
                            }
                          });
                        },
                      ),
                      if (_fullNameError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            _fullNameError!,
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
            
            // Role Dropdown
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Role',
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
                        placeholder: const Text('Select role...'),
                        initialValue: _role,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _role = value;
                              if (_roleError != null) {
                                _roleError = null;
                              }
                            });
                          }
                        },
                        options: const [
                          ShadOption(value: 'superadmin', child: Text('Super Admin')),
                          ShadOption(value: 'admin', child: Text('Admin')),
                          ShadOption(value: 'owner', child: Text('Owner')),
                          ShadOption(value: 'member', child: Text('Member')),
                        ],
                        selectedOptionBuilder: (context, value) => Text(
                          value.split('').first.toUpperCase() +
                                  value.substring(1),
                        ),
                      ),
                      if (_roleError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            _roleError!,
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
            
            // Contact Phone Field
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Contact Phone',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.small,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: ShadInput(
                    placeholder: const Text('Enter contact phone'),
                    initialValue: _contactPhone,
                    onChanged: (value) {
                      setState(() {
                        _contactPhone = value;
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