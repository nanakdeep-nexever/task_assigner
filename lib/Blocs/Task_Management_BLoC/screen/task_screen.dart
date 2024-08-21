import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../task_bloc.dart';
import '../task_event.dart';
import '../task_state.dart';

class ActiveTasksPage extends StatelessWidget {
  const ActiveTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Active Tasks',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
        ),
      ),
      body: BlocProvider(
        create: (_) => TaskBloc()..add(LoadTasks()),
        child: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is TaskError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is TaskLoaded) {
              final tasks = state.tasks;

              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];

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
                          colors: [Colors.green.withOpacity(0.1), Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(
                          "Task: ${task['name']}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Desc: ${task['description']}",
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            const SizedBox(height: 4),
                            Text(
                                'Assigned to: ${task['assignedTo'] ?? 'Unassigned'}',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500)),
                            Text(
                                'Assigned by: ${task['assignedBy'] ?? 'Unknown'}',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text(
                              'Deadline: ${DateFormat.yMd().format((task['deadline'] as Timestamp).toDate())}',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Status: ${task['status']}',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'Edit') {
                              _showEditTaskDialog(context, task);
                            } else if (value == 'Delete') {
                              context.read<TaskBloc>().add(DeleteTask(task.id));
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'Edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'Delete',
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

            return const Center(child: Text('No tasks available'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDeadline;
    String? selectedDeveloper;
    String? selectedManager;
    String? selectedStatus;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              elevation: 10,
              backgroundColor: Colors.green.shade50,
              title: const Center(
                  child: Text(
                'Add New Task',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black),
              )),
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
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != selectedDeadline) {
                          setState(() {
                            selectedDeadline = picked;
                          });
                        }
                      },
                      child: Text(
                        selectedDeadline == null
                            ? 'Pick Deadline'
                            : 'Deadline: ${DateFormat.yMd().format(selectedDeadline!)}',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Add dropdowns for developer and manager if needed
                    // For demonstration, these fields are omitted

                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty &&
                            selectedStatus != null &&
                            selectedDeadline != null) {
                          final newTask = {
                            'name': nameController.text,
                            'description': descriptionController.text,
                            'status': selectedStatus,
                            'deadline': Timestamp.fromDate(selectedDeadline!),
                            'assignedTo': selectedDeveloper,
                            'assignedBy': selectedManager,
                          };

                          context.read<TaskBloc>().add(AddTask(newTask));
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Add Task'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditTaskDialog(BuildContext context, QueryDocumentSnapshot task) {
    final nameController = TextEditingController(text: task['name']);
    final descriptionController =
        TextEditingController(text: task['description']);
    DateTime? selectedDeadline = (task['deadline'] as Timestamp).toDate();
    String? selectedStatus = task['status'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              elevation: 10,
              backgroundColor: Colors.green.shade50,
              title: const Center(
                  child: Text(
                'Edit Task',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black),
              )),
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
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDeadline ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != selectedDeadline) {
                          setState(() {
                            selectedDeadline = picked;
                          });
                        }
                      },
                      child: Text(
                        selectedDeadline == null
                            ? 'Pick Deadline'
                            : 'Deadline: ${DateFormat.yMd().format(selectedDeadline!)}',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty &&
                            selectedStatus != null &&
                            selectedDeadline != null) {
                          final updatedTask = {
                            'name': nameController.text,
                            'description': descriptionController.text,
                            'status': selectedStatus,
                            'deadline': Timestamp.fromDate(selectedDeadline!),
                          };

                          context.read<TaskBloc>().add(
                                UpdateTask(task.id, updatedTask),
                              );
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Update Task'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
