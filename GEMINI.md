# Neural Tuner — Contexto del Proyecto

> Archivo de contexto para Gemini CLI.
> Leer este archivo al inicio de cada sesión antes de hacer cualquier cosa.

---

## Qué es este proyecto

Afinador cromático de guitarra con estética cyberpunk, construido en Flutter.
Distribuido como APK directo — sin publicación en Play Store por ahora.

**Desarrollador**: Damian Otero (no programador profesional, aprende con IA)
**Comunicar siempre en español.**

---

## Stack tecnológico

| Capa | Tecnología |
|------|-----------|
| Framework | Flutter (Dart) |
| Detección de pitch | `pitch_detector_dart` |
| Captura de audio | `flutter_audio_capture` |
| Target | Android-first |
| Distribución | APK directo (no Play Store) |

---

## Comandos de desarrollo

```bash
flutter pub get
flutter run                 # requiere dispositivo físico o emulador
flutter build apk           # genera APK release
flutter test                # corre tests
```

⚠️ La captura de audio requiere **dispositivo físico** — los emuladores no soportan entrada de micrófono.

---

## Identidad visual

- Estética **cyberpunk** — fondo oscuro, acentos neón, fuente monoespaciada
- No cambiar la estética sin instrucción explícita

---

## Reglas de trabajo

- Comunicar siempre en español
- Mantener la estética cyberpunk en cualquier cambio visual
- Al terminar: actualizar `docs/session-log.md` y `docs/tasks.md` si existen
- No añadir dependencias (`flutter pub add`) sin instrucción explícita
