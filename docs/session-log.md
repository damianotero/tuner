# Registro de Sesiones

## Sesión 006 — 2026-07-11 (Claude Code) — Remediación docs-audit (Bloque 8 workspace-wide)

- **Qué se hizo**: Recortar duplicación en `proceso-desarrollo.md` enlazando a `session-log.md` según el plan workspace-wide [`docs/_archive/plans/docs-audit-remediation-2026-07-11-plan.md`](file:///Users/damianotero/workspace/docs/_archive/plans/docs-audit-remediation-2026-07-11-plan.md).

---

## Sesión 005 — 2026-05-24 (Claude Code) — Drop GEMINI.md symlink (limpieza arquitectura workspace)

- `GEMINI.md` eliminado (era symlink → `AGENTS.md`). Antigravity lee `AGENTS.md` directo.
- Parte de la limpieza workspace-wide post-migración Antigravity. Detalle en `~/workspace/docs/migration-antigravity-cleanup.md`.

## Sesión 004 — 2026-05-24 (Claude Code) — Migración Antigravity Fase 3: AGENTS.md + symlinks

- `AGENTS.md` creado como copia del CLAUDE.md/GEMINI.md sincronizado en la sesión 003.
- `CLAUDE.md` y `GEMINI.md` ahora son symlinks a `AGENTS.md`. Sin cambio de contenido.
- Detalle workspace-wide: `~/workspace/docs/session-log.md` sesión 2026-05-24.

## Sesión 003 — 2026-05-23 (Claude Code) — Sync CLAUDE.md y GEMINI.md

- `CLAUDE.md` era breve y en inglés; `GEMINI.md` era más completo en español. Se tomó la versión más completa como base y se sincronizaron ambos archivos (mismo contenido).
- Sin violaciones de "no tasks in context".
- Cambio aprobado por Damian antes de aplicar.

**Contexto:** Parte de la Fase 2 del plan de migración Gemini CLI → Antigravity. Detalle en `~/workspace/docs/session-log.md` sesión 2026-05-23.

## Sesión 002 — 2026-05-01 (Claude Code)
### Qué se hizo
- **Workspace-check hygiene**: envuelto `debugPrint` en `lib/main.dart:135` con guard `if (kDebugMode)` antes de distribución como APK de release.

---

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

---

## Sesión 003 — 2026-04-21 (Claude Code)
### Qué se hizo
- Creado `CLAUDE.md` con propósito, stack, comandos de dev y constraints del proyecto.
- Creado `docs/roadmap.md` con v1.0 y v2.0 en Completed y las 3 ideas futuras en Next.
- Commiteado a main.

### Archivos creados
- `CLAUDE.md`
- `docs/roadmap.md`

## Sesión 002 — 2026-04-27 (Claude Code)

### Qué se hizo
- Workspace check: agregado `.env` a `.gitignore`.
- Creado `docs/tasks.md`.
