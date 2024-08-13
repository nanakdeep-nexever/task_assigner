import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ViewerPage extends StatefulWidget {
  @override
  State<ViewerPage> createState() => _ViewerPageState();
}

class _ViewerPageState extends State<ViewerPage> {
  FirebaseFirestore _firestoretore = FirebaseFirestore.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _firestoretore
        .collection('unassigned_users')
        .doc(_firebaseAuth.currentUser?.email.toString())
        .set({'uid': _firebaseAuth.currentUser?.uid.toString()});
    _firestoretore
        .collection('users')
        .doc(_firebaseAuth.currentUser?.uid.toString())
        .set({
      'email': _firebaseAuth.currentUser?.email.toString(),
      'role': 'viewer'
    });
  }

  @override
  Widget build(BuildContext context) {
    String? email = ModalRoute.of(context)?.settings.arguments.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text('Viewer Dashboard'),
      ),
      body: Center(
        child: Text('Viewer Page $email'),
      ),
    );
  }
}
