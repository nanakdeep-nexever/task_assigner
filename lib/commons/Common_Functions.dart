import 'package:cloud_firestore/cloud_firestore.dart';

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
          .collection('users')
          .doc(managerId)
          .get();

      if (managerDoc.exists) {
        return managerDoc.get('email') as String?;
      } else {
        return 'No email found'; // Or handle as needed
      }
    } catch (e) {
      return 'Unassigned Manager'; // Or handle as needed
    }
  }
}
