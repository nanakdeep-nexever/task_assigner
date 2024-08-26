import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assign_app/Blocs/AdminBloc/admin_state.dart';

import '../../Blocs/AUTHentication/authentication_bloc.dart';
import '../../Blocs/AUTHentication/authentication_event.dart';
import '../../Blocs/AUTHentication/authentication_state.dart';
import '../../Blocs/AdminBloc/admin_bloc.dart';
import '../../Blocs/AdminBloc/admin_event.dart';
import '../../generated/Strings_s.dart';
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
              return _buildLoadingScreen();
            }
            if (adminState is AdminPageError) {
              return _buildErrorScreen(adminState.message);
            }
            if (adminState is AdminPageLoaded) {
              return _buildLoadedScreen(adminState);
            }
            return _buildUnknownStateScreen();
          },
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      body: Center(child: Text('Error: $message')),
    );
  }

  Widget _buildLoadedScreen(AdminPageLoaded adminState) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset("assets/images/user.png", height: 30, width: 30),
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
          Com_string.Admin_Dashboard,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: showLogoutDialog,
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
              _buildSectionTitle(Com_string.Admin),
              const SizedBox(height: 10),
              _buildGridSection(adminState),
              const SizedBox(height: 10),
              _buildListSection(Com_string.Active_Users, adminState.users,
                  Colors.blue, Com_string.email, Com_string.role),
              const SizedBox(height: 10),
              _buildListSection(Com_string.Active_Tasks, adminState.tasks,
                  Colors.green, Com_string.name, Com_string.assignedTo),
              const SizedBox(height: 10),
              _buildListSection(Com_string.Active_Projects, adminState.projects,
                  Colors.orange, Com_string.name, Com_string.description),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnknownStateScreen() {
    return Scaffold(
      body: Center(child: Text('Unknown state')),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontWeight: FontWeight.w500, color: Colors.black, fontSize: 18),
    );
  }

  Widget _buildGridSection(AdminPageLoaded adminState) {
    final titles = [
      Com_string.Active_Users,
      Com_string.Active_Tasks,
      Com_string.Active_Projects
    ];
    final colors = [Colors.blue, Colors.green, Colors.orange];
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

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemBuilder: (context, index) {
          return _buildGridItem(
              titles[index], colors[index], streams[index], screens[index]);
        },
        itemCount: titles.length,
      ),
    );
  }

  Widget _buildGridItem(
      String title, Color color, Stream<QuerySnapshot> stream, Widget screen) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => screen,
          ),
        );
      },
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        color: color,
        elevation: 4,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final count = snapshot.data?.docs.length ?? 0;
                    return Text(
                      '$count',
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListSection(
      String title,
      List<QueryDocumentSnapshot<Object?>> items,
      Color color,
      String titleKey,
      String subtitleKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(title),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      if (title == Com_string.Active_Users) {
                        return ActiveUsersScreen();
                      } else if (title == Com_string.Active_Tasks) {
                        return ActiveTasksScreen();
                      } else {
                        return ActiveProjectsScreen();
                      }
                    },
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
            itemCount: items.take(2).length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.1), Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color,
                      child: Text("${index + 1}"),
                    ),
                    title: Text(
                      "${titleKey == Com_string.email ? 'User-' : title == Com_string.Active_Users ? 'Task-' : 'Project-'} ${item[titleKey] ?? 'No Name'}",
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      "${subtitleKey == Com_string.assignedTo ? 'Assigned-' : subtitleKey == Com_string.description ? 'Description-' : 'Role-'} ${item[subtitleKey] ?? ""}",
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
    );
  }

  void showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade50,
        elevation: 10,
        title: const Center(
          child: Text(Com_string.Confirm_Logout,
              style:
                  TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
        ),
        content: const Text(
          Com_string.Confirm_Logout_message,
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(Com_string.Cancel,
                style: TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthenticationBloc>().add(LogoutEvent());
            },
            child: const Text(Com_string.Logout,
                style: TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
