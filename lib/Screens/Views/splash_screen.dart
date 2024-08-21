import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? role;
  void _fetchrole() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    if (doc.exists) {
      setState(() {
        role = doc.get('role') ?? '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchrole();
    if (role != null || role.toString().isNotEmpty) {
      Timer(
        const Duration(seconds: 3),
        () {
          _navigateToNextScreen(role!);
        },
      );
    }
  }

  Future<void> _navigateToNextScreen(String role) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (role.isEmpty || user == null) {
      Navigator.pushReplacementNamed(context, '/');
    } else if (role == "admin") {
      Navigator.pushReplacementNamed(context, "/admin");
    } else if (role == "manager") {
      Navigator.pushReplacementNamed(context, "/manager");
    } else if (role == "developer") {
      Navigator.pushReplacementNamed(context, "/developer");
    } else if (role == "viewer") {
      Navigator.pushReplacementNamed(context, "/viewer");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/spl2.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
