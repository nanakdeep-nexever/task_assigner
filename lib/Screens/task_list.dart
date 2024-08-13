import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tasks')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No tasks available.'));
          }
          var tasks = snapshot.data?.docs;
          return ListView.builder(
            itemCount: tasks?.length,
            itemBuilder: (context, index) {
              var task = tasks?[index];
              return ListTile(
                title: Text(task?['name']),
                subtitle: Text(task?['description']),
              );
            },
          );
        },
      ),
    );
  }
}
