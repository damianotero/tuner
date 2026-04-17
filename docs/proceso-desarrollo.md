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

**Cambios implementados:**

### Funcionales
- **Modo cromático**: Detecta cualquier nota (C0 a B8) usando fórmula semitono = 12 × log₂(f/440).
- **4 afinaciones de guitarra**: Standard, Drop D, Open G, DADGAD.
- **Identificación correcta de cuerda**: Cruza nombre de nota + octava para distinguir E2 de E4.

### Rendimiento
- **Flag `_processing`**: Evita futures concurrentes en el callback de audio.
- **Throttle de 80ms**: Máximo ~12 rebuilds de UI por segundo.

### UX
- **Timeout de señal 2s**: Timer periódico resetea display cuando no hay audio.
- **Pantalla de permiso denegado**: Con botón que abre ajustes del sistema.
- **Display numérico de cents**: Desviación exacta visible debajo del status bar.

### Visual
- **Zona verde en medidor**: Arc semitransparente marca el rango ±5 cents.
- **Tick central prominente**: El centro del medidor es visualmente más claro.
- **Glow condicional**: El halo de luz solo aparece cuando hay señal activa.

**APK generada**: `build/app/outputs/flutter-apk/app-release.apk` (42.8 MB)
