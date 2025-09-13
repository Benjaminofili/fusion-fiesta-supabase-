import 'package:hive_flutter/hive_flutter.dart';

part 'feedback_model.g.dart';

@HiveType(typeId: 3)
class FeedbackModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String eventId;

  @HiveField(3)
  int rating;

  @HiveField(4)
  String? message;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  bool isAnonymous;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.rating,
    this.message,
    required this.createdAt,
    this.isAnonymous = false,
  });

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      eventId: map['event_id'] as String,
      rating: map['rating'] as int,
      message: map['message'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      isAnonymous: map['is_anonymous'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
      'rating': rating,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_anonymous': isAnonymous,
    };
  }
}