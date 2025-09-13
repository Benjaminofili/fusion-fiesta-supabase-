// lib/core/services/feedback_service.dart
import 'package:uuid/uuid.dart';
import '../../models/feedback_model.dart';
import '../../storage/hive_manager.dart';
import '../../supabase_manager.dart';
import 'auth_service.dart';
import 'sync_service.dart';

class FeedbackService {
  static final _supabase = SupabaseManager.client;

  static Future<Map<String, dynamic>> submitFeedback({
    required String eventId,
    required int rating,
    String? message,
  }) async {
    try {
      final user = EnhancedAuthService.getCurrentUser();
      if (user == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      final feedback = FeedbackModel(
        id: const Uuid().v4(),
        userId: user.id,
        eventId: eventId,
        rating: rating,
        message: message,
        createdAt: DateTime.now(),
      );

      bool isOnline = await SyncService.checkConnectivityAndSync();

      if (isOnline) {
        await _supabase.from('feedback').insert(feedback.toMap());
      } else {
        await HiveManager.offlineBox.add({
          'type': 'feedback',
          'data': feedback.toMap(),
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      await HiveManager.feedbackBox.put(feedback.id, feedback);

      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getEventFeedback(String eventId) async {
    try {
      List<FeedbackModel> feedbacks = [];

      bool isOnline = await SyncService.checkConnectivityAndSync();

      if (isOnline) {
        final response = await _supabase
            .from('feedback')
            .select()
            .eq('event_id', eventId);

        feedbacks = response.map((data) => FeedbackModel.fromMap(data)).toList();
      } else {
        feedbacks = HiveManager.feedbackBox.values
            .where((f) => f.eventId == eventId)
            .toList();
      }

      return {'success': true, 'feedbacks': feedbacks};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}