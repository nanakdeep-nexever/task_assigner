import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_bloc.dart';
import 'package:task_assign_app/Blocs/Management_bloc/management_bloc.dart';
import 'package:task_assign_app/Blocs/Notification_bloc/notification_bloc.dart';
import 'package:task_assign_app/Screens/Views/Admin.dart';
import 'package:task_assign_app/Screens/Views/Devloper_view.dart';
import 'package:task_assign_app/Screens/Views/Manager_view.dart';
import 'package:task_assign_app/Screens/Views/viewer_view.dart';

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
  //
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthenticationBloc(),
        ),
        BlocProvider(
          create: (context) => UserBloc(),
        ),
        BlocProvider(
          create: (context) => NotificationBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'TaskAssignPro',
        initialRoute: '/',
        routes: {
          '/': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/admin': (context) => AdminPage(),
          '/manager': (context) => ManagerPage(),
          '/developer': (context) => DeveloperPage(),
          '/viewer': (context) => ViewerPage(),
          '/dashboard': (context) => DashboardPage(),
          '/projects': (context) => ProjectManagementPage(),
          '/tasks': (context) => TaskManagementPage(),
          '/users': (context) => UserManagementPage(),
          '/roles': (context) => RoleManagementPage(),
          '/notifications': (context) => NotificationPage(),
        },
      ),
    );
  }
}
