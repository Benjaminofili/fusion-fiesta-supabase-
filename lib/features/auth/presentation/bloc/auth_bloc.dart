import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusion_fiesta/core/services/auth_service.dart'; // Updated import
import '../../../../../models/user_model.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String role;
  final String? phone;
  final String? enrollmentNumber;
  final String? department;

  const RegisterEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.phone,
    this.enrollmentNumber,
    this.department,
  });

  @override
  List<Object> get props => [name, email, password, role];
}

class LogoutEvent extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await EnhancedAuthService.login(
      email: event.email,
      password: event.password,
    );
    if (result['success'] == true) {
      emit(AuthAuthenticated(user: result['user']));
    } else {
      emit(AuthError(message: result['error']));
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await EnhancedAuthService.register(
      name: event.name,
      email: event.email,
      password: event.password,
      role: event.role,
      phone: event.phone,
      enrollmentNumber: event.enrollmentNumber,
      department: event.department,
    );
    if (result['success'] == true) {
      emit(AuthAuthenticated(user: result['user']));
    } else {
      emit(AuthError(message: result['error'] ?? 'Registration failed'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await EnhancedAuthService.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final user = EnhancedAuthService.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user: user));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}