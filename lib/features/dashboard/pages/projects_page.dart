// ignore_for_file: unused_import

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:office_management/features/dashboard/providers/project_providers.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:office_management/features/dashboard/widgets/project_creation_dialog.dart';
import 'package:office_management/features/dashboard/widgets/project_edit_dialog.dart';

class ProjectsPage extends HookConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final searchController = useTextEditingController();

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

    final allProjectsAsyncValue = ref.watch(allProjectsProvider);
    final filteredAndSortedProjects = ref.watch(
      filteredAndSortedProjectsProvider,
    );
    final sortState = ref.watch(projectSortProvider);
    final statusFilters = ref.watch(projectStatusFilterProvider);
    final headings = [
      'Project',
      'Description',
      'Location',
      'Status',
      'End Date',
      'Contact Phone',
      'Actions',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      body: allProjectsAsyncValue.when(
        data: (allProjects) {
          final projects = filteredAndSortedProjects;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('All Projects', style: theme.textTheme.h2),
                    const SizedBox(width: 8),
                    ShadButton(
                      child: const Text('Create Project'),
                      onPressed: () {
                        showShadDialog(
                          context: context,
                          builder: (context) => const ProjectCreationDialog(),
                        ).then((_) => ref.invalidate(allProjectsProvider));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const ShadSeparator.horizontal(thickness: 1, color: Colors.grey),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ShadCard(
                    width: double.infinity,
                    child: Column(
                      children: [
                        // Search bar row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Reset Button
                            Padding(
                              padding: const EdgeInsets.only(left: 250),
                              child: ShadButton.outline(
                                child: const Text('Reset Filters'),
                                onPressed: () {
                                  searchController.clear(); // Clear search text
                                  ref
                                          .read(
                                            projectSearchQueryProvider.notifier,
                                          )
                                          .state =
                                      '';
                                  ref
                                          .read(
                                            projectStatusFilterProvider
                                                .notifier,
                                          )
                                          .state =
                                      [];
                                },
                              ),
                            ),
                            // Search bar and Status filter
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 250,
                                      ),
                                      child: ShadInput(
                                        controller: searchController,
                                        placeholder: const Text(
                                          'Search projects...',
                                        ),
                                        onChanged: (value) {
                                          ref
                                                  .read(
                                                    projectSearchQueryProvider
                                                        .notifier,
                                                  )
                                                  .state =
                                              value;
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 250),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 300,
                                      ),
                                      child: ShadSelect<String>.multiple(
                                        minWidth: 200,
                                        placeholder: const Text(
                                          'Filter by status',
                                        ),
                                        selectedOptionsBuilder: (context, values) {
                                          if (values.isEmpty) {
                                            return const Text(
                                              'Filter by status',
                                            );
                                          }
                                          return Text(
                                            '${values.length} status selected',
                                          );
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
                                                            .replaceAll(
                                                              '_',
                                                              ' ',
                                                            )
                                                            .replaceFirst(
                                                              status[0],
                                                              status[0]
                                                                  .toUpperCase(),
                                                            ),
                                                        style: TextStyle(
                                                          color: getStatusColor(
                                                            status,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                        onChanged: (values) {
                                          ref
                                              .read(
                                                projectStatusFilterProvider
                                                    .notifier,
                                              )
                                              .state = values
                                              .toList();
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Table
                        if (projects.isEmpty)
                          const Center(child: Text('No projects found.'))
                        else
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                key: ValueKey(
                                  projects.length,
                                ), // Add key to force rebuild
                                sortColumnIndex: sortState.columnIndex,
                                sortAscending: sortState.ascending,
                                columns: [
                                  for (var i = 0; i < headings.length; i++)
                                    DataColumn(
                                      label: Text(headings[i]),
                                      onSort: (columnIndex, ascending) {
                                        ref
                                            .read(projectSortProvider.notifier)
                                            .update((state) {
                                              if (state.columnIndex ==
                                                  columnIndex) {
                                                return state.copyWith(
                                                  ascending: !state.ascending,
                                                );
                                              } else {
                                                return state.copyWith(
                                                  columnIndex: columnIndex,
                                                  ascending: true,
                                                );
                                              }
                                            });
                                      },
                                    ),
                                ],
                                rows: projects.map((project) {
                                  final data = [
                                    project['name'],
                                    project['description'] ?? 'N/A',
                                    project['location'] ?? 'N/A',
                                    project['status'],
                                    project['end_date']?.toString() ?? 'N/A',
                                    project['contact_phone'] ?? 'N/A',
                                  ];
                                  // Reorder data to match new headings
                                  final reorderedData = [
                                    data[0], // Project
                                    data[1], // Description
                                    data[2], // Location
                                    data[3], // Status
                                    data[4], // End Date (moved from original index 5)
                                    data[5], // Contact Phone (moved from original index 6)
                                  ];
                                  return DataRow(
                                    cells: [
                                      for (var i = 0; i < data.length; i++)
                                        DataCell(
                                          Container(
                                            alignment: i == 3
                                                ? Alignment
                                                      .center // Status column
                                                : Alignment.centerLeft,
                                            child: i == 3
                                                ? ShadBadge.outline(
                                                    child: Text(
                                                      data[i].toString(),
                                                      style: TextStyle(
                                                        color: getStatusColor(
                                                          data[i].toString(),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Text(data[i].toString()),
                                          ),
                                        ),
                                      DataCell(
                                        Container(
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit),
                                                onPressed: () {
                                                  showShadDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        ProjectEditDialog(
                                                          project: project,
                                                        ),
                                                  ).then(
                                                    (_) => ref.invalidate(
                                                      allProjectsProvider,
                                                    ),
                                                  );
                                                },
                                              ),
                                              // Add other action buttons here if needed
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) => Center(
          child: SelectableText.rich(
            TextSpan(
              text: 'Error: ',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: error.toString(),
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
