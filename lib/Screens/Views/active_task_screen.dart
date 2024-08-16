import 'package:flutter/material.dart';

class ActiveTasksScreen extends StatelessWidget {
  final Stream<int> activeTasksStream;

  ActiveTasksScreen({required this.activeTasksStream});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Active Tasks'),
      ),
      body: StreamBuilder<int>(
        stream: activeTasksStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final count = snapshot.data ?? 0;

          return Center(
            child: Text(
              'Active Tasks: $count',
              style: TextStyle(fontSize: 24),
            ),
          );
        },
      ),
    );
  }
}
