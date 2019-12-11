import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' show auth, firestore;
import 'package:notever/widgets.dart' show evernoteBackground;

/// Handle OAuth result
class AuthScreen extends StatefulWidget {
  AuthScreen({
    Key key,
    this.uid,
  }) : super(key: key);

  final String uid;

  @override
  State<StatefulWidget> createState() => _AuthState();
}

class _AuthState extends State<AuthScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestToken());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: evernoteBackground(),
      padding: const EdgeInsets.symmetric(vertical: 150),
      child: Container(
        alignment: Alignment.topCenter,
        child: const Card(
          child: const Padding(
            padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 30),
            child: const Text('Just a second, processing...',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  /// Retrieve customToken from backend
  void _requestToken() async {
    try {
      if (widget.uid?.isNotEmpty == true) {
        await _firebaseAuth(widget.uid);
      } else {
        debugPrint('abort firebase auth: uid is empty');
      }
    } catch (e) {
      debugPrint("firebase auth failed with $e");
    } finally {
      debugPrint("return to home screen");
      Navigator.of(context).pop(); // always return to home screen
    }
  }

  /// Login using Firebase custom auth
  Future _firebaseAuth(String uid) async {
    final doc = await firestore().collection('_t').doc(uid).get();
    if (!doc.exists) throw Exception("abort firebase auth: token not found for uid=$uid");

    final customToken = doc.data()["customToken"];
    if (customToken?.isNotEmpty != true) throw Exception('token is empty for uid=$uid');

    await auth().signInWithCustomToken(customToken);
    final user = auth().currentUser;
    debugPrint("firebase auth done! $user");
  }
}
