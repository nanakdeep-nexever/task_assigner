import 'package:equatable/equatable.dart';
import 'package:task_assign_app/model/Notification_Model.dart';

abstract class NotificationState extends Equatable {
  @override
  List<Object> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<Notification> notifications;

  NotificationLoaded({required this.notifications});

  @override
  List<Object> get props => [notifications];
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError({required this.message});

  @override
  List<Object> get props => [message];
}
