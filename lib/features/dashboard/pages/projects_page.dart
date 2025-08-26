import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:office_management/core/services/supabase_service.dart';
import 'package:office_management/features/dashboard/widgets/project_creation_dialog.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _projects = [];
  List<Map<String, dynamic>> _filteredProjects = [];
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  String _searchQuery = '';
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await _fetchProjects(sortBy: 'name', ascending: true);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<String> _generateSuggestions(String query) {
    if (query.isEmpty) return [];

    final allSuggestions = <String>{};

    // Add project names, descriptions, and locations as suggestions
    for (final project in _projects) {
      final name = project['name'] as String?;
      final description = project['description'] as String?;
      final location = project['location'] as String?;

      if (name != null && name.toLowerCase().contains(query.toLowerCase())) {
        allSuggestions.add(name);
      }

      if (description != null &&
          description.toLowerCase().contains(query.toLowerCase())) {
        allSuggestions.add(description);
      }

      if (location != null &&
          location.toLowerCase().contains(query.toLowerCase())) {
        allSuggestions.add(location);
      }
    }

    // Convert to list and limit to 5 suggestions
    // Convert to list, sort, and limit to 5 suggestions
    final sortedSuggestions = allSuggestions.toList()..sort();
    return sortedSuggestions.length > 5
        ? sortedSuggestions.take(5).toList()
        : sortedSuggestions;
  }

  Future<void> _fetchProjects({
    String sortBy = 'name',
    bool ascending = true,
  }) async {
    final projects = await SupabaseService().fetchAllProjects(
      sortBy: sortBy,
      ascending: ascending,
    );

    // Filter projects based on search query
    final filtered = _searchQuery.isEmpty
        ? projects
        : projects.where((project) {
            return project['name'].toString().toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                project['description'].toString().toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                project['location'].toString().toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }).toList();

    if (mounted) {
      setState(() {
        _projects = projects;
        _filteredProjects = filtered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
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
                      Text('All Projects', style: theme.textTheme.h2),
                      GestureDetector(
                        onTap: () {
                          // Hide suggestions when tapping outside
                          if (_showSuggestions) {
                            setState(() {
                              _showSuggestions = false;
                            });
                          }
                        },
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                SizedBox(
                                  width: 300,
                                  child: ShadInput(
                                    placeholder: const Text(
                                      'Search projects...',
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                        _suggestions = _generateSuggestions(
                                          value,
                                        );
                                        _showSuggestions =
                                            value.isNotEmpty &&
                                            _suggestions.isNotEmpty;
                                      });
                                      _fetchProjects(
                                        sortBy:
                                            headings[_sortColumnIndex] ==
                                                'Project'
                                            ? 'name'
                                            : headings[_sortColumnIndex] ==
                                                  'Description'
                                            ? 'description'
                                            : headings[_sortColumnIndex] ==
                                                  'Location'
                                            ? 'location'
                                            : headings[_sortColumnIndex] ==
                                                  'Start Date'
                                            ? 'start_date'
                                            : headings[_sortColumnIndex] ==
                                                  'End Date'
                                            ? 'end_date'
                                            : headings[_sortColumnIndex]
                                                  .toLowerCase(),
                                        ascending: _sortAscending,
                                      );
                                    },
                                  ),
                                ),
                                if (_showSuggestions)
                                  Positioned(
                                    top: 40,
                                    left: 0,
                                    right: 0,
                                    child: Material(
                                      elevation: 4,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: _suggestions.map((
                                            suggestion,
                                          ) {
                                            return ListTile(
                                              title: Text(suggestion),
                                              onTap: () {
                                                setState(() {
                                                  _searchQuery = suggestion;
                                                  _showSuggestions = false;
                                                });
                                                _fetchProjects(
                                                  sortBy:
                                                      headings[_sortColumnIndex] ==
                                                          'Project'
                                                      ? 'name'
                                                      : headings[_sortColumnIndex] ==
                                                            'Description'
                                                      ? 'description'
                                                      : headings[_sortColumnIndex] ==
                                                            'Location'
                                                      ? 'location'
                                                      : headings[_sortColumnIndex] ==
                                                            'Start Date'
                                                      ? 'start_date'
                                                      : headings[_sortColumnIndex] ==
                                                            'End Date'
                                                      ? 'end_date'
                                                      : headings[_sortColumnIndex]
                                                            .toLowerCase(),
                                                  ascending: _sortAscending,
                                                );
                                              },
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ShadButton(
                        child: const Text('Create Project'),
                        onPressed: () {
                          showShadDialog(
                            context: context,
                            builder: (context) => const ProjectCreationDialog(),
                          ).then((_) => _fetchProjects());
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
                    width: double.infinity,
                    child: _projects.isEmpty
                        ? const Center(child: Text('No projects found.'))
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: 1200, // or some other appropriate width
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ShadTable(
                                  columnCount: headings.length,
                                  rowCount: _filteredProjects.length,
                                  header: (context, column) {
                                    return ShadTableCell.header(
                                      alignment: Alignment.center,
                                      child: headings[column] == 'Actions'
                                          ? Text(headings[column])
                                          : GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (_sortColumnIndex ==
                                                      column) {
                                                    _sortAscending =
                                                        !_sortAscending;
                                                  } else {
                                                    _sortColumnIndex = column;
                                                    _sortAscending = true;
                                                  }
                                                  final sortBy =
                                                      headings[column] ==
                                                          'Project'
                                                      ? 'name'
                                                      : headings[column] ==
                                                            'Description'
                                                      ? 'description'
                                                      : headings[column] ==
                                                            'Location'
                                                      ? 'location'
                                                      : headings[column] ==
                                                            'Start Date'
                                                      ? 'start_date'
                                                      : headings[column] ==
                                                            'End Date'
                                                      ? 'end_date'
                                                      : headings[column]
                                                            .toLowerCase();
                                                  _fetchProjects(
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
                                                  if (_sortColumnIndex ==
                                                      column)
                                                    Icon(
                                                      _sortAscending
                                                          ? Icons.arrow_upward
                                                          : Icons
                                                                .arrow_downward,
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
                                      return const FixedTableSpanExtent(150);
                                    } // Project
                                    if (index == 1) {
                                      return const FixedTableSpanExtent(200);
                                    } // Description
                                    if (index == 2) {
                                      return const FixedTableSpanExtent(120);
                                    } // Location
                                    if (index == 3) {
                                      return const FixedTableSpanExtent(120);
                                    } // Status
                                    if (index == 4) {
                                      return const FixedTableSpanExtent(120);
                                    } // Start Date
                                    if (index == 5) {
                                      return const FixedTableSpanExtent(120);
                                    } // End Date
                                    return const FixedTableSpanExtent(
                                      100,
                                    ); // Actions
                                  },
                                  builder: (context, index) {
                                    final project =
                                        _filteredProjects[index.row];
                                    final data = [
                                      project['name'],
                                      project['description'] ?? 'N/A',
                                      project['location'] ?? 'N/A',
                                      project['status'],
                                      project['start_date']?.toString() ??
                                          'N/A',
                                      project['end_date']?.toString() ?? 'N/A',
                                    ];

                                    if (index.column == 6) {
                                      // Actions column
                                      return ShadTableCell(
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Add action buttons here if needed
                                            // For now, we'll just have a placeholder
                                            const Icon(Icons.more_vert),
                                          ],
                                        ),
                                      );
                                    }

                                    return ShadTableCell(
                                      alignment: Alignment.center,
                                      child: Text(data[index.column]),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
