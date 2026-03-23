# Background Audio Notification Controls - Change Documentation

## Goal
Add Android background playback notification controls using just_audio_background while preserving the current architecture and existing app behavior as much as possible.

## Scope and Constraints Followed
- Kept existing folder structure and layering:
  - `lib/model` for data model
  - `lib/services` for I/O + metadata
  - `lib/ui/provider` for playback state and side effects
  - `lib/ui/screens` and `lib/ui/widgets` for presentation
- Limited changes to only files required for background playback controls.
- Kept existing screen routes and UI widget contracts unchanged.
- Targeted Android-only runtime behavior as requested.

---

## File-by-File Changes

### 1) pubspec.yaml
### What changed
- Added dependency:
  - `just_audio_background: ^0.0.1-beta.17`

### Why this was needed
- The package provides notification/lock-screen/media button integration for a single just_audio player instance.

### App impact
- Enables background media control support capability at dependency level.
- No direct UI or routing impact.

---

### 2) lib/main.dart
### What changed
- Imported `just_audio_background`.
- Converted `main()` to `Future<void> main() async`.
- Added:
  - `WidgetsFlutterBinding.ensureInitialized();`
  - `await JustAudioBackground.init(...)` before `runApp(...)`.
- Configured:
  - Android notification channel id
  - Android notification channel name
  - Ongoing notification behavior

### Why this was needed
- just_audio_background must be initialized before app startup so playback session + notification components are ready when the player is used.

### App impact
- Background notification channel is initialized once at startup.
- Existing router, ProviderScope, and UI startup flow remains unchanged.

---

### 3) lib/ui/provider/player_provider.dart
### What changed

#### A. Media queue source loading
- Replaced single-file load path (`setFilePath`) with queue source loading via:
  - `setAudioSource(ConcatenatingAudioSource(...), initialIndex: ..., initialPosition: ...)`
- Audio sources are built from existing playlist songs.

#### B. Media metadata tagging for notifications
- Added mapping from each `Song` to `AudioSource.uri(..., tag: MediaItem(...))`.
- Metadata fields used:
  - id
  - title
  - artist
  - album
  - duration
  - optional artwork URI (safe parsing)

#### C. Provider state synchronization for external controls
- Added `playingStream` listener in `PlayingState.build()` to keep Riverpod play/pause state aligned with player state.
- Added `currentIndexStream` listener in `PlayingState.build()` to keep Riverpod current index aligned when track changes happen externally (notification/media buttons).
- Added `CurrentSongIndex.syncFromPlayer(int index)` for internal state sync without re-triggering seek logic.

#### D. Existing control method compatibility
- Updated `CurrentSongIndex` methods to async so they can call player queue methods when available:
  - `setIndex` seeks to selected index when queue exists
  - `nextSong` uses `seekToNext` when possible
  - `previousSong` uses `seekToPrevious` when possible
- Existing method names and usage points in UI were preserved.

### Why this was needed
- Background notification next/previous controls operate on the player queue, not just local index state.
- MediaItem tags are required for notification metadata (title/artist/etc.).
- Stream listeners are required so external actions (notification buttons) do not desynchronize in-app provider state.

### App impact
- Playback now uses playlist queue source under the same provider architecture.
- Notification metadata reflects current track details.
- Next/previous actions from notification and app remain synchronized with current index and play state.
- Player screen and widgets continue using the same providers and callbacks.

---

### 4) android/app/src/main/AndroidManifest.xml
### What changed
- Added `tools` namespace on `<manifest>`.
- Added permissions:
  - `android.permission.WAKE_LOCK`
  - `android.permission.FOREGROUND_SERVICE`
  - `android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK`
- Updated activity class from `.MainActivity` to:
  - `com.ryanheise.audioservice.AudioServiceActivity`
- Added service declaration:
  - `com.ryanheise.audioservice.AudioService`
  - `android:foregroundServiceType="mediaPlayback"`
- Added media button receiver:
  - `com.ryanheise.audioservice.MediaButtonReceiver`

### Why this was needed
- Android background media controls require foreground playback service wiring and media button receiver registration.
- These entries are part of the package setup for notification/lock-screen/control integration.

### App impact
- Android can show and manage media playback notifications while app is backgrounded.
- Media hardware/system buttons can route to the playback session.

---

## Project Structure Alignment Justification
- No new architectural layer was introduced.
- No UI component contract changed.
- All behavior changes were isolated to:
  - startup initialization (`main.dart`)
  - playback state/control layer (`ui/provider/player_provider.dart`)
  - Android platform integration (`AndroidManifest.xml`)
- Data model and service layer remained unchanged and were reused as-is.

---

## Verification Performed
1. Ran dependency resolution:
   - `flutter pub get`
2. Regenerated code:
   - `dart run build_runner build --delete-conflicting-outputs`
3. Ran analyzer:
   - `flutter analyze`

### Analyzer result summary
- No new compile errors after integration changes.
- Remaining outputs are info-level lint warnings that already existed in the project style baseline (for example print usage and deprecation/info warnings).

---

## Behavior Summary After Change
- App still uses the same screens and provider-driven flow.
- Playback can now expose metadata-backed notification controls for Android background playback.
- Play/pause/next/previous actions can be triggered from notification and stay synchronized with in-app state through provider listeners.

---

## Known Limitations / Notes
- Artwork in notification depends on `coverUrl` being a valid URI or absolute file path; invalid values are safely ignored.
- iOS background setup was intentionally not added in this implementation because scope was Android-only.

---

## Rollback Plan (if needed)
To revert this feature safely, undo changes in:
1. `android/app/src/main/AndroidManifest.xml`
2. `lib/ui/provider/player_provider.dart`
3. `lib/main.dart`
4. `pubspec.yaml` (remove just_audio_background)
