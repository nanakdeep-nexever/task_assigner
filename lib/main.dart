import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_bloc.dart';
import 'package:task_assign_app/Blocs/Management_bloc/management_bloc.dart';
import 'package:task_assign_app/Blocs/Notification_bloc/notification_bloc.dart';
import 'package:task_assign_app/Blocs/Project_Management_BLoC/project_manage_bloc.dart';
import 'package:task_assign_app/Screens/Views/Admin.dart';
import 'package:task_assign_app/Screens/Views/Devloper_view.dart';
import 'package:task_assign_app/Screens/Views/Manager_view.dart';
import 'package:task_assign_app/Screens/Views/viewer_view.dart';

import 'Blocs/check_user_cubit.dart';
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
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized()
      .addObserver(CustomWidgetsBindingObserver());
  runApp(MyApp());
}

class CustomWidgetsBindingObserver extends WidgetsBindingObserver {
  void _setOnlineStatus(bool status) async {
    try {
      if (FirebaseAuth.instance.currentUser?.uid != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({
          'status_online': status,
        });
      }
    } catch (e) {
      if (AppConfig.contextExits) {
        ScaffoldMessenger.of(AppConfig.context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _setOnlineStatus(state == AppLifecycleState.resumed);

    super.didChangeAppLifecycleState(state);
  }
}

class AppConfig {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static BuildContext context = navigatorKey.currentState!.context;
  static bool contextExits = navigatorKey.currentState?.context != null;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        BlocProvider(
          create: (context) => ProjectBloc(),
        ),
        BlocProvider(
          create: (context) => UserRoleCubit(
            FirebaseAuth.instance,
            FirebaseFirestore.instance,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'TaskAssignPro',
        navigatorKey: AppConfig.navigatorKey,
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
