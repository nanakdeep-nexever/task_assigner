import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadNotificationsEvent extends NotificationEvent {}

class MarkNotificationAsReadEvent extends NotificationEvent {
  final String notificationId;

  MarkNotificationAsReadEvent({required this.notificationId});
}
