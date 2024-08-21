import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_assign_app/Blocs/Project_Management_BLoC/project_manage_event.dart';
import 'package:task_assign_app/model/Project_model.dart';

import '../Blocs/Project_Management_BLoC/project_manage_bloc.dart';
import '../Blocs/Project_Management_BLoC/project_manage_state.dart';
import '../Showupdate_dialog.dart';

class ProjectManagementPage extends StatefulWidget {
  @override
  State<ProjectManagementPage> createState() => _ProjectManagementPageState();
}

class _ProjectManagementPageState extends State<ProjectManagementPage> {
  String? role;
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchrole();
  }

  @override
  Widget build(BuildContext context) {
    void navigateToProjectPage(BuildContext context, {Project? project}) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProjectPage(project: project),
        ),
      );
    }

    return Scaffold(
      floatingActionButton: role == 'admin' || role == 'manager'
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
                String _selectedStatus = "Not Started";

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
                      content: SingleChildScrollView(
                        child: StatefulBuilder(builder: (context, setState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              DropdownButton<String>(
                                value: _selectedStatus,
                                items: <String>[
                                  'In Progress',
                                  'Done',
                                  'Not Started'
                                ].map((String status) {
                                  return DropdownMenuItem<String>(
                                    value: status,
                                    child: Text(status),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedStatus = newValue!;
                                  });
                                },
                                hint: Text('Select Status'),
                              ),
                            ],
                          );
                        }),
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
                                      _selectedDateTime,
                                      _selectedStatus.toString()),
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

                    return role == 'admin'
                        ? StreamBuilder<String>(
                            stream: getManagerEmail(project.managerId),
                            builder: (context, snapshot) {
                              final managerEmail = snapshot.data ?? 'Unknown';
                              String Email =
                                  getDeveloperemail(project.developerId)
                                      .toString();

                              return Card(
                                margin: EdgeInsets.all(8.0),
                                color: now.isAfter(project.deadline)
                                    ? Colors.red.shade100
                                    : Colors.white,
                                child: ListTile(
                                  title: Text(
                                    project.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(deadlineText),
                                      Text('Manager: $managerEmail'),
                                      Text("Status: ${project.status_project}"),
                                    ],
                                  ),
                                  trailing: now.isAfter(project.deadline)
                                      ? Icon(Icons.warning, color: Colors.red)
                                      : null,
                                  onTap: () {
                                    navigateToProjectPage(context,
                                        project: project);
                                  },
                                  onLongPress: () => _showDeleteConfirmation(
                                      context, project.projectid),
                                ),
                              );
                            },
                          )
                        : StreamBuilder<String>(
                            stream: getDeveloperemail(project.developerId),
                            builder: (context, snapshot) {
                              final devloperEmail = snapshot.data ?? 'Unknown';

                              return Card(
                                margin: EdgeInsets.all(8.0),
                                color: now.isAfter(project.deadline)
                                    ? Colors.red.shade100
                                    : Colors.white,
                                child: ListTile(
                                  title: Text(
                                    project.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(deadlineText),
                                      Text('Devloper: $devloperEmail'),
                                      Text("Status: ${project.status_project}"),
                                    ],
                                  ),
                                  trailing: now.isAfter(project.deadline)
                                      ? Icon(Icons.warning, color: Colors.red)
                                      : null,
                                  onTap: () {
                                    navigateToProjectPage(context,
                                        project: project);
                                  },
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
                      stream: getDeveloperemail(project.developerId),
                      builder: (context, snapshot) {
                        final developerEmail = snapshot.data ?? 'Unknown';

                        return Card(
                          margin: EdgeInsets.all(8.0),
                          color: now.isAfter(project.deadline)
                              ? Colors.red.shade100
                              : Colors.white,
                          child: ListTile(
                              title: Text(
                                project.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(deadlineText),
                                  Text("Developer: $developerEmail"),
                                  Text('Status: ${project.status_project}')
                                ],
                              ),
                              trailing: now.isAfter(project.deadline)
                                  ? Icon(Icons.warning, color: Colors.red)
                                  : null,
                              onTap: () {
                                //_showProjectDialog(context, project: project);
                              }),
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
