import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_assign_app/Screens/Notification_Handle/Notification_Handle.dart';
import 'package:task_assign_app/Screens/Views/check_role.dart';

class TaskPage extends StatefulWidget {
  final QueryDocumentSnapshot? task;

  const TaskPage({super.key, this.task});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  DateTime? selectedDeadline;
  String? selectedDeveloper;
  String? selectedManager;
  String? selectedStatus;
  String? selectedProjectId;
  Map<String, String> projectMap = {}; // To store project id and name
  bool isEditing = false;

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      isEditing = true;
      final task = widget.task!.data() as Map<String, dynamic>;
      nameController = TextEditingController(text: task['name']);
      descriptionController = TextEditingController(text: task['description']);
      selectedDeadline = task['deadline']?.toDate();
      selectedDeveloper = task['assignedTo'];
      selectedManager = task['assignedBy'];
      selectedStatus = task['status'];
      selectedProjectId = task['Project_id'];
    } else {
      // Initialize controllers for adding a new task
      nameController = TextEditingController();
      descriptionController = TextEditingController();
    }

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

  Future<QuerySnapshot> _getProjectsForManager() async {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid != null) {
      return FirebaseFirestore.instance
          .collection('projects')
          .where('manager_id', isEqualTo: currentUserUid)
          .get();
    } else {
      // If no current user UID, return an empty query
      return FirebaseFirestore.instance.collection('projects').limit(0).get();
    }
  }

  bool isDeveloper() => UserRoleManager().currentRole == 'developer';
  bool isAdmin() => UserRoleManager().currentRole == 'admin';
  bool isManager() => UserRoleManager().currentRole == 'manager';

  void _saveTask() async {
    String? Fcm;
    String? fcmManager;
    String? uiddeveloper = await getDocumentIdByEmail(selectedDeveloper ?? '');
    String? uidManager = await getDocumentIdByEmail(selectedManager ?? '');
    final updatedTask = {
      'name': nameController.text,
      'description': descriptionController.text,
      'assignedTo': uiddeveloper ?? 'Unassigned',
      'assignedBy': uidManager ?? 'Unknown',
      'status': selectedStatus ?? 'Open',
      'deadline': selectedDeadline ?? Timestamp.now(),
      'Project_id': selectedProjectId ?? '',
    };

    if (isEditing) {
      // Update existing task
      FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.task!.id)
          .update(updatedTask)
          .then((_) async {
        if (uiddeveloper != null || uidManager != null) {
          if (isManager() || isAdmin()) {
            final snapshot = await FirebaseFirestore.instance
                .collection('users')
                .doc(uiddeveloper)
                .get();
            if (snapshot.exists) {
              Fcm = snapshot.get('FCM-token');
              if (Fcm != null) {
                NotificationHandler.sendNotification(
                    FCM_token: Fcm.toString(),
                    title: "Task Updated: ${nameController.text}",
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
    } else {
      FirebaseFirestore.instance
          .collection('tasks')
          .add(updatedTask)
          .then((_) async {
        if (uiddeveloper != null || uidManager != null) {
          if (isManager() || isAdmin()) {
            final snapshot = await FirebaseFirestore.instance
                .collection('users')
                .doc(uiddeveloper)
                .get();
            if (snapshot.exists) {
              Fcm = snapshot.get('FCM-token');
              if (Fcm != null) {
                NotificationHandler.sendNotification(
                    FCM_token: Fcm.toString(),
                    title: "Task Added: ${nameController.text}",
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
            content: Text('Failed to add task: $error'),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: nameController,
                label: 'Task Name',
                enabled: !isDeveloper() || isEditing,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: descriptionController,
                label: 'Task Description',
                enabled: !isDeveloper() || isEditing,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                hint: 'Select Status',
                value: selectedStatus,
                items: ['Open', 'In Progress', 'Completed', 'Cancelled'],
                onChanged: isDeveloper() || isAdmin() || isManager()
                    ? (value) {
                        setState(() {
                          selectedStatus = value;
                        });
                      }
                    : null,
              ),
              const SizedBox(height: 16),
              _buildDropdownManager(),
              const SizedBox(height: 16),
              _buildDropdownDeveloper(),
              const SizedBox(height: 16),
              _buildDropdownProject(),
              const SizedBox(height: 16),
              const Text(
                "Date & Time",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              isAdmin() || isManager()
                  ? _buildDeadlineField()
                  : Text(
                      selectedDeadline != null
                          ? DateFormat('yyyy-MM-dd HH:mm')
                              .format(selectedDeadline!)
                          : 'No deadline set',
                      style: const TextStyle(fontSize: 14),
                    ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _saveTask,
                  child: Text(
                    isEditing ? 'Update Task' : 'Add Task',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool enabled,
  }) {
    return TextField(
      enabled: enabled,
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      ),
      hint: Text(hint),
      value: value,
      items: items
          .map((status) => DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownManager() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assigned By (Manager)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
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
                .map((doc) =>
                    (doc.data() as Map<String, dynamic>)['email'] as String?)
                .toSet()
                .toList();

            if (selectedManager != null &&
                !managers.contains(selectedManager)) {
              selectedManager = null;
            }

            return isAdmin()
                ? DropdownButtonFormField<String>(
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
      ],
    );
  }

  Widget _buildDropdownDeveloper() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assigned To (Developer)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
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
                .map((doc) =>
                    (doc.data() as Map<String, dynamic>)['email'] as String?)
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
                ? DropdownButtonFormField<String>(
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
      ],
    );
  }

  Widget _buildDropdownProject() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Project',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        FutureBuilder<QuerySnapshot>(
          future: isAdmin()
              ? FirebaseFirestore.instance.collection('projects').get()
              : _getProjectsForManager(),
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

            projectMap = {for (var entry in projects) entry.key: entry.value};

            return DropdownButtonFormField<String>(
              value: projectMap.containsKey(selectedProjectId)
                  ? selectedProjectId
                  : null,
              hint: const Text('Select Project'),
              items: projectMap.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
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
      ],
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
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
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
