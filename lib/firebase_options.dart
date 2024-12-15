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
    apiKey: 'AIzaSyDovw3qXJO6fsbjcGpGeRTrA8xKgVE-fqM',
    appId: '1:110011374632:web:48c8e34613995feb3b291d',
    messagingSenderId: '110011374632',
    projectId: 'curasync-8dd7a',
    authDomain: 'curasync-8dd7a.firebaseapp.com',
    storageBucket: 'curasync-8dd7a.firebasestorage.app',
    measurementId: 'G-WGZL4B1ZKV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC9Bnzaox16F7acWUR9EqerdcKeNE-GpM8',
    appId: '1:110011374632:android:0206b12f8555d7e63b291d',
    messagingSenderId: '110011374632',
    projectId: 'curasync-8dd7a',
    storageBucket: 'curasync-8dd7a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDt3xstu3rj2c1GzXxIyAasQUOjmV0QrhI',
    appId: '1:110011374632:ios:b221b6dfcc9ee22a3b291d',
    messagingSenderId: '110011374632',
    projectId: 'curasync-8dd7a',
    storageBucket: 'curasync-8dd7a.firebasestorage.app',
    iosBundleId: 'com.example.mobileAppFinal',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDt3xstu3rj2c1GzXxIyAasQUOjmV0QrhI',
    appId: '1:110011374632:ios:b221b6dfcc9ee22a3b291d',
    messagingSenderId: '110011374632',
    projectId: 'curasync-8dd7a',
    storageBucket: 'curasync-8dd7a.firebasestorage.app',
    iosBundleId: 'com.example.mobileAppFinal',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDovw3qXJO6fsbjcGpGeRTrA8xKgVE-fqM',
    appId: '1:110011374632:web:6ceec7ed910582453b291d',
    messagingSenderId: '110011374632',
    projectId: 'curasync-8dd7a',
    authDomain: 'curasync-8dd7a.firebaseapp.com',
    storageBucket: 'curasync-8dd7a.firebasestorage.app',
    measurementId: 'G-D6NM4WX15H',
  );
}
