import 'package:hive/hive.dart';
import '../../storage/hive_manager.dart';
import '../../supabase_manager.dart';

part 'certificate_model.g.dart';

@HiveType(typeId: 4)
class CertificateModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String eventId;

  @HiveField(3)
  final String certificateUrl;

  @HiveField(4)
  final String certificateCode;

  @HiveField(5)
  final String? templateUsed;

  @HiveField(6)
  final DateTime issuedAt;

  @HiveField(7)
  DateTime? downloadedAt; // Removed final

  @HiveField(8)
  String? eventTitle;

  CertificateModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.certificateUrl,
    required this.certificateCode,
    this.templateUsed,
    required this.issuedAt,
    this.downloadedAt,
    this.eventTitle,
  });

  factory CertificateModel.fromMap(Map<String, dynamic> map) {
    return CertificateModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      eventId: map['event_id'] as String,
      certificateUrl: map['certificate_url'] as String,
      certificateCode: map['certificate_code'] as String,
      templateUsed: map['template_used'] as String?,
      issuedAt: DateTime.parse(map['issued_at'] as String),
      downloadedAt: map['downloaded_at'] != null ? DateTime.parse(map['downloaded_at'] as String) : null,
      eventTitle: map['event_title'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
      'certificate_url': certificateUrl,
      'certificate_code': certificateCode,
      'template_used': templateUsed,
      'issued_at': issuedAt.toIso8601String(),
      'downloaded_at': downloadedAt?.toIso8601String(),
      'event_title': eventTitle,
    };
  }

  Future<String?> getEventTitle() async {
    if (eventTitle != null) return eventTitle;
    try {
      final event = HiveManager.eventsBox.get(eventId);
      if (event != null) {
        eventTitle = event.title;
        await save();
        return eventTitle;
      }

      final response = await SupabaseManager.client
          .from('events')
          .select('title')
          .eq('id', eventId)
          .single();
      eventTitle = response['title'] as String;
      await save();
      return eventTitle;
    } catch (e) {
      return null;
    }
  }
}