import 'package:flutter/material.dart';

class TaskManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Management')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Task 1'),
            subtitle: Text('Assigned to Developer A'),
            trailing: IconButton(
              icon: Icon(Icons.edit),
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
