import 'package:flutter/material.dart';

class RoleManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Role Management')),
      body: ListView(
        children: [
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
