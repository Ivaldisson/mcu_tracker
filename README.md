# MCU Watch Tracker

A Flutter app for tracking your way through the Marvel Cinematic Universe —
movies, series, specials and shorts — with two ways to watch: **story
(chronological) order**, or **release order**.

Built for personal use, shared here in case it's useful (or forkable) for
anyone else doing an MCU watch-through.

## Features

- **Two viewing orders**
  - *Chronological*: grouped into year sections with month subsections,
    following the in-universe timeline (including "timey-wimey" placement
    estimates for titles that don't fit a clean spot).
  - *Release order*: grouped by era/phase, following real-world release
    order.
- **Per-episode progress** for series — expand a title to see its season's
  episodes and check them off individually, not just "watched/unwatched" for
  the whole season.
- **TMDB integration** — synopsis, poster art and episode lists are fetched
  live from [The Movie Database](https://www.themoviedb.org/) and cached
  locally.
- **Importance tiers** (critical / high / medium / low) with quick filters,
  plus a bulk "skip" option to exclude whole tiers from your watch bar.
- **Watch bar** showing total/watched/remaining runtime for whatever's
  currently visible.
- Dutch and English localization (`lib/l10n`).

## How it's built

This is a Flutter client. Content (titles, ordering, episodes, importance,
era/phase, etc.) is *not* bundled into the app — it's fetched from a small
private backend ("mcuapi") over a simple authenticated REST API
(`lib/services/api_service.dart`) and cached locally in SQLite
(`lib/services/database_helper.dart`). Watch/skip progress and the TMDB
cache are entirely local to your device — nothing about *your* progress is
sent anywhere.

**If you fork this repo, the bundled backend URL won't be usable** — it
points at the maintainer's own private server. To run this app yourself
you'll need either access to that backend, or your own server implementing
the same `/content` contract (see `ApiService.fetchContent` and
`ContentItem.fromJson` for the expected shape). This may get open-sourced
separately at some point — check back, or open an issue if you're
interested.

## Getting started

### Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install), channel
  stable (Dart SDK `^3.13.2`, per `pubspec.yaml`)
- An Android/iOS toolchain if you want to build for a device (Android Studio
  SDK / Xcode)
- A [TMDB API Read Access Token](https://www.themoviedb.org/settings/api)
  (free) for synopsis/poster/episode data
- Access to an mcuapi-compatible content backend (see above)

### Setup

```bash
git clone https://github.com/Ivaldisson/mcu_tracker.git
cd mcu_tracker
flutter pub get
```

Copy the API keys template and fill in your own keys — this file is
gitignored, so your keys never end up in version control:

```bash
cp lib/services/api_keys.template.dart lib/services/api_keys.dart
```

Then edit `lib/services/api_keys.dart`:

```dart
class ApiKeys {
  static const String mcuApiKey = 'your mcuapi X-API-Key';
  static const String tmdbReadAccessToken = 'your TMDB read access token';
}
```

Also update `ApiService.baseUrl` in `lib/services/api_service.dart` to point
at your own content backend.

### Run

```bash
flutter run
```

### Build a release APK

Release builds need their own signing key — generate one and point
`android/key.properties` (gitignored) at it, following the
[Flutter Android deployment guide](https://docs.flutter.dev/deployment/android#signing-the-app):

```properties
storePassword=...
keyPassword=...
keyAlias=...
storeFile=/absolute/path/to/your.keystore
```

```bash
flutter build apk --release
```

## Project status

Currently used for personal tracking only — not published to any app
store. `TODO.md` in this repo tracks known issues and planned work.

## Support

If this was useful to you, consider buying me a coffee:
[ko-fi.com/ivaldisson](https://ko-fi.com/ivaldisson)
