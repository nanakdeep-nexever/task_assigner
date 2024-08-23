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
import 'package:task_assign_app/Blocs/Profile_bloc/profile_bloc.dart';
import 'package:task_assign_app/Blocs/Project_Management_BLoC/project_manage_bloc.dart';
import 'package:task_assign_app/Blocs/Rolecube.dart';
import 'package:task_assign_app/Blocs/Task_Management_BLoC/task_bloc.dart';
import 'package:task_assign_app/Screens/Views/reset_password_screen.dart';

import 'Blocs/Messaging.dart';
import 'Screens/Dashboard.dart';
import 'Screens/Notification_Handle/Notification_Handle.dart';
import 'Screens/Notification_page.dart';
import 'Screens/ProjectManagement_page.dart';
import 'Screens/Register.dart';
import 'Screens/Role_manage.dart';
import 'Screens/Taskmanagement.dart';
import 'Screens/User_managment.dart';
import 'Screens/Views/Admin.dart';
import 'Screens/Views/Devloper_view.dart';
import 'Screens/Views/Manager_view.dart';
import 'Screens/Views/complete_profile_screen.dart';
import 'Screens/Views/edit_profile_screen.dart';
import 'Screens/Views/splash_screen.dart';
import 'Screens/Views/viewer_view.dart';
import 'Screens/login.dart';
import 'commons/profile_section.dart';
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
  FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

  runApp(const MyApp());
}

void _handleBackgroundMessage(RemoteMessage message) {
  if (message.notification != null) {
    _showNotification(
      title: message.notification?.title,
      body: message.notification?.body,
    );
  }
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
          create: (context) => ProfileBloc(),
        ),
        BlocProvider(
          create: (context) => RoleCubit(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: AppConfig.navigatorKey,
        title: 'TaskAssignPro',
        initialRoute: '/splash',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return getRoute(settings, (_) => const LoginPage());
            case '/splash':
              return getRoute(settings, (_) => const SplashScreen());
            case '/register':
              return getRoute(settings, (_) => const RegisterPage());
            case '/admin':
              return getRoute(settings, (_) => const AdminPage());
            case '/manager':
              return getRoute(settings, (_) => const ManagerPage());
            case '/developer':
              return getRoute(settings, (_) => const DeveloperPage());
            case '/viewer':
              return getRoute(settings, (_) => const ViewerPage());
            case '/dashboard':
              return getRoute(settings, (_) => const DashboardPage());
            case '/projects':
              return getRoute(settings, (_) => const ProjectManagementPage());
            case '/tasks':
              return getRoute(settings, (_) => const TaskManagementPage());
            case '/users':
              return getRoute(settings, (_) => const UserManagementPage());
            case '/roles':
              return getRoute(settings, (_) => const RoleManagementPage());
            case '/notifications':
              return getRoute(settings, (_) => const NotificationPage());
            case '/forgot_password':
              return getRoute(settings, (_) => const ResetPasswordScreen());
            case '/completeProfile':
              return getRoute(settings, (_) => const CompleteProfileScreen());
            case '/editProfile':
              return getRoute(settings, (_) => const EditProfileScreen());
            case '/profile':
              return getRoute(settings, (_) {
                Map<String, dynamic>? data =
                    settings.arguments as Map<String, dynamic>?;
                return ProfileSection(
                  heading: data?['heading'] ?? "",
                );
              });
            // Ensure that 'heading' is correctly passed
            default:
              return getRoute(settings, (_) => const SplashScreen());
          }
        },

        // routes: {
        //   '/': (context) => const LoginPage(),
        //   '/splash': (context) => const SplashScreen(),
        //   '/register': (context) => const RegisterPage(),
        //   '/admin': (context) => const AdminPage(),
        //   '/manager': (context) => const ManagerPage(),
        //   '/developer': (context) => const DeveloperPage(),
        //   '/viewer': (context) => const ViewerPage(),
        //   '/dashboard': (context) => const DashboardPage(),
        //   '/projects': (context) => const ProjectManagementPage(),
        //   '/tasks': (context) => const TaskManagementPage(),
        //   '/users': (context) => const UserManagementPage(),
        //   '/roles': (context) => const RoleManagementPage(),
        //   '/notifications': (context) => const NotificationPage(),
        //   '/forgot_password': (context) => const ResetPasswordScreen(),
        //   '/profile': (context) => const ProfileSection(heading: heading),
        // },
      ),
    );
  }

  Route<dynamic> getRoute(RouteSettings settings, WidgetBuilder builder) {
    return MaterialPageRoute(
      builder: builder,
      settings: settings,
    );
  }
}
