import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_state.dart';
import 'package:task_assign_app/Blocs/check_user_cubit.dart';
import 'package:task_assign_app/Blocs/check_user_state.dart';
import 'package:task_assign_app/Screens/Views/check_role.dart';

class ViewerPage extends StatefulWidget {
  @override
  State<ViewerPage> createState() => _ViewerPageState(UserRoleManager().init());
}

class _ViewerPageState extends State<ViewerPage> {
  FirebaseFirestore _firestoretore = FirebaseFirestore.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  _ViewerPageState(void init);

  @override
  void initState() {
    super.initState();
    _firestoretore
        .collection('unassigned_users')
        .doc(_firebaseAuth.currentUser?.email.toString())
        .set({'uid': _firebaseAuth.currentUser?.uid.toString()});
  }

  @override
  Widget build(BuildContext context) {
    String? email = ModalRoute.of(context)?.settings.arguments.toString();

    return BlocConsumer<UserRoleCubit, UserRoleState>(
        listener: (context, state) {
      if (state is UserRoleLoaded) {
        if (state.role == 'developer') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("You're Devloper now"),
              duration: Duration(milliseconds: 10),
            ),
          );
          Navigator.pushReplacementNamed(context, '/developer');
        }
        if (state.role == 'manager') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("You're manager now"),
              duration: Duration(milliseconds: 10),
            ),
          );
          Navigator.pushReplacementNamed(context, '/manager');
        }
      } else if (state is AuthenticationUnauthenticated) {
        Navigator.pushReplacementNamed(context, '/');
      }
    }, builder: (context, state) {
      if (state is UserRoleLoaded) {
        if (state.role == 'viewer') {
          return Scaffold(
            body: Center(
              child: Text("Viewer"),
            ),
          );
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      } else {
        return Scaffold(
          body: Center(
            child: Text("data"),
          ),
        );
      }
    });
  }
}
