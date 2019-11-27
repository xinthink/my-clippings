import 'dart:async' show StreamSubscription;

import 'package:firebase/firebase.dart' show auth, firestore;
import 'package:firebase/firestore.dart' show QuerySnapshot;
import 'package:flutter/material.dart';
import 'package:notever/models.dart' show Job;
import 'package:notever/widgets.dart' show JobItem;

/// Screen showing Clippings syncing jobs.
class JobsScreen extends StatefulWidget {
  /// Instantiate a [JobsScreen]
  JobsScreen({
    Key key,
    @required this.uid,
  }) : super(key: key);

  final String uid;

  @override
  State<StatefulWidget> createState() => _JobsScreenState();
}

/// [State] of [JobsScreen]
class _JobsScreenState extends State<JobsScreen> {
  final _jobs = List<Map<String, dynamic>>();
  StreamSubscription<QuerySnapshot> _jobsSubs;

  @override
  void initState() {
    super.initState();
    _jobsSubs = firestore()
      .collection('_jobs')
      .where('uid', '==', widget.uid)
      .orderBy('createdAt', 'desc')
      .onSnapshot
      .listen(
        _onJobsUpdated,
        onError: (e) => debugPrint("query jobs failed: $e"),
      );
  }

  @override
  void dispose() {
    _jobsSubs?.cancel();
    super.dispose();
  }

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
        child: Container(
          alignment: Alignment.topCenter,
          child: Container(
            width: 800,
            child: _jobs.isNotEmpty ? _buildJobs() : _buildBlankView(),
          ),
        ),
      ),
    );

  /// Rendering a blank view when no job available
  Widget _buildBlankView() => Card(
    margin: const EdgeInsets.symmetric(horizontal: 80, vertical: 32),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 48),
      child: const Text('Just a second, receiving updates...',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
      ),
    ),
  );

  /// Rendering status of jobs
  Widget _buildJobs() => ListView.builder(
    itemCount: _jobs.length,
    itemBuilder: _buildJob,
  );

  /// Render a single `Job`
  Widget _buildJob(BuildContext context, int i) {
    final job = _jobs[i];
    final atTop = i == 0;
    final atBottom = i == _jobs.length - 1;
    return JobItem(
      job: Job.fromDoc(job),
      margin: EdgeInsets.only(left: 80, right: 80,
        top: atTop ? 32 : 10,
        bottom: atBottom ? 32 : 10,
      ),
    );
  }

  /// Callback when Firestore query result updated
  void _onJobsUpdated(QuerySnapshot snapshot) {
    final docs = snapshot.docs
      .map((ds) => ds.exists ? ds.data() : null)
      .where((d) => d != null);
    setState(() {
      _jobs.replaceRange(0, _jobs.length, docs);
    });
  }

  void _onLogout() async {
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

const _BACKGROUND = 'assets/images/evernote_bg.png';
