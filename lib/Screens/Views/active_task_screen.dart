import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_assign_app/Screens/editTask_page.dart';

import 'check_role.dart';

class ActiveTasksScreen extends StatelessWidget {
  final Stream<int> activeTasksStream;

  const ActiveTasksScreen({super.key, required this.activeTasksStream});

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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tasks available'));
          }

          final tasks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                        Text('Assigned by: ${task['assignedBy'] ?? 'Unknown'}',
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text(
                          'Deadline: ${DateFormat.yMd().format((task['deadline'] as Timestamp).toDate())}',
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Status: ${task['status']}',
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'Edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditTaskPage(
                                task: task,
                              ),
                            ),
                          );
                        } else if (value == 'Delete') {
                          _deleteTask(
                              context, task.id); // Pass context to _deleteTask
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
        },
      ),
      floatingActionButton: isAdmin()
          ? FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () => _showAddTaskDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
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
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final newTask = {
                      'id': DateTime.now().toString(),
                      'name': nameController.text,
                      'description': descriptionController.text,
                      'assignedTo': selectedDeveloper ?? 'Unassigned',
                      'assignedBy': selectedManager ?? 'Unknown',
                      'status': selectedStatus ?? 'Open', // Add status
                      'deadline': selectedDeadline ?? DateTime.now(),
                    };

                    FirebaseFirestore.instance
                        .collection('tasks')
                        .add(newTask)
                        .catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add task: $error')),
                      );
                    });

                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Add Task',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // void _showEditTaskDialog(BuildContext context, QueryDocumentSnapshot task) {
  //   final nameController = TextEditingController(text: task['name']);
  //   final descriptionController =
  //       TextEditingController(text: task['description']);
  //   DateTime? selectedDeadline = (task['deadline'] as Timestamp).toDate();
  //   String? selectedDeveloper = task['assignedTo'];
  //   String? selectedManager = task['assignedBy'];
  //   String? selectedStatus = task['status'];
  //
  //   bool isDeveloper() {
  //     UserRoleManager().init();
  //     String role = UserRoleManager().currentRole.toString();
  //     if (role == 'developer') {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   }
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return AlertDialog(
  //             elevation: 10,
  //             backgroundColor: Colors.green.shade50,
  //             title: const Center(
  //                 child: Text(
  //               'Edit Task',
  //               style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.w500,
  //                   color: Colors.black),
  //             )),
  //             content: SingleChildScrollView(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   TextField(
  //                     enabled: isDeveloper() ? false : true,
  //                     controller: nameController,
  //                     decoration: const InputDecoration(labelText: 'Task Name'),
  //                   ),
  //                   TextField(
  //                     enabled: isDeveloper() ? false : true,
  //                     controller: descriptionController,
  //                     decoration:
  //                         const InputDecoration(labelText: 'Task Description'),
  //                   ),
  //                   const SizedBox(height: 16),
  //                   DropdownButton<String>(
  //                     hint: const Text('Select Status'),
  //                     value: selectedStatus,
  //                     items: ['Open', 'In Progress', 'Completed']
  //                         .map((status) => DropdownMenuItem<String>(
  //                               value: status,
  //                               child: Text(status),
  //                             ))
  //                         .toList(),
  //                     onChanged: (value) {
  //                       setState(() {
  //                         selectedStatus = value;
  //                       });
  //                     },
  //                   ),
  //                   const SizedBox(height: 16),
  //                   FutureBuilder(
  //                     future: FirebaseFirestore.instance
  //                         .collection('users')
  //                         .where("role", isEqualTo: "manager")
  //                         .get(),
  //                     builder:
  //                         (context, AsyncSnapshot<QuerySnapshot> snapshot) {
  //                       if (snapshot.connectionState ==
  //                           ConnectionState.waiting) {
  //                         return const Center(
  //                             child: CircularProgressIndicator());
  //                       }
  //                       if (snapshot.hasError) {
  //                         return Center(
  //                             child: Text('Error: ${snapshot.error}'));
  //                       }
  //                       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
  //                         return const Text('No managers available');
  //                       }
  //                       final managers = snapshot.data!.docs;
  //                       return DropdownButton<String>(
  //                         hint: const Text('Assigned By (Manager)'),
  //                         value: selectedManager,
  //                         items: managers.map((doc) {
  //                           final manager = doc.data() as Map<String, dynamic>;
  //                           return DropdownMenuItem<String>(
  //                             value: manager['email'] as String?,
  //                             child: Text(
  //                                 manager['email'] as String? ?? 'Unknown'),
  //                           );
  //                         }).toList(),
  //                         onChanged: (value) {
  //                           setState(() {
  //                             selectedManager = value;
  //                           });
  //                         },
  //                       );
  //                     },
  //                   ),
  //                   const SizedBox(height: 16),
  //                   FutureBuilder(
  //                     future: FirebaseFirestore.instance
  //                         .collection('users')
  //                         .where("role", isEqualTo: "developer")
  //                         .get(),
  //                     builder:
  //                         (context, AsyncSnapshot<QuerySnapshot> snapshot) {
  //                       if (snapshot.connectionState ==
  //                           ConnectionState.waiting) {
  //                         return const Center(
  //                             child: CircularProgressIndicator());
  //                       }
  //                       if (snapshot.hasError) {
  //                         return Center(
  //                             child: Text('Error: ${snapshot.error}'));
  //                       }
  //                       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
  //                         return const Text('No developers available');
  //                       }
  //                       final developers = snapshot.data!.docs;
  //                       return DropdownButton<String>(
  //                         hint: const Text('Assign to Developer'),
  //                         value: selectedDeveloper,
  //                         items: developers.map((doc) {
  //                           final developer =
  //                               doc.data() as Map<String, dynamic>;
  //                           return DropdownMenuItem<String>(
  //                             value: developer['email'] as String?,
  //                             child: Text(
  //                                 developer['email'] as String? ?? 'Unknown'),
  //                           );
  //                         }).toList(),
  //                         onChanged: (value) {
  //                           setState(() {
  //                             selectedDeveloper = value;
  //                           });
  //                         },
  //                       );
  //                     },
  //                   ),
  //                   const SizedBox(height: 16),
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: Text(
  //                           selectedDeadline == null
  //                               ? 'Select Deadline'
  //                               : DateFormat.yMd().format(selectedDeadline!),
  //                         ),
  //                       ),
  //                       IconButton(
  //                         icon: const Icon(Icons.calendar_today),
  //                         onPressed: () async {
  //                           final pickedDate = await showDatePicker(
  //                             context: context,
  //                             initialDate: selectedDeadline ?? DateTime.now(),
  //                             firstDate: DateTime.now(),
  //                             lastDate: DateTime(2100),
  //                           );
  //                           if (pickedDate != null) {
  //                             setState(() {
  //                               selectedDeadline = pickedDate;
  //                             });
  //                           }
  //                         },
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.of(context).pop(),
  //                 child: const Text(
  //                   'Cancel',
  //                   style: TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w500,
  //                       color: Colors.black),
  //                 ),
  //               ),
  //               TextButton(
  //                 onPressed: () {
  //                   final updatedTask = {
  //                     'name': nameController.text,
  //                     'description': descriptionController.text,
  //                     'assignedTo': selectedDeveloper ?? 'Unassigned',
  //                     'assignedBy': selectedManager ?? 'Unknown',
  //                     'status': selectedStatus ?? 'Open', // Add status
  //                     'deadline': selectedDeadline ?? DateTime.now(),
  //                   };
  //
  //                   FirebaseFirestore.instance
  //                       .collection('tasks')
  //                       .doc(task.id)
  //                       .update(updatedTask)
  //                       .catchError((error) {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(
  //                           content: Text('Failed to update task: $error')),
  //                     );
  //                   });
  //
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: const Text(
  //                   'Update Task',
  //                   style: TextStyle(
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.w600,
  //                       color: Colors.black),
  //                 ),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  void _deleteTask(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          elevation: 10,
          backgroundColor: Colors.green.shade50,
          title: const Center(
              child: Text(
            'Delete Task',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
          )),
          content: const Text(
            'Are you sure you want to delete this task?',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(taskId)
                    .delete()
                    .catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete task: $error')),
                  );
                });

                Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 20),
              ),
            ),
          ],
        );
      },
    );
  }

  bool isAdmin() {
    UserRoleManager().init();
    String role = UserRoleManager().currentRole.toString();
    if (role == 'admin') {
      return true;
    } else {
      return false;
    }
  }
}
