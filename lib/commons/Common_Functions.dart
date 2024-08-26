import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../generated/Strings_s.dart';

class Common_function {
  Common_function._();

  ///Check Date
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  static bool isPassed(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Get Manager Email From UID
  static Future<String?> getManagerEmail(String managerId) async {
    try {
      DocumentSnapshot managerDoc = await FirebaseFirestore.instance
          .collection(Com_string.Firebase_collection_users)
          .doc(managerId)
          .get();

      if (managerDoc.exists) {
        return managerDoc.get(Com_string.email) as String?;
      } else {
        return 'No email found'; // Or handle as needed
      }
    } catch (e) {
      return 'Unassigned Manager'; // Or handle as needed
    }
  }

  static snack(BuildContext context, String msg) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
