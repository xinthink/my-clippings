import 'package:flutter/foundation.dart';

/// Representing a single Clipping in Kindle books.
///
/// It can be a *note*, *highlight*, or *book mark*.
@immutable
class Clipping {
  /// Instantiate a [Clipping].
  ///
  /// - [text]: content of the clipping, including position in the book, and creation time
  /// - [timestamp]: time of creation as text (multi-language)
  /// - [book]: name of the book
  /// - [author]: author of the book
  const Clipping({
    @required this.text,
    this.timestamp,
    this.book,
    this.author,
  });

  /// Transform the clipping text([doc]) to a [Clipping] object.
  ///
  /// For example, the origin clipping (Chinese version):
  /// ```
  /// Docker in Practice, Second Edition (Ian Miell Aidan Hobson Sayers)
  /// - 您在第 77 页（位置 #1181-1182）的标注 | 添加于 2019年9月28日星期六 下午12:17:44
  ///
  /// If Docker virtualizes anything, it virtualizes the environment in which services run, not the machine.
  /// ```
  ///
  /// will be parsed as:
  /// ```
  /// Clipping(
  ///   text: """- 您在第 77 页（位置 #1181-1182）的标注 | 添加于 2019年9月28日星期六 下午12:17:44
  ///
  ///     If Docker virtualizes anything, it virtualizes the environment in which services run, not the machine.
  ///     """,
  ///   timestamp: "添加于 2019年9月28日星期六 下午12:17:44",
  ///   book: "Docker in Practice, Second Edition",
  ///   author: "Ian Miell Aidan Hobson Sayers",
  /// )
  /// ```
  factory Clipping.parse(String doc) {
    if (doc?.isNotEmpty != true) return null;
    final m = clippingPattern.firstMatch(doc);
    return m != null ? Clipping(
      text: m.group(3)?.trim(),
      timestamp: m.group(4),
      book: m.group(1),
      author: m.group(2),
    ) : null;
  }

  /// pattern for parsing a clipping
  @visibleForTesting
  static final clippingPattern = RegExp(
    r"^(.+) \((.+?)\)\r?\n(- .+? \| (.*)(\r?\n)*(.|\n|\r\n)*)",
    multiLine: true,
    caseSensitive: false,
  );

  /// Transform a list of [Clipping] to a JSON array.
  static Iterable<Map<String, dynamic>> clippingsToJson(Iterable<Clipping> clippings) =>
    clippings.map((c) => c.toJson()).toList(growable: false);

  final String book;
  final String author;
  final String timestamp;
  final String text;

  Map<String, dynamic> toJson() => {
    'text': text,
    'timestamp': timestamp,
    'book': book,
    'author': author,
  };

  @override
  String toString() => "Clipping($book ($author)\n$text)\n$timestamp\n)";
}
