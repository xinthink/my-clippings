import 'dart:html' show window;

import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:notever/local.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = auth().currentUser;
    debugPrint("check Firebase auth state: $currentUser");
  }

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: AppBar(
        title: const Text('Notever'),
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: _buildActions,
            onSelected: _onAction,
          ),
        ],
      ),
      body: Center(
        child: currentUser != null
          ? Text("Logged in user: [${currentUser.uid}] ${currentUser.displayName ?? ''} ${currentUser.email ?? ''}")
          : SizedBox(),
      ),
    );

  /// AppBar popup actions
  List<PopupMenuEntry<int>> _buildActions(BuildContext context) {
    final loggedIn = currentUser != null;
    return loggedIn ? [
      PopupMenuItem(
        value: 10,
        child: const Text('Logout'),
      ),
    ] : [
      PopupMenuItem(
        value: 0,
        child: const Text('Evernote Login'),
      ),
      PopupMenuItem(
        value: 1,
        child: const Text('Yinxiang Login'),
      ),
    ];
  }

  /// When appbar action selected
  void _onAction(int id) {
    switch (id) {
      case 0:
        _onLogin();
        break;
      case 1:
        _onLogin(true);
        break;
      case 10:
        _onLogout();
        break;
    }
  }

  void _onLogin([bool isYinxiang = false]) {
    window.location.href = '${EvernoteConfig.funcPrefix}/${isYinxiang ? 'yinxiang' : 'evernote'}/';
  }

  void _onLogout() async {
    debugPrint('logout clicked... Firebase auth state: $currentUser');
    await auth().signOut();
    setState(() {
      currentUser = null;
    });
  }
}
