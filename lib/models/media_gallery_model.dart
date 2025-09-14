import 'package:hive_flutter/hive_flutter.dart';

part 'media_gallery_model.g.dart';

@HiveType(typeId: 6)
class MediaGalleryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String eventId;

  @HiveField(2)
  String fileType;

  @HiveField(3)
  String fileUrl;

  @HiveField(4)
  String uploadedBy;

  @HiveField(5)
  String? caption;

  @HiveField(6)
  DateTime uploadedAt;

  MediaGalleryModel({
    required this.id,
    required this.eventId,
    required this.fileType,
    required this.fileUrl,
    required this.uploadedBy,
    this.caption,
    required this.uploadedAt,
  });

  factory MediaGalleryModel.fromMap(Map<String, dynamic> map) {
    return MediaGalleryModel(
      id: map['id'] as String,
      eventId: map['event_id'] as String,
      fileType: map['file_type'] as String,
      fileUrl: map['file_url'] as String,
      uploadedBy: map['uploaded_by'] as String,
      caption: map['caption'] as String?,
      uploadedAt: DateTime.parse(map['uploaded_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'file_type': fileType,
      'file_url': fileUrl,
      'uploaded_by': uploadedBy,
      'caption': caption,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}