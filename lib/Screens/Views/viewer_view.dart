import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_bloc.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_event.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_state.dart';
import 'package:task_assign_app/Screens/Views/check_role.dart';

class ViewerPage extends StatefulWidget {
  @override
  State<ViewerPage> createState() => _ViewerPageState(UserRoleManager().init());
}

class _ViewerPageState extends State<ViewerPage> {
  FirebaseFirestore _firestoretore = FirebaseFirestore.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  _ViewerPageState(void init);
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

  void dispose() {
    _setOnlineStatus(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? email = ModalRoute.of(context)?.settings.arguments.toString();

    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is Rolechanged) {
          if (state.role == 'developer') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("You're Devloper now"),
              ),
            );
            Navigator.pushReplacementNamed(context, '/developer');
          }
          if (state.role == 'manager') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("You're manager now"),
              ),
            );
            Navigator.pushReplacementNamed(context, '/manager');
          }
        }
      },
      builder: (context, state) {
        return StreamBuilder(
            stream: UserRoleManager().roleStream,
            builder: (context, snapshot) {
              if (snapshot.data.toString() == 'viewer') {
                return Scaffold(
                  appBar: AppBar(
                    title: Text("${snapshot.data.toString()}"),
                    actions: [
                      IconButton(
                        onPressed: () {
                          context.read<AuthenticationBloc>().add(LogoutEvent());
                        },
                        icon: Icon(Icons.logout),
                      ),
                    ],
                  ),
                  body: Center(
                    child: Text("viewer"),
                  ),
                );
              } else {
                print(snapshot.data.toString());
                context
                    .read<AuthenticationBloc>()
                    .add(AuthenticationRoleChanged(snapshot.data.toString()));
                return Text("viewer");
              }
            });
      },
    );
  }
}
