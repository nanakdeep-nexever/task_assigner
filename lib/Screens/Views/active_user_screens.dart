import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_assign_app/Screens/Notification_Handle/Notification_Handle.dart';
import 'package:task_assign_app/Screens/Views/check_role.dart';
import 'package:task_assign_app/Screens/Views/create%20_user.dart';

import 'edit_profile_screen.dart';

class ActiveUsersScreen extends StatelessWidget {
  ActiveUsersScreen({super.key});
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _confirmDeleteUser(BuildContext context, String uid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue.shade50,
          elevation: 10,
          title: const Center(
              child: Text(
            'Confirm Deletion',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: Colors.black, fontSize: 20),
          )),
          content: const Text(
            'Are you sure you want to delete this user?',
            style: TextStyle(
                fontWeight: FontWeight.w400, color: Colors.black, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteUser(context, uid);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(BuildContext context, String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e')),
      );
    }
  }

  void _updateUserRole(BuildContext context, String uid, String newRole) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': newRole,
      });
      final snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (snapshot.exists) {
        String fcmManager = snapshot.get('FCM-token');
        if (fcmManager.isNotEmpty) {
          NotificationHandler.sendNotification(
              FCM_token: fcmManager.toString(),
              title: "Role Changed",
              body:
                  "New Role $newRole Updated By ${FirebaseAuth.instance.currentUser?.email}");
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error updating role: $e')));
    }
  }

  void _showCreateUserDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'viewer';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 10,
          backgroundColor: Colors.blue.shade50,
          title: const Center(
              child: Text(
            'Create User',
            style: TextStyle(
                fontWeight: FontWeight.w500, fontSize: 20, color: Colors.black),
          )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: ['admin', 'manager', 'developer', 'viewer']
                    .map((role) => DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (newValue) {
                  selectedRole = newValue!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () async {
                final email = emailController.text;
                final password = passwordController.text;

                if (email.isNotEmpty && password.isNotEmpty) {
                  try {
                    UserCredential userCredential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                            email: email, password: password);

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userCredential.user?.uid)
                        .set({
                      'email': email,
                      'role': selectedRole,
                      'status_online': 'false'
                    });

                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('User created successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error creating user: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: const Text(
                'Create User',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRoleChangeConfirmationDialog(
      BuildContext context, String uid, String currentRole) {
    if (currentRole == 'admin') {
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 10,
          backgroundColor: Colors.blue.shade50,
          title: const Center(
              child: Text(
            'Confirm Role Change',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          )),
          content: const Text(
            'Are you sure you want to edit the role?',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w400, fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _showRoleChangeDialog(context, uid, currentRole);
              },
              child: const Text(
                'Yes',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRoleChangeDialog(
      BuildContext context, String uid, String currentRole) {
    final List<String> roles = ['manager', 'developer', 'viewer'];

    String selectedRole =
        roles.contains(currentRole) ? currentRole : roles.first;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 10,
          backgroundColor: Colors.blue.shade50,
          title: const Center(child: Text('Change Role')),
          content: DropdownButtonFormField<String>(
            value: selectedRole,
            decoration: const InputDecoration(labelText: 'Role'),
            items: roles
                .map((role) => DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    ))
                .toList(),
            onChanged: (newValue) {
              selectedRole = newValue!;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style:
                    TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                if (selectedRole != currentRole) {
                  _updateUserRole(context, uid, selectedRole);
                }
                Navigator.of(context).pop();
              },
              child: const Text(
                'Update Role',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Active Users',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
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
              final role = user["role"];
              final img = user["profileImageUrl"] ?? "";
              final name = user["firstName"] ?? "Unknown";
              final lastName = user["lastName"] ?? "Unknown";
              final phone = user["phoneNumber"] ?? "Unknown";

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.withOpacity(0.1), Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(img),
                      backgroundColor: Colors.grey,
                      child: Text(""),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Name: ${name ?? "unknown"}",
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                        Text(
                          "Email: $email",
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      "Role: $role",
                      style: const TextStyle(
                          fontWeight: FontWeight.w400, color: Colors.black),
                    ),
                    trailing: isAdmin()
                        ? PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditUserScreen(
                                              uid: uid,
                                              initialFirstName: name,
                                              initialLastName: lastName,
                                              initialPhoneNumber: phone,
                                              initialProfileImageUrl: img,
                                            )));
                              } else if (value == 'delete') {
                                _confirmDeleteUser(context, uid);
                              } else if (value == 'role') {
                                _showRoleChangeConfirmationDialog(
                                    context, uid, role);
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'role',
                                child: Text('Edit role'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isAdmin()
          ? FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CreateUserPage()));
              },
              child: const Icon(
                Icons.add,
                size: 30,
              ),
            )
          : null,
    );
  }

  bool isAdmin() {
    UserRoleManager().init();
    String role = UserRoleManager().currentRole.toString();
    if (role == 'admin') {
      return true;
    } else {
      return false;
    }
  }
}
