import 'dart:async' show StreamSubscription;

import 'package:firebase/firebase.dart' show auth, User;
import 'package:flutter/material.dart';
import 'package:notever/widgets.dart' show evernoteBackground, Login, ClippingList, ClippingListState, ClippingUploaderFab;

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User currentUser;
  int selectedClippingIndex;

  /// if clippings is being uploaded
  bool isUploading = false;

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
        title: const Text('My Clippings'),
        centerTitle: true,
        actions: <Widget>[
          if (currentUser != null) IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Logout',
            onPressed: _onLogout,
          ),
        ],
      ),
      body: Container(
        decoration: evernoteBackground(),
        child: currentUser != null
          ? ClippingList(
            key: clippingListKey,
            onSelection: _onClippingSelected,
          )
          : _buildLoginWidget(),
//        child: ClippingList(
//          key: clippingListKey,
//          onSelection: _onClippingSelected,
//        ),
      ),
      floatingActionButton: _buildFab(),
    );

  Widget _buildLoginWidget() => SingleChildScrollView(
    child: Container(
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.symmetric(vertical: 150),
      child: Login(),
    ),
  );

  Widget _buildFab() => currentUser != null && selectedClippingIndex > -1
    ? ClippingUploaderFab(
      clippings: clippingListKey.currentState?.unsyncedClippings,
      onComplete: _onClippingsUploaded,
    )
    : const SizedBox();

  void _onLogout() async {
    debugPrint('logout clicked... Firebase auth state: $currentUser');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Please confirm to logout.'),
        actions: <Widget>[
          FlatButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          FlatButton(
            child: const Text('Confirm'),
            onPressed: () => Navigator.of(context).pop(true),
          )
        ],
      ),
    );

    if (!confirmed) return;

    try {
      await auth().signOut();
      setState(() {
        currentUser = null;
        selectedClippingIndex = -1;
      });
    } catch (e, s) {
      debugPrint("firebase signOut failed: $e $s");
    }
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

  /// When clippings upload is complete
  void _onClippingsUploaded(String taskId) async {
    Navigator.of(context).pushNamed('/jobs', arguments: '${currentUser.uid}:$taskId');
    setState(() {
      selectedClippingIndex = -1;
    });
  }
}
