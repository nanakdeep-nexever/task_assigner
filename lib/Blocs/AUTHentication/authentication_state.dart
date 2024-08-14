import 'package:equatable/equatable.dart';

abstract class AuthenticationState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthenticationInitial extends AuthenticationState {
  AuthenticationInitial(void init);
}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationAuthenticated extends AuthenticationState {
  final String? userId;

  AuthenticationAuthenticated({required this.userId});

  @override
  List<Object> get props => [userId!];
}

class AuthenticationUnauthenticated extends AuthenticationState {}

class AuthenticationError extends AuthenticationState {
  final String message;

  AuthenticationError({required this.message});

  @override
  List<Object> get props => [message];
}

class Rolechanged extends AuthenticationState {
  final String role;

  Rolechanged({required this.role});

  @override
  List<Object> get props => [role];
}
