import 'package:firebase/firebase.dart';
import 'package:firebase/firestore.dart';

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
    /*final app =*/ initializeApp(
      apiKey: apiKey,
      authDomain: authDomain,
      databaseURL: databaseURL,
      projectId: projectId,
      storageBucket: storageBucket,
      messagingSenderId: messagingSenderId,
    );
//    app.firestore().settings(Settings(
//      host: 'http://localhost:5005', // not yet supported
//      ssl: false,
//    ));
  }
}

class EvernoteConfig {
  static const funcPrefix = "<functions-domain>/auth";
}
