import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:task_assign_app/Screens/Views/splash_screen.dart';

import 'Blocs/AUTHentication/authentication_bloc.dart';
import 'Blocs/AdminBloc/admin_bloc.dart';
import 'Blocs/Management_bloc/management_bloc.dart';
import 'Blocs/Messaging.dart';
import 'Blocs/Notification_bloc/notification_bloc.dart';
import 'Blocs/Profile_bloc/profile_bloc.dart';
import 'Blocs/Project_Management_BLoC/project_manage_bloc.dart';
import 'Blocs/Rolecube.dart';
import 'Blocs/Task_Management_BLoC/task_bloc.dart';
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
import 'Screens/Views/reset_password_screen.dart';
import 'Screens/Views/viewer_view.dart';
import 'Screens/login.dart';
import 'commons/LifeCycle.dart';
import 'commons/profile_section.dart';
import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(
      () => MessagingBloc(flutterLocalNotificationsPlugin));
  locator.registerLazySingleton(
      () => NotificationHandler(flutterLocalNotificationsPlugin));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupLocator();

  // Initialize NotificationHandler
  await NotificationHandler.init();
  Bloc.observer = MyBlocObserver();
  final appLifecycleObserver = AppLifecycleObserver();
  WidgetsBinding.instance.addObserver(appLifecycleObserver);

  runApp(MyApp(
    messagingBloc: locator<MessagingBloc>(),
    notificationHandler: locator<NotificationHandler>(),
    lifecycleObserver: appLifecycleObserver,
  ));
}

class MyApp extends StatelessWidget {
  final MessagingBloc messagingBloc;
  final NotificationHandler notificationHandler;
  final AppLifecycleObserver lifecycleObserver;

  const MyApp(
      {required this.messagingBloc,
      required this.notificationHandler,
      required this.lifecycleObserver});

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthenticationBloc()),
        BlocProvider(create: (context) => ManagerPageBloc(_firestore)),
        BlocProvider(create: (context) => AdminPageBloc()),
        BlocProvider(create: (context) => NotificationBloc()),
        BlocProvider(create: (context) => ProjectBloc()),
        BlocProvider(create: (context) => TaskBloc()),
        BlocProvider(create: (context) => ProfileBloc()),
        BlocProvider(create: (context) => RoleCubit()),
      ],
      child: MaterialApp(
        navigatorKey: AppConfig.navigatorKey,
        title: 'TaskAssignPro',
        initialRoute: '/splash',
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    final routes = {
      '/': (context) => const LoginPage(),
      '/splash': (context) => const SplashScreen(),
      '/register': (context) => const RegisterPage(),
      '/admin': (context) => AdminPage(),
      '/manager': (context) => const ManagerPage(),
      '/developer': (context) => const DeveloperPage(),
      '/viewer': (context) => const ViewerPage(),
      '/dashboard': (context) => const DashboardPage(),
      '/projects': (context) => ActiveProjectsScreen(),
      '/tasks': (context) => ActiveTasksScreen(),
      '/users': (context) => const UserManagementPage(),
      '/roles': (context) => const RoleManagementPage(),
      '/notifications': (context) => const NotificationPage(),
      '/forgot_password': (context) => const ResetPasswordScreen(),
      '/completeProfile': (context) => const CompleteProfileScreen(),
      '/profile': (context) {
        final data = settings.arguments as Map<String, dynamic>?;
        return ProfileSection(heading: data?['heading'] ?? "");
      },
    };
    return MaterialPageRoute(
      builder: routes[settings.name] ?? (context) => const SplashScreen(),
      settings: settings,
    );
  }
}

class AppConfig {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}

class MyBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('Event: ${bloc.runtimeType}, $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('Change: ${bloc.runtimeType}, $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('Transition: ${bloc.runtimeType}, $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    print('Error: ${bloc.runtimeType}, $error, $stackTrace');
  }
}
