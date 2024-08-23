import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assign_app/Blocs/Rolecube.dart';
import 'package:task_assign_app/Blocs/Rolestate.dart';
import 'package:task_assign_app/Screens/Views/Admin.dart';
import 'package:task_assign_app/Screens/Views/Devloper_view.dart';
import 'package:task_assign_app/Screens/Views/Manager_view.dart';
import 'package:task_assign_app/Screens/Views/check_role.dart';
import 'package:task_assign_app/Screens/Views/viewer_view.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    UserRoleManager().init();
    return Scaffold(
      body: BlocConsumer<RoleCubit, RoleState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is RoleLoaded) {
              if (state.role == 'admin') {
                return AdminPage();
              } else if (state.role == 'manager') {
                return ManagerPage();
              } else if (state.role == 'developer') {
                return DeveloperPage();
              } else {
                return ViewerPage();
              }
            } else {
              return Text("");
            }
          }),
    );
  }
}
