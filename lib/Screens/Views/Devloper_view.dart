import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_bloc.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_event.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_state.dart';
import 'package:task_assign_app/Screens/Views/check_role.dart';

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({super.key});

  @override
  State<DeveloperPage> createState() =>
      _DeveloperPageState(UserRoleManager().init());
}

class _DeveloperPageState extends State<DeveloperPage> {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _firestoretore = FirebaseFirestore.instance;
  _DeveloperPageState(void init);

  void _setOnlineStatus(bool status) async {
    try {
      await _firestoretore
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
  void initState() {
    super.initState();
    _setOnlineStatus(true);
    _firestoretore
        .collection('unassigned_users')
        .doc(_firebaseAuth.currentUser?.email.toString())
        .set({'uid': _firebaseAuth.currentUser?.uid.toString()});
  }

  @override
  void dispose() {
    _setOnlineStatus(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is Rolechanged) {
          if (state.role == 'manager') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("You're manager now"),
                  duration: Duration(milliseconds: 100)),
            );
            Navigator.pushReplacementNamed(context, '/manager');
          } else if (state.role == 'viewer') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("You're viewer now"),
                  duration: Duration(milliseconds: 100)),
            );
            Navigator.pushReplacementNamed(context, '/viewer');
          }
        }
      },
      builder: (context, state) {
        return StreamBuilder(
            stream: UserRoleManager().roleStream,
            builder: (context, snapshot) {
              if (snapshot.data.toString() == 'developer') {
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
                    child: Text("developer"),
                  ),
                );
              } else {
                print(snapshot.data.toString());
                context
                    .read<AuthenticationBloc>()
                    .add(AuthenticationRoleChanged(snapshot.data.toString()));
                return const Text("data of develper");
              }
            });
      },
    );
  }
}
