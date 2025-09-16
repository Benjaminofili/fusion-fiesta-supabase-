import '../../models/event_model.dart';
import '../../models/certificate_model.dart';
import '../../models/notification_model.dart';
import '../../models/feedback_model.dart';
import '../../storage/hive_manager.dart';
import '../../supabase_manager.dart';
import '../constants/app_constants.dart';
import 'AppError.dart';
import 'sync_service.dart';
import 'auth_service.dart';
import 'event_service.dart';
import 'notification_service.dart';
import 'certificate_service.dart';
import 'feedback_service.dart';

class DashboardService {
  static final _supabase = SupabaseManager.client;

  static Future<Map<String, dynamic>> fetchDashboardData({
    required String userId,
    required String userRole,
  }) async {
    try {
      bool isOnline = await SyncService.checkConnectivityAndSync();
      Map<String, dynamic> dashboardData = {
        'upcomingEvents': <EventModel>[],
        'registeredEvents': <EventModel>[],
        'bookmarkedEvents': <EventModel>[],
        'certificates': <CertificateModel>[],
        'notifications': <NotificationModel>[],
        'createdEvents': <EventModel>[],
        'pendingEvents': <EventModel>[],
        'eventStats': <String, Map<String, dynamic>>{},
        'eventFeedback': <String, List<FeedbackModel>>{},
        'userStats': <String, dynamic>{},
      };

      if (isOnline) {
        // Fetch notifications
        final notificationsResult = await NotificationService.getNotifications(userId);
        if (notificationsResult['success']) {
          dashboardData['notifications'] = notificationsResult['notifications'];
        }

        if (userRole == AppConstants.roleParticipant) {
          // Student data
          final upcomingResult = await EventService.getUpcomingEvents();
          if (upcomingResult['success']) {
            dashboardData['upcomingEvents'] = upcomingResult['events'];
          }

          final registeredResult = await EventService.getRegisteredEvents(userId);
          if (registeredResult['success']) {
            dashboardData['registeredEvents'] = registeredResult['events'];
          }

          final certificatesResult = await CertificateService.getUserCertificates(userId);
          if (certificatesResult['success']) {
            dashboardData['certificates'] = certificatesResult['certificates'];
          }
        } else if (userRole == AppConstants.roleStaff) {
          // Organizer data
          final createdResult = await EventService.getCreatedEvents(userId);
          if (createdResult['success']) {
            dashboardData['createdEvents'] = createdResult['events'];
          }

          for (final event in dashboardData['createdEvents'] as List<EventModel>) {
            final statsResult = await EventService.getEventStatistics(event.id);
            if (statsResult['success']) {
              dashboardData['eventStats'][event.id] = {
                'registrations': statsResult['registrations'],
                'averageFeedback': statsResult['averageFeedback'],
              };
            }

            final feedbackResult = await FeedbackService.getEventFeedback(event.id);
            if (feedbackResult['success']) {
              dashboardData['eventFeedback'][event.id] = feedbackResult['feedbacks'];
            }
          }

          // Admin data (assuming approved staff are admins)
          final user = EnhancedAuthService.getCurrentUser();
          if (user?.approved == true) {
            final pendingResult = await EventService.getPendingEvents();
            if (pendingResult['success']) {
              dashboardData['pendingEvents'] = pendingResult['events'];
            }

            final allEventsResult = await EventService.getAllEvents();
            if (allEventsResult['success']) {
              dashboardData['allEvents'] = allEventsResult['events'];
            }

            final userCountResponse = await _supabase.from('users').select('count(*)').single();
            dashboardData['userStats']['totalUsers'] = userCountResponse['count'] as int? ?? 0;
          }
        }
      } else {
        // Offline mode
        dashboardData['notifications'] = HiveManager.notificationsBox.values
            .where((n) => n.userId == userId)
            .toList();

        if (userRole == AppConstants.roleParticipant) {
          dashboardData['upcomingEvents'] = HiveManager.eventsBox.values
              .where((e) => e.status == AppConstants.statusApproved && e.dateTime.isAfter(DateTime.now()))
              .toList();

          dashboardData['registeredEvents'] = HiveManager.eventsBox.values
              .where((e) => HiveManager.registrationsBox.values
              .any((r) => r.eventId == e.id && r.userId == userId && r.status == 'registered'))
              .toList();

          dashboardData['certificates'] = HiveManager.certificatesBox.values
              .where((c) => c.userId == userId)
              .toList();
        } else if (userRole == AppConstants.roleStaff) {
          dashboardData['createdEvents'] = HiveManager.eventsBox.values
              .where((e) => e.organizerId == userId)
              .toList();

          for (final event in dashboardData['createdEvents'] as List<EventModel>) {
            dashboardData['eventStats'][event.id] = {
              'registrations': HiveManager.registrationsBox.values
                  .where((r) => r.eventId == event.id && r.status == 'registered')
                  .length,
              'averageFeedback': HiveManager.feedbackBox.values
                  .where((f) => f.eventId == event.id)
                  .isNotEmpty
                  ? HiveManager.feedbackBox.values
                  .where((f) => f.eventId == event.id)
                  .map((f) => f.rating)
                  .reduce((a, b) => a + b) /
                  HiveManager.feedbackBox.values.where((f) => f.eventId == event.id).length
                  : 0.0,
            };
            dashboardData['eventFeedback'][event.id] = HiveManager.feedbackBox.values
                .where((f) => f.eventId == event.id)
                .toList();
          }

          final user = EnhancedAuthService.getCurrentUser();
          if (user?.approved == true) {
            dashboardData['pendingEvents'] = HiveManager.eventsBox.values
                .where((e) => e.status == AppConstants.statusPending)
                .toList();
            dashboardData['allEvents'] = HiveManager.eventsBox.values.toList();
            dashboardData['userStats']['totalUsers'] = HiveManager.usersBox.values.length;
          }
        }
      }

      return {'success': true, 'data': dashboardData};
    } catch (e) {
      return {'success': false, 'error': AppError.fromException(e).message};
    }
  }
}