import 'package:hive/hive.dart';
import '../core/constants/app_constants.dart';

part 'bookmark_model.g.dart';

@HiveType(typeId: 8)
class BookmarkModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String eventId;

  @HiveField(3)
  final DateTime createdAt;

  BookmarkModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.createdAt,
  });

  factory BookmarkModel.fromMap(Map<String, dynamic> map) {
    return BookmarkModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      eventId: map['event_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}