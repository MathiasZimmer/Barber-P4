// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///

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
    apiKey: 'AIzaSyA_RTywZ6G0A2nd0jqbFRrlcWjpDMQqiDo',
    appId: '1:919848002904:web:bee1e5df23311562e3312d',
    messagingSenderId: '919848002904',
    projectId: 'barberdma-9d67f',
    authDomain: 'barberdma-9d67f.firebaseapp.com',
    storageBucket: 'barberdma-9d67f.firebasestorage.app',
    measurementId: 'G-8ZYLVD4FDY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDe7Im-y6P21DEhBWjWsURxRTlfxEuxlJE',
    appId: '1:919848002904:android:69482f962716f660e3312d',
    messagingSenderId: '919848002904',
    projectId: 'barberdma-9d67f',
    storageBucket: 'barberdma-9d67f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCTKeaorjCMis9WYgk0jydAbCAfdZ4FKMQ',
    appId: '1:919848002904:ios:625e8707cb242304e3312d',
    messagingSenderId: '919848002904',
    projectId: 'barberdma-9d67f',
    storageBucket: 'barberdma-9d67f.firebasestorage.app',
    iosBundleId: 'com.example.barbershopApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCTKeaorjCMis9WYgk0jydAbCAfdZ4FKMQ',
    appId: '1:919848002904:ios:625e8707cb242304e3312d',
    messagingSenderId: '919848002904',
    projectId: 'barberdma-9d67f',
    storageBucket: 'barberdma-9d67f.firebasestorage.app',
    iosBundleId: 'com.example.barbershopApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA_RTywZ6G0A2nd0jqbFRrlcWjpDMQqiDo',
    appId: '1:919848002904:web:bd8bbb98cd87f1fce3312d',
    messagingSenderId: '919848002904',
    projectId: 'barberdma-9d67f',
    authDomain: 'barberdma-9d67f.firebaseapp.com',
    storageBucket: 'barberdma-9d67f.firebasestorage.app',
    measurementId: 'G-F3CSWLXYS6',
  );
}
