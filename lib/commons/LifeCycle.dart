import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_assign_app/generated/Strings_s.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        // App is in the foreground
        print("App is in the foreground");
        _updateUserStatus(userId, true);
        break;
      case AppLifecycleState.paused:
        // App is in the background
        print("App is in the background");
        _updateUserStatus(userId, false);
        break;
      case AppLifecycleState.inactive:
        // App is inactive (e.g., during a phone call)
        print("App is inactive");
        _updateUserStatus(userId, false);
        break;
      case AppLifecycleState.detached:
        // App is detached from the view hierarchy
        print("App is detached");
        _updateUserStatus(userId, false);
        break;
      case AppLifecycleState.hidden:
        print("App is hidden");
        _updateUserStatus(userId, false);
        break;
    }
  }

  void _updateUserStatus(String userId, bool isOnline) {
    _firestore
        .collection(Com_string.Firebase_collection_users)
        .doc(userId)
        .update({
      Com_string.Status_online: isOnline,
    }).catchError((error) {
      print("Failed to update user status: $error");
    });
  }
}
