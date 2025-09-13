import 'package:hive/hive.dart';

part 'event_model.g.dart';

@HiveType(typeId: 1)
class EventModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String location;

  @HiveField(4)
  DateTime dateTime;

  @HiveField(5)
  String createdBy; // userId of organizer

  @HiveField(6)
  double cost;

  @HiveField(7)
  int capacity;

  @HiveField(8)
  DateTime createdAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.createdBy,
    required this.cost,
    required this.capacity,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'datetime': dateTime.toIso8601String(),
      'created_by': createdBy,
      'cost': cost,
      'capacity': capacity,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      dateTime: _parseDate(json['datetime']),
      createdBy: json['created_by'] ?? '',
      cost: json['cost'] != null ? double.tryParse(json['cost'].toString()) ?? 0.0 : 0.0,
      capacity: json['capacity'] != null ? (json['capacity'] as num).toInt() : 0,
      createdAt: _parseDate(json['created_at']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) return DateTime.parse(value);
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
