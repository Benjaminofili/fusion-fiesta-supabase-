import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class FeedbackEvent extends Equatable {
  const FeedbackEvent();

  @override
  List<Object> get props => [];
}

class FetchUserFeedbacksEvent extends FeedbackEvent {
  final String userId;

  const FetchUserFeedbacksEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class FetchEventFeedbacksEvent extends FeedbackEvent {
  final String eventId;

  const FetchEventFeedbacksEvent({required this.eventId});

  @override
  List<Object> get props => [eventId];
}

class SubmitFeedbackEvent extends FeedbackEvent {
  final String userId;
  final String eventId;
  final int rating;
  final String comment;
  final Map<String, int>? categoryRatings; // Optional category-specific ratings

  const SubmitFeedbackEvent({
    required this.userId,
    required this.eventId,
    required this.rating,
    required this.comment,
    this.categoryRatings,
  });

  @override
  List<Object> get props => [userId, eventId, rating, comment, categoryRatings ?? const {}];
}

class UpdateFeedbackEvent extends FeedbackEvent {
  final String feedbackId;
  final int? rating;
  final String? comment;
  final Map<String, int>? categoryRatings;

  const UpdateFeedbackEvent({
    required this.feedbackId,
    this.rating,
    this.comment,
    this.categoryRatings,
  });

  @override
  List<Object> get props => [feedbackId, rating ?? 0, comment ?? '', categoryRatings ?? const {}];
}

class DeleteFeedbackEvent extends FeedbackEvent {
  final String feedbackId;

  const DeleteFeedbackEvent({required this.feedbackId});

  @override
  List<Object> get props => [feedbackId];
}

// States
abstract class FeedbackState extends Equatable {
  const FeedbackState();

  @override
  List<Object> get props => [];
}

class FeedbackInitial extends FeedbackState {}

class FeedbackLoading extends FeedbackState {}

class UserFeedbacksLoaded extends FeedbackState {
  final List<Map<String, dynamic>> feedbacks;

  const UserFeedbacksLoaded({required this.feedbacks});

  @override
  List<Object> get props => [feedbacks];
}

class EventFeedbacksLoaded extends FeedbackState {
  final List<Map<String, dynamic>> feedbacks;
  final Map<String, dynamic> eventStats;

  const EventFeedbacksLoaded({
    required this.feedbacks,
    required this.eventStats,
  });

  @override
  List<Object> get props => [feedbacks, eventStats];
}

class FeedbackSubmitting extends FeedbackState {}

class FeedbackSubmitted extends FeedbackState {
  final Map<String, dynamic> feedback;

  const FeedbackSubmitted({required this.feedback});

  @override
  List<Object> get props => [feedback];
}

class FeedbackUpdating extends FeedbackState {}

class FeedbackUpdated extends FeedbackState {
  final Map<String, dynamic> feedback;

  const FeedbackUpdated({required this.feedback});

  @override
  List<Object> get props => [feedback];
}

class FeedbackDeleting extends FeedbackState {}

class FeedbackDeleted extends FeedbackState {
  final String feedbackId;

  const FeedbackDeleted({required this.feedbackId});

  @override
  List<Object> get props => [feedbackId];
}

class FeedbackError extends FeedbackState {
  final String message;

  const FeedbackError({required this.message});

  @override
  List<Object> get props => [message];
}

// Bloc
class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  FeedbackBloc() : super(FeedbackInitial()) {
    on<FetchUserFeedbacksEvent>(_onFetchUserFeedbacks);
    on<FetchEventFeedbacksEvent>(_onFetchEventFeedbacks);
    on<SubmitFeedbackEvent>(_onSubmitFeedback);
    on<UpdateFeedbackEvent>(_onUpdateFeedback);
    on<DeleteFeedbackEvent>(_onDeleteFeedback);
  }

  Future<void> _onFetchUserFeedbacks(FetchUserFeedbacksEvent event, Emitter<FeedbackState> emit) async {
    emit(FeedbackLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock user feedbacks data
      final userFeedbacks = [
        {
          'id': '1',
          'eventId': 'event1',
          'eventName': 'Tech Conference 2023',
          'userId': event.userId,
          'rating': 4,
          'comment': 'Great conference with insightful sessions. The networking opportunities were excellent.',
          'timestamp': '2023-11-16T14:30:00Z',
          'categoryRatings': {
            'content': 5,
            'organization': 4,
            'venue': 3,
            'speakers': 5,
          },
        },
        {
          'id': '2',
          'eventId': 'event3',
          'eventName': 'Hackathon 2023',
          'userId': event.userId,
          'rating': 5,
          'comment': 'Amazing experience! Well organized and challenging problems to solve. Looking forward to next year\'s event.',
          'timestamp': '2023-10-23T09:15:00Z',
          'categoryRatings': {
            'challenges': 5,
            'organization': 5,
            'mentorship': 4,
            'prizes': 5,
          },
        },
        {
          'id': '3',
          'eventId': 'event4',
          'eventName': 'Web Development Workshop',
          'userId': event.userId,
          'rating': 4,
          'comment': 'Very informative workshop. The hands-on exercises were particularly helpful.',
          'timestamp': '2023-09-16T16:45:00Z',
          'categoryRatings': {
            'content': 4,
            'instructor': 5,
            'materials': 3,
            'pace': 4,
          },
        },
      ];
      
      emit(UserFeedbacksLoaded(feedbacks: userFeedbacks));
    } catch (e) {
      emit(FeedbackError(message: e.toString()));
    }
  }

  Future<void> _onFetchEventFeedbacks(FetchEventFeedbacksEvent event, Emitter<FeedbackState> emit) async {
    emit(FeedbackLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock event feedbacks data
      List<Map<String, dynamic>> eventFeedbacks = [];
      Map<String, dynamic> eventStats = {};
      
      if (event.eventId == 'event1') { // Tech Conference
        eventFeedbacks = [
          {
            'id': '1',
            'eventId': 'event1',
            'eventName': 'Tech Conference 2023',
            'userId': 'user1',
            'userName': 'John Doe',
            'userAvatar': 'assets/avatars/john.jpg',
            'rating': 4,
            'comment': 'Great conference with insightful sessions. The networking opportunities were excellent.',
            'timestamp': '2023-11-16T14:30:00Z',
            'categoryRatings': {
              'content': 5,
              'organization': 4,
              'venue': 3,
              'speakers': 5,
            },
          },
          {
            'id': '4',
            'eventId': 'event1',
            'eventName': 'Tech Conference 2023',
            'userId': 'user2',
            'userName': 'Jane Smith',
            'userAvatar': 'assets/avatars/jane.jpg',
            'rating': 5,
            'comment': 'Excellent event! The speakers were top-notch and I learned a lot of new technologies.',
            'timestamp': '2023-11-16T15:45:00Z',
            'categoryRatings': {
              'content': 5,
              'organization': 5,
              'venue': 4,
              'speakers': 5,
            },
          },
          {
            'id': '5',
            'eventId': 'event1',
            'eventName': 'Tech Conference 2023',
            'userId': 'user3',
            'userName': 'Mike Johnson',
            'userAvatar': 'assets/avatars/mike.jpg',
            'rating': 3,
            'comment': 'Good content but the venue was too crowded. Audio issues in some sessions.',
            'timestamp': '2023-11-17T10:20:00Z',
            'categoryRatings': {
              'content': 4,
              'organization': 3,
              'venue': 2,
              'speakers': 4,
            },
          },
        ];
        
        eventStats = {
          'averageRating': 4.0,
          'totalFeedbacks': 3,
          'ratingDistribution': {
            '5': 1,
            '4': 1,
            '3': 1,
            '2': 0,
            '1': 0,
          },
          'categoryAverages': {
            'content': 4.7,
            'organization': 4.0,
            'venue': 3.0,
            'speakers': 4.7,
          },
        };
      } else if (event.eventId == 'event3') { // Hackathon
        eventFeedbacks = [
          {
            'id': '2',
            'eventId': 'event3',
            'eventName': 'Hackathon 2023',
            'userId': 'user1',
            'userName': 'John Doe',
            'userAvatar': 'assets/avatars/john.jpg',
            'rating': 5,
            'comment': 'Amazing experience! Well organized and challenging problems to solve. Looking forward to next year\'s event.',
            'timestamp': '2023-10-23T09:15:00Z',
            'categoryRatings': {
              'challenges': 5,
              'organization': 5,
              'mentorship': 4,
              'prizes': 5,
            },
          },
          {
            'id': '6',
            'eventId': 'event3',
            'eventName': 'Hackathon 2023',
            'userId': 'user4',
            'userName': 'Sarah Williams',
            'userAvatar': 'assets/avatars/sarah.jpg',
            'rating': 4,
            'comment': 'Great hackathon! The mentors were very helpful. Would have liked more time for the final project.',
            'timestamp': '2023-10-23T11:30:00Z',
            'categoryRatings': {
              'challenges': 4,
              'organization': 4,
              'mentorship': 5,
              'prizes': 4,
            },
          },
        ];
        
        eventStats = {
          'averageRating': 4.5,
          'totalFeedbacks': 2,
          'ratingDistribution': {
            '5': 1,
            '4': 1,
            '3': 0,
            '2': 0,
            '1': 0,
          },
          'categoryAverages': {
            'challenges': 4.5,
            'organization': 4.5,
            'mentorship': 4.5,
            'prizes': 4.5,
          },
        };
      } else if (event.eventId == 'event4') { // Workshop
        eventFeedbacks = [
          {
            'id': '3',
            'eventId': 'event4',
            'eventName': 'Web Development Workshop',
            'userId': 'user1',
            'userName': 'John Doe',
            'userAvatar': 'assets/avatars/john.jpg',
            'rating': 4,
            'comment': 'Very informative workshop. The hands-on exercises were particularly helpful.',
            'timestamp': '2023-09-16T16:45:00Z',
            'categoryRatings': {
              'content': 4,
              'instructor': 5,
              'materials': 3,
              'pace': 4,
            },
          },
          {
            'id': '7',
            'eventId': 'event4',
            'eventName': 'Web Development Workshop',
            'userId': 'user5',
            'userName': 'Emily Chen',
            'userAvatar': 'assets/avatars/emily.jpg',
            'rating': 5,
            'comment': 'Excellent workshop! The instructor was knowledgeable and the content was well-structured.',
            'timestamp': '2023-09-16T17:10:00Z',
            'categoryRatings': {
              'content': 5,
              'instructor': 5,
              'materials': 4,
              'pace': 5,
            },
          },
          {
            'id': '8',
            'eventId': 'event4',
            'eventName': 'Web Development Workshop',
            'userId': 'user6',
            'userName': 'David Brown',
            'userAvatar': 'assets/avatars/david.jpg',
            'rating': 3,
            'comment': 'Good content but the pace was too fast for beginners. More examples would have been helpful.',
            'timestamp': '2023-09-17T09:30:00Z',
            'categoryRatings': {
              'content': 4,
              'instructor': 4,
              'materials': 3,
              'pace': 2,
            },
          },
        ];
        
        eventStats = {
          'averageRating': 4.0,
          'totalFeedbacks': 3,
          'ratingDistribution': {
            '5': 1,
            '4': 1,
            '3': 1,
            '2': 0,
            '1': 0,
          },
          'categoryAverages': {
            'content': 4.3,
            'instructor': 4.7,
            'materials': 3.3,
            'pace': 3.7,
          },
        };
      }
      
      emit(EventFeedbacksLoaded(
        feedbacks: eventFeedbacks,
        eventStats: eventStats,
      ));
    } catch (e) {
      emit(FeedbackError(message: e.toString()));
    }
  }

  Future<void> _onSubmitFeedback(SubmitFeedbackEvent event, Emitter<FeedbackState> emit) async {
    emit(FeedbackSubmitting());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock submitted feedback
      final feedback = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'eventId': event.eventId,
        'eventName': _getEventName(event.eventId),
        'userId': event.userId,
        'userName': 'John Doe', // Mock user name
        'userAvatar': 'assets/avatars/john.jpg', // Mock user avatar
        'rating': event.rating,
        'comment': event.comment,
        'timestamp': DateTime.now().toIso8601String(),
        'categoryRatings': event.categoryRatings,
      };
      
      emit(FeedbackSubmitted(feedback: feedback));
      
      // Restore previous state if available
      if (state is UserFeedbacksLoaded) {
        final previousState = state as UserFeedbacksLoaded;
        final updatedFeedbacks = [...previousState.feedbacks, feedback];
        emit(UserFeedbacksLoaded(feedbacks: updatedFeedbacks));
      } else if (state is EventFeedbacksLoaded) {
        final previousState = state as EventFeedbacksLoaded;
        final updatedFeedbacks = [...previousState.feedbacks, feedback];
        
        // Recalculate event stats (simplified)
        final updatedStats = {
          ...previousState.eventStats,
          'totalFeedbacks': previousState.eventStats['totalFeedbacks'] + 1,
        };
        
        emit(EventFeedbacksLoaded(
          feedbacks: updatedFeedbacks,
          eventStats: updatedStats,
        ));
      }
    } catch (e) {
      emit(FeedbackError(message: e.toString()));
    }
  }

  Future<void> _onUpdateFeedback(UpdateFeedbackEvent event, Emitter<FeedbackState> emit) async {
    emit(FeedbackUpdating());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      Map<String, dynamic>? updatedFeedback;
      
      // Update feedback in state
      if (state is UserFeedbacksLoaded) {
        final previousState = state as UserFeedbacksLoaded;
        final updatedFeedbacks = previousState.feedbacks.map((feedback) {
          if (feedback['id'] == event.feedbackId) {
            updatedFeedback = {
              ...feedback,
              if (event.rating != null) 'rating': event.rating,
              if (event.comment != null) 'comment': event.comment,
              if (event.categoryRatings != null) 'categoryRatings': {
                ...feedback['categoryRatings'] as Map<String, dynamic>,
                ...event.categoryRatings!,
              },
              'timestamp': DateTime.now().toIso8601String(), // Update timestamp
            };
            return updatedFeedback!;
          }
          return feedback;
        }).toList();
        
        if (updatedFeedback != null) {
          emit(FeedbackUpdated(feedback: updatedFeedback!));
          emit(UserFeedbacksLoaded(feedbacks: updatedFeedbacks));
        } else {
          emit(FeedbackError(message: 'Feedback not found'));
        }
      } else if (state is EventFeedbacksLoaded) {
        final previousState = state as EventFeedbacksLoaded;
        final updatedFeedbacks = previousState.feedbacks.map((feedback) {
          if (feedback['id'] == event.feedbackId) {
            updatedFeedback = {
              ...feedback,
              if (event.rating != null) 'rating': event.rating,
              if (event.comment != null) 'comment': event.comment,
              if (event.categoryRatings != null) 'categoryRatings': {
                ...feedback['categoryRatings'] as Map<String, dynamic>,
                ...event.categoryRatings!,
              },
              'timestamp': DateTime.now().toIso8601String(), // Update timestamp
            };
            return updatedFeedback!;
          }
          return feedback;
        }).toList();
        
        if (updatedFeedback != null) {
          // Recalculate event stats (simplified)
          // In a real app, you would recalculate all stats based on the updated feedback
          
          emit(FeedbackUpdated(feedback: updatedFeedback!));
          emit(EventFeedbacksLoaded(
            feedbacks: updatedFeedbacks,
            eventStats: previousState.eventStats,
          ));
        } else {
          emit(FeedbackError(message: 'Feedback not found'));
        }
      } else {
        emit(FeedbackError(message: 'Invalid state for updating feedback'));
      }
    } catch (e) {
      emit(FeedbackError(message: e.toString()));
    }
  }

  Future<void> _onDeleteFeedback(DeleteFeedbackEvent event, Emitter<FeedbackState> emit) async {
    emit(FeedbackDeleting());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Delete feedback from state
      if (state is UserFeedbacksLoaded) {
        final previousState = state as UserFeedbacksLoaded;
        final updatedFeedbacks = previousState.feedbacks
            .where((feedback) => feedback['id'] != event.feedbackId)
            .toList();
        
        emit(FeedbackDeleted(feedbackId: event.feedbackId));
        emit(UserFeedbacksLoaded(feedbacks: updatedFeedbacks));
      } else if (state is EventFeedbacksLoaded) {
        final previousState = state as EventFeedbacksLoaded;
        final updatedFeedbacks = previousState.feedbacks
            .where((feedback) => feedback['id'] != event.feedbackId)
            .toList();
        
        // Recalculate event stats (simplified)
        final updatedStats = {
          ...previousState.eventStats,
          'totalFeedbacks': previousState.eventStats['totalFeedbacks'] - 1,
        };
        
        emit(FeedbackDeleted(feedbackId: event.feedbackId));
        emit(EventFeedbacksLoaded(
          feedbacks: updatedFeedbacks,
          eventStats: updatedStats,
        ));
      } else {
        emit(FeedbackError(message: 'Invalid state for deleting feedback'));
      }
    } catch (e) {
      emit(FeedbackError(message: e.toString()));
    }
  }

  // Helper method to get event name from event ID
  String _getEventName(String eventId) {
    switch (eventId) {
      case 'event1':
        return 'Tech Conference 2023';
      case 'event2':
        return 'Cultural Fest';
      case 'event3':
        return 'Hackathon 2023';
      case 'event4':
        return 'Web Development Workshop';
      default:
        return 'Unknown Event';
    }
  }
}