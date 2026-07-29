import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

      default:
        throw UnsupportedError(
          'Plateforme non supportée.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDHvDLyeOS2gwo9W_XfagV3yjM5QlUnJfs',
    appId: '1:1066773178761:android:234d29db518c9792e65958',
    messagingSenderId: '1066773178761',
    projectId: 'semence-smart-a8563',
    storageBucket: 'semence-smart-a8563.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC1JAwFtdxixus4POBFH8O4dv-MD4HFigs',
    appId: '1:1066773178761:ios:04b661c7e597cd9be65958',
    messagingSenderId: '1066773178761',
    projectId: 'semence-smart-a8563',
    storageBucket: 'semence-smart-a8563.firebasestorage.app',
    iosBundleId: 'com.example.agriadvisor',
  );
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBDmo49WljHQaQwMWWWgUaz9aPGLT4MMX0',
    appId: '1:1066773178761:web:d1f8ad522d2842bde65958',
    messagingSenderId: '1066773178761',
    projectId: 'semence-smart-a8563',
    authDomain: 'semence-smart-a8563.firebaseapp.com',
    storageBucket: 'semence-smart-a8563.firebasestorage.app',
  );
}
