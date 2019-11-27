import 'dart:async' show StreamSubscription;

import 'package:firebase/firebase.dart' show auth, User;
import 'package:flutter/material.dart';
import 'package:notever/framework.dart';
import 'package:notever/local.dart';
import 'package:notever/widgets.dart' show Login, ClippingList, ClippingListState;

import 'package:notever/src/models/clipping.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User currentUser;
  int selectedClippingIndex;
  bool isSyncing = false;

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
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(_BACKGROUND),
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: currentUser != null
          ? ClippingList(
            key: clippingListKey,
            onSelection: _onClippingSelected,
          )
          : _buildLoginWidget(),
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

  Widget _buildFab() => currentUser != null && selectedClippingIndex > -1 && !isSyncing
    ? FloatingActionButton(
      child: const Icon(Icons.cloud_upload),
      onPressed: _onSyncClippings,
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

  /// Start syncing clippings to Evernote
  void _onSyncClippings() async {
    final clippings = clippingListKey.currentState?.unsyncedClippings;
    if (isSyncing || clippings?.isNotEmpty != true) return;

    final message = """Are sure to import all clippings newer than your selection into your Evernote account?
${clippings.length} notes will be created.

Please confirm to continue.
""";
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sync Clippings'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          FlatButton(
            child: const Text('Continue'),
            onPressed: () => Navigator.of(context).pop(true),
          )
        ],
      ),
    );
    if (!confirmed) return;

    try {
      setState(() {
        isSyncing = true;
      });
      final uri = '${EvernoteConfig.funcPrefix}/import.json';
      await postJson(uri, body: {
        'uid': currentUser.uid,
        'clippings': Clipping.clippingsToJson(clippings),
      });
      Navigator.of(context).pushNamed('/jobs', arguments: currentUser.uid);
    } catch (e) {
      debugPrint('sync clippings request rejected: $e');
    } finally {
      setState(() {
        isSyncing = false;
      });
    }
  }
}

const _BACKGROUND = 'assets/images/evernote_bg.png';
