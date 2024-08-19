import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_bloc.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_event.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_state.dart';
import 'package:task_assign_app/Blocs/Project_Management_BLoC/project_manage_event.dart';
import 'package:task_assign_app/model/Project_model.dart';

import '../Blocs/Project_Management_BLoC/project_manage_bloc.dart';
import '../Blocs/Project_Management_BLoC/project_manage_state.dart';

class ProjectManagementPage extends StatefulWidget {
  @override
  State<ProjectManagementPage> createState() => _ProjectManagementPageState();
}

class _ProjectManagementPageState extends State<ProjectManagementPage> {
  @override
  Widget build(BuildContext context) {
    String? role = ModalRoute.of(context)?.settings.arguments.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text("Project"),
        actions: [
          BlocConsumer<AuthenticationBloc, AuthenticationState>(
            listener: (context, state) {
              if (state is AuthenticationUnauthenticated) {
                Navigator.pushReplacementNamed(context, '/');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Logged Out"),
                    duration: Duration(milliseconds: 10),
                  ),
                );
              }
            },
            builder: (context, state) {
              return IconButton(
                onPressed: () {
                  context.read<AuthenticationBloc>().add(LogoutEvent());
                },
                icon: Icon(Icons.logout),
              );
            },
          ),
        ],
      ),
      floatingActionButton: role == 'admin'
          ? FloatingActionButton(
              onPressed: () {
                final TextEditingController _projectNameController =
                    TextEditingController();
                final TextEditingController _Project_IdController =
                    TextEditingController();
                final TextEditingController _projectDescriptionController =
                    TextEditingController();
                final TextEditingController _dateController =
                    TextEditingController();
                final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

                DateTime _selectedDateTime = DateTime.now();

                void _selectDateTime(BuildContext context) async {
                  final DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDateTime,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2025),
                  );

                  if (selectedDate != null) {
                    final TimeOfDay? selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                    );

                    if (selectedTime != null) {
                      final DateTime combinedDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      setState(() {
                        _selectedDateTime = combinedDateTime;
                        _dateController.text =
                            _dateFormat.format(combinedDateTime);
                      });
                    }
                  }
                }

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Add Project'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField(
                            decoration:
                                InputDecoration(labelText: 'Project Id'),
                            controller: _Project_IdController,
                          ),
                          TextField(
                            decoration:
                                InputDecoration(labelText: 'Project Name'),
                            controller: _projectNameController,
                          ),
                          TextField(
                            controller: _projectDescriptionController,
                            decoration:
                                InputDecoration(labelText: 'Description'),
                          ),
                          TextField(
                            controller: _dateController,
                            decoration: InputDecoration(
                              labelText: 'Deadline',
                              hintText: 'Select a date and time',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            keyboardType: TextInputType.datetime,
                            onTap: () => _selectDateTime(context),
                            readOnly: true, // Make the TextField read-only
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            context.read<ProjectBloc>().add(
                                  CreateProjectEvent(
                                      _Project_IdController.text.toString(),
                                      _projectNameController.text.toString(),
                                      _projectDescriptionController.text
                                          .toString(),
                                      _selectedDateTime),
                                );
                            Navigator.of(context).pop();
                          },
                          child: Text('Add'),
                        ),
                      ],
                    );
                  },
                );
              },
              tooltip: "Create Project",
              child: Icon(Icons.task),
            )
          : null,
      body: BlocBuilder<ProjectBloc, ProjectState>(
        builder: (context, state) {
          if (role == 'admin' || role == 'manager') {
            return StreamBuilder<List<Project>>(
              stream: context.read<ProjectBloc>().projectsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error snapshot: ${snapshot.error}'));
                }

                final projects = snapshot.data ?? [];

                return ListView.builder(
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    final now = DateTime.now();
                    final isToday = now.year == project.deadline.year &&
                        now.month == project.deadline.month &&
                        now.day == project.deadline.day;

                    final deadlineText = isToday
                        ? 'Time: ${project.deadline.toLocal().toString().split(' ')[1].substring(0, 5)}' // Display time only
                        : 'Deadline: ${project.deadline.toLocal().toString().split(' ')[0]}'; // Display full date

                    return StreamBuilder<String>(
                      stream: getManagerEmail(project.managerId),
                      builder: (context, snapshot) {
                        final managerEmail = snapshot.data ?? 'Unknown';

                        return Card(
                          margin: EdgeInsets.all(8.0),
                          color: now.isAfter(project.deadline)
                              ? Colors.red.shade100
                              : Colors.white,
                          child: ListTile(
                            title: Text(project.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(deadlineText),
                                Text('Manager: $managerEmail'),
                              ],
                            ),
                            trailing: now.isAfter(project.deadline)
                                ? Icon(Icons.warning, color: Colors.red)
                                : null,
                            onTap: () =>
                                _showProjectDialog(context, project: project),
                            onLongPress: () => _showDeleteConfirmation(
                                context, project.projectid),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          } else if (role == 'developer') {
            return StreamBuilder<List<Project>>(
              stream: context.read<ProjectBloc>().projectsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final projects = snapshot.data ?? [];

                return ListView.builder(
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    final now = DateTime.now();
                    final isToday = now.year == project.deadline.year &&
                        now.month == project.deadline.month &&
                        now.day == project.deadline.day;

                    final deadlineText = isToday
                        ? 'Time: ${project.deadline.toLocal().toString().split(' ')[1].substring(0, 5)}' // Display time only
                        : 'Deadline: ${project.deadline.toLocal().toString().split(' ')[0]}'; // Display full date

                    return StreamBuilder<String>(
                      stream: getManagerEmail(project.managerId),
                      builder: (context, snapshot) {
                        final managerEmail = snapshot.data ?? 'Unknown';

                        return Card(
                          margin: EdgeInsets.all(8.0),
                          color: now.isAfter(project.deadline)
                              ? Colors.red.shade100
                              : Colors.white,
                          child: ListTile(
                            title: Text(project.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(deadlineText),
                                Text('Manager: $managerEmail'),
                              ],
                            ),
                            trailing: now.isAfter(project.deadline)
                                ? Icon(Icons.warning, color: Colors.red)
                                : null,
                            onTap: () =>
                                _showProjectDialog(context, project: project),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          }
          return Center(child: Text("No Projects"));
        },
      ),
    );
  }

  void _addDeveloper() {
    // Logic to add a developer
    // This could involve showing another dialog or updating the project details
  }

  void _showProjectDialog(BuildContext context, {Project? project}) async {
    String? role = ModalRoute.of(context)?.settings.arguments.toString();

    final nameController = TextEditingController(text: project?.name ?? '');
    final project_idController =
        TextEditingController(text: project?.projectid ?? '');
    final descriptionController =
        TextEditingController(text: project?.description ?? '');
    final statusController =
        TextEditingController(text: project?.status_project ?? '');
    final deadlineController = TextEditingController(
        text: project != null
            ? DateFormat('yyyy-MM-dd').format(project.deadline)
            : '');

    String? selectedManagerId = project?.managerId;
    String? selectedDeveloperId = project?.developerId;
    List<Map<String, String>> managers = [];
    List<Map<String, String>> developer = [];

    // Fetch managers for dropdown
    Future<void> _fetchManagers() async {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'manager')
          .get();

      managers = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'email': data['email'] as String? ?? '',
        };
      }).toList();

      // Ensure selectedManagerId is valid
      if (selectedManagerId != null &&
          !managers.any((manager) => manager['id'] == selectedManagerId)) {
        selectedManagerId = null; // Reset if the manager is not in the list
      }
    }

    Future<void> _fetchDeveloper() async {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'developer')
          .get();

      developer = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'email': data['email'] as String? ?? '',
        };
      }).toList();

      // Ensure selectedManagerId is valid
      if (selectedDeveloperId != null &&
          !developer
              .any((developers) => developers['id'] == selectedDeveloperId)) {
        selectedDeveloperId = null; // Reset if the manager is not in the list
      }
    }

    await _fetchManagers();
    await _fetchDeveloper();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: AlertDialog(
                title: Text(project == null ? 'Add Project' : 'Edit Project'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: project_idController,
                      decoration: InputDecoration(labelText: 'Project Id'),
                    ),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Project Name'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                    ),
                    TextField(
                      controller: statusController,
                      decoration: InputDecoration(labelText: 'Status'),
                    ),
                    TextField(
                      controller: deadlineController,
                      decoration: InputDecoration(
                        labelText: 'Deadline (YYYY-MM-DD)',
                        hintText: 'Select a date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.datetime,
                      onTap: () async {
                        final DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: project?.deadline ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2025),
                        );
                        if (selectedDate != null) {
                          deadlineController.text =
                              DateFormat('yyyy-MM-dd').format(selectedDate);
                        }
                      },
                    ),
                    if (role == 'admin') ...[
                      DropdownButton<String>(
                        value: selectedManagerId,
                        disabledHint: Text(selectedManagerId != null
                            ? 'Manager Assigned'
                            : selectedManagerId.toString()),
                        hint: Text('Select Manager'),
                        onChanged: selectedManagerId == null
                            ? (String? newValue) {
                                setState(() {
                                  selectedManagerId = newValue;
                                });
                              }
                            : null,
                        items:
                            managers.map<DropdownMenuItem<String>>((manager) {
                          return DropdownMenuItem<String>(
                            value: manager['id'],
                            child: Text(manager['email'] ?? ''),
                          );
                        }).toList(),
                      ),
                      if (selectedManagerId !=
                          null) // Option to remove developer
                        TextButton(
                          onPressed: () {
                            final Projectid = project_idController.text;
                            final name = nameController.text;
                            final description = descriptionController.text;
                            final status = statusController.text;
                            final deadline =
                                DateTime.parse(deadlineController.text);
                            if (selectedDeveloperId == selectedManagerId) {
                              if (role == 'admin') {
                                selectedDeveloperId = '';
                              } else if (role == 'manager') {
                                selectedManagerId = '';
                              }
                            }
                            setState(() {
                              if (project != null) {
                                context
                                    .read<ProjectBloc>()
                                    .add(UpdateProjectEvent(
                                      projectId: Projectid,
                                      name: name,
                                      description: description,
                                      deadline: deadline,
                                      developer_id: selectedDeveloperId ?? '',
                                      manager_id: '',
                                      Project_Status: status,
                                    ));
                              }
                            });
                            Navigator.of(context).pop();
                          },
                          child: Text('Remove Manager'),
                        ),
                    ] else if (role == 'manager') ...[
                      DropdownButton<String>(
                        value: selectedDeveloperId,
                        hint: Text('Select developer'),
                        disabledHint: Text(selectedDeveloperId != null
                            ? 'Developer Assigned'
                            : selectedDeveloperId.toString()),
                        onChanged: selectedDeveloperId == null
                            ? (String? newValue) {
                                setState(() {
                                  selectedDeveloperId = newValue;
                                });
                              }
                            : null,
                        items: developer
                            .map<DropdownMenuItem<String>>((developers) {
                          return DropdownMenuItem<String>(
                            value: developers['id'],
                            child: Text(developers['email'] ?? ''),
                          );
                        }).toList(),
                      ),
                      if (selectedDeveloperId !=
                          null) // Option to remove developer
                        TextButton(
                          onPressed: () {
                            final Projectid = project_idController.text;
                            final name = nameController.text;
                            final description = descriptionController.text;
                            final status = statusController.text;
                            final deadline =
                                DateTime.parse(deadlineController.text);
                            if (selectedDeveloperId == selectedManagerId) {
                              if (role == 'admin') {
                                selectedDeveloperId = '';
                              } else if (role == 'manager') {
                                selectedManagerId = '';
                              }
                            }
                            setState(() {
                              if (project != null) {
                                context
                                    .read<ProjectBloc>()
                                    .add(UpdateProjectEvent(
                                      projectId: Projectid,
                                      name: name,
                                      description: description,
                                      deadline: deadline,
                                      developer_id: '',
                                      manager_id: selectedManagerId ?? '',
                                      Project_Status: status,
                                    ));
                              }
                            });
                            Navigator.of(context).pop();
                          },
                          child: Text('Remove Developer'),
                        ),
                    ]
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      final Projectid = project_idController.text;
                      final name = nameController.text;
                      final description = descriptionController.text;
                      final status = statusController.text;
                      final deadline = DateTime.parse(deadlineController.text);
                      if (selectedDeveloperId == selectedManagerId) {
                        if (role == 'admin') {
                          selectedDeveloperId = '';
                        } else if (role == 'manager') {
                          selectedManagerId = '';
                        }
                      }

                      if (project != null) {
                        context.read<ProjectBloc>().add(UpdateProjectEvent(
                              projectId: Projectid,
                              name: name,
                              description: description,
                              deadline: deadline,
                              developer_id: selectedDeveloperId ?? '',
                              manager_id: selectedManagerId ?? '',
                              Project_Status: status,
                            ));
                      }

                      Navigator.of(context).pop();
                    },
                    child: Text(project == null ? 'Add' : 'Update'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Project'),
          content: Text('Are you sure you want to delete this project?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                context
                    .read<ProjectBloc>()
                    .add(DeleteProjectEvent(projectId: id));
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Stream<String> getManagerEmail(String managerId) {
    if (managerId.isEmpty) {
      return Stream.value(
          'Unknown'); // Return a default value if the managerId is empty
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(managerId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['email'] ?? 'Unknown');
  }

  Stream<String> getDeveloperemail(String developerId) {
    if (developerId.isEmpty) {
      return Stream.value(
          'Unknown'); // Return a default value if the managerId is empty
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(developerId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['email'] ?? 'Unknown');
  }
}
