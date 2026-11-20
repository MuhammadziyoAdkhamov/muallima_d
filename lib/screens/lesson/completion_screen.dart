import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CompletionScreen extends StatefulWidget {
  const CompletionScreen({
    super.key,
    required this.learnerName,
    required this.xpEarned,
    required this.streakDays,
    required this.onHome,
    this.isReview = false,
  });

  final String learnerName;
  final int xpEarned;
  final int streakDays;
  final VoidCallback onHome;
  final bool isReview;

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen> {
  late ConfettiController _confetti;
  Timer? _stopTimer;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    // Confetti 2 soniya yog'sin
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confetti.play();
      _stopTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) _confetti.stop();
      });
    });
  }

  @override
  void dispose() {
    _stopTimer?.cancel();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4527A0), Color(0xFF7C3AED)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Confetti — top-center dan
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: pi / 2, // pastga
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              colors: const [
                Colors.yellow,
                Colors.pink,
                Colors.lightBlueAccent,
                Colors.greenAccent,
                Colors.orangeAccent,
                Colors.white,
              ],
            ),
          ),

          // Asosiy content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 👑 Royal Crown Icon
                    Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD1DC), Color(0xFFFFE4E1), Color(0xFFFFF0F5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pink.withValues(alpha: 0.35),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('👑', style: TextStyle(fontSize: 68)),
                          ),
                        )
                        .animate()
                        .scale(
                          delay: 200.ms,
                          duration: 700.ms,
                          curve: Curves.elasticOut,
                          begin: const Offset(0, 0),
                          end: const Offset(1, 1),
                        )
                        .fadeIn(),

                    const SizedBox(height: 28),

                    // Sarlavha
                    Text(
                          'Barakalla, ${widget.learnerName}! 👑💖',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                          textAlign: TextAlign.center,
                        )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 500.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 10),

                    Text(
                      widget.isReview
                          ? 'Takrorlashni tugatdingiz!'
                          : 'Darsni muvaffaqiyatli tugatdingiz!',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                    const SizedBox(height: 8),

                    Text(
                      'Siz benuqsonsiz! Ilm yo‘lidagi har bir qadamingiz muborak bo‘lsin 🌸',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 13.5,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 550.ms, duration: 400.ms),

                    const SizedBox(height: 36),

                    // XP badge is omitted for review sessions.
                    if (!widget.isReview)
                      Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBBF24),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('⚡', style: TextStyle(fontSize: 28)),
                                const SizedBox(width: 10),
                                Text(
                                  '+${widget.xpEarned} XP',
                                  style: const TextStyle(
                                    color: Color(0xFF78350F),
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 600.ms, duration: 400.ms)
                          .scale(
                            delay: 600.ms,
                            duration: 500.ms,
                            curve: Curves.elasticOut,
                            begin: const Offset(0.6, 0.6),
                            end: const Offset(1, 1),
                          )
                          .then()
                          .shake(hz: 2, offset: const Offset(0, -4)),

                    const SizedBox(height: 20),

                    // Streak Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.streakDays} kunlik seriya!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 700.ms, duration: 400.ms),

                    const SizedBox(height: 48),

                    // Uyga qaytish tugmasi
                    SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: widget.onHome,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF4527A0),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.home_rounded, size: 24),
                                SizedBox(width: 10),
                                Text(
                                  'Uyga qaytish',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 900.ms, duration: 400.ms)
                        .slideY(begin: 0.3, end: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
