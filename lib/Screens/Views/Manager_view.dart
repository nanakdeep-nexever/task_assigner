import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_bloc.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_event.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_state.dart';
import 'package:task_assign_app/Screens/Views/check_role.dart';

class ManagerPage extends StatefulWidget {
  const ManagerPage({super.key});

  @override
  State<ManagerPage> createState() =>
      _ManagerPageState(UserRoleManager().init());
}

class _ManagerPageState extends State<ManagerPage> {
  _ManagerPageState(void init);
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _setOnlineStatus(bool status) async {
    try {
      await _firestore
          .collection('users')
          .doc(_firebaseAuth.currentUser?.uid)
          .update({
        'status_online': status,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  void dispose() {
    _setOnlineStatus(false);
    super.dispose();
  }

  @override
  void initState() {
    _setOnlineStatus(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is RoleChanged) {
          if (state.role == 'developer') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("You're Devloper now"),
                  duration: Duration(milliseconds: 100)),
            );
            Navigator.pushReplacementNamed(context, '/developer');
          } else if (state.role == 'viewer') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("You're viewer now"),
                duration: Duration(milliseconds: 100),
              ),
            );
            Navigator.pushReplacementNamed(context, '/viewer');
          }
        }
      },
      builder: (context, state) {
        return StreamBuilder(
            stream: UserRoleManager().roleStream,
            builder: (context, snapshot) {
              if (snapshot.data.toString() == 'manager') {
                print(snapshot.data.toString());
                return Scaffold(
                  appBar: AppBar(
                    title: Text(snapshot.data.toString()),
                    actions: [
                      IconButton(
                        onPressed: () {
                          context.read<AuthenticationBloc>().add(LogoutEvent());
                        },
                        icon: const Icon(Icons.logout),
                      ),
                    ],
                  ),
                  body: const Center(
                    child: Text("manager"),
                  ),
                );
              } else {
                print(snapshot.data.toString());
                context
                    .read<AuthenticationBloc>()
                    .add(AuthenticationRoleChanged(snapshot.data.toString()));
                return const Text("data of manager");
              }
            });
      },
    );
  }
}
