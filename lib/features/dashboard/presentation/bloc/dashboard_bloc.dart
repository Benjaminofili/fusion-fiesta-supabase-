import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusion_fiesta/core/services/event_service.dart';
import 'package:fusion_fiesta/core/services/notification_service.dart';
import 'package:fusion_fiesta/core/services/feedback_service.dart';
import 'package:fusion_fiesta/core/services/certificate_service.dart';
import 'package:fusion_fiesta/core/services/bookmark_service.dart'; // Added bookmark service
import 'package:fusion_fiesta/models/event_model.dart';
import 'package:fusion_fiesta/models/notification_model.dart';
import 'package:fusion_fiesta/models/feedback_model.dart';
import 'package:fusion_fiesta/models/certificate_model.dart';
import 'package:fusion_fiesta/supabase_manager.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/AppError.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../storage/hive_manager.dart';

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

class SearchEventsEvent extends DashboardEvent {
  final String query;
  final String? category;
  final DateTime? startDate;
  final DateTime? endDate;

  const SearchEventsEvent({
    required this.query,
    this.category,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object> get props => [
    query,
    category ?? '',
    startDate ?? DateTime(1970),
    endDate ?? DateTime(1970),
  ];
}

class RefreshBookmarksEvent extends DashboardEvent {
  final String userId;

  const RefreshBookmarksEvent({required this.userId});

  @override
  List<Object> get props => [userId];
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
    on<SearchEventsEvent>(_onSearchEvents);
    on<RefreshBookmarksEvent>(_onRefreshBookmarks);
  }

  Future<void> _onFetchDashboardData(FetchDashboardDataEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      Map<String, dynamic> dashboardData = {
        'notifications': <NotificationModel>[],
        'upcomingEvents': <EventModel>[],
        'registeredEvents': <EventModel>[],
        'bookmarkedEvents': <EventModel>[], // Added bookmarked events
        'certificates': <CertificateModel>[],
        'createdEvents': <EventModel>[],
        'pendingEvents': <EventModel>[],
        'eventStats': <String, Map<String, dynamic>>{},
        'eventFeedback': <String, List<FeedbackModel>>{},
        'userStats': <String, dynamic>{},
      };

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

        // Fetch bookmarked events
        final bookmarkedResult = await BookmarkService.getBookmarkedEvents(event.userId);
        if (bookmarkedResult['success']) {
          dashboardData['bookmarkedEvents'] = bookmarkedResult['events'] as List<EventModel>;
        } else {
          print('Failed to load bookmarked events: ${bookmarkedResult['error']}');
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

        // Admin data (check if approved staff)
        final user = EnhancedAuthService.getCurrentUser();
        if (user?.approved == true) {
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

          final userCountResponse = await SupabaseManager.client.from('users').select('count').single();
          final totalUsers = userCountResponse['count'] as int? ?? 0;
          dashboardData['userStats'] = {
            'totalUsers': totalUsers,
          };
        }
      }

      emit(DashboardLoaded(dashboardData: dashboardData));
    } catch (e) {
      emit(DashboardError(message: AppError.fromException(e).message));
    }
  }

  Future<void> _onRefreshBookmarks(RefreshBookmarksEvent event, Emitter<DashboardState> emit) async {
    try {
      // Sync bookmarks with server
      await BookmarkService.syncBookmarks(event.userId);

      // Refresh dashboard data
      final user = EnhancedAuthService.getCurrentUser();
      if (user != null) {
        add(FetchDashboardDataEvent(userRole: user.role, userId: user.id));
      }
    } catch (e) {
      print('Failed to refresh bookmarks: ${AppError.fromException(e).message}');
    }
  }

  Future<void> _onSearchEvents(SearchEventsEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      bool isOnline = await SyncService.checkConnectivityAndSync();
      List<EventModel> filteredEvents = [];

      if (isOnline) {
        var query = SupabaseManager.client
            .from('events')
            .select()
            .eq('status', AppConstants.statusApproved);

        // Apply filters
        if (event.query.isNotEmpty) {
          query = query.ilike('title', '%${event.query}%');
        }
        if (event.category != null) {
          query = query.eq('category', event.category!);
        }
        if (event.startDate != null && event.endDate != null) {
          query = query
              .gte('date', event.startDate!.toIso8601String().split('T')[0])
              .lte('date', event.endDate!.toIso8601String().split('T')[0]);
        }

        final response = await query.order('date', ascending: true);
        filteredEvents = response.map((data) => EventModel.fromMap(data)).toList();

        for (final event in filteredEvents) {
          await HiveManager.eventsBox.put(event.id, event);
        }
      } else {
        filteredEvents = HiveManager.eventsBox.values
            .where((e) => e.status == AppConstants.statusApproved)
            .where((e) => event.query.isEmpty || e.title.toLowerCase().contains(event.query.toLowerCase()))
            .where((e) => event.category == null || e.category == event.category)
            .where((e) =>
        event.startDate == null ||
            e.dateTime.isAfter(event.startDate!) ||
            e.dateTime.isAtSameMomentAs(event.startDate!))
            .where((e) =>
        event.endDate == null ||
            e.dateTime.isBefore(event.endDate!) ||
            e.dateTime.isAtSameMomentAs(event.endDate!))
            .toList();
      }

      // Fetch registered events, bookmarked events, and other data to maintain consistency
      final user = EnhancedAuthService.getCurrentUser();
      List<EventModel> registeredEvents = [];
      List<EventModel> bookmarkedEvents = [];
      List<CertificateModel> certificates = [];
      List<NotificationModel> notifications = [];

      if (user != null) {
        final registeredResult = await EventService.getRegisteredEvents(user.id);
        if (registeredResult['success']) {
          registeredEvents = registeredResult['events'] as List<EventModel>;
        }

        final bookmarkedResult = await BookmarkService.getBookmarkedEvents(user.id);
        if (bookmarkedResult['success']) {
          bookmarkedEvents = bookmarkedResult['events'] as List<EventModel>;
        }

        final certificatesResult = await CertificateService.getUserCertificates(user.id);
        if (certificatesResult['success']) {
          certificates = certificatesResult['certificates'] as List<CertificateModel>;
        }

        final notificationsResult = await NotificationService.getNotifications(user.id);
        if (notificationsResult['success']) {
          notifications = notificationsResult['notifications'] as List<NotificationModel>;
        }
      }

      emit(DashboardLoaded(dashboardData: {
        'upcomingEvents': filteredEvents,
        'registeredEvents': registeredEvents,
        'bookmarkedEvents': bookmarkedEvents, // Include bookmarked events in search results
        'certificates': certificates,
        'notifications': notifications,
      }));
    } catch (e) {
      emit(DashboardError(message: AppError.fromException(e).message));
    }
  }
}