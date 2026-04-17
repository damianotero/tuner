# Tareas del Proyecto: Neural Tuner

## v1.0 — Completado (Gemini CLI)
- [x] Inicializar proyecto Flutter.
- [x] Configurar permisos de Android (Micrófono).
- [x] Implementar captura de audio.
- [x] Implementar detección de frecuencia (Pitch Detection).
- [x] Diseñar UI cyberpunk con medidor analógico CustomPainter.
- [x] Corregir errores de integración de librerías.
- [x] Generar APK de producción.

## v2.0 — Completado (Claude Code)
- [x] Detección cromática (todas las notas, no solo las 6 cuerdas de guitarra).
- [x] Múltiples afinaciones: Standard, Drop D, Open G, DADGAD.
- [x] Throttle de UI — máximo ~12 rebuilds/segundo (era ~21).
- [x] Flag `_processing` para evitar futures concurrentes en el callback de audio.
- [x] Timeout de señal — reset automático si no hay audio por 2 segundos.
- [x] Pantalla de permiso denegado con botón a ajustes del sistema.
- [x] Display numérico de cents (ej: +3.2 cents).
- [x] Zona verde en el medidor analógico (marca visual del centro).
- [x] Tick central más prominente en el medidor.
- [x] README actualizado con descripción real del proyecto.
- [x] Versión bumpeada a 2.0.0+2.

## Pendientes / Ideas futuras
- [ ] Metrónomo integrado.
- [ ] Afinaciones personalizadas (editar frecuencias).
- [ ] Historial de sesión de afinación.
- [ ] Soporte iOS.
