import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assign_app/Blocs/Rolecube.dart';
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
    return Scaffold(
      body: BlocConsumer<RoleCubit, RoleState>(
        listener: (context, state) {
          UserRoleManager().init();
        },
        builder: (context, state) {
          if (state.role == 'admin') {
            return const AdminPage();
          } else if (state.role == 'manager') {
            return const ManagerPage();
          } else if (state.role == 'developer') {
            return const DeveloperPage();
          } else {
            return const ViewerPage();
          }
        },
      ),
    );
  }
}
