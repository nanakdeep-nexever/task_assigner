import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        children: const [
          ListTile(
            title: Text('Task Assignment'),
            subtitle: Text('You have been assigned a new task.'),
          ),
          // Add more notifications as necessary
        ],
      ),
    );
  }
}
