import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' show auth, firestore;

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
    appBar: AppBar(
      title: const Text('Login'),
    ),
    body: Center(
      child: Text('Logging in ... uid=${widget.uid ?? ''}'),
    ),
  );

  /// Retrieve customToken from backend
  void _requestToken() async {
    if (widget.uid?.isNotEmpty != true) {
      debugPrint('abort firebase auth: uid is empty');
      return;
    }

    try {
      final doc = await firestore().collection('_t').doc(widget.uid).get();
      if (!doc.exists) return debugPrint("abort firebase auth: token not found for uid=${widget.uid}");

      final tokenInfo = doc.data();
      _firebaseAuth(tokenInfo["customToken"]);
    } catch (e, s) {
      debugPrint("firebase auth failed: $e $s");
    }
  }

  /// Login using Firebase custom auth
  Future _firebaseAuth(String customToken) async {
    if (customToken?.isNotEmpty != true) throw Exception('token is empty');

    await auth().signInWithCustomToken(customToken);
    final user = auth().currentUser;
    debugPrint("firebase auth done! $user");
    Navigator.of(context).pop();
  }
}
