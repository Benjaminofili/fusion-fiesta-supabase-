import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusion_fiesta/core/services/event_service.dart';
import 'package:fusion_fiesta/core/services/notification_service.dart';
import 'package:fusion_fiesta/core/services/feedback_service.dart';
import 'package:fusion_fiesta/core/services/certificate_service.dart';
import 'package:fusion_fiesta/models/event_model.dart';
import 'package:fusion_fiesta/models/notification_model.dart';
import 'package:fusion_fiesta/models/feedback_model.dart';
import 'package:fusion_fiesta/models/certificate_model.dart';
import 'package:fusion_fiesta/supabase_manager.dart'; // Added import
import '../../../../core/constants/app_constants.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class FetchDashboardDataEvent extends DashboardEvent {
  final String userRole;
  final String userId;

  const FetchDashboardDataEvent({
    required this.userRole,
    required this.userId,
  });

  @override
  List<Object> get props => [userRole, userId];
}

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final Map<String, dynamic> dashboardData;

  const DashboardLoaded({required this.dashboardData});

  @override
  List<Object> get props => [dashboardData];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object> get props => [message];
}

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<FetchDashboardDataEvent>(_onFetchDashboardData);
  }

  Future<void> _onFetchDashboardData(FetchDashboardDataEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      Map<String, dynamic> dashboardData = {};

      // Fetch notifications (common for all roles)
      final notificationsResult = await NotificationService.getNotifications(event.userId);
      if (notificationsResult['success']) {
        dashboardData['notifications'] = notificationsResult['notifications'] as List<NotificationModel>;
      } else {
        print('Failed to load notifications: ${notificationsResult['error']}');
      }

      if (event.userRole == AppConstants.roleParticipant) {
        // Student dashboard data
        final upcomingResult = await EventService.getUpcomingEvents();
        if (upcomingResult['success']) {
          dashboardData['upcomingEvents'] = upcomingResult['events'] as List<EventModel>;
        } else {
          print('Failed to load upcoming events: ${upcomingResult['error']}');
        }

        final registeredResult = await EventService.getRegisteredEvents(event.userId);
        if (registeredResult['success']) {
          dashboardData['registeredEvents'] = registeredResult['events'] as List<EventModel>;
        } else {
          print('Failed to load registered events: ${registeredResult['error']}');
        }

        final certificatesResult = await CertificateService.getUserCertificates(event.userId);
        if (certificatesResult['success']) {
          dashboardData['certificates'] = certificatesResult['certificates'] as List<CertificateModel>;
        } else {
          print('Failed to load certificates: ${certificatesResult['error']}');
        }

      } else if (event.userRole == AppConstants.roleStaff) {
        // Organizer dashboard data
        final createdResult = await EventService.getCreatedEvents(event.userId);
        if (createdResult['success']) {
          dashboardData['createdEvents'] = createdResult['events'] as List<EventModel>;
        } else {
          print('Failed to load created events: ${createdResult['error']}');
        }

        dashboardData['eventStats'] = {};
        dashboardData['eventFeedback'] = {};
        for (final event in (dashboardData['createdEvents'] ?? []) as List<EventModel>) {
          final statsResult = await EventService.getEventStatistics(event.id);
          if (statsResult['success']) {
            dashboardData['eventStats'][event.id] = {
              'registrations': statsResult['registrations'],
              'averageFeedback': statsResult['averageFeedback'],
            };
          } else {
            print('Failed to load stats for event ${event.id}: ${statsResult['error']}');
          }

          final feedbackResult = await FeedbackService.getEventFeedback(event.id);
          if (feedbackResult['success']) {
            dashboardData['eventFeedback'][event.id] = feedbackResult['feedbacks'] as List<FeedbackModel>;
          } else {
            print('Failed to load feedback for event ${event.id}: ${feedbackResult['error']}');
          }
        }

      } else if (event.userRole == AppConstants.roleStaff && /* Check if admin, e.g., user.approved */ true) {
        // Admin dashboard data
        final pendingResult = await EventService.getPendingEvents();
        if (pendingResult['success']) {
          dashboardData['pendingEvents'] = pendingResult['events'] as List<EventModel>;
        } else {
          print('Failed to load pending events: ${pendingResult['error']}');
        }

        final allEventsResult = await EventService.getAllEvents();
        if (allEventsResult['success']) {
          dashboardData['allEvents'] = allEventsResult['events'] as List<EventModel>;
        } else {
          print('Failed to load all events: ${allEventsResult['error']}');
        }

        // Fetch user count using SupabaseManager.client
        final userCountResponse = await SupabaseManager.client.from('users').select('count(*)');
        final totalUsers = (userCountResponse as List).isNotEmpty ? (userCountResponse[0]['count'] as int?) ?? 0 : 0;
        dashboardData['userStats'] = {
          'totalUsers': totalUsers,
        };
      }

      emit(DashboardLoaded(dashboardData: dashboardData));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }
}