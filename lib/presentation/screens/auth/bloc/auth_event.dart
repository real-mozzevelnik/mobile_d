import 'package:equatable/equatable.dart';
import '../../../../data/models/auth_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final LoginRequest loginRequest;

  const LoginRequested(this.loginRequest);

  @override
  List<Object> get props => [loginRequest];
}

class RegisterRequested extends AuthEvent {
  final RegisterRequest registerRequest;

  const RegisterRequested(this.registerRequest);

  @override
  List<Object> get props => [registerRequest];
}

class LogoutRequested extends AuthEvent {}
