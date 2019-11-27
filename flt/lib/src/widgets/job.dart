import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notever/models.dart';

/// A single item in a list of job status.
class JobItem extends StatefulWidget {

  /// Instantiate a [JobItem].
  const JobItem({
    Key key,
    @required this.job,
    this.margin,
  }) : super(key: key);

  final Job job;
  final EdgeInsetsGeometry margin;

  @override
  State<StatefulWidget> createState() => _JobItemState();
}

/// State of a [JobItem] widget.
class _JobItemState extends State<JobItem> {
  /// Fraction of finished clippings
  double finishedFraction = 0;

  /// The finished fraction before update
  double prevFinishedFraction = 0;

  Job get job => widget.job;

  @override
  void initState() {
    finishedFraction = widget.job.finishedFraction;
    super.initState();
  }

  @override
  void didUpdateWidget(JobItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    prevFinishedFraction = oldWidget.job.finishedFraction;
    finishedFraction = widget.job.finishedFraction;
  }

  @override
  Widget build(BuildContext context) => Card(
    margin: widget.margin,
    child: Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16, left: 30, right: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildJobProgress(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 8),
              _renderStats(),
              const SizedBox(height: 20),
              job.isFinished ? _renderFinished() : _renderInProgress(),
            ],
          ),
        ],
      ),
    ),
  );

  /// Progress indicator
  Widget _buildJobProgress() => ClipRRect(
    borderRadius: const BorderRadius.all(const Radius.circular(5)),
    child: SizedBox(
      height: 10,
      child: TweenAnimationBuilder(
        duration: const Duration(seconds: 1),
        tween: Tween<double>(begin: prevFinishedFraction, end: finishedFraction),
        builder: (_, value, __) => LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey.shade300,
        ),
      ),
    ),
  );

  /// Render stats of the job
  Widget _renderStats() => Row(
    children: <Widget>[
      Text("Succeed: ${job.succeed}",
        style: const TextStyle(
          color: Colors.green,
          fontSize: 14,
        ),
      ),
      const SizedBox(width: 18),
      Text("Failed: ${job.failed}",
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 14,
        ),
      ),
      const SizedBox(width: 18),
      Text("Total: ${job.total}",
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
        ),
      ),
    ],
  );

  /// Render an in-progress status
  Widget _renderInProgress() => Text(
    "Still processing, started at ${_formatDateTime(job.createdAt)}.",
    style: const TextStyle(
      fontSize: 14,
      color: Colors.black45,
    ),
  );

  /// Render when the job is finished
  Widget _renderFinished() => Text(
    "Toke ${_formatJobDuration()} seconds, finished at ${_formatDateTime(job.finishedAt)}.",
    style: const TextStyle(
      fontSize: 14,
      color: Colors.black45,
    ),
  );

  String _formatDateTime(num ts) => ts != null
    ? DateFormat.jm().add_yMMMd().format(DateTime.fromMillisecondsSinceEpoch(ts))
    : '';

  String _formatJobDuration() => NumberFormat('#,##0.##').format(job.duration / 1000);
}
