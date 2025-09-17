import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_model.dart';
import '../../storage/hive_manager.dart';
import '../../storage/auth_storage.dart';
import '../../supabase_manager.dart';
import '../constants/app_constants.dart';
import 'sync_service.dart';

class EnhancedAuthService {
  static final _supabase = SupabaseManager.client;

  // Register with enhanced error handling
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? enrollmentNumber,
    String? department,
    String? profilePictureUrl, // Added optional profile picture URL
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
        'profile_picture_url': profilePictureUrl, // Added
        'approved': role != AppConstants.roleStaff, // Staff needs approval
      };

      await _supabase.from('users').insert(userRecord);

      // Create local user model
      final user = UserModel.fromMap({
        ...userRecord,
        'password': password, // Store locally for offline access
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
        'needsEmailVerification': true,
      };

    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Enhanced login with offline support
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Try online login first
      final authResult = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResult.user != null) {
        // Fetch user details from database
        final userResponse = await _supabase
            .from('users')
            .select()
            .eq('id', authResult.user!.id)
            .single();

        // Create user model
        final user = UserModel.fromMap({
          ...userResponse,
          'password': password, // Store for offline
        });

        // Save session
        await HiveManager.usersBox.put(user.id, user);
        await AuthStorage.persistSession(user);

        return {
          'success': true,
          'user': user,
          'isOnline': true,
        };
      }

    } catch (e) {
      // Fallback to offline login
      print('Online login failed, trying offline: $e');
    }

    // Offline login attempt
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

  // Get current user
  static UserModel? getCurrentUser() {
    return AuthStorage.loadSession();
  }

  // Logout
  static Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('Supabase logout error: $e');
    }
    await AuthStorage.clearSession();
  }

  // Check if authenticated
  static bool isAuthenticated() {
    return getCurrentUser() != null;
  }

  // Update profile picture
  static Future<Map<String, dynamic>> updateProfilePicture(String url) async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      bool isOnline = await SyncService.checkConnectivityAndSync();

      if (isOnline) {
        await _supabase
            .from('users')
            .update({'profile_picture_url': url})
            .eq('id', user.id);
      } else {
        await HiveManager.offlineBox.add({
          'type': 'profile_picture_update',
          'data': {'id': user.id, 'profile_picture_url': url},
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      // Update local user
      user.profilePictureUrl = url;
      await HiveManager.usersBox.put(user.id, user);
      await AuthStorage.persistSession(user);

      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Upload profile picture
  static Future<Map<String, dynamic>> uploadProfilePicture(File file) async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      final fileExt = file.path.split('.').last;
      final fileName = '${user.id}.${fileExt}';
      final filePath = 'profile_pictures/$fileName';

      bool isOnline = await SyncService.checkConnectivityAndSync();

      String? url;
      if (isOnline) {
        final response = await _supabase.storage
            .from('profile_pictures')
            .upload(filePath, file);

        if (response.isEmpty) {
          return {'success': false, 'error': 'Upload failed'};
        }

        url = _supabase.storage
            .from('profile_pictures')
            .getPublicUrl(filePath);

        await updateProfilePicture(url);
      } else {
        // Save locally and queue for sync
        final localDir = await getApplicationDocumentsDirectory();
        final localPath = '${localDir.path}/$filePath';
        await file.copy(localPath);

        await HiveManager.offlineBox.add({
          'type': 'profile_picture_upload',
          'data': {
            'id': user.id,
            'file_path': filePath,
            'local_path': localPath,
          },
          'timestamp': DateTime.now().toIso8601String(),
        });

        // Update local URL as placeholder
        url = 'local:$localPath';
        await updateProfilePicture(url);
      }

      return {'success': true, 'url': url};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}