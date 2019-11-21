import 'dart:html';

import 'package:flutter/material.dart';
import 'package:notever/local.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Login'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('Logging in ...'),
          const SizedBox(height: 12),
          RaisedButton(
            child: const Text('Login'),
            onPressed: () => window.location.href = '${EvernoteConfig.funcPrefix}/evernote/',
          ),
        ],
      ),
    ),
  );
}
