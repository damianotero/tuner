# Neural Tuner

Android guitar tuner with a cyberpunk aesthetic, built with Flutter.

## Features

- **Guitar mode** — tunes all 6 strings with per-string active detection
- **Chromatic mode** — detects any musical note (C to B, all octaves)
- **4 tunings** — Standard, Drop D, Open G, DADGAD
- **Analog meter** — needle with center green zone (±5 cents)
- **Cents display** — real-time numeric deviation
- **Signal timeout** — auto-reset if no audio detected for 2 seconds
- **Permission handling** — error screen if microphone is denied
- **Cyberpunk aesthetic** — neon colors (cyan/pink), glow effects

## Stack

- Flutter 3.x + Dart
- `flutter_audio_capture` — real-time audio capture
- `pitch_detector_dart` — fundamental frequency detection
- `permission_handler` — microphone permissions

## Build

```bash
flutter pub get
flutter build apk --release
# APK output: build/app/outputs/flutter-apk/app-release.apk
```

## Background

Built from scratch with Gemini CLI in 3 prompts (v1.0), then improved with Claude Code (v2.0).
See `docs/proceso-desarrollo.md` for the full development log.
