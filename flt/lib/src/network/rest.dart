import 'dart:io' show HttpException;
import 'dart:convert' show jsonDecode;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

typedef ErrorCheck = http.Response Function(http.Response);
typedef BodyParser<T> = T Function(String body);

/// A simple [BodyParser] doing nothing.
T ignoreBody<T>(String body) => null;

/// A simple [BodyParser] returning response body as is.
String stringBody(String body) => body;

/// A [BodyParser] parsing a `JSON` response.
dynamic jsonBody(String body) => jsonDecode(body);

/// Issues a `HTTP GET` request for [uri].
///
/// with optional [headers],
/// customized [bodyParser] to parse the response body, defaults to *ignoring*,
/// customized [errorCheck] handling HTTP status, `2xx` considered successful by default.
Future<T> get<T>(uri, {
  Map<String, String> headers,
  BodyParser<T> bodyParser,
  ErrorCheck errorCheck,
}) {
  debugPrint("GET $uri headers=$headers");
  return http.get(uri, headers: headers)
    .then(errorCheck ?? _checkHttpError)
    .then((resp) => (bodyParser ?? ignoreBody)(resp.body));
}

/// `GET` a `JSON` response from [uri].
///
/// with optional [headers],
/// customized [errorCheck] handling HTTP status, `2xx` considered successful by default.
Future<dynamic> getJson<T>(uri, {
  Map<String, String> headers,
  ErrorCheck errorCheck,
}) => get(uri, headers: headers, bodyParser: jsonBody, errorCheck: errorCheck);

/// Checking HTTP status code for failures
http.Response _checkHttpError(http.Response resp) {
  if (resp.statusCode < 200 || resp.statusCode >= 300) {
    throw HttpException("${resp.request.method} ${resp.request.url} failed: ${resp.statusCode}");
  }
  return resp;
}
