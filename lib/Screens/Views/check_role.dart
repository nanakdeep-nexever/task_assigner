import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../generated/Strings_s.dart';

class UserRoleManager {
  static final UserRoleManager _instance = UserRoleManager._internal();

  UserRoleManager._internal();

  factory UserRoleManager() {
    return _instance;
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final StreamController<String?> _roleController =
      StreamController<String?>.broadcast();

  Stream<String?> get roleStream => _roleController.stream;

  String? _currentRole;

  String? get currentRole => _currentRole;

  void init() {
    String? uid = _firebaseAuth.currentUser?.uid;

    if (uid != null) {
      _firestore
          .collection(Com_string.Firebase_collection_users)
          .doc(uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          _currentRole = snapshot.data()?[Com_string.role] as String?;
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
    return role == Com_string.Role_viewer;
  }

  bool isDeveloper() {
    String role = currentRole.toString();
    return role == Com_string.Role_developer;
  }

  bool isManager() {
    String role = currentRole.toString();
    return role == Com_string.Role_manager;
  }

  bool isAdmin() {
    String role = currentRole.toString();
    return role == 'admin';
  }

  void dispose() {
    _roleController.close();
  }
}
