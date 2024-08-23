import 'package:bloc/bloc.dart';
import 'package:task_assign_app/Screens/Views/check_role.dart';

import 'Rolestate.dart';

class RoleCubit extends Cubit<RoleState> {
  final UserRoleManager _userRoleManager = UserRoleManager();

  RoleCubit() : super(RoleInitial()) {
    _userRoleManager.init();
    _userRoleManager.roleStream.listen((role) {
      emit(RoleLoaded(role));
    });
  }

  bool isViewer() {
    final roleState = state;
    if (roleState is RoleLoaded) {
      return _userRoleManager.isViewer();
    }
    return false;
  }

  bool isManager() {
    final roleState = state;
    if (roleState is RoleLoaded) {
      return _userRoleManager.isManager();
    }
    return false;
  }

  bool isAdmin() {
    final roleState = state;
    if (roleState is RoleLoaded) {
      return _userRoleManager.isAdmin();
    }
    return false;
  }

  @override
  Future<void> close() {
    _userRoleManager.dispose();
    return super.close();
  }
}
