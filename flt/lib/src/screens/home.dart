import 'dart:async' show StreamSubscription;
import 'dart:html' show window;

import 'package:firebase/firebase.dart' show auth, User;
import 'package:flutter/material.dart';
import 'package:notever/framework.dart';
import 'package:notever/local.dart';
import 'package:notever/widgets.dart' show ClippingList, ClippingListState;

import 'package:notever/src/clippings/clipping.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User currentUser;
  int selectedClippingIndex;

  final clippingListKey = GlobalKey<ClippingListState>();
  StreamSubscription authStateSub;

  @override
  void initState() {
    super.initState();
    currentUser = auth().currentUser;
    authStateSub = auth().onAuthStateChanged.listen(_onAuthState);
    selectedClippingIndex = -1;
  }

  @override
  void dispose() {
    authStateSub?.cancel();
    super.dispose();
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
//      body: Center(
//        child: Column(
//          children: <Widget>[
//            currentUser != null
//              ? Text("Logged in user: [${currentUser.uid}] ${currentUser.displayName ?? ''} ${currentUser.email ?? ''}")
//              : SizedBox(),
//            const SizedBox(height: 12),
//            ClippingList(key: clippingListKey),
//          ],
//        ),
//      ),
      body: Container(
        child: ClippingList(
          key: clippingListKey,
          onSelection: _onClippingSelected,
        ),
      ),
      floatingActionButton: _buildFab(),
    );

  Widget _buildFab() => currentUser != null && selectedClippingIndex > -1
    ? FloatingActionButton(
      child: const Icon(Icons.cloud_upload),
      onPressed: _onSyncClippings,
    )
    : const SizedBox();

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

  /// Firebase auth state listener
  void _onAuthState(User user) {
    setState(() {
      currentUser = user;
    });
  }

  /// On clipping selection changed
  void _onClippingSelected(int index) {
    debugPrint("clipping #$index selected.");
    setState(() {
      selectedClippingIndex = index;
    });
  }

  /// Start syncing clippings to Evernote
  void _onSyncClippings() async {
    final clippings = clippingListKey.currentState?.unsyncedClippings;
    if (clippings?.isNotEmpty != true) return;

    try {
      final uri = '${EvernoteConfig.funcPrefix}/import.json';
      await postJson(uri, body: {
        'uid': currentUser.uid,
        'clippings': Clipping.clippingsToJson(clippings),
      });
    } catch (e) {
      debugPrint('sync clippings request rejected: $e');
    }
  }
}
