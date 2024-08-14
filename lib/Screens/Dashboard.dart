import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    String? uid = ModalRoute.of(context)?.settings.arguments.toString();
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Card(
              child: ListTile(
                title: Text('Overall Task Status $uid'),
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
