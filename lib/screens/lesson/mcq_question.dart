import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/question.dart';
import '../../services/audio_service.dart';

class McqQuestion extends StatefulWidget {
  const McqQuestion({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  final Question question;
  final void Function(bool isCorrect) onAnswer;

  @override
  State<McqQuestion> createState() => _McqQuestionState();
}

class _McqQuestionState extends State<McqQuestion> {
  String? _selectedOption;
  bool _answered = false;

  void _handleTap(String option) {
    if (_answered) return;
    final isCorrect = option == widget.question.correctAnswer;
    setState(() {
      _selectedOption = option;
      if (isCorrect) {
        _answered = true;
      }
    });
    widget.onAnswer(isCorrect);
  }

  Color _optionBackground(String option, bool isDark) {
    if (option == _selectedOption && option != widget.question.correctAnswer) {
      return isDark ? const Color(0xFF4A1E24) : const Color(0xFFFFECEF);
    }
    if (_answered && option == widget.question.correctAnswer) {
      return isDark ? const Color(0xFF133827) : const Color(0xFFE8F8F0);
    }
    if (!_answered && _selectedOption == option) {
      return isDark ? const Color(0xFF372654) : const Color(0xFFF3E8FF);
    }
    return isDark ? const Color(0xFF232038) : Colors.white;
  }

  Color _optionBorderColor(String option, bool isDark) {
    if (option == _selectedOption && option != widget.question.correctAnswer) {
      return Colors.red.shade400;
    }
    if (_answered && option == widget.question.correctAnswer) {
      return const Color(0xFF10B981);
    }
    if (!_answered && _selectedOption == option) {
      return const Color(0xFF8B5CF6);
    }
    return isDark ? const Color(0xFF332D50) : const Color(0xFFE2D9F3);
  }

  Color _optionBottomShadowColor(String option, bool isDark) {
    if (option == _selectedOption && option != widget.question.correctAnswer) {
      return Colors.red.shade700;
    }
    if (_answered && option == widget.question.correctAnswer) {
      return const Color(0xFF059669);
    }
    if (!_answered && _selectedOption == option) {
      return const Color(0xFF6D28D9);
    }
    return isDark ? const Color(0xFF181528) : const Color(0xFFD1C4E9);
  }

  IconData? _optionIcon(String option) {
    if (_answered && option == widget.question.correctAnswer) {
      return Icons.check_circle_rounded;
    }
    if (option == _selectedOption && option != widget.question.correctAnswer) {
      return Icons.cancel_rounded;
    }
    return null;
  }

  Color _optionIconColor(String option) {
    if (option == widget.question.correctAnswer) {
      return const Color(0xFF10B981);
    }
    return Colors.red.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ───────── Arab so'zi — Deluxe Romantic Calligraphy Card ─────────
            Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 26,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              const Color(0xFF282344),
                              const Color(0xFF332A54),
                              const Color(0xFF231D3C),
                            ]
                          : [
                              const Color(0xFFFAF5FF),
                              const Color(0xFFF3E8FF),
                              const Color(0xFFFDF2F8),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF4C3D77)
                          : const Color(0xFFDDD6FE),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED)
                            .withValues(alpha: isDark ? 0.25 : 0.09),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Romantic corner ornaments
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Text(
                          '🌸',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.pink.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Text(
                          '✨',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.amber.withValues(alpha: 0.6),
                          ),
                        ),
                      ),

                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Arabic Calligraphy
                          Text(
                            widget.question.arabic,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 58,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFFE9D5FF)
                                  : const Color(0xFF4C1D95),
                              height: 1.35,
                              shadows: [
                                Shadow(
                                  color: const Color(0xFF7C3AED)
                                      .withValues(alpha: 0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ).animate().scale(
                            duration: 350.ms,
                            curve: Curves.easeOutBack,
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1, 1),
                          ),

                          const SizedBox(height: 10),

                          // Interactive Pronunciation Capsule
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () => AudioService.instance.speak(
                                widget.question.arabic,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF382F5C)
                                      : Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF5D4E8E)
                                        : const Color(0xFFC4B5FD),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF8B5CF6)
                                          .withValues(alpha: 0.12),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.volume_up_rounded,
                                      size: 19,
                                      color: Color(0xFF7C3AED),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        '[ ${widget.question.transliteration} ]',
                                        style: TextStyle(
                                          color: isDark
                                              ? const Color(0xFFDDD6FE)
                                              : const Color(0xFF5B21B6),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          letterSpacing: 0.5,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '🔊',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.purple.shade300,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 350.ms)
                .slideY(begin: -0.1, end: 0, curve: Curves.easeOutCubic),

            const SizedBox(height: 10),

            // Prompt Question
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🌷', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  'Qaysi ma\'no to\'g\'ri?',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFC4B5FD)
                        : const Color(0xFF6B21A8),
                    letterSpacing: 0.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(width: 6),
                const Text('🌸', style: TextStyle(fontSize: 16)),
              ],
            ).animate().fadeIn(delay: 80.ms),

            const SizedBox(height: 14),

            // ───────── 3D Tactile Option Buttons (A, B, C, D) ─────────
            ...widget.question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isCorrectOption =
                  _answered && option == widget.question.correctAnswer;
              final isWrongSelected =
                  option == _selectedOption &&
                  option != widget.question.correctAnswer;

              Widget optionCard = Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: _optionBackground(option, isDark),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _optionBorderColor(option, isDark),
                      width: 2,
                    ),
                    boxShadow: [
                      // 3D tactile bottom bevel shadow
                      BoxShadow(
                        color: _optionBottomShadowColor(option, isDark),
                        offset: const Offset(0, 4),
                        blurRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.3 : 0.05,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _handleTap(option),
                      borderRadius: BorderRadius.circular(20),
                      splashColor: const Color(0xFF8B5CF6)
                          .withValues(alpha: 0.15),
                      highlightColor: const Color(0xFF8B5CF6)
                          .withValues(alpha: 0.08),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            // Circular letter badge (A, B, C, D)
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isCorrectOption
                                      ? [
                                          const Color(0xFF10B981),
                                          const Color(0xFF059669),
                                        ]
                                      : isWrongSelected
                                      ? [
                                          Colors.red.shade400,
                                          Colors.red.shade600,
                                        ]
                                      : [
                                          const Color(0xFF8B5CF6),
                                          const Color(0xFF7C3AED),
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (isCorrectOption
                                                ? Colors.green
                                                : isWrongSelected
                                                ? Colors.red
                                                : const Color(0xFF8B5CF6))
                                            .withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index), // A, B, C, D
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Option Text
                            Expanded(
                              child: Text(
                                option,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1F1A3A),
                                ),
                              ),
                            ),

                            // Result Icon (Checkmark / Cancel)
                            if (_optionIcon(option) != null)
                              Icon(
                                _optionIcon(option),
                                color: _optionIconColor(option),
                                size: 26,
                              ).animate().scale(
                                duration: 300.ms,
                                curve: Curves.elasticOut,
                                begin: const Offset(0.2, 0.2),
                                end: const Offset(1, 1),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );

              // Correct answer bounce or wrong answer shake
              if (isCorrectOption) {
                optionCard = optionCard.animate().scale(
                  duration: 300.ms,
                  curve: Curves.elasticOut,
                  begin: const Offset(1, 1),
                  end: const Offset(1.025, 1.025),
                );
              } else if (isWrongSelected) {
                optionCard = optionCard.animate().shakeX(
                  amount: 6,
                  duration: 350.ms,
                );
              }

              // Staggered initial entrance animation
              return optionCard
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: 100 + index * 70),
                    duration: 300.ms,
                  )
                  .slideY(begin: 0.15, end: 0, curve: Curves.easeOutBack);
            }),
          ],
        ),
      ),
    );
  }
}
