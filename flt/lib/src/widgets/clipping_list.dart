import 'dart:async' show StreamSubscription;
import 'dart:html' show FileUploadInputElement;

import 'package:flutter/material.dart';
import 'package:notever/src/clippings/reader.dart';

/// Recent clippings view
class ClippingList extends StatefulWidget {
  /// Instantiate a [ClippingList] widget.
  ClippingList({
    Key key,
    this.onSelection,
  }) : super(key: key);

  final void Function(int index) onSelection;

  @override
  State<StatefulWidget> createState() => ClippingListState();
}

/// [State] for [ClippingList]
class ClippingListState extends State<ClippingList> {
  final _clippings = List<Clipping>();
  int _selectedIndex = -1;

  StreamSubscription _fileInputSub;

  /// Index of current selected clipping, `-1` if no selection
  int get selectedClipping => _selectedIndex;

  /// A readonly subset of clippings newer than the selected index
  List<Clipping> get unsyncedClippings => _selectedIndex > -1
    ? List.unmodifiable(
      _clippings
        .sublist(0, _selectedIndex + 1)
        .reversed
    ) : null;

  @override
  void dispose() {
    _fileInputSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _clippings.isNotEmpty
    ? ListView.builder(
      itemCount: _clippings.length + 1,
      itemBuilder: (_, i) => i == 0 ? _buildTips() : _buildClipping(i - 1),
    )
    : _buildUploader();

  /// Tips to choose clippings for syncing
  Widget _buildTips() => Container(
    margin: const EdgeInsets.only(left: 80, right: 80, top: 36, bottom: 0),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    child: const Text('Select a clipping below, so that only clippings newer than it (including itself) will be imported into your Evernote notebook.',
      style: const TextStyle(
        color: Colors.black54,
        fontSize: 16,
      ),
    ),
  );

  /// render a single [Clipping]
  Widget _buildClipping(int i) {
    final c = _clippings[i];
    final atBottom = i == _clippings.length - 1;
    return Card(
      margin: EdgeInsets.only(left: 80, right: 80, top: 10,
        bottom: atBottom ? 32 : 10,
      ),
      child: ListTile(
        title: Text("${c.meta}\n\n${c.text}\n\n"),
        subtitle: Text("${c.book} (${c.author})"),
        selected: i == _selectedIndex,
        onTap: () => _onClippingSelected(i),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    );
  }

  Widget _buildUploader() => Container( // a container with full width
    alignment: Alignment.topCenter,
    child: Container( // and then a smaller container
      constraints: const BoxConstraints(maxWidth: 512),
      margin: const EdgeInsets.symmetric(vertical: 150),
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RaisedButton(
            child: const ListTile(
              leading: const Icon(Icons.file_upload),
              title: const Text('Upload My Clippings.txt'),
            ),
            onPressed: _onPickFile,
          ),
          const SizedBox(height: 40),
          _buildUploadTips('1. Connect your Kindle to your computer with USB cable'),
          _buildUploadTips('2. Click the above button'),
          _buildUploadTips("3. Navigate to Kindle's storage, choose the 'My Clippings.txt' file under 'documents' folder"),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );

  Widget _buildUploadTips(String text) => Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black45,
      ),
    ),
  );

  void _onPickFile() {
    final input = FileUploadInputElement()
      ..accept = "text/plain"
      ..multiple = false;

    _fileInputSub = input.onChange.listen((_) => _onFileSelected(input));
    input.click();
  }

  void _onFileSelected(FileUploadInputElement input) async {
    if (input.files.isNotEmpty != true) return;

    final file = input.files[0];
    debugPrint("selected file: ${file.name}");
    if (file.name != "My Clippings.txt") return;

    final clippings = await readClippings(file);
    debugPrint("loaded ${clippings.length} clippings");
    setState(() {
      _selectedIndex = -1;
      _clippings.replaceRange(0, _clippings.length, clippings.reversed); // new clippings first
    });
    _notifySelectionChange(-1);

//    clippingsSub = readClippings(file).listen((chunk) {
//       debugPrint("read chunks: $chunk");
//      // clippingsSub.pause();
//    }, onError: debugPrint);

//     await for (final txt in readClippings(file)) {
//       // debugPrint("read chunks: $txt");
//     }
  }

  /// When clipping clicked
  void _onClippingSelected(int i) {
    _notifySelectionChange(i);
    setState(() {
      _selectedIndex = i;
    });
  }

  void _notifySelectionChange(int i) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSelection?.call(i);
    });
  }
}
