import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_bloc.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_state.dart';
import 'package:task_assign_app/Notification_Handle/Notification_Handle.dart';

class RoleManage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<RoleManage> with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  late Stream<QuerySnapshot> _usersStream;

  @override
  void initState() {
    super.initState();
    _usersStream = _firestore.collection('users').snapshots();
  }

  Future<void> _updateUserRole(String uid, String newRole) async {
    try {
      String Fcm;
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'role': newRole}).then(
        (value) async {
          final snapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();
          if (snapshot.exists) {
            Fcm = snapshot.get('FCM-token');
            print("here is Fcm : $Fcm  ");
            NotificationHandler.sendNotification(
                FCM_token: Fcm,
                title: "Role Changed by Admin",
                body: "YouR Role is Now $newRole");
          }
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Role updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error updating role: $e'); // For debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating role: ${e.toString()}'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationUnauthenticated) {
          Navigator.pushReplacementNamed(context, '/');
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: _usersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No users available.'));
                }

                final users = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final uid = user.id;
                    final role = user['role'] ?? 'viewer';

                    return UserTile(
                      email: user['email'] ?? 'No Email',
                      currentRole: role,
                      isAdmin: user['role'] == 'admin',
                      onRoleChanged: (newRole) {
                        if (newRole != user['role']) {
                          _updateUserRole(uid, newRole);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class UserTile extends StatelessWidget {
  final String email;
  final String currentRole;
  final bool isAdmin;
  final ValueChanged<String> onRoleChanged;

  UserTile({
    required this.email,
    required this.currentRole,
    required this.isAdmin,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Define the list of roles.
    final roles = <String>['manager', 'developer', 'viewer'];

    // Debug print statements to check values.
    print('Current role: $currentRole');
    print('Roles list: $roles');

    return ListTile(
      title: Text(email),
      subtitle: Text('Current role: $currentRole'),
      trailing: isAdmin
          ? Text(currentRole, style: TextStyle(fontSize: 15))
          : DropdownButton<String>(
              value: roles.contains(currentRole) ? currentRole : null,
              items: roles.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onRoleChanged(newValue);
                }
              },
            ),
    );
  }
}
