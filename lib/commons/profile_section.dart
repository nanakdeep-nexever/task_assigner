import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Blocs/AUTHentication/authentication_bloc.dart';
import '../Blocs/AUTHentication/authentication_event.dart';
import '../Screens/Views/check_role.dart';

class ProfileSection extends StatelessWidget {
  final String heading;

  const ProfileSection({super.key, required this.heading});

  @override
  Widget build(BuildContext context) {
    UserRoleManager().init();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          heading,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance.collection('users').doc(userId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('No user data found'));
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final String uName = userData['firstName'] ?? 'Guest';
            final String email = userData['email'] ?? 'guest@example.com';
            final String img = userData['profileImageUrl'] ?? '';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            img.isNotEmpty ? NetworkImage(img) : null,
                        radius: 50,
                        child: img.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        uName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                commonHeading("Profile"),
                const SizedBox(
                  height: 14,
                ),
                commonTiles("Complete Profile", Icons.person, () {
                  Navigator.pushNamed(context, "/completeProfile");
                }),
                /*        const SizedBox(
                  height: 14,
                ),
                commonTiles("Edit Profile", Icons.edit, () {
                  Navigator.pushNamed(context, "/completeProfile");
                }),*/
                const SizedBox(
                  height: 14,
                ),
                commonTiles(
                    "Terms & Conditions", Icons.indeterminate_check_box, () {}),
                const SizedBox(
                  height: 14,
                ),
                commonTiles("Privacy and Policy", Icons.privacy_tip, () {}),
                const SizedBox(
                  height: 14,
                ),
                commonTiles("Contact Us", Icons.indeterminate_check_box, () {}),
                UserRoleManager().isAdmin()
                    ? const SizedBox(
                        height: 0,
                      )
                    : const SizedBox(
                        height: 14,
                      ),
                UserRoleManager().isAdmin()
                    ? SizedBox()
                    : commonTiles("Delete Account", Icons.delete, () {
                        showDeleteAccountDialog(
                          "Delete Account",
                          "Are you sure you want to delete this account? This action cannot be undone.",
                          "Delete",
                          context,
                          () {
                            if (userId != null) {
                              context
                                  .read<AuthenticationBloc>()
                                  .add(DeleteAccountEvent(userId));
                            }
                          },
                        );
                      }),
                const SizedBox(
                  height: 14,
                ),
                commonTiles("Log out", Icons.logout_outlined, () {
                  showDeleteAccountDialog(
                      "Log Out",
                      "Are you sure you want to Logout?",
                      "Logout",
                      context, () {
                    context.read<AuthenticationBloc>().add(LogoutEvent());
                  });
                }),
                const SizedBox(
                  height: 30,
                ),
                const Center(
                  child: Column(
                    children: [
                      Text(
                        "version 1.0.1",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text(
                        "Powered by - Task Assign Pro",
                        style: TextStyle(fontSize: 8, color: Colors.grey),
                      )
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget commonHeading(String heading) {
    return Column(
      children: [
        Text(
          heading,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.black,
            fontSize: 20,
          ),
        )
      ],
    );
  }

  Widget commonTiles(String heading, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 1,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 24,
              color: Colors.black,
            ),
            const SizedBox(width: 10),
            Text(
              heading,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showDeleteAccountDialog(String title, String content,
      String confirm, BuildContext context, VoidCallback onConfirm) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          content: Text(
            content,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text(
                confirm,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm(); // Execute the delete action
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: Colors.white,
          elevation: 5,
        );
      },
    );
  }
}
