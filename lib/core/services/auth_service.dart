import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../../models/user_model.dart';
import '../../storage/hive_manager.dart';
import '../../storage/auth_storage.dart';
import '../../supabase_manager.dart';
import '../constants/app_constants.dart';
import 'AppError.dart';

class EnhancedAuthService {
  static final _supabase = SupabaseManager.client;

  // Register without OTP
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? enrollmentNumber,
    String? department,
  }) async {
    try {
      // Validation
      if (role == AppConstants.roleParticipant) {
        if (enrollmentNumber == null || department == null) {
          return {
            'success': false,
            'error': 'Participants must provide enrollment number and department'
          };
        }
      }

      // Create user in Supabase Auth
      final authResult = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResult.user == null) {
        return {
          'success': false,
          'error': 'Failed to create user account'
        };
      }

      // Create user record in database
      final userRecord = {
        'id': authResult.user!.id,
        'name': name,
        'email': email,
        'role': role,
        'phone': phone,
        'enrollment_number': enrollmentNumber,
        'department': department,
        'approved': role != AppConstants.roleStaff,
      };

      await _supabase.from('users').insert(userRecord);

      // Create local user model
      final user = UserModel.fromMap({
        ...userRecord,
        'password': password,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'last_modified': DateTime.now().toIso8601String(),
      });

      // Save locally
      await HiveManager.usersBox.put(user.id, user);
      await AuthStorage.persistSession(user);

      return {
        'success': true,
        'user': user,
      };
    } catch (e) {
      return {
        'success': false,
        'error': AppError.fromException(e).message,
      };
    }
  }

  // Remove verifyOtp method since OTP is no longer used
  // static Future<Map<String, dynamic>> verifyOtp({required String email, required String code}) async { ... }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final authResult = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResult.user != null) {
        final userResponse = await _supabase
            .from('users')
            .select()
            .eq('id', authResult.user!.id)
            .single();

        final user = UserModel.fromMap({
          ...userResponse,
          'password': password,
        });

        await HiveManager.usersBox.put(user.id, user);
        await AuthStorage.persistSession(user);

        return {
          'success': true,
          'user': user,
          'isOnline': true,
        };
      }
    } catch (e) {
      print('Online login failed, trying offline: $e');
    }

    try {
      final localUser = HiveManager.usersBox.values
          .where((u) => u.email.toLowerCase() == email.toLowerCase())
          .firstOrNull;

      if (localUser != null && localUser.password == password) {
        await AuthStorage.persistSession(localUser);
        return {
          'success': true,
          'user': localUser,
          'isOnline': false,
        };
      }
    } catch (e) {
      print('Offline login failed: $e');
    }

    return {
      'success': false,
      'error': 'Invalid email or password',
    };
  }

  static UserModel? getCurrentUser() {
    return AuthStorage.loadSession();
  }

  static Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('Supabase logout error: $e');
    }
    await AuthStorage.clearSession();
  }

  static bool isAuthenticated() {
    return getCurrentUser() != null;
  }
}