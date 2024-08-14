import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_bloc.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_event.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_state.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  late Stream<QuerySnapshot> _usersStream;

  @override
  void initState() {
    super.initState();
    _setOnlineStatus(true);
    _usersStream = _firestore.collection('users').snapshots();
  }

  @override
  void dispose() {
    _setOnlineStatus(false);
    super.dispose();
  }

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

  void _updateUserRole(String uid, String newRole) async {
    try {
      await _firestore.collection('users').doc(uid).update({'role': newRole});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Role updated successfully'),
            duration: Duration(seconds: 2)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error updating role: $e'),
            duration: Duration(seconds: 2)),
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
          appBar: AppBar(
            title: Text('Admin Dashboard'),
            actions: [
              IconButton(
                onPressed: () {
                  context.read<AuthenticationBloc>().add(LogoutEvent());
                },
                icon: Icon(Icons.logout),
              ),
            ],
          ),
          body: StreamBuilder<QuerySnapshot>(
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
                        print(
                            "${user.id} ne role ${newRole} old-Role ${user['role']}");
                        _updateUserRole(uid, newRole);
                      }
                    },
                  );
                },
              );
            },
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
    return ListTile(
      title: Text(email),
      subtitle: Text('Current role: $currentRole'),
      trailing: isAdmin
          ? Text(currentRole, style: TextStyle(fontSize: 15))
          : DropdownButton<String>(
              value: currentRole,
              items: <String>['manager', 'developer', 'viewer']
                  .map((String value) {
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
