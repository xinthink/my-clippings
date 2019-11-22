import 'dart:html' show File, FileReader;

import 'package:flutter/foundation.dart';

import 'clipping.dart';
export 'clipping.dart';

/// Read clippings from [file].
Future<List<Clipping>> readClippings(File file) async {
  final reader = FileReader()..readAsText(file);
  await reader.onLoad.first;
  return readClippingsFromText(reader.result).toList(growable: false);
}

@visibleForTesting
Iterable<Clipping> readClippingsFromText(String text) =>
  text.split(RegExp(r"\s=+\s"))
    .map((d) => Clipping.parse(d))
    .where((c) => c != null);

// FIXME: listening to async* function not working
//const int _CHUNK_SIZE = 512;
//
//Stream<String> readClippings(File file) async* {
//  final reader = FileReader();
//
//  // read in chunks, start from newer records
//  int start = max(0, file.size - _CHUNK_SIZE);
//  int end = file.size;
//  next() {
//    if (start >= 0 && start < end) {
//      reader.readAsText(file.slice(start, end));
//    }
//    start = max(0, start - _CHUNK_SIZE);
//    end = max(0, end - _CHUNK_SIZE);
//  }
//
//  debugPrint("--- first chunk: [$start,$end]");
//  next();
//  await for (final e in reader.onLoad) {
//    debugPrint("loading... ${e.loaded}/${e.total} state=${reader.readyState}");
//    yield reader.result;
//    debugPrint("    next chunk: [$start,$end]");
//    next();
//  }
//}
