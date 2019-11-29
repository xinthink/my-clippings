import 'package:firebase/firebase.dart';

class FirebaseConfig {
  // copied from firebase app settings
  static const apiKey = "...";
  static const authDomain = "...";
  static const databaseURL = "...";
  static const projectId = "...";
  static const storageBucket = "...";
  static const messagingSenderId = "...";
  static const appId = "...";
  static const measurementId = "...";

  static void initialize() {
    initializeApp(
      apiKey: apiKey,
      authDomain: authDomain,
      databaseURL: databaseURL,
      projectId: projectId,
      storageBucket: storageBucket,
      messagingSenderId: messagingSenderId,
    );
  }
}

class EvernoteConfig {
  static const funcPrefix = "<functions-domain>/auth";
}
