import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assign_app/Blocs/Rolecube.dart';
import 'package:task_assign_app/Screens/Views/Admin.dart';
import 'package:task_assign_app/Screens/Views/Devloper_view.dart';
import 'package:task_assign_app/Screens/Views/Manager_view.dart';
import 'package:task_assign_app/Screens/Views/viewer_view.dart';
import 'package:task_assign_app/generated/Strings_s.dart';

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
        listener: (context, state) {},
        builder: (context, state) {
          if (state.role == 'admin') {
            return AdminPage();
          } else if (state.role == Roles.manager.toString()) {
            return const ManagerPage();
          } else if (state.role == Roles.developer.toString()) {
            return const DeveloperPage();
          } else {
            return const ViewerPage();
          }
        },
      ),
    );
  }
}
