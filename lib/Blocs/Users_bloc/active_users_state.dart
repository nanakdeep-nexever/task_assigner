import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class ActiveUsersState extends Equatable {
  const ActiveUsersState();

  @override
  List<Object?> get props => [];
}

class ActiveUsersInitial extends ActiveUsersState {}

class ActiveUsersLoading extends ActiveUsersState {}

class ActiveUsersLoaded extends ActiveUsersState {
  final List<QueryDocumentSnapshot> users;

  const ActiveUsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class ActiveUsersError extends ActiveUsersState {
  final String message;

  const ActiveUsersError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserActionSuccess extends ActiveUsersState {
  final String message;

  const UserActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
