import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadUsersEvent extends UserEvent {}

class CreateUserEvent extends UserEvent {
  final String name;
  final String email;
  final String roleId;

  CreateUserEvent(
      {required this.name, required this.email, required this.roleId});
}

class UpdateUserEvent extends UserEvent {
  final String userId;
  final String name;
  final String email;
  final String roleId;

  UpdateUserEvent(
      {required this.userId,
      required this.name,
      required this.email,
      required this.roleId});
}

class DeleteUserEvent extends UserEvent {
  final String userId;

  DeleteUserEvent({required this.userId});
}
