import 'package:flutter/material.dart';

class ActiveProjectsScreen extends StatelessWidget {
  final Stream<int> activeProjectsStream;

  const ActiveProjectsScreen({super.key, required this.activeProjectsStream});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Projects'),
      ),
      body: StreamBuilder<int>(
        stream: activeProjectsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final count = snapshot.data ?? 0;

          return Center(
            child: Text(
              'Active Projects: $count',
              style: const TextStyle(fontSize: 24),
            ),
          );
        },
      ),
    );
  }
}
