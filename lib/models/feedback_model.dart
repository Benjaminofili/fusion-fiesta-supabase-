import 'package:hive/hive.dart';

part 'feedback_model.g.dart';

@HiveType(typeId: 3)
class FeedbackModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String message;

  @HiveField(3)
  int rating;

  @HiveField(4)
  DateTime createdAt;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.message,
    required this.rating,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'message': message,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      message: json['message'] ?? '',
      rating: json['rating'] != null ? (json['rating'] as num).toInt() : 0,
      createdAt: _parseDate(json['created_at']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) return DateTime.parse(value);
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
