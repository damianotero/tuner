import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const TunerApp());
}

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
  
  double _frequency = 0.0;
  String _note = '-';
  double _diff = 0.0;

  final Map<String, double> guitarNotes = {
    'E2': 82.41,
    'A2': 110.00,
    'D3': 146.83,
    'G3': 196.00,
    'B3': 246.94,
    'E4': 329.63,
  };

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      await _audioCapture.init();
      _startCapture();
    }
  }

  void _startCapture() {
    _audioCapture.start(
      (dynamic obj) async {
        final buffer = List<double>.from(obj);
        final result = await _pitchDetector.getPitchFromFloatBuffer(buffer);
        
        if (result.pitched) {
          _updateTuning(result.pitch);
        }
      },
      (Object e) => debugPrint(e.toString()),
      sampleRate: 44100,
      bufferSize: 2048,
    );
  }

  void _updateTuning(double frequency) {
    String closestNote = '-';
    double minDiff = double.infinity;
    double targetFreq = 0.0;

    guitarNotes.forEach((note, freq) {
      final diff = (frequency - freq).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestNote = note;
        targetFreq = freq;
      }
    });

    if (targetFreq > 0) {
      final cents = 1200 * (log(frequency / targetFreq) / log(2));
      if (mounted) {
        setState(() {
          _frequency = frequency;
          _note = closestNote;
          _diff = cents.clamp(-50.0, 50.0);
        });
      }
    }
  }

  @override
  void dispose() {
    _audioCapture.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAfinado = _diff.abs() < 5;

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.cyanAccent, Colors.pinkAccent],
                ).createShader(bounds),
                child: const Text(
                  'NEURAL TUNER v1.0',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isAfinado ? Colors.greenAccent : Colors.pinkAccent).withValues(alpha: 0.1),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  CustomPaint(
                    size: const Size(300, 200),
                    painter: TunerPainter(
                      diff: _diff,
                      color: isAfinado ? Colors.greenAccent : Colors.pinkAccent,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        _note.replaceAll(RegExp(r'\d'), ''),
                        style: TextStyle(
                          fontSize: 100,
                          fontWeight: FontWeight.w900,
                          color: isAfinado ? Colors.greenAccent : Colors.cyanAccent,
                          shadows: [
                            Shadow(
                              color: (isAfinado ? Colors.greenAccent : Colors.cyanAccent).withValues(alpha: 0.8),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${_frequency.toStringAsFixed(1)} HZ',
                        style: TextStyle(
                          fontSize: 20,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          color: Colors.pinkAccent.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 50),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                decoration: BoxDecoration(
                  color: (isAfinado ? Colors.greenAccent : Colors.pinkAccent).withValues(alpha: 0.05),
                  border: Border.all(
                    color: isAfinado ? Colors.greenAccent : Colors.pinkAccent,
                    width: 1,
                  ),
                ),
                child: Text(
                  isAfinado ? '>>> SYSTEM STABLE <<<' : (_diff > 5 ? 'SIGNAL: HIGH FREQ' : (_diff < -5 ? 'SIGNAL: LOW FREQ' : 'SCANNING...')),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.white70,
                  ),
                ),
              ),
              
              const Spacer(),
              
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: guitarNotes.keys.map((note) {
                    final bool isCurrent = _note == note;
                    return Column(
                      children: [
                        Text(
                          note,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'monospace',
                            color: isCurrent ? Colors.cyanAccent : Colors.white24,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 30,
                          height: 2,
                          color: isCurrent ? Colors.pinkAccent : Colors.transparent,
                        )
                      ],
                    );
                  }).toList(),
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

  TunerPainter({required this.diff, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.8);
    const radius = 140.0;

    final bgPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      bgPaint,
    );

    final tickPaint = Paint()..strokeWidth = 1;
    for (int i = 0; i <= 20; i++) {
      final angle = pi + (pi * i / 20);
      final isMain = i % 5 == 0;
      tickPaint.color = isMain ? Colors.cyanAccent.withValues(alpha: 0.5) : Colors.cyanAccent.withValues(alpha: 0.2);
      
      final p1 = Offset(center.dx + (radius - (isMain ? 15 : 5)) * cos(angle), center.dy + (radius - (isMain ? 15 : 5)) * sin(angle));
      final p2 = Offset(center.dx + (radius + 10) * cos(angle), center.dy + (radius + 10) * sin(angle));
      canvas.drawLine(p1, p2, tickPaint);
    }

    final needlePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final needleAngle = 1.5 * pi + (diff / 50.0) * (pi * 0.4);
    final needleEnd = Offset(
      center.dx + (radius + 20) * cos(needleAngle),
      center.dy + (radius + 20) * sin(needleAngle),
    );

    canvas.drawLine(center, needleEnd, needlePaint);
    
    final scanPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(needleEnd, 5, scanPaint);
    canvas.drawCircle(center, 4, Paint()..color = Colors.cyanAccent);
  }

  @override
  bool shouldRepaint(covariant TunerPainter oldDelegate) {
    return oldDelegate.diff != diff || oldDelegate.color != color;
  }
}
