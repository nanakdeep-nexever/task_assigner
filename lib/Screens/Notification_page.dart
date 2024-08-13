import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: ListView(
        children: [
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
