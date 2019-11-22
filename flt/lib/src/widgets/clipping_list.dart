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

  @override
  void dispose() {
    _fileInputSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _clippings.isNotEmpty
    ? ListView.builder(
      itemCount: _clippings.length,
      itemBuilder: _buildClipping,
    )
    : _buildUploader();

  /// render a single [Clipping]
  Widget _buildClipping(BuildContext context, int i) {
    final c = _clippings[i];
    final atTop = i == 0;
    final atBottom = i == _clippings.length - 1;
    return Card(
      margin: EdgeInsets.only(left: 80, right: 80,
        top: atTop ? 32 : 10,
        bottom: atBottom ? 32 : 10,
      ),
      child: ListTile(
        title: Text(c.text),
        subtitle: Text("${c.book} (${c.author})"),
        selected: i == _selectedIndex,
        onTap: () => _onClippingSelected(i),
      ),
    );
  }

  Widget _buildUploader() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 120, vertical: 80),
    child: RaisedButton(
      child: const ListTile(
        leading: const Icon(Icons.file_upload),
        title: const Text('Upload My Clippings.txt'),
      ),
      onPressed: _onPickFile,
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
