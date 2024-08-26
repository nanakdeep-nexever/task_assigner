import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_assign_app/commons/Common_Functions.dart';

import '../../Blocs/AUTHentication/authentication_bloc.dart';
import '../../Blocs/AUTHentication/authentication_event.dart';
import '../../Blocs/AUTHentication/authentication_state.dart';
import '../../Blocs/Management_bloc/management_bloc.dart';
import '../../Blocs/Management_bloc/management_event.dart';
import '../../Blocs/Management_bloc/management_state.dart';
import '../ProjectManagement_page.dart';
import '../Taskmanagement.dart';

class ManagerPage extends StatefulWidget {
  const ManagerPage({super.key});

  @override
  ManagerPageState createState() => ManagerPageState();
}

class ManagerPageState extends State<ManagerPage> {
  late ManagerPageBloc _managerPageBloc;

  @override
  void initState() {
    super.initState();
    _managerPageBloc = ManagerPageBloc(FirebaseFirestore.instance);
    _managerPageBloc.add(LoadActiveUsers());
    _managerPageBloc.add(LoadActiveTasks());
    _managerPageBloc.add(LoadActiveProjects());
    _managerPageBloc.add(LoadUserTasks());
    _managerPageBloc.add(LoadUserProjects());
  }

  @override
  void dispose() {
    _managerPageBloc.close();
    super.dispose();
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
                    'heading': "Manager Profile",
                    "uName": FirebaseAuth.instance.currentUser?.displayName ??
                        "User",
                    "email": FirebaseAuth.instance.currentUser?.email
                  },
                );
              },
            ),
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text(
              'Manager Dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
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
          body: BlocBuilder<ManagerPageBloc, ManagerState>(
            bloc: _managerPageBloc,
            builder: (context, state) {
              if (state is ManagerPageLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ManagerPageError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Something went wrong!',
                        style: const TextStyle(fontSize: 18, color: Colors.red),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Retry logic
                          _managerPageBloc.add(LoadActiveUsers());
                          _managerPageBloc.add(LoadActiveTasks());
                          _managerPageBloc.add(LoadActiveProjects());
                          _managerPageBloc.add(LoadUserTasks());
                          _managerPageBloc.add(LoadUserProjects());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is ManagerPageLoaded) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Manager",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DashboardGrid(
                          titles: ['Active Tasks', 'Active Projects'],
                          counts: [state.activeTasks, state.activeProjects],
                          screens: [
                            ActiveTasksScreen(),
                            ActiveProjectsScreen()
                          ],
                        ),
                        const SizedBox(height: 6),
                        SectionHeader(
                          title: "Active Tasks",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ActiveTasksScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        TaskList(tasks: state.userTasks),
                        const SizedBox(height: 10),
                        SectionHeader(
                          title: "Active Projects",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ActiveProjectsScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        ProjectList(projects: state.userProjects),
                      ],
                    ),
                  ),
                );
              }

              return Container();
            },
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
          child: Text(
            'Confirm Logout',
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
          ),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style:
                  TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthenticationBloc>().add(LogoutEvent());
            },
            child: const Text(
              'Logout',
              style:
                  TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // DashboardGrid Widget
  Widget DashboardGrid({
    required List<String> titles,
    required List<int> counts,
    required List<Widget> screens,
  }) {
    final colors = [Colors.green, Colors.orange];

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.15,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemBuilder: (context, index) {
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
                      Text(
                        '${counts[index]}',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        itemCount: titles.length,
      ),
    );
  }

  // SectionHeader Widget
  Widget SectionHeader({
    required String title,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        GestureDetector(
          onTap: onTap,
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
    );
  }

  // TaskList Widget
  Widget TaskList({
    required List<QueryDocumentSnapshot> tasks,
  }) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 4,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tasks.take(2).length,
        itemBuilder: (context, index) {
          final Task = tasks[index];
          final deadline = (Task['deadline'] as Timestamp).toDate();
          final isDeadlineToday = Common_function.isToday(deadline);
          final isDeadlinePassed = Common_function.isPassed(deadline);
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
                    Colors.white,
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
                  "Task- ${Task['name'] ?? 'No Name'}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Assigned To: ${Task['assignedTo'] ?? 'Unknown'}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Deadline: ${DateFormat.yMd().format(deadline)} ${isDeadlineToday ? DateFormat.Hm().format(deadline) : ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ProjectList Widget
  Widget ProjectList({
    required List<QueryDocumentSnapshot> projects,
  }) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 4,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: projects.take(2).length,
        itemBuilder: (context, index) {
          final project = projects[index];
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
                    Colors.white,
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
                  "Project- ${project['name'] ?? 'No Title'}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                subtitle: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<String?>(
                      future: Common_function.getManagerEmail(
                          project["manager_id"] ?? ''),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            snapshot.data != null
                                ? 'Manager: ${snapshot.data}'
                                : 'Unassigned Manager',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black),
                          );
                        } else {
                          return const Text('Unassigned Manager');
                        }
                      },
                    ),
                    Text(
                      "Status: ${project['status'] ?? 'Unknown'}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
