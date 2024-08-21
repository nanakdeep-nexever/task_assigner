import 'package:flutter/material.dart';

class RoleManagementPage extends StatelessWidget {
  const RoleManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Role Management')),
      body: ListView(
        children: const [
          ListTile(
            title: Text('Admin'),
            subtitle: Text('Full access to all features.'),
          ),
          ListTile(
            title: Text('Manager'),
            subtitle: Text('Can create and manage projects.'),
          ),
          // Add more roles as necessary
        ],
      ),
    );
  }
}
