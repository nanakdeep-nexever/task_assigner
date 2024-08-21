import 'package:equatable/equatable.dart';

abstract class ActiveUsersEvent extends Equatable {
  const ActiveUsersEvent();

  @override
  List<Object?> get props => [];
}

class LoadActiveUsers extends ActiveUsersEvent {}

class CreateUser extends ActiveUsersEvent {
  final String email;
  final String password;
  final String role;

  const CreateUser(this.email, this.password, this.role);

  @override
  List<Object?> get props => [email, password, role];
}

class DeleteUser extends ActiveUsersEvent {
  final String uid;

  const DeleteUser(this.uid);

  @override
  List<Object?> get props => [uid];
}

class UpdateUserRole extends ActiveUsersEvent {
  final String uid;
  final String newRole;

  const UpdateUserRole(this.uid, this.newRole);

  @override
  List<Object?> get props => [uid, newRole];
}
