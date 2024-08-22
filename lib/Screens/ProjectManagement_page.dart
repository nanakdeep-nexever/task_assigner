import 'package:flutter/material.dart';

class ProjectManagementPage extends StatelessWidget {
  const ProjectManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project Management')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Project A'),
            subtitle: const Text('Description of Project A'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
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
