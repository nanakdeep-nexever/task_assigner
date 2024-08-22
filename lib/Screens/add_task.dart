import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'Notification_Handle/Notification_Handle.dart';
import 'Views/check_role.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime? selectedDeadline;
  String? selectedDeveloper;
  String? selectedManager;
  String? selectedStatus;
  String? selectedProjectId;
  Map<String, String> projectMap = {}; // To store project id and name

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 10,
      backgroundColor: Colors.green.shade50,
      title: const Center(
        child: Text(
          'Add New Task',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Task Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Task Description'),
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
              onChanged: (value) {
                setState(() {
                  selectedStatus = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Assigned By (Manager)'),
            _buildDropdown(
              collection: FirebaseFirestore.instance
                  .collection('users')
                  .where("role", isEqualTo: "manager"),
              selectedValue: selectedManager,
              hintText: 'Assigned By (Manager)',
              onChanged: (value) {
                setState(() {
                  selectedManager = value;
                });
              },
              context: context,
            ),
            const SizedBox(height: 16),
            const Text('Assigned To (Developer)'),
            _buildDropdown(
              collection: FirebaseFirestore.instance
                  .collection('users')
                  .where("role", isEqualTo: "developer"),
              selectedValue: selectedDeveloper,
              hintText: 'Assign to Developer',
              onChanged: (value) {
                setState(() {
                  selectedDeveloper = value;
                });
              },
              context: context,
            ),
            const SizedBox(height: 16),
            const Text('Select Project'),
            _buildDropdown(
              collection: FirebaseFirestore.instance.collection('projects'),
              selectedValue: selectedProjectId,
              hintText: 'Select Project',
              onChanged: (value) {
                setState(() {
                  selectedProjectId = value;
                });
              },
              context: context,
              projectMap: projectMap,
            ),
            const SizedBox(height: 16),
            const Text('Date & Time'),
            _buildDeadlineField(selectedDeadline, setState, context),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            String? Fcm;
            String? fcmManager;
            String? uid = await getDocumentIdByEmail(selectedDeveloper ?? '');
            String? uidManager =
                await getDocumentIdByEmail(selectedManager ?? '');
            final newTask = {
              'name': nameController.text,
              'description': descriptionController.text,
              'assignedTo': selectedDeveloper ?? 'Unassigned',
              'assignedBy': selectedManager ?? 'Unknown',
              'status': selectedStatus ?? 'Open',
              'deadline': selectedDeadline ?? Timestamp.now(),
              'Project_id': selectedProjectId ?? '',
            };

            FirebaseFirestore.instance
                .collection('tasks')
                .add(newTask)
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
                        title: "Task Updated: ${nameController.text}",
                        body: isManager()
                            ? "Deadline: ${selectedDeadline.toString()}, Assigned By: $selectedManager"
                            : "Deadline: ${selectedDeadline.toString()}, Assigned By: Admin",
                      );
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
                        title: "Task: ${nameController.text}",
                        body:
                            "Status $selectedStatus Updated By $selectedDeveloper",
                      );
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
          },
          child: const Text(
            'Add Task',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required Query collection,
    required String? selectedValue,
    required String hintText,
    required ValueChanged<String?> onChanged,
    required BuildContext context,
    Map<String, String>? projectMap,
  }) {
    return FutureBuilder<QuerySnapshot>(
      future: collection.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No data available');
        }

        final items = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final id = doc.id;
          final name = data['name'] ?? 'Unknown';
          return MapEntry(id, name);
        }).toList();

        // Convert the dynamic map entries to the required String map entries
        final convertedMap = { for (var entry in items) entry.key : entry.value as String };

        if (projectMap != null) {
          projectMap.clear();
          projectMap.addEntries(convertedMap.entries);
        }

        return DropdownButton<String>(
          value: projectMap?.containsKey(selectedValue) ?? false
              ? selectedValue
              : null,
          hint: Text(hintText),
          items: projectMap?.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList() ??
              [],
          onChanged: onChanged,
        );
      },
    );
  }

  Widget _buildDeadlineField(
      DateTime? selectedDeadline, StateSetter setState, BuildContext context) {
    final deadlineController = TextEditingController(
      text: selectedDeadline != null
          ? DateFormat('yyyy-MM-dd HH:mm').format(selectedDeadline)
          : '',
    );

    return TextField(
      controller: deadlineController,
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
              deadlineController.text =
                  DateFormat('yyyy-MM-dd HH:mm').format(selectedDeadline!);
            });
          }
        }
      },
    );
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
}
