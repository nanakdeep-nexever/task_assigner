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
import 'package:task_assign_app/Blocs/Task_Management_BLoC/task_bloc.dart';
import 'package:task_assign_app/Screens/Views/Admin.dart';
import 'package:task_assign_app/Screens/Views/Devloper_view.dart';
import 'package:task_assign_app/Screens/Views/Manager_view.dart';
import 'package:task_assign_app/Screens/Views/viewer_view.dart';

import 'Blocs/Messaging.dart';
import 'Blocs/check_user_cubit.dart';
import 'Notification_Handle/Notification_Handle.dart';
import 'Screens/Dashboard.dart';
import 'Screens/Notification_page.dart';
import 'Screens/ProjectManagement_page.dart';
import 'Screens/Register.dart';
import 'Screens/Role_manage.dart';
import 'Screens/Taskmanagement.dart';
import 'Screens/User_managment.dart';
import 'Screens/login.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';

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

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: null, // iOS settings can be added here
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  setupLocator();

  await NotificationHandler.init();
  FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

  runApp(MyApp());
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MessagingBloc _messagingBloc;
  @override
  void initState() {
    super.initState();
    _messagingBloc = locator<MessagingBloc>();
    _messagingBloc.messageStream.listen((message) {
      print('object on Screen $message');
      _messagingBloc.addstream(message);
    });
    setupbackground();
  }

  void _handleMessage(RemoteMessage message) {
    _messagingBloc.addstream(message);
    if (message.data['Type'] == "data_person") {
    } else if (message.data['Type'] == "data_testcase2") {
    } else {}
  }

  void setupbackground() async {
    print("trigrred");
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print("not empty");
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  @override
  void dispose() {
    _messagingBloc.dispose();
    super.dispose();
  }

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
          create: (context) => UserRoleCubit(
            FirebaseAuth.instance,
            FirebaseFirestore.instance,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'TaskAssignPro',
        navigatorKey: AppConfig.navigatorKey,
        initialRoute: '/splash',
        routes: {
          '/': (context) => LoginPage(),
          '/splash': (context) => SplashScreen(),
          '/register': (context) => RegisterPage(),
          '/admin': (context) => AdminPage(),
          '/manager': (context) => ManagerPage(),
          '/developer': (context) => DeveloperPage(),
          '/viewer': (context) => ViewerPage(),
          '/dashboard': (context) => DashboardPage(),
          '/projects': (context) => ProjectManagementPage(),
          '/tasks': (context) => ActiveTasksScreen(),
          '/users': (context) => UserManagementPage(),
          '/roles': (context) => RoleManage(),
          '/notifications': (context) => NotificationPage(),
        },
      ),
    );
  }
}
