import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// Events
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

// States
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

// Bloc
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<FetchDashboardDataEvent>(_onFetchDashboardData);
  }

  Future<void> _onFetchDashboardData(FetchDashboardDataEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock dashboard data based on user role
      Map<String, dynamic> dashboardData = {};
      
      if (event.userRole == 'student') {
        dashboardData = {
          'upcomingEvents': [
            {
              'id': '1',
              'title': 'Tech Conference 2023',
              'date': '2023-11-15',
              'location': 'Main Auditorium',
            },
            {
              'id': '2',
              'title': 'Cultural Fest',
              'date': '2023-12-05',
              'location': 'College Grounds',
            },
          ],
          'registeredEvents': [
            {
              'id': '3',
              'title': 'Hackathon 2023',
              'date': '2023-10-20',
              'location': 'Computer Lab',
              'status': 'Confirmed',
            },
          ],
          'certificates': [
            {
              'id': '1',
              'title': 'Web Development Workshop',
              'issueDate': '2023-09-15',
              'issuer': 'Computer Science Department',
            },
          ],
          'notifications': [
            {
              'id': '1',
              'title': 'Registration Confirmed',
              'message': 'Your registration for Hackathon 2023 has been confirmed.',
              'timestamp': '2023-10-10T10:30:00Z',
              'read': false,
            },
            {
              'id': '2',
              'title': 'New Event Added',
              'message': 'Tech Conference 2023 has been added to the calendar.',
              'timestamp': '2023-10-08T14:15:00Z',
              'read': true,
            },
          ],
          'stats': {
            'eventsAttended': 5,
            'certificatesEarned': 3,
            'feedbackSubmitted': 4,
          },
        };
      } else if (event.userRole == 'organizer') {
        dashboardData = {
          'managedEvents': [
            {
              'id': '1',
              'title': 'Tech Conference 2023',
              'date': '2023-11-15',
              'location': 'Main Auditorium',
              'registrations': 150,
              'capacity': 200,
            },
            {
              'id': '3',
              'title': 'Hackathon 2023',
              'date': '2023-10-20',
              'location': 'Computer Lab',
              'registrations': 98,
              'capacity': 100,
            },
          ],
          'pendingApprovals': [
            {
              'id': '1',
              'type': 'Event Registration',
              'user': 'John Doe',
              'event': 'Tech Conference 2023',
              'timestamp': '2023-10-12T09:45:00Z',
            },
            {
              'id': '2',
              'type': 'Certificate Request',
              'user': 'Jane Smith',
              'event': 'Web Development Workshop',
              'timestamp': '2023-10-11T16:20:00Z',
            },
          ],
          'notifications': [
            {
              'id': '1',
              'title': 'Event Capacity Alert',
              'message': 'Hackathon 2023 is at 98% capacity.',
              'timestamp': '2023-10-15T11:30:00Z',
              'read': false,
            },
          ],
          'stats': {
            'totalEvents': 2,
            'totalRegistrations': 248,
            'averageFeedbackRating': 4.5,
          },
        };
      } else if (event.userRole == 'admin') {
        dashboardData = {
          'allEvents': [
            {
              'id': '1',
              'title': 'Tech Conference 2023',
              'organizer': 'Computer Science Department',
              'date': '2023-11-15',
              'registrations': 150,
              'capacity': 200,
            },
            {
              'id': '2',
              'title': 'Cultural Fest',
              'organizer': 'Cultural Committee',
              'date': '2023-12-05',
              'registrations': 320,
              'capacity': 500,
            },
            {
              'id': '3',
              'title': 'Hackathon 2023',
              'organizer': 'Coding Club',
              'date': '2023-10-20',
              'registrations': 98,
              'capacity': 100,
            },
          ],
          'userStats': {
            'totalUsers': 1250,
            'students': 1150,
            'organizers': 80,
            'admins': 20,
          },
          'eventStats': {
            'totalEvents': 3,
            'upcomingEvents': 2,
            'pastEvents': 1,
            'totalRegistrations': 568,
          },
          'systemAlerts': [
            {
              'id': '1',
              'title': 'Server Load High',
              'message': 'The server is experiencing high load due to increased registration activity.',
              'severity': 'warning',
              'timestamp': '2023-10-15T14:30:00Z',
            },
          ],
        };
      }
      
      emit(DashboardLoaded(dashboardData: dashboardData));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }
}