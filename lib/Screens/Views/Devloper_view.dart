import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assign_app/Blocs/developer_view/develop_bloc.dart';
import 'package:task_assign_app/Blocs/developer_view/develop_state.dart';

import '../../Blocs/AUTHentication/authentication_bloc.dart';
import '../../Blocs/AUTHentication/authentication_event.dart';
import '../../Blocs/AUTHentication/authentication_state.dart';
import '../../Blocs/developer_view/develop_event.dart';
import '../../generated/Strings_s.dart';
import '../Taskmanagement.dart';

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({super.key});

  @override
  DeveloperPageState createState() => DeveloperPageState();
}

class DeveloperPageState extends State<DeveloperPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _updateUserStatus(true);
    context.read<DevelopBloc>().add(LoadTasks());
  }

  @override
  void dispose() {
    _updateUserStatus(false);
    super.dispose();
  }

  Future<void> _updateUserStatus(bool isOnline) async {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId != null) {
        await _firestore
            .collection(Com_string.Firebase_collection_users)
            .doc(userId)
            .update({
          Com_string.Status_online: isOnline,
        });
      }
    } catch (e) {
      // Handle error
      print('Error updating user status: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationUnauthenticated) {
          Navigator.pushReplacementNamed(context, '/');
        }
      },
      builder: (context, authState) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Image.asset(
                "assets/images/user.png",
                height: 30,
                width: 30,
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  "/profile",
                  arguments: {
                    'heading': "Developer Profile",
                    "uName": "Akash",
                    Com_string.email: "jddhfj@gmail.com"
                  },
                );
              },
            ),
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text(
              'Developer Dashboard',
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
          body: BlocBuilder<DevelopBloc, DevelopState>(
            builder: (context, taskState) {
              if (taskState is TaskLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (taskState is TaskError) {
                return Center(child: Text('Error: ${taskState.message}'));
              }

              if (taskState is TaskLoaded) {
                final tasks = taskState.tasks;
                final activeTasksCount = taskState.activeTasksCount;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Developer",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              color: Colors.green,
                              elevation: 4,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        Com_string.Active_Tasks,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '$activeTasksCount',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            Com_string.Active_Tasks,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ActiveTasksScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "See all",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 4,
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tasks.length > 2 ? 2 : tasks.length,
                          itemBuilder: (context, index) {
                            final user = tasks[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
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
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Assigned to- ${user[Com_string.assignedTo] ?? "nothing assigned"}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              }

              return Container(); // Default empty container
            },
          ),
        );
      },
    );
  }
}
