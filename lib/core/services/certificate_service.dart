import 'package:uuid/uuid.dart';
import '../../models/certificate_model.dart';
import '../../models/registration_model.dart';
import '../../storage/hive_manager.dart';
import '../../supabase_manager.dart';
import '../constants/app_constants.dart';
import 'AppError.dart';
import 'notification_service.dart';
import 'sync_service.dart';
import 'auth_service.dart'; // Fixed import

class CertificateService {
  static final _supabase = SupabaseManager.client;

  static Future<Map<String, dynamic>> issueCertificate({
    required String userId,
    required String eventId,
    required String certificateUrl,
    String? templateUsed,
  }) async {
    try {
      // Validate user eligibility
      final registrationResponse = await _supabase
          .from('registrations')
          .select()
          .eq('user_id', userId)
          .eq('event_id', eventId)
          .eq('status', 'attended')
          .maybeSingle();

      if (registrationResponse == null) {
        return {
          'success': false,
          'error': 'User has not attended this event',
        };
      }

      final certificate = CertificateModel(
        id: const Uuid().v4(),
        userId: userId,
        eventId: eventId,
        certificateUrl: certificateUrl,
        certificateCode: const Uuid().v4(),
        templateUsed: templateUsed,
        issuedAt: DateTime.now(),
        downloadedAt: null,
        eventTitle: null,
      );

      bool isOnline = await SyncService.checkConnectivityAndSync();

      if (isOnline) {
        await _supabase.from('certificates').insert(certificate.toMap());
      } else {
        await HiveManager.offlineBox.add({
          'type': 'certificate_issue',
          'data': certificate.toMap(),
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      await HiveManager.certificatesBox.put(certificate.id, certificate);

      // Notify user
      final user = EnhancedAuthService.getCurrentUser();
      if (user != null) {
        // Fetch event title for notification
        final eventTitle = await certificate.getEventTitle() ?? 'Event $eventId';
        await NotificationService.createNotification(
          userId: userId,
          title: 'Certificate Issued',
          message: 'Your certificate for $eventTitle has been issued.',
          type: 'success',
        );
      }

      return {'success': true, 'certificate': certificate};
    } catch (e) {
      return {'success': false, 'error': AppError.fromException(e).message};
    }
  }

  static Future<Map<String, dynamic>> getUserCertificates(String userId) async {
    try {
      List<CertificateModel> certificates = [];
      bool isOnline = await SyncService.checkConnectivityAndSync();

      if (isOnline) {
        final response = await _supabase
            .from('certificates')
            .select('*, events!inner(title)')
            .eq('user_id', userId);

        certificates = response.map((data) => CertificateModel.fromMap({
          ...data,
          'event_title': data['events']['title'],
        })).toList();

        for (final cert in certificates) {
          await HiveManager.certificatesBox.put(cert.id, cert);
        }
      } else {
        certificates = HiveManager.certificatesBox.values
            .where((c) => c.userId == userId)
            .toList();
      }

      for (final cert in certificates.where((c) => c.eventTitle == null)) {
        await cert.getEventTitle();
      }

      return {'success': true, 'certificates': certificates};
    } catch (e) {
      return {'success': false, 'error': AppError.fromException(e).message};
    }
  }

  static Future<Map<String, dynamic>> markCertificateDownloaded(String certificateId) async {
    try {
      bool isOnline = await SyncService.checkConnectivityAndSync();
      final cert = HiveManager.certificatesBox.get(certificateId);

      if (cert == null) {
        return {'success': false, 'error': 'Certificate not found'};
      }

      if (isOnline) {
        await _supabase
            .from('certificates')
            .update({'downloaded_at': DateTime.now().toIso8601String()})
            .eq('id', certificateId);
      } else {
        await HiveManager.offlineBox.add({
          'type': 'certificate_download',
          'data': {'id': certificateId, 'downloaded_at': DateTime.now().toIso8601String()},
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      cert.downloadedAt = DateTime.now();
      await cert.save();

      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': AppError.fromException(e).message};
    }
  }
}