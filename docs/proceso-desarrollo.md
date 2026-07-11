# Historial de Prompts y Proceso de Desarrollo

## Fase 1: Concepción e Inicialización (Gemini CLI)
**Prompt Inicial:**
> "inicia esta carpeta como workspace. Quiero que crees una app totalmente funcional desde 0. La app es un afinador simple de guitarra, con las tipicas opciones comunes a los afinadores. Muy simple. Debe funcionar en android. Que tenga una estetica acorde con las ultimas tendencias de android. Haz todo el proceso hasta que la app este totalmente funcional. Genera la apk lista para probar en mi Android."

**Proceso:**
1. **Investigación de entorno**: Se detectó que el usuario tenía Flutter y Java instalados.
2. **Creación del proyecto**: `flutter create --platforms android --org com.damianotero.tuner .`
3. **Selección de stack**: `flutter_audio_capture`, `pitch_detector_dart`, `permission_handler`.

## Fase 2: Implementación Técnica y Depuración (Gemini CLI)
**Proceso:**
1. **Configuración nativa**: Adición de `RECORD_AUDIO` en `AndroidManifest.xml`.
2. **Desarrollo de UI**: Creación de un medidor analógico usando `CustomPainter`.
3. **Resolución de errores**: API asíncronas, renombrado de `getPitch` a `getPitchFromFloatBuffer`.

## Fase 3: Corrección de Funcionamiento (Gemini CLI)
**Feedback del usuario:**
> "la instale pero no funciona, muestra el medidor pero no hace nada, ni siquiera pide permiso para usar el micro"

**Corrección**: Se identificó que `flutter_audio_capture` requiere `.init()` antes de `.start()`. Se añadió la inicialización explícita y solicitud de permisos.

## Fase 4: Personalización Estética (Gemini CLI)
**Prompt del usuario:**
> "funciona. por ultimo le puedes cambiar el aspecto y hacerla con estetica cyberpunk?"

**Resultado**: Neural Tuner v1.0 con colores neón (Cian Eléctrico y Rosa Neón), efectos de brillo, tipografía monoespaciada.

---

## Fase 5: Mejoras v2.0 (Claude Code)
**Prompt del usuario:**
> "Quiero que con solamente este prompt hagas todos los cambios que veas conveniente y mejores esta app. Debes darme una apk que yo pueda probar en mi android."

**Análisis previo de Claude:**
- Problema de async sin throttle: callback de audio lanzaba futures concurrentes (~21/seg).
- Solo detectaba 6 cuerdas (no es un afinador real).
- Sin manejo de permiso denegado.
- Sin estado de "sin señal".

Detalle completo de los cambios implementados (modo cromático, 4 afinaciones, throttle, timeout de señal, pantalla de permiso denegado, zona verde del medidor) en `docs/session-log.md` → **Sesión 002 — 2026-04-17 (Claude Code)**.

**APK generada**: `build/app/outputs/flutter-apk/app-release.apk` (42.8 MB)
