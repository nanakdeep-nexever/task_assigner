part of 'admin_bloc.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object> get props => [message];
}

class AdminUserDataLoaded extends AdminState {
  final Stream<QuerySnapshot> userStream;

  const AdminUserDataLoaded(this.userStream);

  @override
  List<Object> get props => [userStream];
}

class AdminActiveUsersLoaded extends AdminState {
  final Stream<int> activeUsersStream;

  const AdminActiveUsersLoaded(this.activeUsersStream);

  @override
  List<Object> get props => [activeUsersStream];
}

class AdminActiveTasksLoaded extends AdminState {
  final Stream<int> activeTasksStream;

  const AdminActiveTasksLoaded(this.activeTasksStream);

  @override
  List<Object> get props => [activeTasksStream];
}

class AdminActiveProjectsLoaded extends AdminState {
  final Stream<int> activeProjectsStream;

  const AdminActiveProjectsLoaded(this.activeProjectsStream);

  @override
  List<Object> get props => [activeProjectsStream];
}
