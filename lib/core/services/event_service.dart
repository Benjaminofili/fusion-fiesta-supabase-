import 'package:uuid/uuid.dart';
import '../../models/event_model.dart';
import '../../models/registration_model.dart';
import '../../storage/hive_manager.dart';
import '../../supabase_manager.dart';
import '../constants/app_constants.dart';
import 'auth_service.dart';
import 'sync_service.dart';

class EventService {
  static final _supabase = SupabaseManager.client;

  static Future<Map<String, dynamic>> createEvent({
    required String title,
    required String description,
    required String category,
    required String department,
    required DateTime dateTime,
    required String venue,
    required int maxParticipants,
    String? bannerUrl,
    required double cost,
  }) async {
    try {
      final user = EnhancedAuthService.getCurrentUser();
      if (user == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      if (user.role != AppConstants.roleStaff) {
        return {'success': false, 'error': 'Only staff can create events'};
      }

      final event = EventModel(
        id: const Uuid().v4(),
        title: title,
        description: description,
        category: category,
        department: department,
        dateTime: dateTime,
        venue: venue,
        status: AppConstants.statusPending,
        organizerId: user.id,
        maxParticipants: maxParticipants,
        currentParticipants: 0, // Default value
        bannerUrl: bannerUrl,
        cost: cost,
        registrationDeadline: null, // Default null
        eventType: 'academic', // Default value, adjust as needed
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(), // Added required field
      );

      final eventMap = {
        'id': event.id,
        'title': event.title,
        'description': event.description,
        'category': event.category,
        'department': event.department,
        'date': dateTime.toIso8601String().split('T')[0], // Split for Supabase
        'time': '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
        'venue': event.venue,
        'status': event.status,
        'organizer_id': event.organizerId,
        'max_participants': event.maxParticipants,
        'current_participants': event.currentParticipants,
        'banner_url': event.bannerUrl,
        'cost': event.cost,
        'event_type': event.eventType, // Added to match schema
        'created_at': event.createdAt.toIso8601String(),
        'updated_at': event.updatedAt.toIso8601String(), // Added to match schema
      };

      bool isOnline = await SyncService.checkConnectivityAndSync();

      if (isOnline) {
        await _supabase.from('events').insert(eventMap);
      } else {
        await HiveManager.offlineBox.add({
          'type': 'event_creation',
          'data': eventMap,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      await HiveManager.eventsBox.put(event.id, event);

      return {'success': true, 'event': event};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getUpcomingEvents() async {
    try {
      List<EventModel> events = [];

      bool isOnline = await SyncService.checkConnectivityAndSync();

      if (isOnline) {
        final response = await _supabase
            .from('events')
            .select()
            .gt('date', DateTime.now().toIso8601String().split('T')[0]) // Use 'date' for comparison
            .eq('status', AppConstants.statusApproved)
            .order('date', ascending: true); // Order by date

        events = response.map((data) => EventModel.fromMap(data)).toList();

        for (final event in events) {
          await HiveManager.eventsBox.put(event.id, event);
        }
      } else {
        events = HiveManager.eventsBox.values
            .where((e) => e.dateTime.isAfter(DateTime.now()) && e.status == AppConstants.statusApproved)
            .toList();
      }

      return {'success': true, 'events': events};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getRegisteredEvents(String userId) async {
    try {
      List<EventModel> events = [];

      bool isOnline = await SyncService.checkConnectivityAndSync();

      if (isOnline) {
        final response = await _supabase
            .from('registrations')
            .select('events(*)')
            .eq('user_id', userId)
            .eq('status', 'registered');

        events = response
            .where((data) => data['events'] != null)
            .map((data) => EventModel.fromMap(data['events']))
            .toList();
      } else {
        final registrations = HiveManager.registrationsBox.values
            .where((r) => r.userId == userId && r.status == 'registered')
            .toList();

        for (final reg in registrations) {
          final event = HiveManager.eventsBox.get(reg.eventId);
          if (event != null) {
            events.add(event);
          }
        }
      }

      return {'success': true, 'events': events};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> registerForEvent(String eventId) async {
    try {
      final user = EnhancedAuthService.getCurrentUser();
      if (user == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      final registration = RegistrationModel(
        id: const Uuid().v4(),
        userId: user.id,
        eventId: eventId,
        status: 'registered',
        registeredAt: DateTime.now(),
      );

      bool isOnline = await SyncService.checkConnectivityAndSync();

      if (isOnline) {
        await _supabase.from('registrations').insert(registration.toMap());
      } else {
        await HiveManager.offlineBox.add({
          'type': 'registration',
          'data': registration.toMap(),
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      await HiveManager.registrationsBox.put(registration.id, registration);

      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getCreatedEvents(String organizerId) async {
    try {
      List<EventModel> events = [];

      bool isOnline = await SyncService.checkConnectivityAndSync();

      if (isOnline) {
        final response = await _supabase
            .from('events')
            .select()
            .eq('organizer_id', organizerId)
            .order('created_at', ascending: false);

        events = response.map((data) => EventModel.fromMap(data)).toList();

        for (final event in events) {
          await HiveManager.eventsBox.put(event.id, event);
        }
      } else {
        events = HiveManager.eventsBox.values
            .where((e) => e.organizerId == organizerId)
            .toList();
      }

      return {'success': true, 'events': events};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getEventStatistics(String eventId) async {
    try {
      int registrations = 0;
      double averageFeedback = 0.0;

      bool isOnline = await SyncService.checkConnectivityAndSync();

      if (isOnline) {
        final regResponse = await _supabase
            .from('registrations')
            .select('count(*)')
            .eq('event_id', eventId)
            .eq('status', 'registered');

        registrations = regResponse[0]['count'] ?? 0;

        final feedbackResponse = await _supabase
            .from('feedback')
            .select('rating')
            .eq('event_id', eventId);

        if (feedbackResponse.isNotEmpty) {
          averageFeedback = feedbackResponse.map((f) => f['rating'] as int).reduce((a, b) => a + b) / feedbackResponse.length;
        }
      } else {
        registrations = HiveManager.registrationsBox.values
            .where((r) => r.eventId == eventId && r.status == 'registered')
            .length;

        final feedbacks = HiveManager.feedbackBox.values
            .where((f) => f.eventId == eventId)
            .toList();

        if (feedbacks.isNotEmpty) {
          averageFeedback = feedbacks.map((f) => f.rating).reduce((a, b) => a + b) / feedbacks.length;
        }
      }

      return {'success': true, 'registrations': registrations, 'averageFeedback': averageFeedback};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getPendingEvents() async {
    try {
      List<EventModel> events = [];

      bool isOnline = await SyncService.checkConnectivityAndSync();

      if (isOnline) {
        final response = await _supabase
            .from('events')
            .select()
            .eq('status', AppConstants.statusPending)
            .order('created_at', ascending: true);

        events = response.map((data) => EventModel.fromMap(data)).toList();
      } else {
        events = HiveManager.eventsBox.values
            .where((e) => e.status == AppConstants.statusPending)
            .toList();
      }

      return {'success': true, 'events': events};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> approveEvent(String eventId) async {
    try {
      bool isOnline = await SyncService.checkConnectivityAndSync();

      if (isOnline) {
        await _supabase
            .from('events')
            .update({'status': AppConstants.statusApproved})
            .eq('id', eventId);
      } else {
        await HiveManager.offlineBox.add({
          'type': 'event_approval',
          'data': {'id': eventId},
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      // Since status is final, fetch and create a new instance
      final eventData = await _supabase.from('events').select().eq('id', eventId).single();
      final updatedEvent = EventModel.fromMap(eventData);
      await HiveManager.eventsBox.put(updatedEvent.id, updatedEvent);

      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getAllEvents() async {
    try {
      List<EventModel> events = [];

      bool isOnline = await SyncService.checkConnectivityAndSync();

      if (isOnline) {
        final response = await _supabase
            .from('events')
            .select()
            .eq('status', AppConstants.statusApproved)
            .order('date', ascending: true);

        events = response.map((data) => EventModel.fromMap(data)).toList();

        for (final event in events) {
          await HiveManager.eventsBox.put(event.id, event);
        }
      } else {
        events = HiveManager.eventsBox.values
            .where((e) => e.status == AppConstants.statusApproved)
            .toList();
      }

      return {'success': true, 'events': events};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}