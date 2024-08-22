import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_assign_app/Screens/Notification_Handle/Notification_Handle.dart';
import 'package:task_assign_app/Screens/Views/check_role.dart';

class EditTaskPage extends StatefulWidget {
  final QueryDocumentSnapshot task;

  const EditTaskPage({super.key, required this.task});

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  DateTime? selectedDeadline;
  String? selectedDeveloper;
  String? selectedManager;
  String? selectedStatus;
  String? selectedProjectId;
  Map<String, String> projectMap = {}; // To store project id and name

  @override
  void initState() {
    super.initState();
    final task = widget.task.data() as Map<String, dynamic>;
    nameController = TextEditingController(text: task['name']);
    descriptionController = TextEditingController(text: task['description']);
    selectedDeadline = task['deadline']?.toDate();
    selectedDeveloper = task['assignedTo'];
    selectedManager = task['assignedBy'];
    selectedStatus = task['status'];
    selectedProjectId = task['Project_id']; // Initialize selected project ID

    // Initialize user role
    UserRoleManager().init();
  }

  Future<String?> getDocumentIdByEmail(String email) async {
    final collectionRef = FirebaseFirestore.instance.collection('users');
    final querySnapshot =
        await collectionRef.where('email', isEqualTo: email).get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    } else {
      return null;
    }
  }

  bool isDeveloper() => UserRoleManager().currentRole == 'developer';
  bool isAdmin() => UserRoleManager().currentRole == 'admin';
  bool isManager() => UserRoleManager().currentRole == 'manager';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                enabled: !isDeveloper(),
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Task Name'),
              ),
              TextField(
                enabled: !isDeveloper(),
                controller: descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Task Description'),
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                hint: const Text('Select Status'),
                value: selectedStatus,
                items: ['Open', 'In Progress', 'Completed']
                    .map((status) => DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: isDeveloper() || isAdmin() || isManager()
                    ? (value) {
                        setState(() {
                          selectedStatus = value;
                        });
                      }
                    : null,
              ),
              const SizedBox(height: 16),
              const Text('Assigned By (Manager)'),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where("role", isEqualTo: "manager")
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No managers available');
                  }

                  final managers = snapshot.data!.docs
                      .map((doc) => (doc.data()
                          as Map<String, dynamic>)['email'] as String?)
                      .toSet()
                      .toList();

                  if (selectedManager != null &&
                      !managers.contains(selectedManager)) {
                    selectedManager = null;
                  }

                  return isAdmin()
                      ? DropdownButton<String>(
                          value: selectedManager,
                          hint: const Text('Assigned By (Manager)'),
                          items: managers.map((email) {
                            return DropdownMenuItem<String>(
                              value: email,
                              child: Text(email ?? 'Unknown'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedManager = value;
                            });
                          },
                        )
                      : Text(selectedManager ?? 'No manager assigned');
                },
              ),
              const SizedBox(height: 16),
              const Text('Assigned To (Developer)'),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where("role", isEqualTo: "developer")
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No developers available');
                  }

                  final developers = snapshot.data!.docs
                      .map((doc) => (doc.data()
                          as Map<String, dynamic>)['email'] as String?)
                      .toSet()
                      .toList();

                  if (selectedDeveloper != null &&
                      !developers.contains(selectedDeveloper)) {
                    selectedDeveloper = null;
                  }

                  if (isManager() && selectedDeveloper == selectedManager) {
                    selectedDeveloper = null;
                  }

                  return isAdmin() || isManager()
                      ? DropdownButton<String>(
                          value: selectedDeveloper,
                          hint: const Text('Assign to Developer'),
                          items: developers.map((email) {
                            return DropdownMenuItem<String>(
                              value: email,
                              child: Text(email ?? 'Unknown'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedDeveloper = value;
                            });
                          },
                        )
                      : Text(selectedDeveloper ?? 'No Developer assigned');
                },
              ),
              const SizedBox(height: 16),
              const Text('Select Project'),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('projects').get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No projects available');
                  }

                  // Create a map of project ID to project name
                  final projects = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final id = doc.id;
                    final name = data['name'] ?? 'Unknown';
                    return MapEntry(id, name);
                  }).toList();

                  projectMap = {
                    for (var entry in projects) entry.key: entry.value
                  };

                  return DropdownButton<String>(
                    value: projectMap.containsKey(selectedProjectId)
                        ? selectedProjectId
                        : null, // Ensure the value matches one of the items
                    hint: const Text('Select Project'),
                    items: projectMap.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key, // Use the project ID as value
                        child: Text(entry.value), // Display the project name
                      );
                    }).toList(),
                    onChanged: isAdmin() || isManager()
                        ? (value) {
                            setState(() {
                              selectedProjectId = value;
                            });
                          }
                        : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text("Date & Time"),
              isAdmin() || isManager()
                  ? _buildDeadlineField()
                  : Text(
                      selectedDeadline != null
                          ? DateFormat('yyyy-MM-dd HH:mm')
                              .format(selectedDeadline!)
                          : 'No deadline set',
                      style: const TextStyle(fontSize: 14),
                    ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () async {
                      String? Fcm;
                      String? fcmManager;
                      String? uid =
                          await getDocumentIdByEmail(selectedDeveloper ?? '');
                      String? uidManager =
                          await getDocumentIdByEmail(selectedManager ?? '');
                      final updatedTask = {
                        'name': nameController.text,
                        'description': descriptionController.text,
                        'assignedTo': selectedDeveloper ?? 'Unassigned',
                        'assignedBy': selectedManager ?? 'Unknown',
                        'status': selectedStatus ?? 'Open',
                        'deadline': selectedDeadline ?? Timestamp.now(),
                        'Project_id': selectedProjectId ??
                            '', // Use project ID for update
                      };

                      FirebaseFirestore.instance
                          .collection('tasks')
                          .doc(widget.task.id)
                          .update(updatedTask)
                          .then((_) async {
                        if (uid != null || uidManager != null) {
                          if (isManager() || isAdmin()) {
                            final snapshot = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .get();
                            if (snapshot.exists) {
                              Fcm = snapshot.get('FCM-token');
                              if (Fcm != null) {
                                NotificationHandler.sendNotification(
                                    FCM_token: Fcm.toString(),
                                    title:
                                        "Task Updated: ${nameController.text}",
                                    body:
                                        "Deadline: ${selectedDeadline.toString()}, Assigned By: $selectedManager");
                              }
                            }
                          } else if (isDeveloper()) {
                            final snapshot = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uidManager)
                                .get();
                            if (snapshot.exists) {
                              fcmManager = snapshot.get('FCM-token');
                              if (fcmManager != null) {
                                NotificationHandler.sendNotification(
                                    FCM_token: fcmManager.toString(),
                                    title: "Task : ${nameController.text}",
                                    body:
                                        "Status $selectedStatus Updated By $selectedDeveloper");
                              }
                            }
                          }
                        }
                        Navigator.of(context).pop();
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update task: $error'),
                          ),
                        );
                      });
                    },
                    child: const Text(
                      'Update Task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeadlineField() {
    return TextField(
      controller: TextEditingController(
        text: selectedDeadline != null
            ? DateFormat('yyyy-MM-dd HH:mm').format(selectedDeadline!)
            : '',
      ),
      decoration: const InputDecoration(
        labelText: 'Deadline (YYYY-MM-DD HH:mm)',
        hintText: 'Select a date and time',
        suffixIcon: Icon(Icons.calendar_today),
      ),
      readOnly: true,
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        final DateTime? selectedDate = await showDatePicker(
          context: context,
          initialDate: selectedDeadline ?? DateTime.now(),
          firstDate: DateTime(2024),
          lastDate: DateTime(2025),
        );
        if (selectedDate != null) {
          final TimeOfDay? selectedTime = await showTimePicker(
            context: context,
            initialTime:
                TimeOfDay.fromDateTime(selectedDeadline ?? DateTime.now()),
          );
          if (selectedTime != null) {
            setState(() {
              selectedDeadline = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              );
            });
          }
        }
      },
    );
  }
}
