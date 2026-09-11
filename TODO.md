# TODO — MCU Watch Tracker

## Open GitHub Issues

- [ ] [#2](https://github.com/Ivaldisson/mcu_tracker/issues/2) Remove Era from release order — release order currently shows era/phase section headers; that grouping should be removed and replaced with just showing the current phase.

## UI

- [x] ~~Rework order-display UI: chronological view should use year sections with month subsections~~ — done.
  - `lib/widgets/timeline_header.dart` adds `YearHeader`/`MonthHeader`; chronological (story) order now groups by `storyDate` year/month instead of `era`.
- [x] ~~Move era/phase groupings to the release-order display~~ — done.
  - Release order now shows `EraHeader` sections (`lib/screens/content_list_screen.dart`), since phases release mostly in order — unlike story order, where flashbacks/prequels interleave eras.

## Bugs

- [x] ~~Investigate why **WandaVision** shows no episodes on expand~~ — fixed in `lib/services/tmdb_service.dart`.
  - Root cause: episodes were only fetched when the title had an explicit `(Season N)` suffix. Multi-season shows (Loki) get that suffix per season row, but single-season miniseries (WandaVision, Secret Invasion, Agatha All Along, Vision Quest) don't, so `seasonNumber` parsed as `null` and the episode fetch was skipped entirely — not a `content_type`/TMDB `type` filtering issue as originally suspected.
  - Fix: default to season 1 when no season number is present in the title.
- [x] ~~**The Defenders** pulls metadata from an unrelated 1961 courtroom drama instead of Marvel's Netflix miniseries~~ — fixed in `lib/services/tmdb_service.dart`.
  - Root cause: TMDB search took `results.first` on the plain title. TMDB's own entry for the show is titled `"Marvel's The Defenders"`, so a plain `"The Defenders"` query ranks the identically-named 1961 legal drama above it.
  - Fix: for series, search with a `"Marvel's "` prefix first (falls back to the plain title if that yields nothing) — verified against TMDB's live API across WandaVision, Loki, Hawkeye, Moon Knight, She-Hulk, Ironheart, What If...?, Daredevil and The Punisher with no regressions, since this app is exclusively Marvel content.
  - Any bad cached entry for The Defenders was already cleared by today's release reinstall, so this takes effect on first expand.

## Install/Deploy Gotchas

Lessons learned from local deploys — keep in mind for this and future Flutter projects.

- [x] ~~`INSTALL_FAILED_VERSION_DOWNGRADE` when installing a release build~~ — fixed for now.
  - Cause: the phone already had a build installed with `versionCode=2001` (from some earlier build), while `pubspec.yaml` was still at `1.0.0+1` (`versionCode=1`). Android refuses to "downgrade" a versionCode even for a resigned/rebuilt app.
  - Fix: bumped `pubspec.yaml` to `1.0.0+2002`. Before shipping to the Play Store, replace this with a real, incrementing versioning scheme (e.g. tie it to CI build number or semver) instead of an arbitrary bump.
- [x] ~~`flutter install` / `flutter run --release` silently wipes local app data on redeploy~~ — worked around.
  - Cause: when its `adb install -t -r` attempt fails for any reason, the Flutter tool falls back to a full `adb uninstall` + fresh install (see `flutter/packages/flutter_tools/lib/src/android/android_device.dart`), which wipes the app's local SQLite data (watch/skip progress, TMDB cache). Happened twice in a row on this phone (Oppo/Realme, ColorOS) — likely because ColorOS shows an on-device "install this app?" confirmation for adb-driven installs, which an unattended CLI install can't tap in time, causing the initial in-place attempt to fail and time out.
  - Confirmed this is purely a local dev-tooling quirk: a direct `adb install -t -r <apk>` between two content-different, same-signature, same-versionCode builds upgrades cleanly in place and preserves data every time.
  - Confirmed this does **not** affect production: the Play Store's own installer always does proper in-place upgrades, so this has no bearing on the eventual Play Store rollout.
  - Workaround for local test deploys: build with `flutter build apk --release`, then install with `adb install -t -r build/app/outputs/flutter-apk/app-release.apk` directly — do not use `flutter install`/`flutter run --release` for redeploying over an existing install with data you want to keep.
