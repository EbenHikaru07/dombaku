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
    apiKey: 'AIzaSyCruf8kD8sa1om5hM-ZWkQnnpm7n6vcJH4',
    appId: '1:1023308371527:web:7c732b1dc5f08546d98362',
    messagingSenderId: '1023308371527',
    projectId: 'dombaku-974fe',
    authDomain: 'dombaku-974fe.firebaseapp.com',
    storageBucket: 'dombaku-974fe.firebasestorage.app',
    measurementId: 'G-H9CDK4E9BS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAJJ_qZkoGfQrYax21bOG068Az3tB4fyCA',
    appId: '1:1023308371527:android:104e47959ebba9c0d98362',
    messagingSenderId: '1023308371527',
    projectId: 'dombaku-974fe',
    storageBucket: 'dombaku-974fe.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBUPsEsRBWnrK61VQFWJ27JMUVZ6t1jL0Q',
    appId: '1:1023308371527:ios:6117f62e3a761dfed98362',
    messagingSenderId: '1023308371527',
    projectId: 'dombaku-974fe',
    storageBucket: 'dombaku-974fe.firebasestorage.app',
    iosBundleId: 'com.example.dombaku',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBUPsEsRBWnrK61VQFWJ27JMUVZ6t1jL0Q',
    appId: '1:1023308371527:ios:6117f62e3a761dfed98362',
    messagingSenderId: '1023308371527',
    projectId: 'dombaku-974fe',
    storageBucket: 'dombaku-974fe.firebasestorage.app',
    iosBundleId: 'com.example.dombaku',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCruf8kD8sa1om5hM-ZWkQnnpm7n6vcJH4',
    appId: '1:1023308371527:web:72a78e9251fa49f3d98362',
    messagingSenderId: '1023308371527',
    projectId: 'dombaku-974fe',
    authDomain: 'dombaku-974fe.firebaseapp.com',
    storageBucket: 'dombaku-974fe.firebasestorage.app',
    measurementId: 'G-KYY26ZDLG9',
  );

}