import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_assign_app/Screens/Views/check_role.dart';
import 'package:task_assign_app/Screens/editTask_page.dart';

class ActiveTasksScreen extends StatelessWidget {
  ActiveTasksScreen({super.key});

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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
        builder: (context, snapshot) {
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
              return TaskCard(
                task: task,
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskPage(task: task),
                    ),
                  );
                },
                onDelete: () => _deleteTask(context, task.id),
              );
            },
          );
        },
      ),
      floatingActionButton: _shouldShowAddButton()
          ? FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TaskPage()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  bool _shouldShowAddButton() {
    final userRoleManager = UserRoleManager();
    return userRoleManager.isAdmin() || userRoleManager.isManager();
  }

  Future<void> _deleteTask(BuildContext context, String taskId) async {
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
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this task?',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('tasks')
                      .doc(taskId)
                      .delete();
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete task: $error')),
                  );
                } finally {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Delete',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 20)),
            ),
          ],
        );
      },
    );
  }
}

class TaskCard extends StatelessWidget {
  final QueryDocumentSnapshot task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final deadline = (task['deadline'] as Timestamp).toDate();
    final isDeadlineToday = _isToday(deadline);
    final isDeadlinePassed = _isPassed(deadline);
    final status = task['status'] ?? '';

    // Determine the text color for the deadline
    final deadlineTextColor =
        isDeadlinePassed && !['Completed', 'Cancelled'].contains(status)
            ? Colors.red
            : Colors.black;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
              "${task.reference.id}",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          title: Text(
            "Task: ${task['name']}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    color: Colors.black, fontWeight: FontWeight.w500),
              ),
              Text(
                'Assigned by: ${task['assignedBy'] ?? 'Unknown'}',
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Deadline: ${DateFormat.yMd().format(deadline)} ${isDeadlineToday ? DateFormat.Hm().format(deadline) : ''}',
                      style: TextStyle(
                        color: deadlineTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isDeadlinePassed &&
                      !['Completed', 'Cancelled'].contains(status))
                    Icon(
                      Icons.notifications_active,
                      color: Colors.red,
                    ),
                ],
              ),
              Text(
                'Status: $status',
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
                      onEdit();
                    } else if (value == 'Delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'Edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'Delete', child: Text('Delete')),
                  ],
                ),
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  bool _isPassed(DateTime date) {
    return date.isBefore(DateTime.now());
  }
}
