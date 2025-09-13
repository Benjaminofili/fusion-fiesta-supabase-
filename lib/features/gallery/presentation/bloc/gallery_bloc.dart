import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class GalleryEvent extends Equatable {
  const GalleryEvent();

  @override
  List<Object> get props => [];
}

class FetchGalleryEvent extends GalleryEvent {
  final String? eventId; // Optional: if provided, fetch gallery for specific event

  const FetchGalleryEvent({this.eventId});

  @override
  List<Object> get props => [eventId ?? ''];
}

class FilterGalleryEvent extends GalleryEvent {
  final String filterType; // 'all', 'images', 'videos'
  final String? eventId; // Optional: filter by event
  final String? tag; // Optional: filter by tag

  const FilterGalleryEvent({
    required this.filterType,
    this.eventId,
    this.tag,
  });

  @override
  List<Object> get props => [filterType, eventId ?? '', tag ?? ''];
}

// States
abstract class GalleryState extends Equatable {
  const GalleryState();

  @override
  List<Object> get props => [];
}

class GalleryInitial extends GalleryState {}

class GalleryLoading extends GalleryState {}

class GalleryLoaded extends GalleryState {
  final List<Map<String, dynamic>> mediaItems;
  final String? activeFilter;
  final String? activeEventId;
  final String? activeTag;
  final List<String> availableTags;
  final List<Map<String, dynamic>> availableEvents;

  const GalleryLoaded({
    required this.mediaItems,
    this.activeFilter = 'all',
    this.activeEventId,
    this.activeTag,
    required this.availableTags,
    required this.availableEvents,
  });

  @override
  List<Object> get props => [
        mediaItems,
        activeFilter ?? 'all',
        activeEventId ?? '',
        activeTag ?? '',
        availableTags,
        availableEvents,
      ];

  GalleryLoaded copyWith({
    List<Map<String, dynamic>>? mediaItems,
    String? activeFilter,
    String? activeEventId,
    String? activeTag,
    List<String>? availableTags,
    List<Map<String, dynamic>>? availableEvents,
  }) {
    return GalleryLoaded(
      mediaItems: mediaItems ?? this.mediaItems,
      activeFilter: activeFilter ?? this.activeFilter,
      activeEventId: activeEventId ?? this.activeEventId,
      activeTag: activeTag ?? this.activeTag,
      availableTags: availableTags ?? this.availableTags,
      availableEvents: availableEvents ?? this.availableEvents,
    );
  }
}

class GalleryError extends GalleryState {
  final String message;

  const GalleryError({required this.message});

  @override
  List<Object> get props => [message];
}

// Bloc
class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  GalleryBloc() : super(GalleryInitial()) {
    on<FetchGalleryEvent>(_onFetchGallery);
    on<FilterGalleryEvent>(_onFilterGallery);
  }

  Future<void> _onFetchGallery(FetchGalleryEvent event, Emitter<GalleryState> emit) async {
    emit(GalleryLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock gallery data
      final allMediaItems = [
        {
          'id': '1',
          'type': 'image',
          'url': 'assets/gallery/tech_conference_1.jpg',
          'thumbnailUrl': 'assets/gallery/thumbnails/tech_conference_1.jpg',
          'title': 'Tech Conference Opening Ceremony',
          'description': 'Opening ceremony of the annual Tech Conference 2023.',
          'eventId': 'event1',
          'eventName': 'Tech Conference 2023',
          'date': '2023-11-15',
          'tags': ['ceremony', 'conference', 'tech'],
        },
        {
          'id': '2',
          'type': 'image',
          'url': 'assets/gallery/tech_conference_2.jpg',
          'thumbnailUrl': 'assets/gallery/thumbnails/tech_conference_2.jpg',
          'title': 'Keynote Speaker',
          'description': 'Industry expert delivering keynote address at Tech Conference 2023.',
          'eventId': 'event1',
          'eventName': 'Tech Conference 2023',
          'date': '2023-11-15',
          'tags': ['keynote', 'speaker', 'conference', 'tech'],
        },
        {
          'id': '3',
          'type': 'video',
          'url': 'assets/gallery/tech_conference_highlights.mp4',
          'thumbnailUrl': 'assets/gallery/thumbnails/tech_conference_highlights.jpg',
          'title': 'Tech Conference Highlights',
          'description': 'Highlights from the Tech Conference 2023 including keynote speeches and panel discussions.',
          'eventId': 'event1',
          'eventName': 'Tech Conference 2023',
          'date': '2023-11-15',
          'duration': '3:45', // minutes:seconds
          'tags': ['highlights', 'conference', 'tech'],
        },
        {
          'id': '4',
          'type': 'image',
          'url': 'assets/gallery/cultural_fest_1.jpg',
          'thumbnailUrl': 'assets/gallery/thumbnails/cultural_fest_1.jpg',
          'title': 'Cultural Fest Dance Performance',
          'description': 'Traditional dance performance at the Cultural Fest 2023.',
          'eventId': 'event2',
          'eventName': 'Cultural Fest',
          'date': '2023-12-05',
          'tags': ['dance', 'cultural', 'performance'],
        },
        {
          'id': '5',
          'type': 'image',
          'url': 'assets/gallery/cultural_fest_2.jpg',
          'thumbnailUrl': 'assets/gallery/thumbnails/cultural_fest_2.jpg',
          'title': 'Cultural Fest Art Exhibition',
          'description': 'Art exhibition showcasing student artwork at the Cultural Fest 2023.',
          'eventId': 'event2',
          'eventName': 'Cultural Fest',
          'date': '2023-12-05',
          'tags': ['art', 'exhibition', 'cultural'],
        },
        {
          'id': '6',
          'type': 'video',
          'url': 'assets/gallery/cultural_fest_highlights.mp4',
          'thumbnailUrl': 'assets/gallery/thumbnails/cultural_fest_highlights.jpg',
          'title': 'Cultural Fest Highlights',
          'description': 'Highlights from the Cultural Fest 2023 including performances and exhibitions.',
          'eventId': 'event2',
          'eventName': 'Cultural Fest',
          'date': '2023-12-05',
          'duration': '4:20', // minutes:seconds
          'tags': ['highlights', 'cultural', 'performance'],
        },
        {
          'id': '7',
          'type': 'image',
          'url': 'assets/gallery/hackathon_1.jpg',
          'thumbnailUrl': 'assets/gallery/thumbnails/hackathon_1.jpg',
          'title': 'Hackathon 2023 Kickoff',
          'description': 'Teams gathering for the kickoff of Hackathon 2023.',
          'eventId': 'event3',
          'eventName': 'Hackathon 2023',
          'date': '2023-10-20',
          'tags': ['hackathon', 'coding', 'tech'],
        },
        {
          'id': '8',
          'type': 'image',
          'url': 'assets/gallery/hackathon_2.jpg',
          'thumbnailUrl': 'assets/gallery/thumbnails/hackathon_2.jpg',
          'title': 'Hackathon Teams Working',
          'description': 'Teams hard at work during the 48-hour Hackathon 2023.',
          'eventId': 'event3',
          'eventName': 'Hackathon 2023',
          'date': '2023-10-20',
          'tags': ['hackathon', 'teamwork', 'coding'],
        },
        {
          'id': '9',
          'type': 'video',
          'url': 'assets/gallery/hackathon_presentations.mp4',
          'thumbnailUrl': 'assets/gallery/thumbnails/hackathon_presentations.jpg',
          'title': 'Hackathon Project Presentations',
          'description': 'Teams presenting their projects at the conclusion of Hackathon 2023.',
          'eventId': 'event3',
          'eventName': 'Hackathon 2023',
          'date': '2023-10-22',
          'duration': '10:15', // minutes:seconds
          'tags': ['hackathon', 'presentations', 'projects'],
        },
        {
          'id': '10',
          'type': 'image',
          'url': 'assets/gallery/workshop_1.jpg',
          'thumbnailUrl': 'assets/gallery/thumbnails/workshop_1.jpg',
          'title': 'Web Development Workshop',
          'description': 'Students participating in the hands-on Web Development Workshop.',
          'eventId': 'event4',
          'eventName': 'Web Development Workshop',
          'date': '2023-09-15',
          'tags': ['workshop', 'web', 'development', 'coding'],
        },
      ];
      
      // Filter by event if eventId is provided
      final List<Map<String, dynamic>> filteredItems = event.eventId != null
          ? allMediaItems.where((item) => item['eventId'] == event.eventId).toList()
          : allMediaItems;
      
      // Extract all unique tags from media items
      final Set<String> tagsSet = {};
      for (final item in allMediaItems) {
        if (item['tags'] != null) {
          final List<String> tags = List<String>.from(item['tags'] as List<dynamic>);
          tagsSet.addAll(tags);
        }
      }
      final List<String> allTags = tagsSet.toList()..sort();
      
      // Extract all unique events from media items
      final Map<String, Map<String, dynamic>> eventsMap = {};
      for (final item in allMediaItems) {
        if (item['eventId'] != null && item['eventName'] != null) {
          eventsMap[item['eventId'].toString()] = {
            'id': item['eventId'],
            'name': item['eventName'],
            'date': item['date'],
          };
        }
      }
      final List<Map<String, dynamic>> allEvents = eventsMap.values.toList();
      
      emit(GalleryLoaded(
        mediaItems: filteredItems,
        activeFilter: 'all',
        activeEventId: event.eventId,
        availableTags: allTags,
        availableEvents: allEvents,
      ));
    } catch (e) {
      emit(GalleryError(message: e.toString()));
    }
  }

  Future<void> _onFilterGallery(FilterGalleryEvent event, Emitter<GalleryState> emit) async {
    if (state is GalleryLoaded) {
      final currentState = state as GalleryLoaded;
      
      // Simulate API call or local filtering
      await Future.delayed(const Duration(milliseconds: 300));
      
      try {
        // Mock gallery data (reuse from _onFetchGallery)
        final allMediaItems = [
          {
            'id': '1',
            'type': 'image',
            'url': 'assets/gallery/tech_conference_1.jpg',
            'thumbnailUrl': 'assets/gallery/thumbnails/tech_conference_1.jpg',
            'title': 'Tech Conference Opening Ceremony',
            'description': 'Opening ceremony of the annual Tech Conference 2023.',
            'eventId': 'event1',
            'eventName': 'Tech Conference 2023',
            'date': '2023-11-15',
            'tags': ['ceremony', 'conference', 'tech'],
          },
          {
            'id': '2',
            'type': 'image',
            'url': 'assets/gallery/tech_conference_2.jpg',
            'thumbnailUrl': 'assets/gallery/thumbnails/tech_conference_2.jpg',
            'title': 'Keynote Speaker',
            'description': 'Industry expert delivering keynote address at Tech Conference 2023.',
            'eventId': 'event1',
            'eventName': 'Tech Conference 2023',
            'date': '2023-11-15',
            'tags': ['keynote', 'speaker', 'conference', 'tech'],
          },
          {
            'id': '3',
            'type': 'video',
            'url': 'assets/gallery/tech_conference_highlights.mp4',
            'thumbnailUrl': 'assets/gallery/thumbnails/tech_conference_highlights.jpg',
            'title': 'Tech Conference Highlights',
            'description': 'Highlights from the Tech Conference 2023 including keynote speeches and panel discussions.',
            'eventId': 'event1',
            'eventName': 'Tech Conference 2023',
            'date': '2023-11-15',
            'duration': '3:45', // minutes:seconds
            'tags': ['highlights', 'conference', 'tech'],
          },
          {
            'id': '4',
            'type': 'image',
            'url': 'assets/gallery/cultural_fest_1.jpg',
            'thumbnailUrl': 'assets/gallery/thumbnails/cultural_fest_1.jpg',
            'title': 'Cultural Fest Dance Performance',
            'description': 'Traditional dance performance at the Cultural Fest 2023.',
            'eventId': 'event2',
            'eventName': 'Cultural Fest',
            'date': '2023-12-05',
            'tags': ['dance', 'cultural', 'performance'],
          },
          {
            'id': '5',
            'type': 'image',
            'url': 'assets/gallery/cultural_fest_2.jpg',
            'thumbnailUrl': 'assets/gallery/thumbnails/cultural_fest_2.jpg',
            'title': 'Cultural Fest Art Exhibition',
            'description': 'Art exhibition showcasing student artwork at the Cultural Fest 2023.',
            'eventId': 'event2',
            'eventName': 'Cultural Fest',
            'date': '2023-12-05',
            'tags': ['art', 'exhibition', 'cultural'],
          },
          {
            'id': '6',
            'type': 'video',
            'url': 'assets/gallery/cultural_fest_highlights.mp4',
            'thumbnailUrl': 'assets/gallery/thumbnails/cultural_fest_highlights.jpg',
            'title': 'Cultural Fest Highlights',
            'description': 'Highlights from the Cultural Fest 2023 including performances and exhibitions.',
            'eventId': 'event2',
            'eventName': 'Cultural Fest',
            'date': '2023-12-05',
            'duration': '4:20', // minutes:seconds
            'tags': ['highlights', 'cultural', 'performance'],
          },
          {
            'id': '7',
            'type': 'image',
            'url': 'assets/gallery/hackathon_1.jpg',
            'thumbnailUrl': 'assets/gallery/thumbnails/hackathon_1.jpg',
            'title': 'Hackathon 2023 Kickoff',
            'description': 'Teams gathering for the kickoff of Hackathon 2023.',
            'eventId': 'event3',
            'eventName': 'Hackathon 2023',
            'date': '2023-10-20',
            'tags': ['hackathon', 'coding', 'tech'],
          },
          {
            'id': '8',
            'type': 'image',
            'url': 'assets/gallery/hackathon_2.jpg',
            'thumbnailUrl': 'assets/gallery/thumbnails/hackathon_2.jpg',
            'title': 'Hackathon Teams Working',
            'description': 'Teams hard at work during the 48-hour Hackathon 2023.',
            'eventId': 'event3',
            'eventName': 'Hackathon 2023',
            'date': '2023-10-20',
            'tags': ['hackathon', 'teamwork', 'coding'],
          },
          {
            'id': '9',
            'type': 'video',
            'url': 'assets/gallery/hackathon_presentations.mp4',
            'thumbnailUrl': 'assets/gallery/thumbnails/hackathon_presentations.jpg',
            'title': 'Hackathon Project Presentations',
            'description': 'Teams presenting their projects at the conclusion of Hackathon 2023.',
            'eventId': 'event3',
            'eventName': 'Hackathon 2023',
            'date': '2023-10-22',
            'duration': '10:15', // minutes:seconds
            'tags': ['hackathon', 'presentations', 'projects'],
          },
          {
            'id': '10',
            'type': 'image',
            'url': 'assets/gallery/workshop_1.jpg',
            'thumbnailUrl': 'assets/gallery/thumbnails/workshop_1.jpg',
            'title': 'Web Development Workshop',
            'description': 'Students participating in the hands-on Web Development Workshop.',
            'eventId': 'event4',
            'eventName': 'Web Development Workshop',
            'date': '2023-09-15',
            'tags': ['workshop', 'web', 'development', 'coding'],
          },
        ];
        
        // Apply filters
        List<Map<String, dynamic>> filteredItems = allMediaItems;
        
        // Filter by type
        if (event.filterType != 'all') {
          filteredItems = filteredItems.where((item) => item['type'] == event.filterType).toList();
        }
        
        // Filter by event
        if (event.eventId != null) {
          filteredItems = filteredItems.where((item) => item['eventId'] == event.eventId).toList();
        }
        
        // Filter by tag
        if (event.tag != null) {
          filteredItems = filteredItems.where((item) {
            final List<String> tags = List<String>.from(item['tags'] ?? []);
            return tags.contains(event.tag);
          }).toList();
        }
        
        emit(currentState.copyWith(
          mediaItems: filteredItems,
          activeFilter: event.filterType,
          activeEventId: event.eventId,
          activeTag: event.tag,
        ));
      } catch (e) {
        emit(GalleryError(message: e.toString()));
      }
    }
  }
}