import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_assign_app/Screens/Views/check_role.dart';

class RoleCubit extends Cubit<RoleState> {
  final UserRoleManager _userRoleManager = UserRoleManager();

  RoleCubit() : super(const RoleState(null)) {
    _userRoleManager.init();
    _userRoleManager.roleStream.listen((role) {
      emit(RoleState(role));
    });
  }

  // @override
  // Future<void> close() {
  //   _userRoleManager.dispose();
  //   return super.close();
  // }
}

class RoleState extends Equatable {
  final String? role;

  const RoleState(this.role);

  @override
  List<Object?> get props => [role];
}
