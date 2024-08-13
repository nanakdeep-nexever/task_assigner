import 'package:flutter/material.dart';

class UserManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Management')),
      body: ListView(
        children: [
          ListTile(
            title: Text('John Doe'),
            subtitle: Text('Role: Developer'),
            trailing: IconButton(
              icon: Icon(Icons.edit),
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
