import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class FetchProfileEvent extends ProfileEvent {
  final String userId;

  const FetchProfileEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class UpdateProfileEvent extends ProfileEvent {
  final Map<String, dynamic> profileData;

  const UpdateProfileEvent({required this.profileData});

  @override
  List<Object> get props => [profileData];
}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> profile;

  const ProfileLoaded({required this.profile});

  @override
  List<Object> get props => [profile];
}

class ProfileUpdateLoading extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final Map<String, dynamic> profile;

  const ProfileUpdateSuccess({required this.profile});

  @override
  List<Object> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object> get props => [message];
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<FetchProfileEvent>(_onFetchProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onFetchProfile(FetchProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock profile data
      final profile = {
        'id': event.userId,
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'phone': '+1 234 567 8901',
        'role': 'Student',
        'department': 'Computer Science',
        'year': '3rd Year',
        'college': 'Example University',
        'bio': 'Passionate computer science student with interests in AI and web development.',
        'profileImage': 'assets/images/profile.jpg',
  'skills': ['Flutter', 'Dart', 'UI/UX Design'],
        'interests': ['Mobile Development', 'Machine Learning', 'Cloud Computing'],
        'socialLinks': {
          'github': 'https://github.com/johndoe',
          'linkedin': 'https://linkedin.com/in/johndoe',
          'twitter': 'https://twitter.com/johndoe',
        },
        'events': [
          {
            'id': '1',
            'name': 'Tech Conference 2023',
            'date': '2023-11-15',
            'role': 'Participant',
            'status': 'Registered',
          },
          {
            'id': '2',
            'name': 'Hackathon 2023',
            'date': '2023-10-20',
            'role': 'Participant',
            'status': 'Completed',
          },
          {
            'id': '3',
            'name': 'Web Development Workshop',
            'date': '2023-09-10',
            'role': 'Volunteer',
            'status': 'Completed',
          },
        ],
        'achievements': [
          {
            'id': '1',
            'title': '1st Place - College Hackathon',
            'issuer': 'Example University',
            'date': '2023-05-15',
            'description': 'Won first place in the annual college hackathon for developing an innovative mobile app.',
          },
          {
            'id': '2',
            'title': 'Dean\'s List',
            'issuer': 'Computer Science Department',
            'date': '2023-01-10',
            'description': 'Recognized for academic excellence in the Fall 2022 semester.',
          },
        ],
        'certificates': [
          {
            'id': '1',
            'title': 'Flutter Development Bootcamp',
            'issuer': 'Mobile App Development Club',
            'date': '2023-08-20',
          },
          {
            'id': '2',
            'title': 'Web Development Workshop',
            'issuer': 'Computer Science Department',
            'date': '2023-09-15',
          },
          {
            'id': '3',
            'title': 'UI/UX Design Fundamentals',
            'issuer': 'Design Innovation Lab',
            'date': '2023-07-05',
          },
        ],
      };
      
      emit(ProfileLoaded(profile: profile));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    // Preserve current profile data
    Map<String, dynamic> currentProfile = {};
    if (state is ProfileLoaded) {
      currentProfile = (state as ProfileLoaded).profile;
    }
    
    emit(ProfileUpdateLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Update profile with new data
      final updatedProfile = {
        ...currentProfile,
        ...event.profileData,
      };
      
      emit(ProfileUpdateSuccess(profile: updatedProfile));
      emit(ProfileLoaded(profile: updatedProfile));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
      
      // Restore previous profile state if available
      if (currentProfile.isNotEmpty) {
        emit(ProfileLoaded(profile: currentProfile));
      }
    }
  }
}