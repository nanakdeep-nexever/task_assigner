// manager_page_event.dart
import 'package:equatable/equatable.dart';

abstract class ManagerPageEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadActiveUsers extends ManagerPageEvent {}

class LoadActiveTasks extends ManagerPageEvent {}

class LoadActiveProjects extends ManagerPageEvent {}

class LoadUserTasks extends ManagerPageEvent {}

class LoadUserProjects extends ManagerPageEvent {}
