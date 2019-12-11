import 'package:firebase/firebase.dart' show auth;
import 'package:flutter/material.dart';
import 'package:notever/widgets.dart' show jobList, evernoteBackground;

/// Screen showing Clippings syncing jobs.
class JobsScreen extends StatelessWidget {
  /// Instantiate a [JobsScreen], to watch the syncing job indexed with [jobKey]
  JobsScreen({
    Key key,
    @required this.jobKey,
  }) : super(key: key);

  final String jobKey;

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: AppBar(
        title: const Text('My Clippings'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Logout',
            onPressed: () => _onLogout(context),
          ),
        ],
      ),
      body: Container(
        decoration: evernoteBackground(),
        child: Container(
          alignment: Alignment.topCenter,
          child: Container(
            width: 800,
            child: jobList(jobKey),
          ),
        ),
      ),
    );

  void _onLogout(BuildContext context) async {
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
    } catch (e, s) {
      debugPrint("firebase signOut failed: $e $s");
    } finally {
      Navigator.of(context).pop();
    }
  }
}
