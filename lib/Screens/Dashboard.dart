import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_bloc.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_event.dart';
import 'package:task_assign_app/Blocs/check_user_cubit.dart';
import 'package:task_assign_app/Blocs/check_user_state.dart';
import 'package:task_assign_app/Screens/Views/Admin.dart';
import 'package:task_assign_app/Screens/Views/Devloper_view.dart';
import 'package:task_assign_app/Screens/Views/Manager_view.dart';
import 'package:task_assign_app/Screens/Views/viewer_view.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    String? uid = ModalRoute.of(context)?.settings.arguments.toString();
    return Scaffold(
      appBar: AppBar(
        title: Text("DashBoArd "),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthenticationBloc>().add(LogoutEvent());
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocConsumer<UserRoleCubit, UserRoleState>(
          listener: (BuildContext context, state) {
        if (state is UserRoleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      }, builder: (BuildContext context, state) {
        if (state is UserRoleLoaded) {
          if (state.role == 'manager') {
            return ManagerPage();
          } else if (state.role == 'admin') {
            return const AdminPage();
          } else if (state.role == 'developer') {
            return DeveloperPage();
          } else {
            return ViewerPage();
          }
        } else {
          return const Scaffold(
            body: Center(
              child: Text("State Unloaded"),
            ),
          );
        }
      }),
    );
  }
}
