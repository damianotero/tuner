# Neural Tuner

Afinador de guitarra para Android con estética cyberpunk, construido con Flutter.

## Características

- **Modo Guitar** — afina las 6 cuerdas con detección por cuerda activa
- **Modo Chromatic** — detecta cualquier nota musical (C a B, todas las octavas)
- **4 afinaciones** — Standard, Drop D, Open G, DADGAD
- **Medidor analógico** — aguja con zona verde central (±5 cents)
- **Display de cents** — desviación numérica en tiempo real
- **Timeout de señal** — reset automático si no hay audio por 2 segundos
- **Manejo de permisos** — pantalla de error si el micrófono es denegado
- **Estética cyberpunk** — colores neón (cian/rosa), efectos de brillo

## Stack técnico

- Flutter 3.x + Dart
- `flutter_audio_capture` — captura de audio en tiempo real
- `pitch_detector_dart` — detección de frecuencia fundamental
- `permission_handler` — permisos de micrófono

## Construcción

```bash
flutter pub get
flutter build apk --release
# APK en: build/app/outputs/flutter-apk/app-release.apk
```

## Historia

Construido desde 0 con Gemini CLI en 3 prompts (v1.0), luego mejorado con Claude Code (v2.0).
Ver `docs/proceso-desarrollo.md` para el historial completo.
