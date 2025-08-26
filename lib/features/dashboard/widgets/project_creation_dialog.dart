import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:office_management/core/services/supabase_service.dart';
import 'package:office_management/features/dashboard/providers/project_providers.dart';

class ProjectCreationDialog extends HookConsumerWidget {
  const ProjectCreationDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectNameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final locationController = useTextEditingController();
    final addressController = useTextEditingController();
    final contactPhoneController = useTextEditingController();
    final selectedStatus = useState<String?>('planning');
    final startDate = useState<DateTime?>(null);
    final endDate = useState<DateTime?>(null);
    final projectNameError = useState<String?>(null);
    final statusError = useState<String?>(null);
    final theme = ShadTheme.of(context);

    Color getStatusColor(String status) {
      switch (status) {
        case 'planning':
          return Colors.blue;
        case 'in_progress':
          return Colors.orange;
        case 'on_hold':
          return Colors.grey;
        case 'completed':
          return Colors.green;
        case 'cancelled':
          return Colors.red;
        default:
          return Colors.black;
      }
    }

    bool validateInputs() {
      projectNameError.value = null;
      statusError.value = null;

      bool isValid = true;

      if (projectNameController.text.trim().isEmpty) {
        projectNameError.value = 'Please enter a project name';
        isValid = false;
      }

      if (selectedStatus.value == null || selectedStatus.value!.isEmpty) {
        statusError.value = 'Please select a status';
        isValid = false;
      }

      return isValid;
    }

    Future<void> selectDate(BuildContext context, bool isStart) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null) {
        if (isStart) {
          startDate.value = picked;
        } else {
          endDate.value = picked;
        }
      }
    }

    void saveProject() async {
      if (validateInputs()) {
        final project = await SupabaseService().createProject(
          name: projectNameController.text.trim(),
          description: descriptionController.text.trim(),
          location: locationController.text.trim(),
          address: addressController.text.trim(),
          contactPhone: contactPhoneController.text.trim(),
          status: selectedStatus.value!,
          startDate: startDate.value,
          endDate: endDate.value,
        );

        if (project != null) {
          ref.invalidate(allProjectsProvider);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        } else {
          // Handle error
        }
      }
    }

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
        ShadButton(onPressed: saveProject, child: const Text('Create')),
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
                        controller: projectNameController,
                      ),
                      if (projectNameError.value != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            projectNameError.value!,
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
                    controller: descriptionController,
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
                    controller: locationController,
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
                    controller: addressController,
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
                    controller: contactPhoneController,
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
                          selectedStatus.value = value;
                          if (statusError.value != null && value != null) {
                            statusError.value = null;
                          }
                        },
                        options:
                            [
                                  'planning',
                                  'in_progress',
                                  'on_hold',
                                  'completed',
                                  'cancelled',
                                ]
                                .map(
                                  (status) => ShadOption(
                                    value: status,
                                    child: ShadBadge.outline(
                                      child: Text(
                                        status
                                            .replaceAll('_', ' ')
                                            .replaceFirst(
                                              status[0],
                                              status[0].toUpperCase(),
                                            ),
                                        style: TextStyle(
                                          color: getStatusColor(status),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        selectedOptionBuilder: (context, value) =>
                            ShadBadge.outline(
                              child: Text(
                                value
                                          .replaceAll('_', ' ')
                                          .replaceFirst(
                                            value[0],
                                            value[0].toUpperCase(),
                                          ),
                                style: TextStyle(
                                  color: getStatusColor(value ?? ''),
                                ),
                              ),
                            ),
                      ),
                      if (statusError.value != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            statusError.value!,
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
                      startDate.value == null
                          ? 'Select Start Date'
                          : '${startDate.value!.day}/${startDate.value!.month}/${startDate.value!.year}',
                    ),
                    onPressed: () => selectDate(context, true),
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
                      endDate.value == null
                          ? 'Select End Date'
                          : '${endDate.value!.day}/${endDate.value!.month}/${endDate.value!.year}',
                    ),
                    onPressed: () => selectDate(context, false),
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
