import 'package:flutter/material.dart';

const _BACKGROUND = 'assets/images/evernote_bg.png';

/// Reusable Evernote background decoration
Decoration evernoteBackground() => const BoxDecoration(
  image: DecorationImage(
    image: AssetImage(_BACKGROUND),
    repeat: ImageRepeat.repeat,
  ),
);
