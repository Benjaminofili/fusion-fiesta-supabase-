import 'dart:io';
import 'dart:convert';
import '../../storage/hive_manager.dart';
import '../../supabase_manager.dart';
import '../constants/app_constants.dart';
import 'AppError.dart';
import 'auth_service.dart';

class SyncService {
  static final _supabase = SupabaseManager.client;

  // Sync offline data when online
  static Future<void> syncOfflineData() async {
    try {
      final offlineQueue = HiveManager.offlineBox.values.toList();

      for (final item in offlineQueue) {
        try {
          final data = Map<String, dynamic>.from(item);

          switch (data['type']) {
            case 'event_creation':
              final eventData = data['data'] as Map<String, dynamic>;
              eventData['category'] ??= 'general';
              eventData['event_type'] ??= 'academic';
              eventData['current_participants'] ??= 0;
              await _supabase.from('events').insert(eventData);
              break;
            case 'registration':
              await _supabase.from('registrations').insert(data['data']);
              break;
            case 'feedback':
              await _supabase.from('feedback').insert(data['data']);
              break;
            case 'certificate_issue':
              await _supabase.from('certificates').insert(data['data']);
              break;
            case 'certificate_download':
              await _supabase
                  .from('certificates')
                  .update({'downloaded_at': data['data']['downloaded_at']})
                  .eq('id', data['data']['id']);
              break;
            case 'event_approval':
              await _supabase
                  .from('events')
                  .update({'status': AppConstants.statusApproved})
                  .eq('id', data['data']['id']);
              break;
            case 'notification_read':
              await _supabase
                  .from('notifications')
                  .update({'is_read': true})
                  .eq('id', data['data']['id']);
              break;
            case 'notification_creation':
              await _supabase.from('notifications').insert(data['data']);
              break;
            case 'bookmark_creation':
              await _supabase.from('bookmarks').insert(data['data']);
              break;
            case 'bookmark_deletion':
              await _supabase.from('bookmarks').delete().eq('id', data['data']['id']);
              break;
            case 'profile_picture_update':
              await _supabase
                  .from('users')
                  .update({'profile_picture_url': data['data']['profile_picture_url']})
                  .eq('id', data['data']['id']);
              break;
            case 'profile_picture_upload':
              final localPath = data['data']['local_path'] as String;
              final file = File(localPath);
              if (await file.exists()) {
                final filePath = data['data']['file_path'] as String;
                await _supabase.storage
                    .from('profile_pictures')
                    .upload(filePath, file);

                final url = _supabase.storage
                    .from('profile_pictures')
                    .getPublicUrl(filePath);

                await EnhancedAuthService.updateProfilePicture(url);
                await file.delete(); // Clean up local file
              }
              break;
          }

          await HiveManager.offlineBox.delete(item.key);
        } catch (e) {
          print('Failed to sync item: ${AppError.fromException(e).message}');
        }
      }
    } catch (e) {
      print('Sync failed: ${AppError.fromException(e).message}');
      throw AppError.fromException(e);
    }
  }

  static Future<bool> checkConnectivityAndSync() async {
    try {
      await _supabase.from('users').select('id').limit(1);
      await syncOfflineData();
      return true;
    } catch (e) {
      print('Connectivity check failed: ${AppError.fromException(e).message}');
      return false;
    }
  }
}