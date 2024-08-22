import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_assign_app/Screens/editTask_page.dart';

import '../add_task.dart';
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
                    trailing: UserRoleManager().isViewer()
                        ? null
                        : PopupMenuButton<String>(
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
                                _deleteTask(context,
                                    task.id); // Pass context to _deleteTask
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
      floatingActionButton:
          UserRoleManager().isAdmin() || UserRoleManager().isManager()
              ? FloatingActionButton(
                  backgroundColor: Colors.green,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddTaskDialog()),
                    );
                  },
                  child: const Icon(Icons.add),
                )
              : null,
    );
  }

  // void _showAddTaskDialog(BuildContext context) {
  //   final nameController = TextEditingController();
  //   final descriptionController = TextEditingController();
  //   DateTime? selectedDeadline;
  //   String? selectedDeveloper;
  //   String? selectedManager;
  //   String? selectedStatus;
  //   String? selectedProjectId;
  //   Map<String, String> projectMap = {}; // To store project id and name
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
  //               child: Text(
  //                 'Add New Task',
  //                 style: TextStyle(
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.w700,
  //                     color: Colors.black),
  //               ),
  //             ),
  //             content: SingleChildScrollView(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   TextField(
  //                     controller: nameController,
  //                     decoration: const InputDecoration(labelText: 'Task Name'),
  //                   ),
  //                   TextField(
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
  //                   Text('Assigned By (Manager)'),
  //                   FutureBuilder<QuerySnapshot>(
  //                     future: FirebaseFirestore.instance
  //                         .collection('users')
  //                         .where("role", isEqualTo: "manager")
  //                         .get(),
  //                     builder: (context, snapshot) {
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
  //
  //                       final managers = snapshot.data!.docs
  //                           .map((doc) => (doc.data()
  //                               as Map<String, dynamic>)['email'] as String?)
  //                           .toSet()
  //                           .toList();
  //
  //                       if (selectedManager != null &&
  //                           !managers.contains(selectedManager)) {
  //                         selectedManager = null;
  //                       }
  //
  //                       return DropdownButton<String>(
  //                         value: selectedManager,
  //                         hint: const Text('Assigned By (Manager)'),
  //                         items: managers.map((email) {
  //                           return DropdownMenuItem<String>(
  //                             value: email,
  //                             child: Text(email ?? 'Unknown'),
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
  //                   Text('Assigned To (Developer)'),
  //                   FutureBuilder<QuerySnapshot>(
  //                     future: FirebaseFirestore.instance
  //                         .collection('users')
  //                         .where("role", isEqualTo: "developer")
  //                         .get(),
  //                     builder: (context, snapshot) {
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
  //
  //                       final developers = snapshot.data!.docs
  //                           .map((doc) => (doc.data()
  //                               as Map<String, dynamic>)['email'] as String?)
  //                           .toSet()
  //                           .toList();
  //
  //                       if (selectedDeveloper != null &&
  //                           !developers.contains(selectedDeveloper)) {
  //                         selectedDeveloper = null;
  //                       }
  //
  //                       return DropdownButton<String>(
  //                         value: selectedDeveloper,
  //                         hint: const Text('Assign to Developer'),
  //                         items: developers.map((email) {
  //                           return DropdownMenuItem<String>(
  //                             value: email,
  //                             child: Text(email ?? 'Unknown'),
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
  //                   Text('Select Project'),
  //                   FutureBuilder<QuerySnapshot>(
  //                     future: FirebaseFirestore.instance
  //                         .collection('projects')
  //                         .get(),
  //                     builder: (context, snapshot) {
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
  //                         return const Text('No projects available');
  //                       }
  //
  //                       final projects = snapshot.data!.docs.map((doc) {
  //                         final data = doc.data() as Map<String, dynamic>;
  //                         final id = doc.id;
  //                         final name = data['name'] ?? 'Unknown';
  //                         return MapEntry(id, name);
  //                       }).toList();
  //
  //                       projectMap = {
  //                         for (var entry in projects) entry.key: entry.value
  //                       };
  //
  //                       return DropdownButton<String>(
  //                         value: projectMap.containsKey(selectedProjectId)
  //                             ? selectedProjectId
  //                             : null,
  //                         hint: const Text('Select Project'),
  //                         items: projectMap.entries.map((entry) {
  //                           return DropdownMenuItem<String>(
  //                             value: entry.key,
  //                             child: Text(entry.value),
  //                           );
  //                         }).toList(),
  //                         onChanged: (value) {
  //                           setState(() {
  //                             selectedProjectId = value;
  //                           });
  //                         },
  //                       );
  //                     },
  //                   ),
  //                   const SizedBox(height: 16),
  //                   Text('Date & Time'),
  //                   _buildDeadlineField(selectedDeadline, setState, context),
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
  //                 onPressed: () async {
  //                   String? Fcm;
  //                   String? Fcm_manager;
  //                   String? uid =
  //                       await getDocumentIdByEmail(selectedDeveloper ?? '');
  //                   String? uid_manager =
  //                       await getDocumentIdByEmail(selectedManager ?? '');
  //                   final newTask = {
  //                     'name': nameController.text,
  //                     'description': descriptionController.text,
  //                     'assignedTo': selectedDeveloper ?? 'Unassigned',
  //                     'assignedBy': selectedManager ?? 'Unknown',
  //                     'status': selectedStatus ?? 'Open',
  //                     'deadline': selectedDeadline ?? Timestamp.now(),
  //                     'Project_id': selectedProjectId ?? '',
  //                   };
  //
  //                   FirebaseFirestore.instance
  //                       .collection('tasks')
  //                       .add(newTask)
  //                       .then((_) async {
  //                     if (uid != null || uid_manager != null) {
  //                       if (isManager() || isAdmin()) {
  //                         final snapshot = await FirebaseFirestore.instance
  //                             .collection('users')
  //                             .doc(uid)
  //                             .get();
  //                         if (snapshot.exists) {
  //                           Fcm = snapshot.get('FCM-token');
  //                           if (Fcm != null) {
  //                             NotificationHandler.sendNotification(
  //                                 FCM_token: Fcm.toString(),
  //                                 title: "Task Updated: ${nameController.text}",
  //                                 body:
  //                                     "Deadline: ${selectedDeadline.toString()}, Assigned By: ${selectedManager}");
  //                           }
  //                         }
  //                       } else if (isDeveloper()) {
  //                         final snapshot = await FirebaseFirestore.instance
  //                             .collection('users')
  //                             .doc(uid_manager)
  //                             .get();
  //                         if (snapshot.exists) {
  //                           Fcm_manager = snapshot.get('FCM-token');
  //                           if (Fcm_manager != null) {
  //                             NotificationHandler.sendNotification(
  //                                 FCM_token: Fcm_manager.toString(),
  //                                 title: "Task : ${nameController.text}",
  //                                 body:
  //                                     "Status $selectedStatus Updated By $selectedDeveloper");
  //                           }
  //                         }
  //                       }
  //                     }
  //                     Navigator.of(context).pop();
  //                   }).catchError((error) {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(
  //                         content: Text('Failed to add task: $error'),
  //                       ),
  //                     );
  //                   });
  //                 },
  //                 child: const Text(
  //                   'Add Task',
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

  Widget _buildDeadlineField(
      DateTime? selectedDeadline, StateSetter setState, BuildContext context) {
    return TextField(
      controller: TextEditingController(
        text: selectedDeadline != null
            ? DateFormat('yyyy-MM-dd HH:mm').format(selectedDeadline)
            : '',
      ),
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

  // void _showAddTaskDialog(BuildContext context) {
  //   final nameController = TextEditingController();
  //   final descriptionController = TextEditingController();
  //   DateTime? selectedDeadline;
  //   String? selectedDeveloper;
  //   String? selectedManager;
  //   String? selectedStatus;
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
  //               'Add New Task',
  //               style: TextStyle(
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.w700,
  //                   color: Colors.black),
  //             )),
  //             content: SingleChildScrollView(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   TextField(
  //                     controller: nameController,
  //                     decoration: const InputDecoration(labelText: 'Task Name'),
  //                   ),
  //                   TextField(
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
  //                             initialDate: DateTime.now(),
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
  //                   final newTask = {
  //                     'id': DateTime.now().toString(),
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
  //                       .add(newTask)
  //                       .catchError((error) {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(content: Text('Failed to add task: $error')),
  //                     );
  //                   });
  //
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: const Text(
  //                   'Add Task',
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
}
