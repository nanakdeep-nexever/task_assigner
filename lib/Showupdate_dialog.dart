import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'Blocs/Project_Management_BLoC/project_manage_bloc.dart';
import 'Blocs/Project_Management_BLoC/project_manage_event.dart';
import 'model/Project_model.dart';

class ProjectPage extends StatefulWidget {
  final Project? project;

  ProjectPage({Key? key, this.project}) : super(key: key);

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  late TextEditingController nameController;
  late TextEditingController projectIdController;
  late TextEditingController descriptionController;
  late TextEditingController deadlineController;
  String? selectedManagerId;
  String? selectedDeveloperId;
  String? selectedStatus;
  List<Map<String, String>> managers = [];
  List<Map<String, String>> developers = [];

  String role = '';

  @override
  void initState() {
    super.initState();
    final project = widget.project;
    nameController = TextEditingController(text: project?.name ?? '');
    projectIdController = TextEditingController(text: project?.projectid ?? '');
    descriptionController =
        TextEditingController(text: project?.description ?? '');
    deadlineController = TextEditingController(
      text: project != null
          ? DateFormat('yyyy-MM-dd HH:mm').format(project.deadline)
          : '',
    );

    selectedManagerId = project?.managerId;
    selectedDeveloperId = project?.developerId;
    selectedStatus = project?.status_project;

    _fetchManagers();
    _fetchDevelopers();
    _fetchrole();
  }

  void _fetchrole() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    if (doc.exists) {
      setState(() {
        role = doc.get('role');
        print("object $role");
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

  void _handleSubmit() {
    final projectId = widget.project?.projectid ?? '';
    final name = nameController.text;
    final description = descriptionController.text;
    final status = selectedStatus ?? '';
    final deadline = DateTime.parse(deadlineController.text);

    context.read<ProjectBloc>().add(UpdateProjectEvent(
          projectId: projectId,
          name: name,
          description: description,
          deadline: deadline,
          developer_id: selectedDeveloperId ?? '',
          manager_id: selectedManagerId ?? '',
          Project_Status: status,
        ));
    Navigator.of(context).pop();
  }

  void _handleRemoveRole(bool isManager) {
    final projectId = widget.project?.projectid ?? '';
    final name = nameController.text;
    final description = descriptionController.text;
    final status = selectedStatus ?? '';
    final deadline = DateTime.parse(deadlineController.text);
    final developerId = isManager ? '' : selectedDeveloperId;
    final managerId = isManager ? selectedManagerId : '';

    context.read<ProjectBloc>().add(UpdateProjectEvent(
          projectId: projectId,
          name: name,
          description: description,
          deadline: deadline,
          developer_id: developerId ?? '',
          manager_id: managerId ?? '',
          Project_Status: status,
        ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project == null ? 'Add Project' : 'Edit Project'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildTextField(
                  controller: projectIdController,
                  label: 'Project Id',
                  enabled: false),
              _buildTextField(
                  controller: nameController, label: 'Project Name'),
              _buildTextField(
                  controller: descriptionController, label: 'Description'),
              _buildStatusDropdown(
                selectedStatus: selectedStatus,
                onStatusChanged: (newValue) =>
                    setState(() => selectedStatus = newValue),
              ),
              _buildDeadlineField(
                context: context,
                controller: deadlineController,
              ),
              if (role == 'admin') ...[
                _buildManagerDropdown(
                    selectedManagerId: selectedManagerId,
                    managers: managers,
                    onManagerChanged: (newValue) {
                      setState(() => selectedManagerId = newValue);
                    }),
                if (selectedManagerId != null)
                  _buildRemoveManagerButton(
                      context, widget.project, role, selectedManagerId),
              ] else if (role == 'manager') ...[
                _buildDeveloperDropdown(
                  selectedDeveloperId: selectedDeveloperId,
                  developers: developers,
                  onDeveloperChanged: (newValue) =>
                      setState(() => selectedDeveloperId = newValue),
                ),
                if (selectedDeveloperId != null)
                  _buildRemoveDeveloperButton(

                      ///
                      context,
                      widget.project,
                      role,
                      selectedDeveloperId),
              ]
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleSubmit,
        child: Icon(Icons.save),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildStatusDropdown(
      {String? selectedStatus,
      required ValueChanged<String?> onStatusChanged}) {
    return DropdownButton<String>(
      value: selectedStatus,
      items:
          <String>['In Progress', 'Done', 'Not Started'].map((String status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(status),
        );
      }).toList(),
      onChanged: onStatusChanged,
      hint: Text('Select Status'),
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

  Widget _buildRemoveManagerButton(BuildContext context, Project? project,
      String? role, String? selectedManagerId) {
    return TextButton(
      onPressed: () {
        final projectId = widget.project?.projectid ?? '';
        final name = nameController.text;
        final description = descriptionController.text;
        final status = selectedStatus ?? '';
        final deadline = DateTime.parse(deadlineController.text);
        final developerId = selectedDeveloperId ?? '';
        final managerId = '';

        context.read<ProjectBloc>().add(UpdateProjectEvent(
              projectId: projectId,
              name: name,
              description: description,
              deadline: deadline,
              developer_id: developerId ?? '',
              manager_id: managerId ?? '',
              Project_Status: status,
            ));
        Navigator.of(context).pop();
      },
      child: Text('Remove Manager'),
    );
  }

  Widget _buildRemoveDeveloperButton(BuildContext context, Project? project,
      String? role, String? selectedDeveloperId) {
    return TextButton(
      onPressed: () {
        final projectId = widget.project?.projectid ?? '';
        final name = nameController.text;
        final description = descriptionController.text;
        final status = selectedStatus ?? '';
        final deadline = DateTime.parse(deadlineController.text);
        final developerId = '';
        final managerId = selectedManagerId ?? '';

        context.read<ProjectBloc>().add(UpdateProjectEvent(
              projectId: projectId,
              name: name,
              description: description,
              deadline: deadline,
              developer_id: developerId ?? '',
              manager_id: managerId ?? '',
              Project_Status: status,
            ));
        Navigator.of(context).pop();
      },
      child: Text('Remove Developer'),
    );
  }
}
