import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
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
}