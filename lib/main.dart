import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'Screens/Dashboard.dart';
import 'Screens/Notification_page.dart';
import 'Screens/ProjectManagement_page.dart';
import 'Screens/Register.dart';
import 'Screens/Role_manage.dart';
import 'Screens/Taskmanagement.dart';
import 'Screens/User_managment.dart';
import 'Screens/login.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskAssignPro',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/dashboard': (context) => DashboardPage(),
        '/projects': (context) => ProjectManagementPage(),
        '/tasks': (context) => TaskManagementPage(),
        '/users': (context) => UserManagementPage(),
        '/roles': (context) => RoleManagementPage(),
        '/notifications': (context) => NotificationPage(),
      },
    );
  }
}
