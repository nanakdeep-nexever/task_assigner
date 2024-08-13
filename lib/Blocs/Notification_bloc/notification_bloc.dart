import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:task_assign_app/Blocs/Notification_bloc/notification_event.dart';
import 'package:task_assign_app/Blocs/Notification_bloc/notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial()) {
    on<LoadNotificationsEvent>(_loadNotification);
    on<MarkNotificationAsReadEvent>(_markNotification_Read);
  }

  FutureOr<void> _loadNotification(
      LoadNotificationsEvent event, Emitter<NotificationState> emit) {}

  FutureOr<void> _markNotification_Read(
      MarkNotificationAsReadEvent event, Emitter<NotificationState> emit) {}
}
