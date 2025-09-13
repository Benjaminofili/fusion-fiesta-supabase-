import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../storage/hive_manager.dart';
import '../../supabase_manager.dart';
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
            case 'registration':
              await _supabase.from('registrations').insert(data['data']);
              break;
            case 'feedback':
              await _supabase.from('feedback').insert(data['data']);
              break;
            case 'otp_insertion':
              final response = await http.post(
                Uri.parse('https://qtfedzzccivfbhpnnaqq.supabase.co/functions/v1/insert-otp'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(data['data']),
              );
              if (response.statusCode != 200) {
                continue; // Keep in queue if failed
              }
              break;
          }

          await HiveManager.offlineBox.delete(item.key);
        } catch (e) {
          print('Failed to sync item: $e');
        }
      }
    } catch (e) {
      print('Sync failed: $e');
    }
  }

  // Check connectivity and sync
  static Future<bool> checkConnectivityAndSync() async {
    try {
      // Simple connectivity check by trying to fetch from Supabase
      await _supabase.from('users').select('id').limit(1);

      // If successful, sync offline data
      await syncOfflineData();

      return true;
    } catch (e) {
      return false;
    }
  }
}