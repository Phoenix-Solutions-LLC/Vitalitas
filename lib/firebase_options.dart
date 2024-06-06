// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCHC6BNv9exY7ayJ9-LVwarUaPkK4hmGcc',
    appId: '1:1090975046021:web:4f200c15cd9e1718f1ccec',
    messagingSenderId: '1090975046021',
    projectId: 'vitalitas-4bb9e',
    authDomain: 'vitalitas-4bb9e.firebaseapp.com',
    storageBucket: 'vitalitas-4bb9e.appspot.com',
    measurementId: 'G-DBQY7R8PL2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAVqhhYsQYA5ngG8EyEpaSOw_S_D51UVNk',
    appId: '1:1090975046021:android:5eee3ea0ff40d48cf1ccec',
    messagingSenderId: '1090975046021',
    projectId: 'vitalitas-4bb9e',
    storageBucket: 'vitalitas-4bb9e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyASAFMt2Lg8eZ_27Q5hWiD5TKwStJHXqHc',
    appId: '1:1090975046021:ios:68fb84c7d6f3f47bf1ccec',
    messagingSenderId: '1090975046021',
    projectId: 'vitalitas-4bb9e',
    storageBucket: 'vitalitas-4bb9e.appspot.com',
    iosBundleId: 'com.phoenixsolve.vitalitas',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCf00Mm-8JUpKdvZSS2g2sfo8dg4zADDGI',
    appId: '1:966765070451:ios:7048fa79b25b5bfd520206',
    messagingSenderId: '966765070451',
    projectId: 'vitalitas-bb512',
    storageBucket: 'vitalitas-bb512.appspot.com',
    iosClientId:
        '966765070451-5vpltadtciboa93sb6ldm7sqk98188k3.apps.googleusercontent.com',
    iosBundleId: 'com.phoenixsolve.vitalitas',
  );
}