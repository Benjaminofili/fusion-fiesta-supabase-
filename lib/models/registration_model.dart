import 'package:hive_flutter/hive_flutter.dart';

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
  String status;

  @HiveField(4)
  DateTime registeredAt;

  @HiveField(5)
  String? registrationCode;

  @HiveField(6)
  DateTime? attendanceMarkedAt;

  @HiveField(7)
  String? paymentStatus;

  @HiveField(8)
  String? paymentReference;

  RegistrationModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.status,
    required this.registeredAt,
    this.registrationCode,
    this.attendanceMarkedAt,
    this.paymentStatus,
    this.paymentReference,
  });

  factory RegistrationModel.fromMap(Map<String, dynamic> map) {
    return RegistrationModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      eventId: map['event_id'] as String,
      status: map['status'] as String,
      registeredAt: DateTime.parse(map['registered_at'] as String),
      registrationCode: map['registration_code'] as String?,
      attendanceMarkedAt: map['attendance_marked_at'] != null
          ? DateTime.parse(map['attendance_marked_at'] as String)
          : null,
      paymentStatus: map['payment_status'] as String?,
      paymentReference: map['payment_reference'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
      'status': status,
      'registered_at': registeredAt.toIso8601String(),
      'registration_code': registrationCode,
      'attendance_marked_at': attendanceMarkedAt?.toIso8601String(),
      'payment_status': paymentStatus,
      'payment_reference': paymentReference,
    };
  }
}