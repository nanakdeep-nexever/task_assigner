import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assign_app/Blocs/AdminBloc/admin_state.dart';

import '../../Blocs/AUTHentication/authentication_bloc.dart';
import '../../Blocs/AUTHentication/authentication_event.dart';
import '../../Blocs/AUTHentication/authentication_state.dart';
import '../../Blocs/AdminBloc/admin_bloc.dart';
import '../../Blocs/AdminBloc/admin_event.dart';
import '../ProjectManagement_page.dart';
import '../Taskmanagement.dart';
import 'active_user_screens.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  AdminPageState createState() => AdminPageState();
}

class AdminPageState extends State<AdminPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminPageBloc>().add(LoadAdminDataEvent());
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
        return BlocBuilder<AdminPageBloc, Admin_Page_State>(
          builder: (context, adminState) {
            if (adminState is AdminPageLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (adminState is AdminPageError) {
              return Scaffold(
                body: Center(child: Text('Error: ${adminState.message}')),
              );
            }

            if (adminState is AdminPageLoaded) {
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
                        arguments: {'heading': "Admin Profile"},
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
                        const SizedBox(height: 10),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
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
                                adminState.activeUsersStream,
                                adminState.activeTasksStream,
                                adminState.activeProjectsStream,
                              ];

                              final screens = [
                                ActiveUsersScreen(),
                                ActiveTasksScreen(),
                                ActiveProjectsScreen(),
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
                                      padding: const EdgeInsets.all(14.0),
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
                                          StreamBuilder<QuerySnapshot>(
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

                                              final count =
                                                  snapshot.data?.docs.length ??
                                                      0;
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
                                    builder: (context) => ActiveUsersScreen(),
                                  ),
                                );
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
                          child: ListView.builder(
                            itemCount: adminState.users.take(2).length,
                            itemBuilder: (context, index) {
                              final users = adminState.users.elementAt(index);

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
                                        Colors.blue.withOpacity(0.3),
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
                                      "User- ${users['email'] ?? 'No Name'}",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                      "Role- ${users["role"] ?? ""}",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400),
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
                              "Active Task",
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
                                    builder: (context) => ActiveTasksScreen(),
                                  ),
                                );
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
                          child: ListView.builder(
                            itemCount: adminState.users.take(2).length,
                            itemBuilder: (context, index) {
                              final task = adminState.tasks.elementAt(index);

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
                                      "User- ${task['name'] ?? 'No Name'}",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                      "Assigned- ${task["assignedTo"] ?? ""}",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
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
                                    builder: (context) =>
                                        ActiveProjectsScreen(),
                                  ),
                                );
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
                          child: ListView.builder(
                            itemCount: adminState.projects.take(2).length,
                            itemBuilder: (context, index) {
                              final project =
                                  adminState.projects.elementAt(index);

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
                                      "Project- ${project['name'] ?? 'No Name'}",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                      "Description- ${project["description"] ?? "no description"}",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return const Scaffold(
              body: Center(child: Text('Unknown state')),
            );
          },
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
