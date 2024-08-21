import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_assign_app/Screens/Views/check_role.dart';

import '../Blocs/Task_Management_BLoC/task_bloc.dart';
import '../Blocs/Task_Management_BLoC/task_event.dart';
import '../Blocs/Task_Management_BLoC/task_state.dart';
import '../Task_add.dart';
import '../model/Task_model.dart';

class ActiveTasksScreen extends StatelessWidget {
  const ActiveTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserRoleManager().init();
    String role = UserRoleManager().currentRole.toString();
    return Scaffold(
        body: BlocConsumer<TaskBloc, TaskState>(
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
                  // Build your task UI here
                },
              );
            } else {
              print("object Task");

              return StreamBuilder<List<Task>>(
                  stream: context.read<TaskBloc>().TasKStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('Error snapshot: ${snapshot.error}'));
                    }
                    final Tasks = snapshot.data ?? [];

                    return ListView.builder(
                      itemCount: Tasks.length ?? 1,
                      itemBuilder: (context, index) {
                        final task = Tasks[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.withOpacity(0.1),
                                  Colors.white
                                ],
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
                                "Task: ${task.name}",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Desc: ${task.description}",
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                      'Assigned to: ${task.assignedTo ?? 'Unassigned'}',
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500)),
                                  Text(
                                      'Assigned by: ${task.assignedBy ?? 'Unknown'}',
                                      style:
                                          const TextStyle(color: Colors.black)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Deadline: ${DateFormat.yMd().format(task.deadline)}',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  Text(
                                    'Status: ${task.status}',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'Edit') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              EditTaskPage(task: task)),
                                    );
                                  } else if (value == 'Delete') {
                                    context
                                        .read<TaskBloc>()
                                        .add(DeleteTaskEvent(taskId: task.id));
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
                  });
            }
          },
          listener: (BuildContext context, TaskState state) {
            if (state is TaskInitial) {
              context.read<TaskBloc>().add(LoadTasksEvent());
            }
          },
        ),
        floatingActionButton: role == 'admin' || role == 'manager'
            ? FloatingActionButton(
                backgroundColor: Colors.green,
                onPressed: () {
                  _showAddTaskDialog(context);
                },
                child: const Icon(Icons.add),
              )
            : null);
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
              backgroundColor: Colors.green.shade50,
              title: const Text('Add New Task'),
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
                    FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .where("role", isEqualTo: "manager")
                          .get(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text('No managers available');
                        }
                        final managers = snapshot.data!.docs;
                        return DropdownButton<String>(
                          hint: const Text('Assigned By (Manager)'),
                          value: selectedManager,
                          items: managers.map((doc) {
                            final manager = doc.data() as Map<String, dynamic>;
                            return DropdownMenuItem<String>(
                              value: manager['email'] as String?,
                              child: Text(
                                  manager['email'] as String? ?? 'Unknown'),
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
                    FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .where("role", isEqualTo: "developer")
                          .get(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text('No developers available');
                        }
                        final developers = snapshot.data!.docs;
                        return DropdownButton<String>(
                          hint: const Text('Assign to Developer'),
                          value: selectedDeveloper,
                          items: developers.map((doc) {
                            final developer =
                                doc.data() as Map<String, dynamic>;
                            return DropdownMenuItem<String>(
                              value: developer['email'] as String?,
                              child: Text(
                                  developer['email'] as String? ?? 'Unknown'),
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
                              initialDate: DateTime.now(),
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
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final newTask = {
                      'id': "SDSD",
                      'name': nameController.text,
                      'description': descriptionController.text,
                      'assignedTo': selectedDeveloper ?? 'Unassigned',
                      'assignedBy': selectedManager ?? 'Unknown',
                      'status': selectedStatus ?? 'Open',
                      'deadline': selectedDeadline ?? DateTime.now(),
                    };

                    // context
                    //     .read<TaskBloc>()
                    //     .add(CreateTaskEvent(taskData: newTask));

                    Navigator.of(context).pop();
                  },
                  child: const Text('Add Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    final nameController = TextEditingController(text: task.name);
    final descriptionController = TextEditingController(text: task.description);
    DateTime? selectedDeadline = task.deadline;
    String? selectedDeveloper = task.assignedTo;
    String? selectedManager = task.assignedBy;
    String? selectedStatus = task.status;

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
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
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
                    FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .where("role", isEqualTo: "manager")
                          .get(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text('No managers available');
                        }
                        final managers = snapshot.data!.docs;
                        return DropdownButton<String>(
                          hint: const Text('Assigned By (Manager)'),
                          value: selectedManager,
                          items: managers.map((doc) {
                            final manager = doc.data() as Map<String, dynamic>;
                            return DropdownMenuItem<String>(
                              value: manager['email'] as String?,
                              child: Text(
                                  manager['email'] as String? ?? 'Unknown'),
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
                    FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .where("role", isEqualTo: "developer")
                          .get(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text('No developers available');
                        }
                        final developers = snapshot.data!.docs;
                        return DropdownButton<String>(
                          hint: const Text('Assign to Developer'),
                          value: selectedDeveloper,
                          items: developers.map((doc) {
                            final developer =
                                doc.data() as Map<String, dynamic>;
                            return DropdownMenuItem<String>(
                              value: developer['email'] as String?,
                              child: Text(
                                  developer['email'] as String? ?? 'Unknown'),
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
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
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

                    // context.read<TaskBloc>().add(UpdateTaskEvent(
                    //     taskId: task.id, updatedTask: updatedTask));

                    Navigator.of(context).pop();
                  },
                  child: const Text('Update Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
