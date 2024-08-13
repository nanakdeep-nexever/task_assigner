import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:task_assign_app/Blocs/Management_bloc/management_state.dart';

import 'management_event.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<LoadUsersEvent>(_loaduser);
    on<CreateUserEvent>(_CreateuserEvent);
    on<UpdateUserEvent>(_UpdateuserEvent);
    on<DeleteUserEvent>(_DeleteuserEvent);
  }

  FutureOr<void> _loaduser(LoadUsersEvent event, Emitter<UserState> emit) {}

  FutureOr<void> _CreateuserEvent(
      CreateUserEvent event, Emitter<UserState> emit) {}

  FutureOr<void> _UpdateuserEvent(
      UpdateUserEvent event, Emitter<UserState> emit) {}

  FutureOr<void> _DeleteuserEvent(
      DeleteUserEvent event, Emitter<UserState> emit) {}
}
