import 'package:uuid/uuid.dart';
import '../../models/notification_model.dart';
import '../../storage/hive_manager.dart';
import '../../supabase_manager.dart';
import '../constants/app_constants.dart';
import 'AppError.dart';
import 'sync_service.dart';

class NotificationService {
  static final _supabase = SupabaseManager.client;

  static Future<Map<String, dynamic>> createNotification({
    required String userId,
    required String title,
    required String message,
    String type = 'info',
  }) async {
    try {
      final notification = NotificationModel(
        id: const Uuid().v4(),
        userId: userId,
        title: title,
        message: message,
        isRead: false,
        createdAt: DateTime.now(),
        type: type,
      );

      bool isOnline = await SyncService.checkConnectivityAndSync();

      if (isOnline) {
        await _supabase.from('notifications').insert(notification.toMap());
      } else {
        await HiveManager.offlineBox.add({
          'type': 'notification_creation',
          'data': notification.toMap(),
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      await HiveManager.notificationsBox.put(notification.id, notification);

      return {'success': true, 'notification': notification};
    } catch (e) {
      return {
        'success': false,
        'error': AppError.fromException(e).message,
      };
    }
  }

  static Future<Map<String, dynamic>> getNotifications(String userId) async {
    try {
      List<NotificationModel> notifications = [];

      bool isOnline = await SyncService.checkConnectivityAndSync();

      if (isOnline) {
        final response = await _supabase
            .from('notifications')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        notifications = response.map((data) => NotificationModel.fromMap(data)).toList();

        for (final notif in notifications) {
          await HiveManager.notificationsBox.put(notif.id, notif);
        }
      } else {
        notifications = HiveManager.notificationsBox.values
            .where((n) => n.userId == userId)
            .toList();
      }

      return {'success': true, 'notifications': notifications};
    } catch (e) {
      return {
        'success': false,
        'error': AppError.fromException(e).message,
      };
    }
  }

  static Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    try {
      bool isOnline = await SyncService.checkConnectivityAndSync();

      if (isOnline) {
        await _supabase
            .from('notifications')
            .update({'is_read': true})
            .eq('id', notificationId);
      } else {
        await HiveManager.offlineBox.add({
          'type': 'notification_read',
          'data': {'id': notificationId},
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      final notif = HiveManager.notificationsBox.get(notificationId);
      if (notif != null) {
        notif.isRead = true;
        await notif.save();
      }

      return {'success': true};
    } catch (e) {
      return {
        'success': false,
        'error': AppError.fromException(e).message,
      };
    }
  }
}