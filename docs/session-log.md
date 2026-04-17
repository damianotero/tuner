# Registro de Sesiones

## Sesión 001 — 2026-04-17
### Qué se hizo
- Inicialización del proyecto Flutter para Android con soporte Material 3.
- Configuración de permisos de micrófono en AndroidManifest.xml.
- Implementación de la lógica de procesamiento de audio en tiempo real usando `flutter_audio_capture` y `pitch_detector_dart`.
- Creación de una interfaz moderna con tema oscuro, medidor visual dinámico y selector de cuerdas de referencia.
- Resolución de conflictos de API en las librerías de audio y pitch.
- **Corrección de Permisos**: Se añadió la llamada obligatoria a `_audioCapture.init()`.
- **Rediseño Cyberpunk**: Transformación estética completa con colores Neón (Cian y Rosa), efectos de brillo (Glow), tipografía estilo "Terminal" y medidor visual rediseñado como un "Neural Scanner".
- Generación del APK final con el nuevo estilo.

### Archivos modificados
- `pubspec.yaml`: Dependencias de audio y permisos.
- `android/app/src/main/AndroidManifest.xml`: Permisos de audio.
- `lib/main.dart`: Implementación completa de la lógica y la UI Cyberpunk.
- `test/widget_test.dart`: Eliminado.

### Decisiones tomadas
- Se utilizó `ShaderMask` para crear un gradiente de texto neón en el título.
- Se implementaron efectos de sombra (`BoxShadow`) y filtros de desenfoque (`MaskFilter`) para simular luces de neón en la interfaz.
- Se cambió el nombre de la app a "Neural Tuner v1.0" para encajar con la temática.
