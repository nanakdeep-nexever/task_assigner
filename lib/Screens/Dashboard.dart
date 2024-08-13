import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Column(
        children: [
          Expanded(
            child: Card(
              child: ListTile(
                title: Text('Overall Task Status'),
                subtitle: Text('Summary of tasks and projects'),
              ),
            ),
          ),
          // Add charts or graphs for performance metrics
        ],
      ),
    );
  }
}
