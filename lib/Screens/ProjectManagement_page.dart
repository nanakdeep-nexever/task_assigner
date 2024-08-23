import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Views/check_role.dart';
import '_save_Project.dart';

class ActiveProjectsScreen extends StatelessWidget {
  final Stream<int>? activeProjectsStream;
  ActiveProjectsScreen({super.key, this.activeProjectsStream});

  @override
  Widget build(BuildContext context) {
    UserRoleManager().init();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Active Projects',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('projects').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No active projects.'));
          }

          final projects = snapshot.data!.docs;

          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              final projectData = project.data() as Map<String, dynamic>;

              return _buildProjectCard(context, project.id, projectData, index);
              ;
            },
          );
        },
      ),
      floatingActionButton:
          UserRoleManager().isAdmin() || UserRoleManager().isManager()
              ? FloatingActionButton(
                  backgroundColor: Colors.orange,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProjectFormPage()),
                    );
                  },
                  child: const Icon(Icons.add),
                )
              : null,
    );
  }

  Widget _buildProjectCard(BuildContext context, String projectId,
      Map<String, dynamic> projectData, int index) {
    DateTime? deadline = projectData['deadline']?.toDate();
    bool isDeadlinePassed =
        deadline != null && deadline.isBefore(DateTime.now());
    bool isToday = deadline != null &&
        deadline.day == DateTime.now().day &&
        deadline.month == DateTime.now().month &&
        deadline.year == DateTime.now().year;

    String deadlineText;
    if (isToday) {
      deadlineText =
          'Deadline: ${TimeOfDay.fromDateTime(deadline).format(context)}';
    } else if (deadline != null) {
      deadlineText = 'Deadline: ${deadline.toLocal()}';
    } else {
      deadlineText = 'No Deadline';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.withOpacity(0.1), Colors.white],
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
          contentPadding: const EdgeInsets.all(8.0),
          title: Text(
            " Project: ${projectData['name'] ?? 'Unnamed Project'}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: ${projectData['status'] ?? 'Unknown'}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.black)),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      deadlineText,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                  ),
                  if (isDeadlinePassed)
                    const Icon(Icons.notifications_active, color: Colors.red)
                ],
              ),
              FutureBuilder<String?>(
                future: getManagerEmail(projectData["manager_id"] ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      snapshot.data != null
                          ? 'Manager: ${snapshot.data}'
                          : 'Unassigned Manager',
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.black),
                    );
                  } else {
                    return const Text('Unassigned Manager');
                  }
                },
              ),
              Text(
                  projectData["description"] != null
                      ? 'Description: ${projectData['description']}'
                      : 'No description',
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.black)),
            ],
          ),
          trailing: UserRoleManager().isViewer()
              ? null
              : PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProjectFormPage(
                            projectId: projectId,
                          ),
                        ),
                      );
                    } else if (value == 'delete') {
                      _deleteProject(context, projectId);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _deleteProject(BuildContext context, String projectId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.orange.shade50,
        elevation: 10,
        title: const Center(
            child: Text(
          'Confirm Delete',
          style: TextStyle(
              fontWeight: FontWeight.w600, color: Colors.black, fontSize: 18),
        )),
        content: const Text(
          'Are you sure you want to delete this project?',
          style: TextStyle(
              fontWeight: FontWeight.w500, color: Colors.black, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('projects')
                  .doc(projectId)
                  .delete();

              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Project deleted successfully')),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> getManagerEmail(String managerId) async {
    try {
      DocumentSnapshot managerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(managerId)
          .get();

      if (managerDoc.exists) {
        return managerDoc.get('email') as String?;
      } else {
        return 'No email found'; // Or handle as needed
      }
    } catch (e) {
      return 'Unassigned Manager'; // Or handle as needed
    }
  }
}
