import 'dart:math';
import 'package:flutter/material.dart';

class FloatingPetalsBackground extends StatefulWidget {
  const FloatingPetalsBackground({
    super.key,
    required this.child,
    this.showPetals = true,
  });

  final Widget child;
  final bool showPetals;

  @override
  State<FloatingPetalsBackground> createState() =>
      _FloatingPetalsBackgroundState();
}

class _FloatingPetalsBackgroundState extends State<FloatingPetalsBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_PetalParticle> _particles = [];
  final Random _random = Random(99);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    // 18 ta romantik zarracha — uch qator to'liq ekranni qoplaydi
    const symbols = [
      '🌸', '✨', '🌷', '💖', '🌸', '✨',
      '🌿', '💫', '🌸', '🌺', '✨', '💕',
      '🌸', '🌷', '✨', '💐', '🌸', '💖',
    ];
    for (int i = 0; i < symbols.length; i++) {
      _particles.add(
        _PetalParticle(
          symbol: symbols[i],
          x: (i / symbols.length) + (_random.nextDouble() * 0.04 - 0.02),
          startY: _random.nextDouble(),
          speed: 0.4 + (_random.nextDouble() * 0.55),
          size: 16 + (_random.nextDouble() * 14).roundToDouble(),
          baseOpacity: 0.22 + (_random.nextDouble() * 0.22),
          rotationSpeed: (_random.nextDouble() - 0.5) * 1.6,
          swayAmp: 10 + _random.nextDouble() * 18,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundGradient = isDark
        ? const LinearGradient(
            colors: [
              Color(0xFF130E2A),
              Color(0xFF1C1535),
              Color(0xFF16112A),
              Color(0xFF1F143A),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [
              Color(0xFFFDF5FF),  // mayin binafsha-oq
              Color(0xFFF8EEFF),  // lavanda
              Color(0xFFFCF0FF),  // pushti-binafsha
              Color(0xFFFFF0F8),  // atirgul pushti
            ],
            stops: [0.0, 0.33, 0.66, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Container(
      decoration: BoxDecoration(gradient: backgroundGradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Chiroyli orqa fon doiralari (Soft blurred blobs)
          if (!isDark) ...[
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFE9C6FF).withValues(alpha: 0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -50,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFB7D5).withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 200,
              left: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFC7B6FF).withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            // Dark mode blobs
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF5B21B6).withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -30,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7C3AED).withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Uchib yuruvchi gul barglari
          if (widget.showPetals)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return IgnorePointer(
                  child: CustomPaint(
                    painter: _PetalsPainter(
                      particles: _particles,
                      progress: _controller.value,
                      isDark: isDark,
                    ),
                    size: Size.infinite,
                  ),
                );
              },
            ),

          widget.child,
        ],
      ),
    );
  }
}

class _PetalParticle {
  final String symbol;
  final double x;
  final double startY;
  final double speed;
  final double size;
  final double baseOpacity;
  final double rotationSpeed;
  final double swayAmp;

  _PetalParticle({
    required this.symbol,
    required this.x,
    required this.startY,
    required this.speed,
    required this.size,
    required this.baseOpacity,
    required this.rotationSpeed,
    required this.swayAmp,
  });
}

class _PetalsPainter extends CustomPainter {
  final List<_PetalParticle> particles;
  final double progress;
  final bool isDark;

  _PetalsPainter({
    required this.particles,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    for (final p in particles) {
      final yNorm = (p.startY + progress * p.speed) % 1.0;
      final sway = sin(progress * 2 * pi * 1.3 + p.startY * 8) * p.swayAmp;
      final dx = p.x * size.width + sway;
      final dy = yNorm * size.height;

      final opacity = p.baseOpacity *
          (0.7 + 0.3 * sin(progress * 2 * pi * 0.7 + p.startY * 5));

      final textSpan = TextSpan(
        text: p.symbol,
        style: TextStyle(
          fontSize: p.size,
          color: (isDark ? Colors.white : const Color(0xFF6B21A8))
              .withValues(alpha: opacity.clamp(0.0, 1.0)),
        ),
      );

      final tp = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(progress * 2 * pi * p.rotationSpeed);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PetalsPainter old) => true;
}
