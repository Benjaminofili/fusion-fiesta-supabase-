import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../storage/hive_manager.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/registration_model.dart';
import '../models/feedback_model.dart';
import '../models/certificate_model.dart';
import '../models/notification_model.dart';
import '../models/media_gallery_model.dart';

class SupabaseManager {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://rpkbppzmjarmbwvexvwi.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJwa2JwcHptamFybWJ3dmV4dndpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc4NDEyMzIsImV4cCI6MjA3MzQxNzIzMn0.n8yEy7J6f_m-VaTIArXzaoqGJmiILU2EjOaHNvP5VKE',
    );

    // Subscribe to real-time updates for all tables with explicit type arguments
    _subscribeToTable<UserModel>('users', UserModel.fromMap, HiveManager.usersBox);
    _subscribeToTable<EventModel>('events', EventModel.fromMap, HiveManager.eventsBox);
    _subscribeToTable<RegistrationModel>('registrations', RegistrationModel.fromMap, HiveManager.registrationsBox);
    _subscribeToTable<FeedbackModel>('feedback', FeedbackModel.fromMap, HiveManager.feedbackBox);
    _subscribeToTable<CertificateModel>('certificates', CertificateModel.fromMap, HiveManager.certificatesBox);
    _subscribeToTable<MediaGalleryModel>('media_gallery', MediaGalleryModel.fromMap, HiveManager.mediaGalleryBox);
    _subscribeToTable<NotificationModel>('notifications', NotificationModel.fromMap, HiveManager.notificationsBox);
  }

  static SupabaseClient get client => Supabase.instance.client;

  // Helper method to subscribe to a table with explicit type parameter
  static void _subscribeToTable<T extends HiveObject>(
      String tableName,
      T Function(Map<String, dynamic>) fromMap,
      Box<T> box,
      ) {
    try {
      final channel = Supabase.instance.client
          .channel('public:$tableName')
          .onPostgresChanges(
        event: PostgresChangeEvent.all,
        callback: (payload) {
          print('Real-time update on $tableName: $payload');
          _handleRealTimeUpdate(payload, fromMap, box);
        },
      )
          .subscribe();

      // No direct onError method; handle subscription state or errors via try-catch
      print('Subscribed to $tableName channel successfully');
    } catch (e) {
      print('Subscription error on $tableName: $e');
    }
  }

  // Helper method to handle real-time updates
  static void _handleRealTimeUpdate<T extends HiveObject>(
      PostgresChangePayload payload,
      T Function(Map<String, dynamic>) fromMap,
      Box<T> box,
      ) {
    final record = payload.newRecord;
    final oldRecord = payload.oldRecord;

    if (record != null) {
      final item = fromMap(record);
      if (item != null) {
        box.put(item.key, item);
      }
    } else if (oldRecord != null) {
      final item = fromMap(oldRecord);
      if (item != null) {
        box.delete(item.key);
      }
    }
    print('Item synced to Hive');
  }
}