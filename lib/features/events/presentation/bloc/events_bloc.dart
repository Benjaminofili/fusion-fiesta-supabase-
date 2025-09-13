import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class EventsEvent extends Equatable {
  const EventsEvent();

  @override
  List<Object> get props => [];
}

class FetchEventsEvent extends EventsEvent {}

class FilterEventsEvent extends EventsEvent {
  final String category;
  final String searchQuery;

  const FilterEventsEvent({
    this.category = '',
    this.searchQuery = '',
  });

  @override
  List<Object> get props => [category, searchQuery];
}

class RegisterForEventEvent extends EventsEvent {
  final String eventId;

  const RegisterForEventEvent({required this.eventId});

  @override
  List<Object> get props => [eventId];
}

// States
abstract class EventsState extends Equatable {
  const EventsState();

  @override
  List<Object> get props => [];
}

class EventsInitial extends EventsState {}

class EventsLoading extends EventsState {}

class EventsLoaded extends EventsState {
  final List<dynamic> events;

  const EventsLoaded({required this.events});

  @override
  List<Object> get props => [events];
}

class EventsError extends EventsState {
  final String message;

  const EventsError({required this.message});

  @override
  List<Object> get props => [message];
}

class EventRegistrationLoading extends EventsState {}

class EventRegistrationSuccess extends EventsState {
  final String eventId;

  const EventRegistrationSuccess({required this.eventId});

  @override
  List<Object> get props => [eventId];
}

class EventRegistrationError extends EventsState {
  final String message;

  const EventRegistrationError({required this.message});

  @override
  List<Object> get props => [message];
}

// Bloc
class EventsBloc extends Bloc<EventsEvent, EventsState> {
  EventsBloc() : super(EventsInitial()) {
    on<FetchEventsEvent>(_onFetchEvents);
    on<FilterEventsEvent>(_onFilterEvents);
    on<RegisterForEventEvent>(_onRegisterForEvent);
  }

  Future<void> _onFetchEvents(FetchEventsEvent event, Emitter<EventsState> emit) async {
    emit(EventsLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock events data
      final events = [
        {
          'id': '1',
          'title': 'Tech Conference 2023',
          'description': 'Annual technology conference featuring the latest innovations and industry trends.',
          'date': '2023-11-15',
          'location': 'Main Auditorium',
          'organizer': 'Computer Science Department',
          'category': 'Technology',
          'image': 'assets/images/event1.jpg',
          'capacity': 200,
          'registered': 150,
        },
        {
          'id': '2',
          'title': 'Cultural Fest',
          'description': 'Celebrate diversity with performances, food, and activities from around the world.',
          'date': '2023-12-05',
          'location': 'College Grounds',
          'organizer': 'Cultural Committee',
          'category': 'Cultural',
          'image': 'assets/images/event2.jpg',
          'capacity': 500,
          'registered': 320,
        },
        {
          'id': '3',
          'title': 'Hackathon 2023',
          'description': '24-hour coding competition to solve real-world problems with innovative solutions.',
          'date': '2023-10-20',
          'location': 'Computer Lab',
          'organizer': 'Coding Club',
          'category': 'Technology',
          'image': 'assets/images/event3.jpg',
          'capacity': 100,
          'registered': 98,
        },
      ];
      
      emit(EventsLoaded(events: events));
    } catch (e) {
      emit(EventsError(message: e.toString()));
    }
  }

  Future<void> _onFilterEvents(FilterEventsEvent event, Emitter<EventsState> emit) async {
    emit(EventsLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock events data
      final allEvents = [
        {
          'id': '1',
          'title': 'Tech Conference 2023',
          'description': 'Annual technology conference featuring the latest innovations and industry trends.',
          'date': '2023-11-15',
          'location': 'Main Auditorium',
          'organizer': 'Computer Science Department',
          'category': 'Technology',
          'image': 'assets/images/event1.jpg',
          'capacity': 200,
          'registered': 150,
        },
        {
          'id': '2',
          'title': 'Cultural Fest',
          'description': 'Celebrate diversity with performances, food, and activities from around the world.',
          'date': '2023-12-05',
          'location': 'College Grounds',
          'organizer': 'Cultural Committee',
          'category': 'Cultural',
          'image': 'assets/images/event2.jpg',
          'capacity': 500,
          'registered': 320,
        },
        {
          'id': '3',
          'title': 'Hackathon 2023',
          'description': '24-hour coding competition to solve real-world problems with innovative solutions.',
          'date': '2023-10-20',
          'location': 'Computer Lab',
          'organizer': 'Coding Club',
          'category': 'Technology',
          'image': 'assets/images/event3.jpg',
          'capacity': 100,
          'registered': 98,
        },
      ];
      
      // Filter events based on category and search query
      final filteredEvents = allEvents.where((e) {
        final matchesCategory = event.category.isEmpty || e['category'] == event.category;
        final matchesSearch = event.searchQuery.isEmpty || 
          e['title'].toString().toLowerCase().contains(event.searchQuery.toLowerCase()) ||
          e['description'].toString().toLowerCase().contains(event.searchQuery.toLowerCase());
        
        return matchesCategory && matchesSearch;
      }).toList();
      
      emit(EventsLoaded(events: filteredEvents));
    } catch (e) {
      emit(EventsError(message: e.toString()));
    }
  }

  Future<void> _onRegisterForEvent(RegisterForEventEvent event, Emitter<EventsState> emit) async {
    // Preserve current events in state
    final currentState = state;
    List<dynamic> currentEvents = [];
    if (currentState is EventsLoaded) {
      currentEvents = currentState.events;
    }
    
    emit(EventRegistrationLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock successful registration
      emit(EventRegistrationSuccess(eventId: event.eventId));
      
      // Restore events list with updated registration count
      final updatedEvents = currentEvents.map((e) {
        if (e['id'] == event.eventId) {
          return {
            ...e,
            'registered': (e['registered'] as int) + 1,
          };
        }
        return e;
      }).toList();
      
      emit(EventsLoaded(events: updatedEvents));
    } catch (e) {
      emit(EventRegistrationError(message: e.toString()));
      
      // Restore previous events state
      if (currentEvents.isNotEmpty) {
        emit(EventsLoaded(events: currentEvents));
      }
    }
  }
}