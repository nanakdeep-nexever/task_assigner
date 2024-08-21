import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_assign_app/Blocs/Task_Management_BLoC/task_bloc.dart';
import 'package:task_assign_app/Blocs/Task_Management_BLoC/task_event.dart';
import 'package:task_assign_app/Screens/Views/check_role.dart';

import 'model/Task_model.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;

  EditTaskPage({Key? key, required this.task}) : super(key: key);

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController deadlineController;
  String? selectedDeveloperId;
  String? selectedManagerId;
  String? selectedStatus;
  String? role;
  List<Map<String, String>> managers = [];
  List<Map<String, String>> developers = [];

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

  Future<void> _fetchDevelopers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'developer')
          .get();

      setState(() {
        developers = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'email': data['email'] as String? ?? '',
          };
        }).toList();

        if (selectedDeveloperId != null &&
            !developers
                .any((developer) => developer['id'] == selectedDeveloperId)) {
          selectedDeveloperId = null;
        }
      });
    } catch (e) {
      print('Error fetching developers: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    nameController = TextEditingController(text: task.name);
    descriptionController = TextEditingController(text: task.description);
    deadlineController = TextEditingController(
      text: task != null
          ? DateFormat('yyyy-MM-dd HH:mm').format(task.deadline)
          : '',
    );
    selectedDeveloperId = task.assignedTo;
    selectedManagerId = task.assignedBy;
    selectedStatus = task.status;
    _fetchManagers();
    _fetchDevelopers();
    UserRoleManager().init();
    role = UserRoleManager().currentRole.toString();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<List<String>> fetchUsersByRole(String role) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: role)
        .get();

    return querySnapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['email'] as String?)
        .whereType<String>()
        .toSet() // Ensure unique values
        .toList();
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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            if (role == 'admin') ...[
              _buildManagerDropdown(
                  selectedManagerId: selectedManagerId,
                  managers: managers,
                  onManagerChanged: (newValue) {
                    setState(() => selectedManagerId = newValue);
                  }),
              if (selectedManagerId != null)
                _buildRemoveManagerButton(
                    context, widget.task, role, selectedManagerId),
            ] else if (role == 'manager') ...[
              _buildDeveloperDropdown(
                selectedDeveloperId: selectedDeveloperId,
                developers: developers,
                onDeveloperChanged: (newValue) =>
                    setState(() => selectedDeveloperId = newValue),
              ),
              if (selectedDeveloperId != null)
                _buildRemoveDeveloperButton(
                    context, widget.task, role, selectedDeveloperId),
            ],
            _buildDeadlineField(
              context: context,
              controller: deadlineController,
            ),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final updatedTask = {
            'name': nameController.text,
            'description': descriptionController.text,
            'assignedTo': selectedDeveloperId ?? 'Unassigned',
            'assignedBy': selectedManagerId ?? 'Unknown',
            'status': selectedStatus ?? 'Open',
            'deadline': deadlineController ?? DateTime.now(),
          };

          FirebaseFirestore.instance
              .collection('tasks')
              .doc(widget.task.id) // Assuming `task.id` is the document ID
              .update(updatedTask)
              .then((_) {
            Navigator.of(context).pop();
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update task: $error')),
            );
          });
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  Widget _buildDeadlineField(
      {required BuildContext context,
      required TextEditingController controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Deadline (YYYY-MM-DD HH:mm)',
        hintText: 'Select a date and time',
        suffixIcon: Icon(Icons.calendar_today),
      ),
      readOnly: true,
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        final DateTime? selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
          firstDate: DateTime(2024),
          lastDate: DateTime(2025),
        );
        if (selectedDate != null) {
          final TimeOfDay? selectedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(
                DateTime.tryParse(controller.text) ?? DateTime.now()),
          );
          if (selectedTime != null) {
            final DateTime finalDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );
            controller.text =
                DateFormat('yyyy-MM-dd HH:mm').format(finalDateTime);
          }
        }
      },
    );
  }

  Widget _buildManagerDropdown({
    required String? selectedManagerId,
    required List<Map<String, String>> managers,
    required ValueChanged<String?> onManagerChanged,
  }) {
    return DropdownButton<String>(
      value: selectedManagerId,
      hint: Text('Select Manager'),
      onChanged: onManagerChanged,
      items: managers.map<DropdownMenuItem<String>>((manager) {
        return DropdownMenuItem<String>(
          value: manager['id'],
          child: Text(manager['email'] ?? ''),
        );
      }).toList(),
    );
  }

  Widget _buildDeveloperDropdown(
      {String? selectedDeveloperId,
      required List<Map<String, String>> developers,
      required ValueChanged<String?> onDeveloperChanged}) {
    return DropdownButton<String>(
      value: selectedDeveloperId,
      hint: Text('Select Developer'),
      onChanged: onDeveloperChanged,
      items: developers.map<DropdownMenuItem<String>>((developer) {
        return DropdownMenuItem<String>(
          value: developer['id'],
          child: Text(developer['email'] ?? ''),
        );
      }).toList(),
    );
  }

  Widget _buildRemoveManagerButton(BuildContext context, Task? task,
      String? role, String? selectedManagerId) {
    return TextButton(
      onPressed: () {
        final projectId = widget.task?.id ?? '';
        final name = nameController.text;
        final description = descriptionController.text;
        final status = selectedStatus ?? '';
        final deadline = DateTime.parse(deadlineController.text);
        final developerId = selectedDeveloperId ?? '';
        final managerId = '';

        context.read<TaskBloc>().add(UpdateTaskEvent(
              name: name,
              description: description,
              deadline: deadline,
              assignedTo: developerId ?? '',
              assignedBy: managerId ?? '',
              status: status,
            ));
        Navigator.of(context).pop();
      },
      child: Text('Remove Manager'),
    );
  }

  Widget _buildRemoveDeveloperButton(BuildContext context, Task? task,
      String? role, String? selectedDeveloperId) {
    return TextButton(
      onPressed: () {
        final name = nameController.text;
        final description = descriptionController.text;
        final status = selectedStatus ?? '';
        final deadline = DateTime.parse(deadlineController.text);
        final developerId = '';
        final managerId = selectedManagerId ?? '';

        context.read<TaskBloc>().add(UpdateTaskEvent(
              name: name,
              description: description,
              deadline: deadline,
              assignedTo: developerId ?? '',
              assignedBy: managerId ?? '',
              status: status,
            ));
        Navigator.of(context).pop();
      },
      child: Text('Remove Developer'),
    );
  }
}
