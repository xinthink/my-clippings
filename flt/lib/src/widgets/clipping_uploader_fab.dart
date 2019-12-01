import 'dart:math';

import 'package:firebase/firebase.dart' show auth;
import 'package:flutter/material.dart';
import 'package:notever/framework.dart' show partition, postJson;
import 'package:notever/local.dart' show EvernoteConfig;
import 'package:notever/models.dart' show Clipping;
import 'package:uuid/uuid.dart';

/// A [FloatingActionButton] to upload selected [Clipping]s.
class ClippingUploaderFab extends StatefulWidget {
  /// Instantiate a [ClippingUploaderFab].
  ///
  /// To upload the given [clippings] when the FAB is clicked,
  /// with an optional [onComplete] listener receiving notification when all clippings are uploaded (successfully or not).
  const ClippingUploaderFab({
    Key key,
    this.clippings,
    this.onComplete,
  }) : super(key: key);

  /// A list of [Clipping]s to be uploaded.
  final List<Clipping> clippings;

  /// Callback with an unique `task id` when all [Clipping]s are uploaded, no matter successful or not
  final ValueChanged<String> onComplete;

  @override
  State<StatefulWidget> createState() => _ClippingUploaderState();
}

/// [State] of the [ClippingUploaderFab] widget.
class _ClippingUploaderState extends State<ClippingUploaderFab> {
  /// Current user's uid, should has a valid value when the uploader is visible
  String get _currentUserID => auth().currentUser?.uid;

  /// [Clipping]s to be uploaded.
  List<Clipping> get _clippings => widget.clippings;

  /// Whether clippings is being uploaded
  bool _isUploading = false;

  /// Total batches of [Clipping]s to be uploaded
  int _totalBatches = 0;

  /// Currently uploaded batches of [Clipping]s
  int _uploadedBatches = 0;

  /// Previous number of uploaded batches, used to display progress animation
  int _prevUploadedBatches = 0;

  /// Unique task id
  String _taskId;

  /// Function, if none-null, should be called after uploading is done
  VoidCallback _onComplete;

  @override
  Widget build(BuildContext context) => Stack(
    children: <Widget>[
      _buildFab(),
      if (_isUploading) _buildProgressIndicator(), // show progress when upload is started
    ],
  );

  /// Upload FAB
  Widget _buildFab() => FloatingActionButton(
    child: const Icon(Icons.cloud_upload),
    tooltip: 'Upload',
    onPressed: _isUploading ? null : _onPressed, // disabled when syncing
  );

  /// Show uploading progress
  Widget _buildProgressIndicator() => Positioned(
    width: 28,
    height: 28,
    top: 14,
    left: 14,
    child: TweenAnimationBuilder(
      duration: const Duration(seconds: 2),
      tween: Tween<double>(
        begin: _prevUploadedBatches / _totalBatches,
        end: max(_uploadedBatches / _totalBatches, 0.01), // show 1% at the very beginning
      ),
      onEnd: () => _onComplete?.call(),
      builder: (_, value, __) =>
        CircularProgressIndicator(
          value: value,
          valueColor: const AlwaysStoppedAnimation(const Color(0x60ffffff)),
          strokeWidth: 28,
        ),
    ),
  );

  /// Start syncing clippings to Evernote
  void _onPressed() async {
    if (_isUploading || _clippings?.isNotEmpty != true || _currentUserID?.isNotEmpty != true) return;

    final message = """Are sure to import all clippings newer than your selection into your Evernote account?
${_clippings.length} notes will be created.

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

    final batches = partition(_clippings, _BATCH_SIZE);
    _taskId = Uuid().v4();

    setState(() {
      _isUploading = true;
      _totalBatches = batches.length;
      _prevUploadedBatches = _uploadedBatches = 0;
    });

    int i = 0;
    for (var clippings in batches) {
      await _uploadClippings(_taskId, i++, clippings);
      await Future.delayed(const Duration(milliseconds: 25));
    }

    // register the onComplete callback
    _onComplete = _notifyComplete;
  }

  Future<void> _uploadClippings(String taskId, int batchNo, Iterable<Clipping> clippings) async {
    try {
      final uri = '${EvernoteConfig.funcPrefix}/import.json';
      await postJson(uri, body: {
        'taskId': taskId,
        'batch': batchNo,
        'uid': _currentUserID,
        'clippings': Clipping.clippingsToJson(clippings),
      });
    } catch (e) {
      debugPrint('sync clippings request rejected: $e');
    } finally {
      setState(() {
        _prevUploadedBatches = _uploadedBatches;
        _uploadedBatches += 1;
      });
    }
  }

  void _notifyComplete() {
    Future.delayed(Duration(milliseconds: 300), () {
      widget.onComplete?.call(_taskId);

      // reset
      setState(() {
        _isUploading = false;
        _totalBatches = _prevUploadedBatches = _uploadedBatches = 0;
        _taskId = null;
      });
    });

    _onComplete = null;
  }
}

const _BATCH_SIZE = 25;
