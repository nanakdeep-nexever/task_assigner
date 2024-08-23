import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_assign_app/Screens/Views/check_role.dart';

import 'Notification_Handle/Notification_Handle.dart';

class ProjectFormPage extends StatefulWidget {
  final String? projectId;

  ProjectFormPage({Key? key, this.projectId}) : super(key: key);

  @override
  _ProjectFormPageState createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final nameController = TextEditingController();
  final desController = TextEditingController();
  String? selectedStatus;
  DateTime? selectedDeadline;
  String? selectedManagerId;
  String FCmToken = '';
  List<Map<String, String>> managers = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _fetchManagers();
  }

  Future<void> _initializeData() async {
    if (widget.projectId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.projectId)
          .get();
      final projectData = doc.data() as Map<String, dynamic>;

      setState(() {
        nameController.text = projectData['name'] ?? '';
        selectedStatus = projectData['status'];
        desController.text = projectData['description'] ?? '';
        selectedDeadline = (projectData['deadline'] as Timestamp?)?.toDate();
        selectedManagerId = projectData['manager_id'];
      });
    }
  }

  Future<void> _fetchManagers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'manager')
          .get();

      setState(() {
        managers = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'email': data['email'] as String? ?? '',
          };
        }).toList();

        if (selectedManagerId != null &&
            !managers.any((manager) => manager['id'] == selectedManagerId)) {
          selectedManagerId = null;
        }
      });
    } catch (e) {
      print('Error fetching managers: $e');
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    DateTime initialDate = selectedDeadline ?? DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDeadline ?? DateTime.now()),
      );

      if (pickedTime != null) {
        final combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          selectedDeadline = combinedDateTime;
        });
      }
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'No Deadline Selected';

    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(dateTime);
  }

  // Future<void> _saveProject() async {
  //   try {
  //     final projectData = {
  //       'name': nameController.text,
  //       'status': selectedStatus,
  //       'description': desController.text,
  //       'deadline': selectedDeadline != null
  //           ? Timestamp.fromDate(selectedDeadline!)
  //           : null,
  //       'manager_id': selectedManagerId,
  //     };
  //
  //     if (UserRoleManager().isAdmin()) {}
  //     if (widget.projectId == null) {
  //       // Add new project
  //       DocumentReference docRef = await FirebaseFirestore.instance
  //           .collection('projects')
  //           .add(projectData);
  //
  //       // Update the document with its ID
  //       await docRef.update({
  //         'project_id': docRef.id,
  //       });
  //     } else {
  //       // Update existing project
  //       await FirebaseFirestore.instance
  //           .collection('projects')
  //           .doc(widget.projectId)
  //           .update(projectData)
  //           .then((_) async {
  //         if (selectedManagerId != null ||
  //             selectedManagerId.toString().isNotEmpty) {
  //           if (UserRoleManager().isManager()) {
  //             final snapshot = await FirebaseFirestore.instance
  //                 .collection('users')
  //                 .doc(selectedManagerId)
  //                 .get();
  //             if (snapshot.exists) {
  //               String Fcm = snapshot.get('FCM-token');
  //               if (Fcm != null) {
  //                 NotificationHandler.sendNotification(
  //                     FCM_token: Fcm.toString(),
  //                     title: "Project: ${nameController.text}",
  //                     body: "Deadline: ${selectedDeadline.toString()}, ");
  //               }
  //             }
  //           } else if (UserRoleManager().isAdmin()) {
  //             final snapshot = await FirebaseFirestore.instance
  //                 .collection('users')
  //                 .doc(selectedManagerId)
  //                 .get();
  //             if (snapshot.exists) {
  //               String Fcm = snapshot.get('FCM-token');
  //               if (Fcm != null) {
  //                 NotificationHandler.sendNotification(
  //                     FCM_token: Fcm.toString(),
  //                     title: "Project: ${nameController.text}",
  //                     body:
  //                         "Deadline: ${selectedDeadline.toString()}, Assigned By: ${FirebaseAuth.instance.currentUser?.email} ");
  //               }
  //             }
  //           }
  //         }
  //       });
  //     }
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           widget.projectId == null
  //               ? 'New project added successfully'
  //               : 'Project updated successfully',
  //         ),
  //       ),
  //     );
  //
  //     Navigator.of(context).pop(); // Close the page
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //             'Failed to ${widget.projectId == null ? 'add' : 'update'} project: $e'),
  //       ),
  //     );
  //   }
  // }
  Future<void> _saveProject() async {
    try {
      final projectData = {
        'name': nameController.text,
        'status': selectedStatus,
        'description': desController.text,
        'deadline': selectedDeadline != null
            ? Timestamp.fromDate(selectedDeadline!)
            : null,
        'manager_id': selectedManagerId,
      };

      final isAdmin = UserRoleManager().isAdmin();
      final isManager = UserRoleManager().isManager();

      if (widget.projectId == null) {
        // Add new project
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('projects')
            .add(projectData);

        // Update the document with its ID
        await docRef.update({'project_id': docRef.id}).then((_) {
          if (selectedManagerId != null &&
              selectedManagerId.toString().isNotEmpty) {
            _sendNotificationIfNeeded(
                selectedManagerId!, isManager, isAdmin, "Project Created by");
          } else if (isManager) {
            _sendNotificationToAllAdmins("Project Created by");
          }
        }).onError(
          (error, stackTrace) {
            print(
                "Error On Update ${error.toString()}  Stack Is ${stackTrace.toString()}");
          },
        );
      } else {
        // Update existing project
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(widget.projectId)
            .update(projectData)
            .then((_) {
          if (selectedManagerId != null &&
              selectedManagerId.toString().isNotEmpty) {
            _sendNotificationIfNeeded(
                selectedManagerId!, isManager, isAdmin, "Updated By");
          } else if ((FirebaseAuth.instance.currentUser?.uid ==
                  selectedManagerId) &&
              isManager) {
            _sendNotificationToAllAdmins("Updated By");
          }
        }).onError(
          (error, stackTrace) {
            print(
                "Error On Update ${error.toString()}  Stack Is ${stackTrace.toString()}");
          },
        );

        // Handle notifications
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.projectId == null
                ? 'New project added successfully'
                : 'Project updated successfully',
          ),
        ),
      );

      Navigator.of(context).pop(); // Close the page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to ${widget.projectId == null ? 'add' : 'update'} project: $e'),
        ),
      );
      // Log error or perform other error handling
    }
  }

  Future<void> _sendNotificationToAllAdmins(String sn) async {
    final adminSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .get();

    for (var doc in adminSnapshot.docs) {
      final String? fcmToken = doc.get('FCM-token');
      if (fcmToken != null) {
        final title = "Project: ${nameController.text}";
        final body =
            "Deadline: ${selectedDeadline?.toString()}, $sn : ${FirebaseAuth.instance.currentUser?.email}";

        await NotificationHandler.sendNotification(
          FCM_token: fcmToken,
          title: title,
          body: body,
        );
      }
    }
  }

  Future<void> _sendNotificationIfNeeded(
      String managerId, bool isManager, bool isAdmin, String sn) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(managerId)
        .get();

    if (snapshot.exists) {
      final String? fcmToken = snapshot.get('FCM-token');
      if (fcmToken != null) {
        final title = "Project: ${nameController.text}";
        final body = isManager
            ? "Deadline: ${selectedDeadline?.toString()}, $sn : ${FirebaseAuth.instance.currentUser?.email}"
            : "Deadline: ${selectedDeadline?.toString()}, $sn : ${FirebaseAuth.instance.currentUser?.email}";

        NotificationHandler.sendNotification(
          FCM_token: fcmToken,
          title: title,
          body: body,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.projectId == null ? 'Add New Project' : 'Edit Project'),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade50, Colors.orange.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Select Status',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: ['Open', 'In Progress', 'Completed']
                    .map((status) => DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              UserRoleManager().isAdmin()
                  ? DropdownButtonFormField<String>(
                      value: selectedManagerId,
                      decoration: InputDecoration(
                        labelText: 'Select Manager',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: [
                        ...managers,
                        {
                          'id': '',
                          'email': 'Unassigned',
                        }
                      ]
                          .map((manager) => DropdownMenuItem<String>(
                                value: manager['id'],
                                child: Text(manager['email'] ?? ''),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedManagerId = value;
                        });
                      },
                    )
                  : TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Manager',
                        hintText: selectedManagerId != null
                            ? managers.firstWhere(
                                    (manager) =>
                                        manager['id'] == selectedManagerId,
                                    orElse: () =>
                                        {'email': 'Unassigned'})['email'] ??
                                'Unassigned'
                            : 'Unassigned',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
              const SizedBox(height: 16),
              TextField(
                controller: desController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_formatDateTime(selectedDeadline)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  await _selectDateTime(context);
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveProject,
                  child: Text(widget.projectId == null ? 'Save' : 'Update'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
