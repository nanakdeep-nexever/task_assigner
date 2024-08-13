import 'package:flutter/material.dart';

class ProjectManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Project Management')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Project A'),
            subtitle: Text('Description of Project A'),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Handle project edit
              },
            ),
          ),
          // Add more projects as necessary
        ],
      ),
    );
  }
}
