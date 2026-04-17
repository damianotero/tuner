# Registro de Sesiones

## Sesión 001 — 2026-04-17 (Gemini CLI)
### Qué se hizo
- Inicialización del proyecto Flutter para Android con soporte Material 3.
- Configuración de permisos de micrófono en AndroidManifest.xml.
- Implementación de la lógica de procesamiento de audio en tiempo real usando `flutter_audio_capture` y `pitch_detector_dart`.
- Creación de una interfaz moderna con tema oscuro, medidor visual dinámico y selector de cuerdas de referencia.
- Resolución de conflictos de API en las librerías de audio y pitch.
- **Corrección de Permisos**: Se añadió la llamada obligatoria a `_audioCapture.init()`.
- **Rediseño Cyberpunk**: Transformación estética completa con colores Neón (Cian y Rosa), efectos de brillo (Glow), tipografía estilo "Terminal" y medidor visual rediseñado como un "Neural Scanner".
- Generación del APK final v1.0.

### Archivos modificados
- `pubspec.yaml`: Dependencias de audio y permisos.
- `android/app/src/main/AndroidManifest.xml`: Permisos de audio.
- `lib/main.dart`: Implementación completa de la lógica y la UI Cyberpunk.

### Decisiones tomadas
- Se utilizó `ShaderMask` para crear un gradiente de texto neón en el título.
- Se implementaron efectos de sombra (`BoxShadow`) y filtros de desenfoque (`MaskFilter`) para simular luces de neón.
- Se cambió el nombre de la app a "Neural Tuner v1.0".

---

## Sesión 002 — 2026-04-17 (Claude Code)
### Qué se hizo
- **Detección cromática**: Nuevo modo que detecta cualquier nota musical usando la fórmula `n = round(12 * log2(f / 440))`. Muestra nota + octava.
- **Múltiples afinaciones**: Standard, Drop D, Open G, DADGAD — selector horizontal deslizable.
- **Throttle de UI**: Flag `_processing` (evita futures concurrentes) + chequeo de intervalo mínimo de 80ms entre updates (~12 fps).
- **Timeout de señal**: Timer periódico de 500ms que resetea el display si no hay audio por 2 segundos.
- **Pantalla de permiso denegado**: UI de error con ícono, explicación y botón `openAppSettings()`.
- **Display de cents**: Texto numérico (+X.X cents) debajo del status bar.
- **Zona verde en medidor**: Arc verde semitransparente en el centro del CustomPainter (±5 cents = ±0.04π).
- **Tick central prominente**: El tick de 0 cents es más largo y más brillante.
- **Bump de versión**: 1.0.0+1 → 2.0.0+2.
- **README real**: Descripción completa reemplaza el default de Flutter.
- Generación de APK release v2.0.

### Archivos modificados
- `lib/main.dart`: Reescritura completa (~370 líneas).
- `pubspec.yaml`: Versión y descripción.
- `README.md`: Documentación real del proyecto.
- `docs/tareas.md`: Actualizado con v2.0.
- `docs/session-log.md`: Esta entrada.

### Decisiones técnicas
- Se eligió `_processing` flag sobre un `Completer` para simplicidad — el objetivo es evitar acumulación de futures, no serializar perfectamente.
- Se mantiene un solo archivo `main.dart` — el tamaño (~370 líneas) sigue siendo manejable y no justifica separar en widgets.
- La detección cromática usa A4=440Hz como referencia estándar internacional.
- En modo Guitar, la nota activa se identifica cruzando nombre de nota + octava (no solo el nombre), lo que permite distinguir E2 de E4 correctamente.
