// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBUKhNpZc37vV1OBRRJ6dOMiKlL005bCEQ',
    appId: '1:454982685223:web:ac5a4a215961c9d4f0f402',
    messagingSenderId: '454982685223',
    projectId: 'project-tracker-nk',
    authDomain: 'project-tracker-nk.firebaseapp.com',
    storageBucket: 'project-tracker-nk.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAe8D251GxCIaenAs9LTwzaYhfK6X92RME',
    appId: '1:454982685223:android:c02d68507dfe3ea4f0f402',
    messagingSenderId: '454982685223',
    projectId: 'project-tracker-nk',
    storageBucket: 'project-tracker-nk.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBnVD_c8evBRaIkfCpbrakNZClNAyk57-o',
    appId: '1:454982685223:ios:2148ea65e656730df0f402',
    messagingSenderId: '454982685223',
    projectId: 'project-tracker-nk',
    storageBucket: 'project-tracker-nk.appspot.com',
    iosBundleId: 'com.example.taskAssignApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBnVD_c8evBRaIkfCpbrakNZClNAyk57-o',
    appId: '1:454982685223:ios:2148ea65e656730df0f402',
    messagingSenderId: '454982685223',
    projectId: 'project-tracker-nk',
    storageBucket: 'project-tracker-nk.appspot.com',
    iosBundleId: 'com.example.taskAssignApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBUKhNpZc37vV1OBRRJ6dOMiKlL005bCEQ',
    appId: '1:454982685223:web:cb9f2eed609c485ef0f402',
    messagingSenderId: '454982685223',
    projectId: 'project-tracker-nk',
    authDomain: 'project-tracker-nk.firebaseapp.com',
    storageBucket: 'project-tracker-nk.appspot.com',
  );
}
