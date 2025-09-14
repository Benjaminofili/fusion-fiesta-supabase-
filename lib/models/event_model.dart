import 'package:hive/hive.dart';

import '../core/constants/app_constants.dart';

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
  final DateTime dateTime; // Combined from date and time in Supabase

  @HiveField(6)
  final String venue;

  @HiveField(7)
  final String status;

  @HiveField(8)
  final String? organizerId;

  @HiveField(9)
  final int maxParticipants;

  @HiveField(10)
  final int currentParticipants;

  @HiveField(11)
  final String? bannerUrl;

  @HiveField(12)
  final double cost;

  @HiveField(13)
  final DateTime? registrationDeadline;

  @HiveField(14)
  final String eventType;

  @HiveField(15)
  final DateTime createdAt;

  @HiveField(16)
  final DateTime updatedAt;

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
    required this.maxParticipants,
    required this.currentParticipants,
    this.bannerUrl,
    required this.cost,
    this.registrationDeadline,
    required this.eventType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    // Handle null String fields with defaults
    final id = map['id'] as String? ?? 'unknown_id';
    final title = map['title'] as String? ?? 'Untitled Event';
    final description = map['description'] as String? ?? 'No description';
    final category = map['category'] as String? ?? 'Unknown';
    final venue = map['venue'] as String? ?? 'Unknown Venue';
    final status = map['status'] as String? ?? AppConstants.statusPending;
    final organizerId = map['organizer_id'] as String?;
    final eventType = map['event_type'] as String? ?? 'academic'; // Default value

    // Handle date and time combination
    final date = map['date'] as String?;
    final time = map['time'] as String?;
    DateTime dateTime;
    try {
      dateTime = DateTime.parse('${date ?? '1970-01-01'} ${time ?? '00:00:00'}');
    } catch (e) {
      dateTime = DateTime.now(); // Fallback to current time if parsing fails
    }

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
      maxParticipants: (map['max_participants'] as int?) ?? 0,
      currentParticipants: (map['current_participants'] as int?) ?? 0,
      bannerUrl: map['banner_url'] as String?,
      cost: (map['cost'] as num?)?.toDouble() ?? 0.0,
      registrationDeadline: map['registration_deadline'] != null
          ? DateTime.parse(map['registration_deadline'] as String)
          : null,
      eventType: eventType,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
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
    };
  }

  // Add isRegistered based on registrations
  bool get isRegistered {
    // This requires checking registrations table - implement in service or here if data is joined
    // For now, placeholder - update with actual logic
    return false; // Replace with logic using registrations data
  }
}