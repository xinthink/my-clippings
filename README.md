# My Clippings - save Kindle clippings in Evernote

[![Check Status][check-badge]][github-runs]
[![MIT][license-badge]][license]

> **Demonstration Only** for now, see Limitations

Frontend for this app is built with [Flutter Web], hosted on [Firebase][Firebase Hosting], with [Cloud Functions] + [Cloud Firestore] as backend.

## Usage
Follow instrunctions on the [web page](https://notever.web.app), the app will extract clippings from `My Clippings.txt` file, under `documents` folder of Kindle devices, and create one Evernote note for each clipping.

## Limitations

This repo is still being worked on, may has situations not handled properly:

1. [Evernote API Rate Limits], importing large number of clippings may be interrupted
2. [Cloud Functions Execution Timeout], importing large number of clippings may be interrupted ([Fixed](https://github.com/xinthink/my-clippings/commit/b6153bad071a7dce58c80302905ba1cd495aad57))
3. Multilingual Kindle clippings, may cause bugs in clipping parsing or note creation

## Development
You will have to:
- Config your own [Firebase project][cloud functions get-started]
- Get your own [Evernote API key][Evernote Developer]

Create two configuration files:
1. `functions/src/local.ts` see [template][local.ts template]
2. `flt/lib/local.dart` see [template][local.dart template]

Start debug server:
```
# hosting emulator
yarn serve

# functions emulator
cd functions && yarn serve
```

Deploy Cloud Functions & Firebase Hosting:
```
# hosting deployment
yarn deploy

# functions deployment
cd functions && yarn deploy
```


[check-badge]: https://github.com/xinthink/my-clippings/workflows/Check/badge.svg
[github-runs]: https://github.com/xinthink/my-clippings/actions
[license-badge]: https://img.shields.io/github/license/xinthink/my-clippings
[license]: https://raw.githubusercontent.com/xinthink/my-clippings/master/LICENSE
[Flutter Web]: https://flutter.dev/web
[Firebase Hosting]: https://firebase.google.com/products/hosting/
[Cloud Functions]: https://firebase.google.com/products/functions/
[Cloud Firestore]: https://firebase.google.com/products/firestore/
[Evernote API Rate Limits]: https://dev.evernote.com/doc/articles/rate_limits.php
[Cloud Functions Execution Timeout]: https://cloud.google.com/functions/docs/concepts/exec#timeout
[cloud functions get-started]: https://firebase.google.com/docs/functions/get-started
[Evernote Developer]: https://dev.evernote.com/doc/
[local.ts template]: https://github.com/xinthink/my-clippings/tree/master/templates/local.ts
[local.dart template]: https://github.com/xinthink/my-clippings/tree/master/templates/local.dart
