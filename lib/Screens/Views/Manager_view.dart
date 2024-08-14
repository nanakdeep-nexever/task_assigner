import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_state.dart';
import 'package:task_assign_app/Blocs/check_user_cubit.dart';
import 'package:task_assign_app/Blocs/check_user_state.dart';

class ManagerPage extends StatelessWidget {
  const ManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserRoleCubit, UserRoleState>(
      listener: (context, state) {
        if (state is UserRoleLoaded) {
          if (state.role == 'developer') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("You're Devloper now"),
                  duration: Duration(milliseconds: 10)),
            );
            Navigator.pushReplacementNamed(context, '/developer');
          } else if (state.role == 'viewer') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("You're viewer now"),
                duration: Duration(milliseconds: 10),
              ),
            );
            Navigator.pushReplacementNamed(context, '/viewer');
          }
        } else if (state is AuthenticationUnauthenticated) {
          Navigator.pushReplacementNamed(context, '/');
        }
      },
      builder: (context, state) {
        if (state is UserRoleLoaded) {
          if (state.role == 'manager') {
            return const Scaffold(
              body: Center(
                child: Text("manager"),
              ),
            );
          } else {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        } else {
          return const Scaffold(
            body: Center(
              child: Text("data"),
            ),
          );
        }
      },
    );
  }
}
