import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusion_fiesta/core/services/certificate_service.dart';
import 'package:fusion_fiesta/models/certificate_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fusion_fiesta/core/services/AppError.dart';
import 'package:fusion_fiesta/core/services/sync_service.dart';
import 'package:fusion_fiesta/supabase_manager.dart';
import 'package:fusion_fiesta/storage/hive_manager.dart';

abstract class CertificatesEvent extends Equatable {
  const CertificatesEvent();

  @override
  List<Object> get props => [];
}

class FetchCertificatesEvent extends CertificatesEvent {
  final String userId;

  const FetchCertificatesEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class DownloadCertificateEvent extends CertificatesEvent {
  final String certificateId;

  const DownloadCertificateEvent({required this.certificateId});

  @override
  List<Object> get props => [certificateId];
}

class ShareCertificateEvent extends CertificatesEvent {
  final String certificateId;
  final String platform;

  const ShareCertificateEvent({
    required this.certificateId,
    required this.platform,
  });

  @override
  List<Object> get props => [certificateId, platform];
}

abstract class CertificatesState extends Equatable {
  const CertificatesState();

  @override
  List<Object> get props => [];
}

class CertificatesInitial extends CertificatesState {}

class CertificatesLoading extends CertificatesState {}

class CertificatesLoaded extends CertificatesState {
  final List<CertificateModel> certificates;

  const CertificatesLoaded({required this.certificates});

  @override
  List<Object> get props => [certificates];
}

class CertificateDownloading extends CertificatesState {
  final String certificateId;

  const CertificateDownloading({required this.certificateId});

  @override
  List<Object> get props => [certificateId];
}

class CertificateDownloaded extends CertificatesState {
  final String certificateId;
  final String filePath;

  const CertificateDownloaded({
    required this.certificateId,
    required this.filePath,
  });

  @override
  List<Object> get props => [certificateId, filePath];
}

class CertificateSharing extends CertificatesState {
  final String certificateId;
  final String platform;

  const CertificateSharing({
    required this.certificateId,
    required this.platform,
  });

  @override
  List<Object> get props => [certificateId, platform];
}

class CertificateShared extends CertificatesState {
  final String certificateId;
  final String platform;

  const CertificateShared({
    required this.certificateId,
    required this.platform,
  });

  @override
  List<Object> get props => [certificateId, platform];
}

class CertificatesError extends CertificatesState {
  final String message;

  const CertificatesError({required this.message});

  @override
  List<Object> get props => [message];
}

class CertificatesBloc extends Bloc<CertificatesEvent, CertificatesState> {
  CertificatesBloc() : super(CertificatesInitial()) {
    on<FetchCertificatesEvent>(_onFetchCertificates);
    on<DownloadCertificateEvent>(_onDownloadCertificate);
    on<ShareCertificateEvent>(_onShareCertificate);
  }

  Future<void> _onFetchCertificates(FetchCertificatesEvent event, Emitter<CertificatesState> emit) async {
    emit(CertificatesLoading());
    try {
      final result = await CertificateService.getUserCertificates(event.userId);
      if (result['success']) {
        emit(CertificatesLoaded(certificates: result['certificates'] as List<CertificateModel>));
      } else {
        emit(CertificatesError(message: result['error']));
      }
    } catch (e) {
      emit(CertificatesError(message: AppError.fromException(e).message));
    }
  }

  Future<void> _onDownloadCertificate(DownloadCertificateEvent event, Emitter<CertificatesState> emit) async {
    emit(CertificateDownloading(certificateId: event.certificateId));
    try {
      bool isOnline = await SyncService.checkConnectivityAndSync();
      String? certificateUrl;
      CertificateModel? certificate;

      if (isOnline) {
        final response = await SupabaseManager.client
            .from('certificates')
            .select()
            .eq('id', event.certificateId)
            .single();

        certificate = CertificateModel.fromMap(response);
        certificateUrl = certificate.certificateUrl;
        if (certificateUrl == null) {
          throw Exception('Certificate URL not found');
        }

        await HiveManager.certificatesBox.put(certificate.id, certificate);
      } else {
        certificate = HiveManager.certificatesBox.get(event.certificateId);
        if (certificate == null) {
          throw Exception('Certificate not available offline');
        }
        certificateUrl = certificate.certificateUrl;
      }

      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        emit(CertificatesError(message: 'Storage permission denied'));
        return;
      }

      final response = await http.get(Uri.parse(certificateUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download certificate');
      }

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/certificate_${event.certificateId}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      await CertificateService.markCertificateDownloaded(event.certificateId);

      emit(CertificateDownloaded(
        certificateId: event.certificateId,
        filePath: filePath,
      ));

      if (state is CertificatesLoaded) {
        final previousState = state as CertificatesLoaded;
        emit(CertificatesLoaded(certificates: previousState.certificates));
      }
    } catch (e) {
      emit(CertificatesError(message: AppError.fromException(e).message));
    }
  }

  Future<void> _onShareCertificate(ShareCertificateEvent event, Emitter<CertificatesState> emit) async {
    emit(CertificateSharing(certificateId: event.certificateId, platform: event.platform));
    try {
      bool isOnline = await SyncService.checkConnectivityAndSync();
      String? certificateUrl;
      CertificateModel? certificate;

      if (isOnline) {
        final response = await SupabaseManager.client
            .from('certificates')
            .select()
            .eq('id', event.certificateId)
            .single();

        certificate = CertificateModel.fromMap(response);
        certificateUrl = certificate.certificateUrl;
        if (certificateUrl == null) {
          throw Exception('Certificate URL not found');
        }

        await HiveManager.certificatesBox.put(certificate.id, certificate);
      } else {
        certificate = HiveManager.certificatesBox.get(event.certificateId);
        if (certificate == null) {
          throw Exception('Certificate not available offline');
        }
        certificateUrl = certificate.certificateUrl;
      }

      final response = await http.get(Uri.parse(certificateUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download certificate for sharing');
      }

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/certificate_${event.certificateId}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Check out my certificate for ${certificate?.eventTitle ?? 'Event'}!',
      );

      emit(CertificateShared(certificateId: event.certificateId, platform: event.platform));

      if (state is CertificatesLoaded) {
        final previousState = state as CertificatesLoaded;
        emit(CertificatesLoaded(certificates: previousState.certificates));
      }
    } catch (e) {
      emit(CertificatesError(message: AppError.fromException(e).message));
    }
  }
}