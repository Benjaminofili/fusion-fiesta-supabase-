import 'package:uuid/uuid.dart';
import '../../models/event_model.dart';
import '../../storage/hive_manager.dart';
import '../../supabase_manager.dart';
import 'auth_service.dart';

class EventService {
  static final _supabase = SupabaseManager.client;

  // Create event
  static Future<Map<String, dynamic>> createEvent({
    required String title,
    required String description,
    required String location,
    required DateTime dateTime,
    required double cost,
    required int capacity,
  }) async {
    try {
      final user = EnhancedAuthService.getCurrentUser();
      if (user == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      final event = EventModel(
        id: const Uuid().v4(),
        title: title,
        description: description,
        location: location,
        dateTime: dateTime,
        createdBy: user.id,
        cost: cost,
        capacity: capacity,
        createdAt: DateTime.now(),
      );

      // Save to Supabase
      try {
        await _supabase.from('events').insert({
          'id': event.id,
          'title': event.title,
          'description': event.description,
          'venue': event.location,
          'date': event.dateTime.toIso8601String().split('T')[0],
          'time': '${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}',
          'organizer_id': event.createdBy,
          'cost': event.cost,
          'max_participants': event.capacity,
          'category': 'general',
          'status': 'pending',
        });
      } catch (e) {
        print('Supabase save failed, saving locally: $e');
      }

      // Save locally
      await HiveManager.eventsBox.put(event.id, event);

      return {'success': true, 'event': event};

    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get all events
  static Future<Map<String, dynamic>> getAllEvents() async {
    try {
      List<EventModel> events = [];

      // Try to fetch from Supabase first
      try {
        final response = await _supabase
            .from('events')
            .select()
            .eq('status', 'approved')
            .order('date', ascending: true);

        events = response.map<EventModel>((data) {
          return EventModel.fromJson({
            'id': data['id'],
            'title': data['title'],
            'description': data['description'],
            'location': data['venue'],
            'datetime': '${data['date']}T${data['time']}:00.000Z',
            'created_by': data['organizer_id'],
            'cost': data['cost'],
            'capacity': data['max_participants'],
            'created_at': data['created_at'],
          });
        }).toList();

        // Cache locally
        for (final event in events) {
          await HiveManager.eventsBox.put(event.id, event);
        }

      } catch (e) {
        print('Fetching from Supabase failed, using local data: $e');
        // Fallback to local data
        events = HiveManager.eventsBox.values.toList();
      }

      return {'success': true, 'events': events};

    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Register for event
  static Future<Map<String, dynamic>> registerForEvent(String eventId) async {
    try {
      final user = EnhancedAuthService.getCurrentUser();
      if (user == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      if (user.role != 'participant') {
        return {'success': false, 'error': 'Only participants can register for events'};
      }

      final registration = {
        'id': const Uuid().v4(),
        'user_id': user.id,
        'event_id': eventId,
        'status': 'registered',
        'registered_at': DateTime.now().toIso8601String(),
      };

      // Save to Supabase
      try {
        await _supabase.from('registrations').insert(registration);
      } catch (e) {
        print('Supabase registration failed, saving locally: $e');
        // Add to offline queue
        await HiveManager.offlineBox.add({
          'type': 'registration',
          'data': registration,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      return {'success': true, 'message': 'Successfully registered for event'};

    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}