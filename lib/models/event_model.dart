import 'package:hive/hive.dart';
import '../core/constants/app_constants.dart';
import '../storage/hive_manager.dart';

part 'event_model.g.dart';

@HiveType(typeId: 1)
class EventModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String? department;

  @HiveField(5)
  final DateTime dateTime;

  @HiveField(6)
  final String venue;

  @HiveField(7)
  final String status;

  @HiveField(8)
  final String? organizerId;

  @HiveField(9)
  final int? maxParticipants; // Changed to nullable

  @HiveField(10)
  final int? currentParticipants; // Changed to nullable

  @HiveField(11)
  final String? bannerUrl;

  @HiveField(12)
  final double? cost; // Changed to nullable

  @HiveField(13)
  final DateTime? registrationDeadline;

  @HiveField(14)
  final String eventType;

  @HiveField(15)
  final DateTime createdAt;

  @HiveField(16)
  final DateTime updatedAt;

  @HiveField(17)
  final bool? isBookmarked;

  @HiveField(18)
  final int? registrationsCount;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.department,
    required this.dateTime,
    required this.venue,
    required this.status,
    this.organizerId,
    this.maxParticipants, // Updated constructor
    this.currentParticipants, // Updated constructor
    this.bannerUrl,
    this.cost, // Updated constructor
    this.registrationDeadline,
    required this.eventType,
    required this.createdAt,
    required this.updatedAt,
    this.isBookmarked = false,
    this.registrationsCount = 0,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    final id = map['id'] as String? ?? 'unknown_id';
    final title = map['title'] as String? ?? 'Untitled Event';
    final description = map['description'] as String? ?? 'No description';
    final category = map['category'] as String? ?? 'Unknown';
    final venue = map['venue'] as String? ?? 'Unknown Venue';
    final status = map['status'] as String? ?? AppConstants.statusPending;
    final organizerId = map['organizer_id'] as String?;
    final dateTime = DateTime.parse('${map['date']}T${map['time']}:00.000Z');
    final eventType = map['event_type'] as String? ?? 'academic';

    return EventModel(
      id: id,
      title: title,
      description: description,
      category: category,
      department: map['department'] as String?,
      dateTime: dateTime,
      venue: venue,
      status: status,
      organizerId: organizerId,
      maxParticipants: map['max_participants'] as int?,
      currentParticipants: map['current_participants'] as int?,
      bannerUrl: map['banner_url'] as String?,
      cost: (map['cost'] as num?)?.toDouble(),
      registrationDeadline: map['registration_deadline'] != null
          ? DateTime.parse(map['registration_deadline'] as String)
          : null,
      eventType: eventType,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isBookmarked: map['is_bookmarked'] as bool?,
      registrationsCount: map['registrations_count'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'department': department,
      'date': dateTime.toIso8601String().split('T')[0],
      'time': '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
      'venue': venue,
      'status': status,
      'organizer_id': organizerId,
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'banner_url': bannerUrl,
      'cost': cost,
      'registration_deadline': registrationDeadline?.toIso8601String(),
      'event_type': eventType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_bookmarked': isBookmarked,
      'registrations_count': registrationsCount,
    };
  }

  bool get isRegistered {
    return HiveManager.registrationsBox.values.any((r) => r.eventId == id && r.status == 'registered');
  }

  bool get hasSlotsAvailable {
    return (currentParticipants ?? 0) < (maxParticipants ?? 0); // Handle null with defaults
  }


}