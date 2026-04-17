import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const TunerApp());
}

enum TunerMode { guitar, chromatic }

const List<String> _noteNames = [
  'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
];

const Map<String, Map<String, double>> _tunings = {
  'Standard': {
    'E2': 82.41, 'A2': 110.00, 'D3': 146.83,
    'G3': 196.00, 'B3': 246.94, 'E4': 329.63,
  },
  'Drop D': {
    'D2': 73.42, 'A2': 110.00, 'D3': 146.83,
    'G3': 196.00, 'B3': 246.94, 'E4': 329.63,
  },
  'Open G': {
    'D2': 73.42, 'G2': 98.00, 'D3': 146.83,
    'G3': 196.00, 'B3': 246.94, 'D4': 293.66,
  },
  'DADGAD': {
    'D2': 73.42, 'A2': 110.00, 'D3': 146.83,
    'G3': 196.00, 'A3': 220.00, 'D4': 293.66,
  },
};

class TunerApp extends StatelessWidget {
  const TunerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neural Tuner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.dark,
        ),
      ),
      home: const TunerHomePage(),
    );
  }
}

class TunerHomePage extends StatefulWidget {
  const TunerHomePage({super.key});

  @override
  State<TunerHomePage> createState() => _TunerHomePageState();
}

class _TunerHomePageState extends State<TunerHomePage> {
  final _audioCapture = FlutterAudioCapture();
  final _pitchDetector = PitchDetector(audioSampleRate: 44100, bufferSize: 2048);

  TunerMode _mode = TunerMode.guitar;
  String _selectedTuning = 'Standard';
  bool _permissionDenied = false;
  bool _hasSignal = false;
  bool _processing = false;

  double _frequency = 0.0;
  String _note = '-';
  int _octave = 4;
  double _diff = 0.0;

  DateTime? _lastUpdate;
  DateTime? _lastSignal;
  Timer? _signalTimer;

  static const _updateInterval = Duration(milliseconds: 80); // ~12 fps
  static const _signalTimeout = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _signalTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_lastSignal != null &&
          DateTime.now().difference(_lastSignal!) > _signalTimeout &&
          _hasSignal &&
          mounted) {
        setState(() {
          _hasSignal = false;
          _note = '-';
          _frequency = 0.0;
          _diff = 0.0;
        });
      }
    });
  }

  Future<void> _requestPermission() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      await _audioCapture.init();
      _startCapture();
    } else if (mounted) {
      setState(() => _permissionDenied = true);
    }
  }

  void _startCapture() {
    _audioCapture.start(
      (dynamic obj) async {
        if (_processing) return;
        final now = DateTime.now();
        if (_lastUpdate != null && now.difference(_lastUpdate!) < _updateInterval) return;

        _processing = true;
        try {
          final buffer = List<double>.from(obj);
          final result = await _pitchDetector.getPitchFromFloatBuffer(buffer);
          if (result.pitched) {
            _lastUpdate = DateTime.now();
            _lastSignal = DateTime.now();
            _updateTuning(result.pitch);
          }
        } finally {
          _processing = false;
        }
      },
      (Object e) => debugPrint(e.toString()),
      sampleRate: 44100,
      bufferSize: 2048,
    );
  }

  void _updateTuning(double frequency) {
    String noteName;
    int octave;
    double cents;

    if (_mode == TunerMode.chromatic) {
      final semitones = 12 * log(frequency / 440.0) / log(2);
      final n = semitones.round();
      final midiNote = 69 + n;
      noteName = _noteNames[midiNote % 12];
      octave = midiNote ~/ 12 - 1;
      final targetFreq = 440.0 * pow(2.0, n / 12.0).toDouble();
      cents = 1200 * log(frequency / targetFreq) / log(2);
    } else {
      final tuning = _tunings[_selectedTuning]!;
      String closestKey = '-';
      double minDiff = double.infinity;
      double targetFreq = 0.0;

      tuning.forEach((key, freq) {
        final diff = (frequency - freq).abs();
        if (diff < minDiff) {
          minDiff = diff;
          closestKey = key;
          targetFreq = freq;
        }
      });

      noteName = closestKey.replaceAll(RegExp(r'\d'), '');
      octave = int.tryParse(closestKey.replaceAll(RegExp(r'[^\d]'), '')) ?? 4;
      cents = targetFreq > 0 ? 1200 * log(frequency / targetFreq) / log(2) : 0.0;
    }

    if (mounted) {
      setState(() {
        _frequency = frequency;
        _note = noteName;
        _octave = octave;
        _diff = cents.clamp(-50.0, 50.0);
        _hasSignal = true;
      });
    }
  }

  @override
  void dispose() {
    _signalTimer?.cancel();
    _audioCapture.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionDenied) return _buildPermissionDenied();

    final bool isInTune = _hasSignal && _diff.abs() < 5;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0221),
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.1), width: 2),
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              const Color(0xFF1B065E).withValues(alpha: 0.3),
              const Color(0xFF0D0221),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildModeToggle(),
              if (_mode == TunerMode.guitar) _buildTuningSelector(),
              Expanded(child: _buildTunerDisplay(isInTune)),
              if (_mode == TunerMode.guitar) _buildGuitarStrings(isInTune),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Colors.cyanAccent, Colors.pinkAccent],
        ).createShader(bounds),
        child: const Text(
          'NEURAL TUNER v2.0',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 8,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: TunerMode.values.map((mode) {
          final isSelected = _mode == mode;
          final label = mode == TunerMode.guitar ? 'GUITAR' : 'CHROMATIC';
          return GestureDetector(
            onTap: () => setState(() {
              _mode = mode;
              _hasSignal = false;
              _note = '-';
              _diff = 0.0;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.cyanAccent.withValues(alpha: 0.1)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.cyanAccent : Colors.white12,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.cyanAccent : Colors.white38,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTuningSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _tunings.keys.map((tuning) {
            final isSelected = _selectedTuning == tuning;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedTuning = tuning;
                _hasSignal = false;
                _note = '-';
                _diff = 0.0;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.pinkAccent.withValues(alpha: 0.15)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? Colors.pinkAccent : Colors.white12,
                  ),
                ),
                child: Text(
                  tuning.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    letterSpacing: 1,
                    color: isSelected ? Colors.pinkAccent : Colors.white38,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTunerDisplay(bool isInTune) {
    final accentColor = !_hasSignal
        ? Colors.white24
        : isInTune
            ? Colors.greenAccent
            : Colors.pinkAccent;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: _hasSignal
                    ? [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.1),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                      ]
                    : null,
              ),
            ),
            CustomPaint(
              size: const Size(300, 200),
              painter: TunerPainter(
                diff: _hasSignal ? _diff : 0.0,
                color: accentColor,
                hasSignal: _hasSignal,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _hasSignal ? _note : '-',
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w900,
                    color: isInTune && _hasSignal
                        ? Colors.greenAccent
                        : Colors.cyanAccent,
                    shadows: [
                      Shadow(
                        color: (isInTune && _hasSignal
                                ? Colors.greenAccent
                                : Colors.cyanAccent)
                            .withValues(alpha: _hasSignal ? 0.8 : 0.2),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
                if (_mode == TunerMode.chromatic && _hasSignal)
                  Text(
                    'OCT $_octave',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                      color: Colors.pinkAccent.withValues(alpha: 0.7),
                      letterSpacing: 2,
                    ),
                  ),
                Text(
                  _hasSignal ? '${_frequency.toStringAsFixed(1)} HZ' : '--- HZ',
                  style: TextStyle(
                    fontSize: 16,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.05),
            border: Border.all(color: accentColor, width: 1),
          ),
          child: Text(
            _buildStatusText(isInTune),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ),
        if (_hasSignal) ...[
          const SizedBox(height: 10),
          Text(
            '${_diff >= 0 ? '+' : ''}${_diff.toStringAsFixed(1)} cents',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: isInTune ? Colors.greenAccent : Colors.white38,
              letterSpacing: 1,
            ),
          ),
        ],
      ],
    );
  }

  String _buildStatusText(bool isInTune) {
    if (!_hasSignal) return 'SCANNING...';
    if (isInTune) return '>>> SYSTEM STABLE <<<';
    return _diff > 0 ? 'SIGNAL: HIGH FREQ (+)' : 'SIGNAL: LOW FREQ  (-)';
  }

  Widget _buildGuitarStrings(bool isInTune) {
    final tuning = _tunings[_selectedTuning]!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: tuning.keys.map((key) {
          final keyNote = key.replaceAll(RegExp(r'\d'), '');
          final keyOctave = int.tryParse(key.replaceAll(RegExp(r'[^\d]'), '')) ?? 4;
          final isCurrent = _hasSignal && _note == keyNote && _octave == keyOctave;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                key,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'monospace',
                  color: isCurrent
                      ? (isInTune ? Colors.greenAccent : Colors.cyanAccent)
                      : Colors.white24,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 28,
                height: 2,
                color: isCurrent
                    ? (isInTune ? Colors.greenAccent : Colors.pinkAccent)
                    : Colors.transparent,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0221),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mic_off, color: Colors.pinkAccent, size: 64),
              const SizedBox(height: 24),
              const Text(
                'ACCESO DENEGADO',
                style: TextStyle(
                  color: Colors.pinkAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Neural Tuner necesita acceso al micrófono para detectar el tono de tu instrumento.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, height: 1.6),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: openAppSettings,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.cyanAccent),
                  ),
                  child: const Text(
                    'ABRIR AJUSTES',
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      letterSpacing: 3,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TunerPainter extends CustomPainter {
  final double diff;
  final Color color;
  final bool hasSignal;

  TunerPainter({required this.diff, required this.color, required this.hasSignal});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.8);
    const radius = 140.0;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi, pi, false, bgPaint,
    );

    // Green zone (±5 cents = ±0.04π from center)
    final greenZonePaint = Paint()
      ..color = Colors.greenAccent.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.5 * pi - 0.04 * pi, 0.08 * pi, false, greenZonePaint,
    );

    // Tick marks
    final tickPaint = Paint()..strokeWidth = 1;
    for (int i = 0; i <= 20; i++) {
      final angle = pi + (pi * i / 20);
      final isMain = i % 5 == 0;
      final isCenter = i == 10;
      tickPaint.color = isCenter
          ? Colors.greenAccent.withValues(alpha: 0.9)
          : isMain
              ? Colors.cyanAccent.withValues(alpha: 0.5)
              : Colors.cyanAccent.withValues(alpha: 0.2);
      final tickLen = isCenter ? 18 : (isMain ? 14 : 5);
      final p1 = Offset(
        center.dx + (radius - tickLen) * cos(angle),
        center.dy + (radius - tickLen) * sin(angle),
      );
      final p2 = Offset(
        center.dx + (radius + 10) * cos(angle),
        center.dy + (radius + 10) * sin(angle),
      );
      canvas.drawLine(p1, p2, tickPaint);
    }

    // Needle
    if (hasSignal) {
      final needleAngle = 1.5 * pi + (diff / 50.0) * (pi * 0.4);
      final needleEnd = Offset(
        center.dx + (radius + 20) * cos(needleAngle),
        center.dy + (radius + 20) * sin(needleAngle),
      );

      final needlePaint = Paint()
        ..color = color
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawLine(center, needleEnd, needlePaint);

      canvas.drawCircle(
        needleEnd, 5,
        Paint()
          ..color = color.withValues(alpha: 0.5)
          ..style = PaintingStyle.fill,
      );
    }

    canvas.drawCircle(center, 4, Paint()..color = Colors.cyanAccent);
  }

  @override
  bool shouldRepaint(covariant TunerPainter oldDelegate) {
    return oldDelegate.diff != diff ||
        oldDelegate.color != color ||
        oldDelegate.hasSignal != hasSignal;
  }
}
