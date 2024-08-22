import 'package:flutter/material.dart';

class TaskManagementPage extends StatelessWidget {
  const TaskManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Management')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Task 1'),
            subtitle: const Text('Assigned to Developer A'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Handle task edit
              },
            ),
          ),
          // Add more tasks as necessary
        ],
      ),
    );
  }
}
