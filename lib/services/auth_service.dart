import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? getCurrentUser() => _client.auth.currentUser;

  bool isAuthenticated() => _client.auth.currentSession != null;

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      return await _client.auth.signUp(email: email, password: password);
    } catch (e) {
      debugPrint('❌ Signup error: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('❌ Login error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      debugPrint('✅ Signed out');
    } catch (e) {
      debugPrint('❌ Signout error: $e');
      rethrow;
    }
  }
}
