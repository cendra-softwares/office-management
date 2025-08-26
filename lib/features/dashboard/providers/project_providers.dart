import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:office_management/core/services/supabase_service.dart';

// Provider to expose the SupabaseService instance
final supabaseServiceProvider = Provider((ref) => SupabaseService());

// Provider to fetch all projects once
final allProjectsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  // Fetch projects without any sorting or filtering
  return await supabaseService.fetchAllProjects();
});

// State for sorting
class ProjectSortState {
  final int columnIndex;
  final bool ascending;

  ProjectSortState({this.columnIndex = 0, this.ascending = true});

  ProjectSortState copyWith({int? columnIndex, bool? ascending}) {
    return ProjectSortState(
      columnIndex: columnIndex ?? this.columnIndex,
      ascending: ascending ?? this.ascending,
    );
  }
}

// Provider for sorting state
final projectSortProvider = StateProvider<ProjectSortState>(
  (ref) => ProjectSortState(),
);

// Provider for search query
final projectSearchQueryProvider = StateProvider<String>((ref) => '');

// Provider for selected status filters
final projectStatusFilterProvider = StateProvider<List<String>>((ref) => []);

// Provider for filtered and sorted projects
final filteredAndSortedProjectsProvider = Provider<List<Map<String, dynamic>>>((
  ref,
) {
  final allProjectsAsync = ref.watch(allProjectsProvider);
  final sortState = ref.watch(projectSortProvider);
  final searchQuery = ref.watch(projectSearchQueryProvider);
  final statusFilters = ref.watch(projectStatusFilterProvider);

  // If data is still loading, return an empty list
  if (allProjectsAsync is! AsyncData<List<Map<String, dynamic>>>) {
    return [];
  }

  final allProjects = allProjectsAsync.value;

  // Filter projects based on search query
  List<Map<String, dynamic>> filteredProjects = allProjects;
  if (searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase();
    filteredProjects = allProjects.where((project) {
      final nameContains =
          project['name']?.toString().toLowerCase().contains(query) == true;
      final descriptionContains =
          project['description']?.toString().toLowerCase().contains(query) ==
          true;
      final locationContains =
          project['location']?.toString().toLowerCase().contains(query) == true;
      final statusContains =
          project['status']?.toString().toLowerCase().contains(query) == true;

      return nameContains ||
          descriptionContains ||
          locationContains ||
          statusContains;
    }).toList();
  }

  // Filter projects based on status filters
  if (statusFilters.isNotEmpty) {
    filteredProjects = filteredProjects.where((project) {
      final projectStatus = project['status'];
      final shouldInclude = statusFilters.contains(projectStatus);
      return shouldInclude;
    }).toList();
  }

  // Sort projects
  final headings = [
    'name',
    'description',
    'location',
    'status',
    'start_date',
    'end_date',
  ];

  List<Map<String, dynamic>> sortedProjects = List.from(filteredProjects);

  if (sortState.columnIndex >= 0 && sortState.columnIndex < headings.length) {
    final sortBy = headings[sortState.columnIndex];
    sortedProjects.sort((a, b) {
      final aValue = a[sortBy]?.toString() ?? '';
      final bValue = b[sortBy]?.toString() ?? '';

      if (sortState.ascending) {
        return aValue.compareTo(bValue);
      } else {
        return bValue.compareTo(aValue);
      }
    });
  }

  return sortedProjects;
});
