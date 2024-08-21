import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_bloc.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_state.dart';
import 'package:task_assign_app/Blocs/check_user_cubit.dart';
import 'package:task_assign_app/Blocs/check_user_state.dart';
import 'package:task_assign_app/Screens/ProjectManagement_page.dart';
import 'package:task_assign_app/Screens/Role_manage.dart';
import 'package:task_assign_app/Screens/Taskmanagement.dart';
// Replace with your actual tasks management screen

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  AdminPageState createState() => AdminPageState();
}

class AdminPageState extends State<AdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  late Stream<QuerySnapshot> _usersStream;
  late Stream<int> _activeUsersStream;
  late Stream<int> _activeTasksStream;
  late Stream<int> _activeProjectsStream;

  @override
  void initState() {
    super.initState();
    _usersStream = _firestore.collection('users').snapshots();
    _activeUsersStream = _getActiveUsersStream();
    _activeTasksStream = _getActiveTasksStream();
    _activeProjectsStream = _getActiveProjectsStream();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Stream<int> _getActiveUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.length;
    });
  }

  Stream<int> _getActiveTasksStream() {
    return _firestore
        .collection('tasks')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> _getActiveProjectsStream() {
    return _firestore
        .collection('projects')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> _updateUserRole(String uid, String newRole) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': newRole,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Role updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating role: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserRoleCubit, UserRoleState>(
        builder: (context, state) {
      if (state is UserRoleLoaded) {
        if (state.role == 'admin') {
          return BlocConsumer<AuthenticationBloc, AuthenticationState>(
            listener: (context, state) {
              if (state is AuthenticationUnauthenticated) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            builder: (context, state) {
              return Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemBuilder: (context, index) {
                            final titles = [
                              'Active Users',
                              'Active Tasks',
                              'Active Projects'
                            ];
                            final colors = [
                              Colors.blue,
                              Colors.green,
                              Colors.orange
                            ];

                            final streams = [
                              _activeUsersStream,
                              _activeTasksStream,
                              _activeProjectsStream,
                            ];

                            final screens = [
                              RoleManage(), // Ensure this screen is implemented
                              ActiveTasksScreen(), // Replace with your actual tasks management screen
                              ProjectManagementPage(), // Ensure this screen is implemented
                            ];

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => screens[index],
                                  ),
                                );
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                color: colors[index],
                                elevation: 4,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          titles[index],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        StreamBuilder<int>(
                                          stream: streams[index],
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }

                                            if (snapshot.hasError) {
                                              return Center(
                                                  child: Text(
                                                      'Error: ${snapshot.error}'));
                                            }

                                            final count = snapshot.data ?? 0;
                                            return Text(
                                              '$count',
                                              style: const TextStyle(
                                                fontSize: 24,
                                                color: Colors.white,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: 3,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Expanded(
                      //   child: StreamBuilder<QuerySnapshot>(
                      //     stream: _usersStream,
                      //     builder: (context, snapshot) {
                      //       if (snapshot.connectionState == ConnectionState.waiting) {
                      //         return const Center(child: CircularProgressIndicator());
                      //       }
                      //
                      //       if (snapshot.hasError) {
                      //         return Center(child: Text('Error: ${snapshot.error}'));
                      //       }
                      //
                      //       final users = snapshot.data?.docs ?? [];
                      //
                      //       return ListView.builder(
                      //         itemCount: users.length,
                      //         itemBuilder: (context, index) {
                      //           final user = users[index];
                      //           final uid = user.id;
                      //           final role = user['role'] ?? 'viewer';
                      //
                      //           return ListTile(
                      //             title: Text(user['email'] ?? 'No Email'),
                      //             subtitle: Text('Current role: $role'),
                      //             trailing: role != 'admin'
                      //                 ? DropdownButton<String>(
                      //                     value: role,
                      //                     items: <String>[
                      //                       'manager',
                      //                       'developer',
                      //                       'viewer'
                      //                     ].map((String value) {
                      //                       return DropdownMenuItem<String>(
                      //                         value: value,
                      //                         child: Text(value),
                      //                       );
                      //                     }).toList(),
                      //                     onChanged: (String? newValue) {
                      //                       if (newValue != null &&
                      //                           newValue != role) {
                      //                         _updateUserRole(uid, newValue);
                      //                       }
                      //                     },
                      //                   )
                      //                 : Text(
                      //                     role,
                      //                     style: const TextStyle(fontSize: 15),
                      //                   ),
                      //           );
                      //         },
                      //       );
                      //     },
                      //   ),
                      // ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return Text("");
        }
      } else {
        return CircularProgressIndicator();
      }
    }, listener: (context, state) {
      if (state is UserRoleLoaded) {
        if (state.role == 'manager') {
          Navigator.pushReplacementNamed(context, '/manager',
              arguments: state.role);
        } else if (state.role == 'developer') {
          Navigator.pushReplacementNamed(context, '/developer',
              arguments: state.role);
        } else if (state.role == 'viewer') {
          Navigator.pushReplacementNamed(context, '/viewer',
              arguments: state.role);
        }
      } else {}
    });
  }
}
