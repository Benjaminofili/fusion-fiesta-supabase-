import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// Events
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
  final String platform; // email, whatsapp, linkedin, etc.

  const ShareCertificateEvent({
    required this.certificateId,
    required this.platform,
  });

  @override
  List<Object> get props => [certificateId, platform];
}

// States
abstract class CertificatesState extends Equatable {
  const CertificatesState();

  @override
  List<Object> get props => [];
}

class CertificatesInitial extends CertificatesState {}

class CertificatesLoading extends CertificatesState {}

class CertificatesLoaded extends CertificatesState {
  final List<Map<String, dynamic>> certificates;

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

// Bloc
class CertificatesBloc extends Bloc<CertificatesEvent, CertificatesState> {
  CertificatesBloc() : super(CertificatesInitial()) {
    on<FetchCertificatesEvent>(_onFetchCertificates);
    on<DownloadCertificateEvent>(_onDownloadCertificate);
    on<ShareCertificateEvent>(_onShareCertificate);
  }

  Future<void> _onFetchCertificates(FetchCertificatesEvent event, Emitter<CertificatesState> emit) async {
    emit(CertificatesLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock certificates data
      final certificates = [
        {
          'id': '1',
          'title': 'Flutter Development Bootcamp',
          'issuer': 'Mobile App Development Club',
          'issueDate': '2023-08-20',
          'eventId': 'event1',
          'description': 'Awarded for successfully completing the Flutter Development Bootcamp and demonstrating proficiency in building cross-platform mobile applications.',
          'imageUrl': 'assets/certificates/flutter_bootcamp.jpg',
          'skills': ['Flutter', 'Dart', 'Mobile Development'],
          'verificationCode': 'FLTR-2023-08-JD-001',
        },
        {
          'id': '2',
          'title': 'Web Development Workshop',
          'issuer': 'Computer Science Department',
          'issueDate': '2023-09-15',
          'eventId': 'event2',
          'description': 'Awarded for active participation and completion of the Web Development Workshop, covering HTML, CSS, JavaScript, and responsive design principles.',
          'imageUrl': 'assets/certificates/web_dev_workshop.jpg',
          'skills': ['HTML', 'CSS', 'JavaScript', 'Responsive Design'],
          'verificationCode': 'WEB-2023-09-JD-002',
        },
        {
          'id': '3',
          'title': 'UI/UX Design Fundamentals',
          'issuer': 'Design Innovation Lab',
          'issueDate': '2023-07-05',
          'eventId': 'event3',
          'description': 'Awarded for completing the UI/UX Design Fundamentals course and demonstrating understanding of user-centered design principles and prototyping techniques.',
          'imageUrl': 'assets/certificates/uiux_design.jpg',
          'skills': ['UI Design', 'UX Design', 'Prototyping', 'User Research'],
          'verificationCode': 'UIUX-2023-07-JD-003',
        },
        {
          'id': '4',
          'title': 'Hackathon 2023 Participant',
          'issuer': 'Coding Club',
          'issueDate': '2023-10-22',
          'eventId': 'event4',
          'description': 'Awarded for participating in Hackathon 2023 and developing innovative solutions to real-world problems within a 48-hour timeframe.',
          'imageUrl': 'assets/certificates/hackathon_2023.jpg',
          'skills': ['Problem Solving', 'Teamwork', 'Rapid Prototyping'],
          'verificationCode': 'HACK-2023-10-JD-004',
        },
      ];
      
      emit(CertificatesLoaded(certificates: certificates));
    } catch (e) {
      emit(CertificatesError(message: e.toString()));
    }
  }

  Future<void> _onDownloadCertificate(DownloadCertificateEvent event, Emitter<CertificatesState> emit) async {
    emit(CertificateDownloading(certificateId: event.certificateId));
    try {
      // Simulate download process
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock file path for downloaded certificate
  final filePath = 'certificate_${event.certificateId}.pdf';
      
      emit(CertificateDownloaded(
        certificateId: event.certificateId,
        filePath: filePath,
      ));
      
      // Restore previous state with certificates list if available
      if (state is CertificatesLoaded) {
        final previousState = state as CertificatesLoaded;
        emit(CertificatesLoaded(certificates: previousState.certificates));
      }
    } catch (e) {
      emit(CertificatesError(message: e.toString()));
    }
  }

  Future<void> _onShareCertificate(ShareCertificateEvent event, Emitter<CertificatesState> emit) async {
    emit(CertificateSharing(
      certificateId: event.certificateId,
      platform: event.platform,
    ));
    try {
      // Simulate sharing process
      await Future.delayed(const Duration(seconds: 1));
      
      emit(CertificateShared(
        certificateId: event.certificateId,
        platform: event.platform,
      ));
      
      // Restore previous state with certificates list if available
      if (state is CertificatesLoaded) {
        final previousState = state as CertificatesLoaded;
        emit(CertificatesLoaded(certificates: previousState.certificates));
      }
    } catch (e) {
      emit(CertificatesError(message: e.toString()));
    }
  }
}