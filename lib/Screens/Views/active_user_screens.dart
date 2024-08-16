import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ActiveUsersScreen extends StatelessWidget {
  final Stream<QuerySnapshot> activeUsersStream;

  ActiveUsersScreen({required this.activeUsersStream});

  void _showEditDeleteOptions(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _editUser(context, uid);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _deleteUser(context, uid);
              },
            ),
          ],
        );
      },
    );
  }

  void _editUser(BuildContext context, String uid) {
    // Implement your edit functionality here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit user $uid')),
    );
  }

  void _deleteUser(BuildContext context, String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User $uid deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("---active-users-stream---$activeUsersStream");

    return Scaffold(
      appBar: AppBar(
        title: Text('Active Users'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Stream error: ${snapshot.error}'); // Debug print
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
            return const Center(child: Text('No active users found.'));
          }

          final users = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final uid = user.id;
              final email = user['email'] ?? 'No Email';

              return Card(
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text("${index + 1}"),
                  ),
                  title: Text(email),
                  subtitle: Text('User ID: $uid'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editUser(context, uid);
                      } else if (value == 'delete') {
                        _deleteUser(context, uid);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
