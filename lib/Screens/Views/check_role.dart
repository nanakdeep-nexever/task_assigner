import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRoleManager {
  static final UserRoleManager _instance = UserRoleManager._internal();

  // Private constructor
  UserRoleManager._internal();

  // Factory constructor
  factory UserRoleManager() {
    return _instance;
  }

  // Firebase Auth and Firestore instances
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // StreamController to broadcast role updates
  final StreamController<String?> _roleController =
      StreamController<String?>.broadcast();

  // Getter for the role stream
  Stream<String?> get roleStream => _roleController.stream;

  // Current user role
  String? _currentRole;

  // Getter for current user role
  String? get currentRole => _currentRole;

  // Initialize and start listening to user role changes
  void init() {
    String? uid = _firebaseAuth.currentUser?.uid;

    if (uid != null) {
      _firestore.collection('users').doc(uid).snapshots().listen((snapshot) {
        print(snapshot);
        if (snapshot.exists) {
          _currentRole = snapshot.data()?['role'] as String?;
          _roleController.add(_currentRole);
        } else {
          _currentRole = null;
          _roleController.add(null);
        }
      });
    }
  }

  bool isViewer() {
    String role = currentRole.toString();
    return role == 'viewer';
  }

  bool isManager() {
    String role = currentRole.toString();
    return role == 'manager';
  }

  bool isAdmin() {
    String role = currentRole.toString();
    if (role == 'admin') {
      return true;
    } else {
      return false;
    }
  }

  // Dispose the StreamController when not needed
  void dispose() {
    _roleController.close();
  }
}
