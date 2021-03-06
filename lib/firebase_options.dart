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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCzrNq84Z_8B_iQEyVHvObBuRCYl8lSKEw',
    appId: '1:1063008850823:web:9ae2ff0fff9c04874bb922',
    messagingSenderId: '1063008850823',
    projectId: 'rapivet-f92bb',
    authDomain: 'rapivet-f92bb.firebaseapp.com',
    storageBucket: 'rapivet-f92bb.appspot.com',
    measurementId: 'G-B4X2B5E1VY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDqlxUvSpyd1pdbczSjzic1HMFHgxZOIr0',
    appId: '1:1063008850823:android:ee519a95604e0b834bb922',
    messagingSenderId: '1063008850823',
    projectId: 'rapivet-f92bb',
    storageBucket: 'rapivet-f92bb.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD82y9hjolG3x0MZSlnVEqG_WZ0NDFOizw',
    appId: '1:1063008850823:ios:cf0c591e11de09c84bb922',
    messagingSenderId: '1063008850823',
    projectId: 'rapivet-f92bb',
    storageBucket: 'rapivet-f92bb.appspot.com',
    androidClientId: '1063008850823-d1h1n3cqsn3bkvinv4obauolsmjme0h2.apps.googleusercontent.com',
    iosClientId: '1063008850823-d9pt78q4eg93h9an25b3tc4u230emt78.apps.googleusercontent.com',
    iosBundleId: 'com.raonhealth.rapivet',
  );
}
