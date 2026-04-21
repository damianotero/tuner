# Neural Tuner

Chromatic guitar tuner with a cyberpunk aesthetic, built in Flutter.

## Stack

Flutter (Dart), pitch_detector_dart, flutter_audio_capture. Android-first.

## Local dev

```bash
flutter pub get
flutter run                 # requires connected device or emulator
flutter build apk           # release APK
flutter test                # run tests
```

## Constraints

- Audio capture requires physical device — emulators don't support mic input.
- Cyberpunk aesthetic is intentional: keep UI dark, neon accents, monospace font.
- No planned deployment to Play Store yet — distributed as direct APK.

See root CLAUDE.md for shared conventions.
