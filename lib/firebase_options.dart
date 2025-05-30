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
    apiKey: 'AIzaSyAgcgBEYg4Ij3CiBDUGbPP3kqUx4Jhc_i8',
    appId: '1:392465777417:web:fc8efd97591131c60009d8',
    messagingSenderId: '392465777417',
    projectId: 'bugo-mobile-7a60c',
    authDomain: 'bugo-mobile-7a60c.firebaseapp.com',
    storageBucket: 'bugo-mobile-7a60c.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCVx07ZJ3nCpNshTOFFsjFoAIq4dsz6gFk',
    appId: '1:392465777417:android:dfdca67f8e39f8210009d8',
    messagingSenderId: '392465777417',
    projectId: 'bugo-mobile-7a60c',
    storageBucket: 'bugo-mobile-7a60c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDnDeAVBZXI24tUuSOPtVIeGOSGMRsPHXs',
    appId: '1:392465777417:ios:87dd9b90073f93550009d8',
    messagingSenderId: '392465777417',
    projectId: 'bugo-mobile-7a60c',
    storageBucket: 'bugo-mobile-7a60c.firebasestorage.app',
    iosBundleId: 'com.example.bugoMubNew',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDnDeAVBZXI24tUuSOPtVIeGOSGMRsPHXs',
    appId: '1:392465777417:ios:87dd9b90073f93550009d8',
    messagingSenderId: '392465777417',
    projectId: 'bugo-mobile-7a60c',
    storageBucket: 'bugo-mobile-7a60c.firebasestorage.app',
    iosBundleId: 'com.example.bugoMubNew',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAgcgBEYg4Ij3CiBDUGbPP3kqUx4Jhc_i8',
    appId: '1:392465777417:web:157affac2cbeb6cb0009d8',
    messagingSenderId: '392465777417',
    projectId: 'bugo-mobile-7a60c',
    authDomain: 'bugo-mobile-7a60c.firebaseapp.com',
    storageBucket: 'bugo-mobile-7a60c.firebasestorage.app',
  );
}
