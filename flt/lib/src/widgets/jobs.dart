import 'package:firebase/firebase.dart' show firestore;
import 'package:flutter/material.dart';
import 'package:notever/models.dart' show Job;
import 'package:notever/widgets.dart' show JobItem;

/// Listen to job updates,
Widget jobList(String jobKey) => StreamBuilder<List<Job>>(
  stream: firestore()
    .collection('_jobs')
    .doc(jobKey)
    .collection("batches")
    .orderBy('createdAt', 'desc')
    .onSnapshot
    .map((q) => q.docs
      .map((docs) => docs.exists ? Job.fromDoc(docs.data()) : null)
      .where((d) => d != null)
      .toList(growable: false)
    ),
  initialData: [],
  builder: (_, snapshot) {
    if (snapshot.hasError) return _buildMessage('Retrieving jobs failed: ${snapshot.error}');
    else if (snapshot.hasData && snapshot.data.isNotEmpty) return _buildJobs(snapshot.data);
    else return _buildMessage('Just a second, receiving updates...');
  },
);

/// Rendering status of jobs
Widget _buildJobs(List<Job> jobs) => ListView.builder(
  itemCount: jobs.length,
  itemBuilder: (_, i) => _buildJob(jobs[i], i == 0, i == jobs.length - 1),
);

/// Render a single `Job`
Widget _buildJob(Job job, bool atTop, bool atBottom) => JobItem(
  job: job,
  margin: EdgeInsets.only(left: 80, right: 80,
    top: atTop ? 32 : 10,
    bottom: atBottom ? 32 : 10,
  ),
);

Widget _buildMessage(String message) => Card(
  margin: const EdgeInsets.symmetric(horizontal: 80, vertical: 32),
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 48),
    child: Text(message,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 16,
      ),
    ),
  ),
);
