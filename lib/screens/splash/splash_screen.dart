import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../onboarding/beranda_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _navigationTimer;
  bool _soundStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..forward();
    _playSplashSound();

    _navigationTimer = Timer(const Duration(milliseconds: 4100), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, _) => const BerandaScreen(),
          transitionsBuilder: (_, animation, _, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.025),
                  end: Offset.zero,
                ).animate(curvedAnimation),
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.985,
                    end: 1.0,
                  ).animate(curvedAnimation),
                  child: child,
                ),
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  Future<void> _playSplashSound() async {
    try {
      await _audioPlayer.play(AssetSource('icons/splash_sound.mp3'));
      if (mounted) {
        setState(() => _soundStarted = true);
      }
    } on AudioPlayerException {
      // Splash animation remains usable when audio is unavailable.
    }
  }

  void _enableWebSound() {
    if (_soundStarted) return;
    _playSplashSound();
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final value = _controller.value;
          final size = MediaQuery.sizeOf(context);
          final logoSize = math.min(size.width * 0.52, 220.0);

          return GestureDetector(
            onTap: kIsWeb ? _enableWebSound : null,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: logoSize,
                          height: logoSize * 1.28,
                          child: CustomPaint(
                            painter: _NirvaLogoPainter(
                              progress: Curves.easeOutBack.transform(
                                _interval(value, 0.0, 0.62),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 34),
                        Opacity(
                          opacity: Curves.easeOut.transform(
                            _interval(value, 0.58, 0.88),
                          ),
                          child: Transform.translate(
                            offset: Offset(
                              0,
                              18 *
                                  (1 -
                                      Curves.easeOut.transform(
                                        _interval(value, 0.58, 0.88),
                                      )),
                            ),
                            child: const Text(
                              'NIRVA UMKM',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF347A59),
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Opacity(
                          opacity: Curves.easeOut.transform(
                            _interval(value, 0.72, 1.0),
                          ),
                          child: const Text(
                            'Kelola usaha, kembangkan potensi.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF718078),
                              fontSize: 14,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (kIsWeb && !_soundStarted)
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 32,
                    child: IgnorePointer(
                      child: Text(
                        'Ketuk layar untuk menyalakan suara',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF347A59).withValues(alpha: 0.75),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _interval(double value, double begin, double end) {
    return ((value - begin) / (end - begin)).clamp(0.0, 1.0);
  }
}

class _NirvaLogoPainter extends CustomPainter {
  const _NirvaLogoPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = math.min(size.width, size.height);
    final logoSize = unit * progress;
    final left = (size.width - logoSize) / 2;
    final top = (size.height - logoSize) / 2;
    final rect = Rect.fromLTWH(left, top, logoSize, logoSize);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(logoSize * 0.22)),
      Paint()..color = const Color(0xFF347A59),
    );

    final leaf = Path()
      ..moveTo(left + logoSize * 0.21, top + logoSize * 0.79)
      ..cubicTo(
        left + logoSize * 0.19,
        top + logoSize * 0.43,
        left + logoSize * 0.43,
        top + logoSize * 0.20,
        left + logoSize * 0.80,
        top + logoSize * 0.20,
      )
      ..cubicTo(
        left + logoSize * 0.81,
        top + logoSize * 0.55,
        left + logoSize * 0.64,
        top + logoSize * 0.80,
        left + logoSize * 0.32,
        top + logoSize * 0.80,
      )
      ..close();
    canvas.drawPath(leaf, Paint()..color = Colors.white);

    final vein = Path()
      ..moveTo(left + logoSize * 0.20, top + logoSize * 0.80)
      ..lineTo(left + logoSize * 0.58, top + logoSize * 0.43);
    canvas.drawPath(
      vein,
      Paint()
        ..color = const Color(0xFF347A59)
        ..style = PaintingStyle.stroke
        ..strokeWidth = logoSize * 0.055,
    );
  }

  @override
  bool shouldRepaint(covariant _NirvaLogoPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
