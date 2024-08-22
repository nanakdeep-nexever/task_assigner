import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:task_assign_app/Blocs/AUTHentication/authentication_bloc.dart';
import 'package:task_assign_app/Blocs/Management_bloc/management_bloc.dart';
import 'package:task_assign_app/Blocs/Notification_bloc/notification_bloc.dart';
import 'package:task_assign_app/Blocs/Project_Management_BLoC/project_manage_bloc.dart';
import 'package:task_assign_app/Blocs/Rolecube.dart';
import 'package:task_assign_app/Blocs/Task_Management_BLoC/task_bloc.dart';
import 'package:task_assign_app/Screens/Views/Admin.dart';
import 'package:task_assign_app/Screens/Views/Devloper_view.dart';
import 'package:task_assign_app/Screens/Views/Manager_view.dart';
import 'package:task_assign_app/Screens/Views/splash_screen.dart';
import 'package:task_assign_app/Screens/Views/viewer_view.dart';

import 'Blocs/Messaging.dart';
import 'Screens/Dashboard.dart';
import 'Screens/Notification_Handle/Notification_Handle.dart';
import 'Screens/Notification_page.dart';
import 'Screens/ProjectManagement_page.dart';
import 'Screens/Register.dart';
import 'Screens/Role_manage.dart';
import 'Screens/Taskmanagement.dart';
import 'Screens/User_managment.dart';
import 'Screens/login.dart';
import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final locator = GetIt.instance;
NotificationHandler notificatioHendler = NotificationHandler();

void setupLocator() {
  locator.registerLazySingleton(() => MessagingBloc());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized()
      .addObserver(CustomWidgetsBindingObserver());
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: null,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  setupLocator();

  await NotificationHandler.init();
  FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

  runApp(const MyApp());
}

void _handleForegroundMessage(RemoteMessage message) {
  if (message.notification != null) {
    _showNotification(
      title: message.notification?.title,
      body: message.notification?.body,
    );
  }
}

Future<void> _showNotification({String? title, String? body}) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    channelDescription: 'your_channel_description',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: null, // iOS settings can be added here
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: 'item x',
  );
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
          create: (context) => TaskBloc(),
        ),
        BlocProvider(
          create: (context) => RoleCubit(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: AppConfig.navigatorKey,
        title: 'TaskAssignPro',
        initialRoute: '/splash',
        routes: {
          '/': (context) => const LoginPage(),
          '/splash': (context) => const SplashScreen(),
          '/register': (context) => const RegisterPage(),
          '/admin': (context) => const AdminPage(),
          '/manager': (context) => const ManagerPage(),
          '/developer': (context) => const DeveloperPage(),
          '/viewer': (context) => const ViewerPage(),
          '/dashboard': (context) => const DashboardPage(),
          '/projects': (context) => const ProjectManagementPage(),
          '/tasks': (context) => const TaskManagementPage(),
          '/users': (context) => const UserManagementPage(),
          '/roles': (context) => const RoleManagementPage(),
          '/notifications': (context) => const NotificationPage(),
        },
      ),
    );
  }
}
