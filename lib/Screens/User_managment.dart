import 'package:flutter/material.dart';

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('John Doe'),
            subtitle: const Text('Role: Developer'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Handle user edit
              },
            ),
          ),
          // Add more users as necessary
        ],
      ),
    );
  }
}
