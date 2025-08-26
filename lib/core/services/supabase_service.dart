import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      print('Fetching user profile for user ID: $userId');
      final response = await client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();
      print('User profile fetched successfully: $response');
      return response;
    } catch (e) {
      // Handle error, e.g., user profile not found
      print('Error fetching user profile for user ID: $userId. Error: $e');
      return null;
    }
  }

  /// Fetches a list of users with their IDs and emails for dropdown selection.
  /// This queries the user_profiles table which extends auth.users.
  Future<List<Map<String, dynamic>>> fetchUsersForDropdown() async {
    try {
      // Query the user_profiles table which has a relationship with auth.users
      // This is the correct way to access user data according to the database guide
      // Fetch users from user_profiles table for the dropdown
      // We'll display the full_name column which is in the user_profiles table
      final List<Map<String, dynamic>> users = await client
          .from('user_profiles')
          .select('id, full_name');

      return users;
    } catch (e) {
      print('Error fetching users for dropdown: $e');
      // Return an empty list or rethrow the error based on your error handling strategy
      return [];
    }
  }

  /// Creates a new company in the companies table.
  ///
  /// [name] The name of the company.
  /// [ownerId] The UUID of the owner (from auth.users).
  /// [status] The status of the company (trialing, active, expired, canceled).
  /// [isActive] Whether the company is active.
  ///
  /// Returns the created company data or null if an error occurs.
  Future<Map<String, dynamic>?> createCompany({
    required String name,
    required String ownerId,
    required String status,
    required bool isActive,
    DateTime? trialEndDate, // Added trialEndDate parameter
  }) async {
    try {
      // Log current user information
      final currentUser = client.auth.currentUser;
      print('Current user: ${currentUser?.id}');
      print('Current user email: ${currentUser?.email}');

      // Try to get user role
      try {
        final userRoleResponse = await client
            .from('user_profiles')
            .select('role')
            .eq('id', currentUser?.id ?? '')
            .single();
        print('User role: ${userRoleResponse['role']}');
      } catch (roleError) {
        print('Error fetching user role: $roleError');
      }

      final response = await client
          .from('companies')
          .insert({
            'name': name,
            'owner_id': ownerId,
            'status': status,
            'is_active': isActive,
            if (trialEndDate != null)
              'trial_end_date': trialEndDate.toIso8601String(),
            // created_at and updated_at will use their default values
          })
          .select()
          .single();

      // After creating the company, update the owner's user profile with the company ID
      if (response != null) {
        final companyId = response['id'] as String;
        try {
          await client
              .from('user_profiles')
              .update({'company_id': companyId})
              .eq('id', ownerId)
              .select()
              .single();
          print('User profile updated with company ID: $companyId');
        } catch (e) {
          print('Error updating user profile with company ID: $e');
          // We might want to handle this error, perhaps by deleting the created company
          // or by implementing a transaction rollback mechanism
        }
      }

      print('Company created successfully: $response');
      return response;
    } catch (e) {
      print('Error creating company: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllCompanies({
    String sortBy = 'name',
    bool ascending = true,
  }) async {
    try {
      final response = await client
          .from('companies')
          .select('*, owner:owner_id(full_name)')
          .order(sortBy, ascending: ascending);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error fetching companies: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> updateCompanyOwner({
    required String companyId,
    required String newOwnerId,
  }) async {
    try {
      final response = await client
          .from('companies')
          .update({'owner_id': newOwnerId})
          .eq('id', companyId)
          .select()
          .single();
      print('Company owner updated successfully: $response');
      return response;
    } catch (e) {
      print('Error updating company owner: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllUsers({
    String sortBy = 'full_name',
    bool ascending = true,
  }) async {
    try {
      final response = await client
          .from('user_profiles')
          .select('*, company:company_id(name)')
          .order(sortBy, ascending: ascending);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> updateUser({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await client
          .from('user_profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();
      print('User updated successfully: $response');
      return response;
    } catch (e) {
      print('Error updating user: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllProjects({
    String sortBy = 'name',
    bool ascending = true,
  }) async {
    try {
      // Get the current user's company ID
      final user = client.auth.currentUser;
      if (user == null) return [];

      final userProfile = await getUserProfile(user.id);
      final companyId = userProfile?['company_id'];

      if (companyId == null) return [];

      final response = await client
          .from('projects')
          .select(
            'id, name, description, location, address, contact_phone, status, start_date, end_date',
          )
          .eq('company_id', companyId)
          .order(sortBy, ascending: ascending);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error fetching projects: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> createProject({
    required String name,
    String? description,
    String? location,
    String? address,
    String? contactPhone,
    required String status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Get the current user's company ID
      final user = client.auth.currentUser;
      if (user == null) return null;

      final userProfile = await getUserProfile(user.id);
      final companyId = userProfile?['company_id'];

      if (companyId == null) return null;

      final response = await client
          .from('projects')
          .insert({
            'name': name,
            'description': description,
            'location': location,
            'address': address,
            'contact_phone': contactPhone,
            'status': status,
            'company_id': companyId,
            if (startDate != null) 'start_date': startDate.toIso8601String(),
            if (endDate != null) 'end_date': endDate.toIso8601String(),
          })
          .select()
          .single();

      print('Project created successfully: $response');
      return response;
    } catch (e) {
      print('Error creating project: $e');
      return null;
    }
  }
  Future<Map<String, dynamic>?> updateProject({
    required String id,
    required String name,
    String? description,
    String? location,
    String? address,
    String? contactPhone,
    required String status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await client
          .from('projects')
          .update({
            'name': name,
            'description': description,
            'location': location,
            'address': address,
            'contact_phone': contactPhone,
            'status': status,
            if (startDate != null) 'start_date': startDate.toIso8601String(),
            if (endDate != null) 'end_date': endDate.toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      print('Project updated successfully: $response');
      return response;
    } catch (e) {
      print('Error updating project: $e');
      return null;
    }
  }
}
