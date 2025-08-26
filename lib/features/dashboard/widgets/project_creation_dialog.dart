import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:office_management/core/services/supabase_service.dart';

class ProjectCreationDialog extends StatefulWidget {
  const ProjectCreationDialog({super.key});

  @override
  State<ProjectCreationDialog> createState() => _ProjectCreationDialogState();
}

class _ProjectCreationDialogState extends State<ProjectCreationDialog> {
  final _projectNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  String? _selectedStatus = 'planning'; // Default status
  DateTime? _startDate;
  DateTime? _endDate;
  String? _projectNameError;
  String? _statusError;

  @override
  void dispose() {
    _projectNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    setState(() {
      _projectNameError = null;
      _statusError = null;
    });

    bool isValid = true;

    if (_projectNameController.text.trim().isEmpty) {
      setState(() {
        _projectNameError = 'Please enter a project name';
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

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _saveProject() async {
    if (_validateInputs()) {
      print('Creating project...');
      print('Project name: ${_projectNameController.text.trim()}');
      print('Description: ${_descriptionController.text.trim()}');
      print('Location: ${_locationController.text.trim()}');
      print('Address: ${_addressController.text.trim()}');
      print('Contact Phone: ${_contactPhoneController.text.trim()}');
      print('Status: $_selectedStatus');
      print('Start Date: $_startDate');
      print('End Date: $_endDate');

      final project = await SupabaseService().createProject(
        name: _projectNameController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        address: _addressController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
        status: _selectedStatus!,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (project != null) {
        print('Project created successfully: $project');
        // Close the dialog
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } else {
        // Handle error
        print('Failed to create project');
        // Optionally, show an error message to the user
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadDialog(
      title: const Text('Create New Project'),
      description: const Text('Enter the details for the new project.'),
      actions: [
        ShadButton.outline(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ShadButton(child: const Text('Create'), onPressed: _saveProject),
      ],
      child: Container(
        width: 375,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 16,
          children: [
            // Project Name Input
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Project Name',
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
                        placeholder: const Text('Enter project name'),
                        controller: _projectNameController,
                      ),
                      if (_projectNameError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            _projectNameError!,
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
            // Description Input
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Description',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.small,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: ShadInput(
                    placeholder: const Text('Enter description'),
                    controller: _descriptionController,
                  ),
                ),
              ],
            ),
            // Location Input
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Location',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.small,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: ShadInput(
                    placeholder: const Text('Enter location'),
                    controller: _locationController,
                  ),
                ),
              ],
            ),
            // Address Input
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Address',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.small,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: ShadInput(
                    placeholder: const Text('Enter address'),
                    controller: _addressController,
                  ),
                ),
              ],
            ),
            // Contact Phone Input
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
                    controller: _contactPhoneController,
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
                        options: const [
                          ShadOption(
                            value: 'planning',
                            child: Text('Planning'),
                          ),
                          ShadOption(
                              value: 'in_progress', child: Text('In Progress')),
                          ShadOption(value: 'on_hold', child: Text('On Hold')),
                          ShadOption(value: 'completed', child: Text('Completed')),
                          ShadOption(value: 'cancelled', child: Text('Cancelled')),
                        ],
                        selectedOptionBuilder: (context, value) => Text(
                          value != null
                              ? value.split('_').map((word) {
                                  return word.split('').first.toUpperCase() +
                                      word.substring(1);
                                }).join(' ')
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
            // Start Date Picker
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Start Date',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.small,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: ShadButton.outline(
                    child: Text(
                      _startDate == null
                          ? 'Select Start Date'
                          : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                    ),
                    onPressed: () => _selectDate(context, true),
                  ),
                ),
              ],
            ),
            // End Date Picker
            Row(
              children: [
                Expanded(
                  child: Text(
                    'End Date',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.small,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: ShadButton.outline(
                    child: Text(
                      _endDate == null
                          ? 'Select End Date'
                          : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                    ),
                    onPressed: () => _selectDate(context, false),
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