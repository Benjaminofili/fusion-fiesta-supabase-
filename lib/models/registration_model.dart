import 'package:hive/hive.dart';

part 'registration_model.g.dart';

@HiveType(typeId: 2)
class RegistrationModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String eventId;

  @HiveField(3)
  String status; // pending, confirmed, cancelled

  @HiveField(4)
  DateTime registeredAt;

  RegistrationModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.status,
    required this.registeredAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
      'status': status,
      'registered_at': registeredAt.toIso8601String(),
    };
  }

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      eventId: json['event_id'] ?? '',
      status: json['status'] ?? 'pending',
      registeredAt: _parseDate(json['registered_at']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) return DateTime.parse(value);
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
