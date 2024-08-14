import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_state.dart';
import 'package:task_assign_app/Blocs/check_user_cubit.dart';
import 'package:task_assign_app/Blocs/check_user_state.dart';
import 'package:task_assign_app/Screens/Views/check_role.dart';

class DeveloperPage extends StatefulWidget {
  @override
  State<DeveloperPage> createState() =>
      _DeveloperPageState(UserRoleManager().init());
}

class _DeveloperPageState extends State<DeveloperPage> {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _firestoretore = FirebaseFirestore.instance;
  _DeveloperPageState(void init);

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
    return BlocConsumer<UserRoleCubit, UserRoleState>(
      listener: (context, state) {
        if (state is UserRoleLoaded) {
          if (state.role == 'manager') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("You're manager now"),
                  duration: Duration(milliseconds: 10)),
            );
            Navigator.pushReplacementNamed(context, '/manager');
          } else if (state.role == 'viewer') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("You're viewer now"),
                  duration: Duration(milliseconds: 10)),
            );
            Navigator.pushReplacementNamed(context, '/viewer');
          }
        } else if (state is AuthenticationUnauthenticated) {
          Navigator.pushReplacementNamed(context, '/');
        }
      },
      builder: (context, state) {
        if (state is UserRoleLoaded) {
          if (state.role == 'developer') {
            return Scaffold(
              body: Center(
                child: Text("developer"),
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
      },
    );
  }
}
