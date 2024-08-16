import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CheckAuthEvent extends AuthenticationEvent {}

class LoginEvent extends AuthenticationEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

class RegisterEvent extends AuthenticationEvent {
  final String email;
  final String password;

  RegisterEvent({required this.email, required this.password});
}

class LogoutEvent extends AuthenticationEvent {}

class PasswordResetEvent extends AuthenticationEvent {
  final String email;

  PasswordResetEvent({required this.email});
}

class AuthenticationRoleChanged extends AuthenticationEvent {
  final String role;

  AuthenticationRoleChanged(this.role);
}
