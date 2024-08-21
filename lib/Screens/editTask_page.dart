import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_assign_app/Screens/Views/check_role.dart';

class EditTaskPage extends StatefulWidget {
  final QueryDocumentSnapshot task;

  const EditTaskPage({Key? key, required this.task}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    final task = widget.task.data() as Map<String, dynamic>;
    nameController = TextEditingController(text: task['name']);
    descriptionController = TextEditingController(text: task['description']);
    selectedDeadline = (task['deadline'] as Timestamp).toDate();
    selectedDeveloper = task['assignedTo'];
    selectedManager = task['assignedBy'];
    selectedStatus = task['status'];
  }

  bool isDeveloper() {
    // Assuming UserRoleManager().init() initializes the user's role
    UserRoleManager().init();
    String role = UserRoleManager().currentRole.toString();
    return role == 'developer';
  }

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
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Assigned By (Manager)'),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where("role", isEqualTo: "manager")
                    .get(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                      .map((doc) {
                        final manager = doc.data() as Map<String, dynamic>;
                        return manager['email'] as String?;
                      })
                      .toSet()
                      .toList(); // Ensure unique values

                  // If the selectedManager is not in the list, reset it
                  if (selectedManager != null &&
                      !managers.contains(selectedManager)) {
                    selectedManager = null;
                  }

                  return DropdownButton<String>(
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
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text('Assigned To (Developer)'),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where("role", isEqualTo: "developer")
                    .get(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                      .map((doc) {
                        final developer = doc.data() as Map<String, dynamic>;
                        return developer['email'] as String?;
                      })
                      .toSet()
                      .toList(); // Ensure unique values

                  // If the selectedDeveloper is not in the list, reset it
                  if (selectedDeveloper != null &&
                      !developers.contains(selectedDeveloper)) {
                    selectedDeveloper = null;
                  }

                  // Check if selectedManager and selectedDeveloper are the same
                  if (UserRoleManager().currentRole == 'manager' &&
                      selectedDeveloper == selectedManager) {
                    selectedDeveloper = null; // Reset selectedDeveloper
                  }

                  return DropdownButton<String>(
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
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDeadline == null
                          ? 'Select Deadline'
                          : DateFormat.yMd().format(selectedDeadline!),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDeadline ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      final updatedTask = {
                        'name': nameController.text,
                        'description': descriptionController.text,
                        'assignedTo': selectedDeveloper ?? 'Unassigned',
                        'assignedBy': selectedManager ?? 'Unknown',
                        'status': selectedStatus ?? 'Open',
                        'deadline': selectedDeadline ?? DateTime.now(),
                      };

                      FirebaseFirestore.instance
                          .collection('tasks')
                          .doc(widget.task.id)
                          .update(updatedTask)
                          .catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to update task: $error')),
                        );
                      });

                      Navigator.of(context).pop();
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
}
