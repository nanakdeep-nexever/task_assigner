import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Blocs/AUTHentication/authentication_bloc.dart';
import '../../Blocs/AUTHentication/authentication_event.dart';
import '../../Blocs/AUTHentication/authentication_state.dart';
import '../../commons/function.dart';
import '../ProjectManagement_page.dart';
import '../Taskmanagement.dart';
import 'active_user_screens.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  AdminPageState createState() => AdminPageState();
}

class AdminPageState extends State<AdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  late Stream<QuerySnapshot> _usersStream;
  late Stream<QuerySnapshot> _usersTaskStream;
  late Stream<QuerySnapshot> _usersProjectStream;
  late Stream<int> _activeUsersStream;
  late Stream<int> _activeTasksStream;
  late Stream<int> _activeProjectsStream;

  @override
  void initState() {
    super.initState();
    _firestore.collection('users').doc(_firebaseAuth.currentUser?.uid).update({
      'status_online': true,
    });
    _usersStream = _firestore.collection('users').snapshots();
    _usersTaskStream = _firestore.collection('tasks').snapshots();
    _usersProjectStream = _firestore.collection('projects').snapshots();
    _activeUsersStream = _getActiveUsersStream();
    _activeTasksStream = _getActiveTasksStream();
    _activeProjectsStream = _getActiveProjectsStream();
  }

  @override
  void dispose() {
    _firestore.collection('users').doc(_firebaseAuth.currentUser?.uid).update({
      'status_online': false,
    });
    super.dispose();
  }

  Stream<int> _getActiveUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      print("Active users count: ${snapshot.docs.length}"); // Debug print
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

  void _updateUserRole(String uid, String newRole) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': newRole,
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error updating role: $e')));
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
            leading: IconButton(
              icon: Image.asset(
                "assets/images/user.png",
                height: 30,
                width: 30,
              ),
              onPressed: () {
                pushNamed(
                  context,
                  "/profile",
                  {
                    'heading': "Admin Profile",
                  },
                );
              },
            ),
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text(
              'Admin Dashboard',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  showLogoutDialog();
                },
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Admin",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 18),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.3, // Adjust height as needed
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
                          ActiveUsersScreen(),
                          ActiveTasksScreen(),
                          ActiveProjectsScreen(),
                        ];

                        /*  final screens = [
                          const ActiveUserPage(),
                          const ActiveTasksPage(),
                          const ActiveProjectsPage()
                        ];
*/
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
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Active Users",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontSize: 18),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ActiveUsersScreen()));
                        },
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ActiveUsersScreen()));
                          },
                          child: const Text(
                            "See all",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 4.4,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _usersStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        final users = snapshot.data?.docs ?? [];

                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: users.take(2).length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            final uid = user.id;
                            final role = user['role'] ?? 'viewer';

                            return Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.withOpacity(0.1),
                                        Colors.white
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      child: Text("${index + 1}"),
                                    ),
                                    title: Text(
                                      "Email: ${user['email'] ?? 'No Email'}",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                      ' Role: $role',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ));
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Active Tasks",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontSize: 18),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ActiveTasksScreen()));
                        },
                        child: const Text(
                          "See all",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 4,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _usersTaskStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        final users = snapshot.data?.docs ?? [];

                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: users.take(2).length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            final uid = user.id;

                            return Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.green.withOpacity(0.1),
                                        Colors.white
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.green,
                                      child: Text("${index + 1}"),
                                    ),
                                    title: Text(
                                      "Task- ${user['name'] ?? 'No Name'}",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                      "Assigned to- ${user["assignedTo"] ?? "nothing asssign"}",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ));
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Active Projects",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontSize: 18),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ActiveProjectsScreen(
                                      activeProjectsStream:
                                          _activeProjectsStream)));
                        },
                        child: const Text(
                          "See all",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 4,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _usersProjectStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        final users = snapshot.data?.docs ?? [];

                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: users.take(2).length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            final uid = user.id;

                            return Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.orange.withOpacity(0.1),
                                        Colors.white
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.orange,
                                      child: Text("${index + 1}"),
                                    ),
                                    title: Text(
                                      "Project- ${user['name'] ?? 'No Name'}",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                      "Description- ${user["description"] ?? "no description"}",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ));
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade50,
        elevation: 10,
        title: const Center(
            child: Text('Confirm Logout',
                style: TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.black))),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel',
                style: TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthenticationBloc>().add(LogoutEvent());
            },
            child: const Text('Logout',
                style: TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
