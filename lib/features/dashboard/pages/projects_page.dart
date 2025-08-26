// ignore_for_file: unused_import

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:office_management/features/dashboard/providers/project_providers.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:office_management/features/dashboard/widgets/project_creation_dialog.dart';

class ProjectsPage extends HookConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final allProjectsAsyncValue = ref.watch(allProjectsProvider);
    final filteredAndSortedProjects = ref.watch(
      filteredAndSortedProjectsProvider,
    );
    final sortState = ref.watch(projectSortProvider);
    final headings = [
      'Project',
      'Description',
      'Location',
      'Status',
      'Start Date',
      'End Date',
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
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 250,
                                ),
                                child: ShadInput(
                                  placeholder: const Text('Search projects...'),
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
                                    project['start_date']?.toString() ?? 'N/A',
                                    project['end_date']?.toString() ?? 'N/A',
                                  ];
                                  return DataRow(
                                    cells: [
                                      for (var item in data)
                                        DataCell(
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(item.toString()),
                                          ),
                                        ),
                                      DataCell(
                                        Container(
                                          alignment: Alignment.center,
                                          child: const Icon(Icons.more_vert),
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
