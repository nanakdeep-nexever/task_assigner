part of 'admin_bloc.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object> get props => [];
}

class FetchUserData extends AdminEvent {}

class FetchActiveUsers extends AdminEvent {}

class FetchActiveTasks extends AdminEvent {}

class FetchActiveProjects extends AdminEvent {}
