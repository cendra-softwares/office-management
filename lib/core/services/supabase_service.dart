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
            if (trialEndDate != null) 'trial_end_date': trialEndDate.toIso8601String(),
            // created_at and updated_at will use their default values
          })
          .select()
          .single();

      print('Company created successfully: $response');
      return response;
    } catch (e) {
      print('Error creating company: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllCompanies() async {
    try {
      final response = await client.from('companies').select('*, owner:owner_id(full_name)');
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error fetching companies: $e');
      return [];
    }
  }
}
