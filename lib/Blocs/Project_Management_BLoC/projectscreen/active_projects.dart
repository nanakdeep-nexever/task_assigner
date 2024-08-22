import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../project_manage_bloc.dart';
import '../project_manage_event.dart';
import '../project_manage_state.dart';

class ActiveProjectsPage extends StatelessWidget {
  const ActiveProjectsPage({super.key});

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
      body: BlocConsumer<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectActionSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is ProjectError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ProjectLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProjectError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is ProjectLoaded) {
            final projects = state.projects;

            if (projects.isEmpty) {
              return const Center(child: Text('No active projects.'));
            }

            return ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                        " Project: ${project['name'] ?? 'Unnamed Project'}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: ${project['status'] ?? 'Unknown'}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black)),
                          Text(
                              project['deadline'] != null
                                  ? 'Deadline: ${project['deadline'].toDate()}'
                                  : 'No Deadline',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black)),
                          Text(
                              project["description"] != null
                                  ? 'Description: ${project['description']}'
                                  : 'No description',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black)),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editProject(context, project['id']);
                          } else if (value == 'delete') {
                            _deleteProject(context, project['id']);
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
          }
          return const Center(child: Text('No active projects.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () => _addProject(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addProject(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return const _ProjectDialog();
      },
    );

    if (result != null) {
      context.read<ProjectBloc>().add(AddProject(
            name: result['name'],
            description: result['description'],
            deadline: result['deadline'],
            status: 'hjhj',
          ));
    }
  }

  void _editProject(BuildContext context, String projectId) async {
    final project = (context.read<ProjectBloc>().state as ProjectLoaded)
        .projects
        .firstWhere((project) => project['id'] == projectId);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return _ProjectDialog(
          initialName: project['name'],
          initialDescription: project['description'],
          initialDeadline: project['deadline'],
        );
      },
    );

    if (result != null) {
      context.read<ProjectBloc>().add(EditProject(
            name: result['name'],
            description: result['description'],
            deadline: result['deadline'],
            projectId: projectId,
            status: "jj",
          ));
    }
  }

  void _deleteProject(BuildContext context, String projectId) {
    context.read<ProjectBloc>().add(DeleteProject(projectId: projectId));
  }
}

class _ProjectDialog extends StatefulWidget {
  final String? initialName;
  final String? initialDescription;
  final DateTime? initialDeadline;

  const _ProjectDialog({
    this.initialName,
    this.initialDescription,
    this.initialDeadline,
  });

  @override
  _ProjectDialogState createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<_ProjectDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDeadline;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController =
        TextEditingController(text: widget.initialDescription);
    _selectedDeadline = widget.initialDeadline;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialName != null ? 'Edit Project' : 'Add Project'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Project Name'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDeadline ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );

              if (selectedDate != null) {
                setState(() {
                  _selectedDeadline = selectedDate;
                });
              }
            },
            icon: const Icon(Icons.calendar_today),
            label: Text(_selectedDeadline != null
                ? 'Deadline: ${_selectedDeadline!.toLocal()}'
                : 'Select Deadline'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'name': _nameController.text,
              'description': _descriptionController.text,
              'deadline': _selectedDeadline,
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
