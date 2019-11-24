import 'dart:html' show window;

import 'package:flutter/material.dart';
import 'package:notever/local.dart' show EvernoteConfig;

/// Evernote/YXBJ login widget
class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
    Card(
      color: Colors.white,
      elevation: 2,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 512,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 36),
        child: Column(
          children: <Widget>[
            _buildTitle(),
            _buildAuthOption('evernote', _IC_EVERNOTE),
            _buildOptionsDivider(),
            _buildAuthOption('yinxiang', _IC_YXBJ),
          ],
        ),
      ),
    );

  Widget _buildTitle() => Container(
    margin: const EdgeInsets.only(top: 20, bottom: 70),
    child: Center(
      child: Column(
        children: <Widget>[
          _buildLogos(),
          const SizedBox(height: 12),
          const Text('Save Kindle clippings to your Evernote notebook',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildLogos() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Image.asset(_LOGO_KINDLE, width: 70),
      const SizedBox(width: 30),
      const Icon(Icons.sync, color: Colors.grey),
      const SizedBox(width: 8),
      Image.asset(_LOGO_EVERNOTE, width: 100),
    ],
  );

  Widget _buildAuthOption(String provider, String image) => InkWell(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Continue with',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 144,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(image),
            ),
          ),
        ],
      ),
    ),
    onTap: () => window.location.href = '${EvernoteConfig.funcPrefix}/$provider/',
  );

  Widget _buildOptionsDivider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: const Text('OR',
      style: const TextStyle(
        color: Colors.black38,
        fontSize: 16,
      ),
    ),
  );
}

const _IC_EVERNOTE = 'assets/images/evernote_logo_4c-sm.png';
const _IC_YXBJ = 'assets/images/evernote_logo_4c-sm_yx.png';
const _LOGO_KINDLE = 'assets/images/logo_kindle.jpg';
const _LOGO_EVERNOTE = 'assets/images/logo_evernote.png';
