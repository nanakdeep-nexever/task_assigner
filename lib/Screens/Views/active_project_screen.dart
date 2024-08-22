import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'check_role.dart';

class ActiveProjectsScreen extends StatelessWidget {
  final Stream<int> activeProjectsStream;

  const ActiveProjectsScreen({super.key, required this.activeProjectsStream});

  @override
  Widget build(BuildContext context) {
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
                                fontWeight: FontWeight.w500,
                                color: Colors.black)),
                        Text(
                            projectData['deadline'] != null
                                ? 'Deadline: ${projectData['deadline'].toDate()}'
                                : 'No Deadline',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black)),
                        Text(
                            projectData["description"] != null
                                ? 'Description: ${projectData['description']}'
                                : 'No description',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black)),
                      ],
                    ),
                    trailing: isViewer()
                        ? null
                        : PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editProject(context, project.id);
                              } else if (value == 'delete') {
                                _deleteProject(context, project.id);
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
            },
          );
        },
      ),
      floatingActionButton: isAdmin() || isManager()
          ? FloatingActionButton(
              backgroundColor: Colors.orange,
              onPressed: () => _addProject(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _addProject(BuildContext context) {
    final nameController = TextEditingController();
    final statusController = TextEditingController();
    final desController = TextEditingController();
    DateTime? selectedDeadline;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.orange.shade50,
            elevation: 10,
            title: const Center(
                child: Text(
              'Add New Project',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            )),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Project Name'),
                  ),
                  TextField(
                    controller: statusController,
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                  TextField(
                    controller: desController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    title: Text(
                      selectedDeadline != null
                          ? 'Deadline: ${selectedDeadline!.toLocal()}'
                          : 'No Deadline Selected',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDeadline ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDeadline = pickedDate;
                        });
                      }
                    },
                  ),
                ],
              ),
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
                  // Add the new project to Firestore
                  FirebaseFirestore.instance.collection('projects').add({
                    'name': nameController.text,
                    'status': statusController.text,
                    'description': desController.text,
                    'deadline': selectedDeadline,
                  });

                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('New project added successfully')),
                  );
                },
                child: const Text(
                  'Save',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontSize: 18),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool isViewer() {
    String role = UserRoleManager().currentRole.toString();
    return role == 'viewer';
  }

  bool isManager() {
    String role = UserRoleManager().currentRole.toString();
    return role == 'manager';
  }

  bool isAdmin() {
    UserRoleManager().init();
    String role = UserRoleManager().currentRole.toString();
    return role == 'admin';
  }

  bool isDevloper() {
    String role = UserRoleManager().currentRole.toString();
    return role == 'developer';
  }

  void _editProject(BuildContext context, String projectId) {
    FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .get()
        .then((doc) {
      final projectData = doc.data() as Map<String, dynamic>;

      final nameController = TextEditingController(text: projectData['name']);
      final statusController =
          TextEditingController(text: projectData['status']);
      final desController =
          TextEditingController(text: projectData['description']);
      DateTime? selectedDeadline = projectData['deadline']?.toDate();

      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.orange.shade50,
              elevation: 10,
              title: const Center(
                  child: Text(
                'Edit Project',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 18),
              )),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: 'Project Name'),
                    ),
                    TextField(
                      controller: statusController,
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                    TextField(
                      controller: desController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      title: Text(
                        selectedDeadline != null
                            ? 'Deadline: ${selectedDeadline!.toLocal()}'
                            : 'No Deadline Selected',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDeadline ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDeadline = pickedDate;
                          });
                        }
                      },
                    ),
                  ],
                ),
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
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.orange.shade50,
                        elevation: 10,
                        title: const Center(
                            child: Text(
                          'Confirm Edit',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: 18),
                        )),
                        content: const Text(
                          'Are you sure you want to save the changes?',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: 16),
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
                                  .update({
                                'name': nameController.text,
                                'status': statusController.text,
                                'description': desController.text,
                                'deadline': selectedDeadline,
                              });

                              Navigator.of(context)
                                  .pop(); // Close the confirmation dialog
                              Navigator.of(context)
                                  .pop(); // Close the edit dialog

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Project updated successfully')),
                              );
                            },
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    'Next',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 18),
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
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
}
