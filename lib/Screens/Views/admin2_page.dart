/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Blocs/AUTHentication/authentication_bloc.dart';
import '../../Blocs/AUTHentication/authentication_event.dart';
import '../../Blocs/AdminBloc/admin_bloc.dart';
import 'active_project_screen.dart';
import 'active_task_screen.dart';
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
    context.read<AdminBloc>().add(FetchUserData());
    context.read<AdminBloc>().add(FetchActiveUsers());
    context.read<AdminBloc>().add(FetchActiveTasks());
    context.read<AdminBloc>().add(FetchActiveProjects());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminBloc, AdminState>(
      listener: (context, state) {
        if (state is AdminError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
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
          body: Padding(
            padding: const EdgeInsets.all(12),
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
                      final colors = [Colors.blue, Colors.green, Colors.orange];

                      final streams = [
                        context.watch<AdminBloc>().state
                                is AdminActiveUsersLoaded
                            ? (context.watch<AdminBloc>().state
                                    as AdminActiveUsersLoaded)
                                .activeUsersStream
                            : null,
                        context.watch<AdminBloc>().state
                                is AdminActiveTasksLoaded
                            ? (context.watch<AdminBloc>().state
                                    as AdminActiveTasksLoaded)
                                .activeTasksStream
                            : null,
                        context.watch<AdminBloc>().state
                                is AdminActiveProjectsLoaded
                            ? (context.watch<AdminBloc>().state
                                    as AdminActiveProjectsLoaded)
                                .activeProjectsStream
                            : null,
                      ];

                      final screens = [
                        ActiveUsersScreen(activeUsersStream: streams[0]!),
                        ActiveTasksScreen(activeTasksStream: streams[1]!),
                        ActiveProjectsScreen(activeProjectsStream: streams[2]!),
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
                              padding: const EdgeInsets.all(16.0),
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
                                            child: CircularProgressIndicator());
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
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  flex: 1,
                  child: BlocBuilder<AdminBloc, AdminState>(
                    builder: (context, state) {
                      if (state is AdminLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is AdminError) {
                        return Center(child: Text('Error: ${state.message}'));
                      }

                      if (state is AdminUserDataLoaded) {
                        final users = state.userStream;

                        return StreamBuilder<QuerySnapshot>(
                          stream: users,
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

                            final userDocs = snapshot.data?.docs ?? [];

                            return ListView.builder(
                              itemCount: userDocs.length,
                              itemBuilder: (context, index) {
                                final user = userDocs[index];
                                final uid = user.id;
                                final role = user['role'] ?? 'viewer';

                                return ListTile(
                                  title: Text(user['email'] ?? 'No Email'),
                                  subtitle: Text('Current role: $role'),
                                  trailing: user['role'] != 'admin'
                                      ? DropdownButton<String>(
                                          value: role,
                                          items: <String>[
                                            'manager',
                                            'developer',
                                            'viewer'
                                          ].map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            if (newValue != null &&
                                                newValue != user['role']) {
                                              context.read<AdminBloc>().add(
                                                    UpdateUserRole(
                                                        uid, newValue),
                                                  );
                                            }
                                          },
                                        )
                                      : Text(
                                          "${user['role']}",
                                          style: TextStyle(fontSize: 15),
                                        ),
                                );
                              },a
                            );
                          },
                        );
                      }

                      return Center(child: Text('No data available.'));
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
*/
