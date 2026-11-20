import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../data/local_learning_store.dart';
import '../../models/question.dart';
import '../../services/audio_service.dart';
import '../../widgets/floating_petals_background.dart';
import 'completion_screen.dart';
import 'flashcard_question.dart';
import 'mcq_question.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.store,
    required this.questions,
    required this.onComplete,
    this.isReview = false,
  });

  final LocalLearningStore store;
  final List<Question> questions;
  final VoidCallback onComplete;
  final bool isReview;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _currentIndex = 0;
  int _xpEarned = 0;
  bool? _lastAnswerCorrect;
  bool _transitioning = false;
  bool _showCompletion = false;
  final DateTime _sessionStartedAt = DateTime.now();

  Future<void> _handleAnswer(bool isCorrect) async {
    if (_transitioning) return;

    final question = widget.questions[_currentIndex];

    if (!isCorrect) {
      await widget.store.recordMistake(question.id);
      setState(() {
        _lastAnswerCorrect = false;
        _transitioning = false;
      });
      return;
    }

    setState(() {
      _lastAnswerCorrect = true;
      if (!widget.isReview) _xpEarned += 20;
      _transitioning = true;
    });

    if (widget.store.dueWordIds.contains(question.id)) {
      await widget.store.resolveReview(question.id);
    }

    // 0.8s kutgach keyingisiga o'tish
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    if (_currentIndex + 1 >= widget.questions.length) {
      // Barcha savollar tugadi — session yozamiz
      final elapsedMinutes = DateTime.now()
          .difference(_sessionStartedAt)
          .inMinutes;
      final studyMinutes = elapsedMinutes > 0 ? elapsedMinutes : 1;
      final earnedReward = widget.isReview
          ? await widget.store.addStudyMinutes(studyMinutes).then((_) => false)
          : await widget.store.completeSession(
              widget.questions.map((q) => q.id),
              xpReward: _xpEarned,
              studyMinutes: studyMinutes,
            );
      if (!mounted) return;
      if (!earnedReward) _xpEarned = 0;
      setState(() {
        _showCompletion = true;
        _transitioning = false;
        _lastAnswerCorrect = null;
      });
    } else {
      setState(() {
        _currentIndex++;
        _transitioning = false;
        _lastAnswerCorrect = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showCompletion) {
      return CompletionScreen(
        learnerName: widget.store.learnerName,
        xpEarned: _xpEarned,
        streakDays: widget.store.streakDays,
        onHome: widget.onComplete,
        isReview: widget.isReview,
      );
    }

    final question = widget.questions[_currentIndex];
    final total = widget.questions.length;
    final progress = (_currentIndex + 1) / total;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FloatingPetalsBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context, progress),
              _buildFeedbackBanner(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.08, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: KeyedSubtree(
                          key: ValueKey<int>(_currentIndex),
                          child: _buildQuestionWidget(question),
                        ),
                      ),
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

  Widget _buildTopBar(BuildContext context, double progress) {
    final theme = Theme.of(context);
    final streakDays = widget.store.streakDays;
    final totalXp = widget.store.totalXp + _xpEarned;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Orqaga qaytish
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),

              const SizedBox(width: 10),

              // Progress bar
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 10,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Savol raqami
              Text(
                '${_currentIndex + 1}/${widget.questions.length}',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // XP va Streak row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Streak
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      '$streakDays kun',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // XP counter
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child:
                    Container(
                          key: ValueKey<int>(totalXp),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amber.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('⚡', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 4),
                              Text(
                                '$totalXp XP',
                                style: TextStyle(
                                  color: Colors.amber.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate(
                          onPlay: (ctrl) {
                            // Har yangi XP qo'shilganda bounce
                          },
                        )
                        .scale(
                          duration: 300.ms,
                          curve: Curves.elasticOut,
                          begin: const Offset(1, 1),
                          end: const Offset(1.15, 1.15),
                        )
                        .then()
                        .scale(
                          duration: 150.ms,
                          begin: const Offset(1.15, 1.15),
                          end: const Offset(1, 1),
                        ),
              ),
            ],
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFeedbackBanner(BuildContext context) {
    if (_lastAnswerCorrect == null) return const SizedBox.shrink();

    final isCorrect = _lastAnswerCorrect!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isCorrect
                  ? (isDark
                      ? [const Color(0xFF133827), const Color(0xFF1B4E37)]
                      : [const Color(0xFFE8F8F0), const Color(0xFFD1F2E0)])
                  : (isDark
                      ? [const Color(0xFF4A1E24), const Color(0xFF5C252D)]
                      : [const Color(0xFFFFECEF), const Color(0xFFFFD9DF)]),
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isCorrect ? const Color(0xFF10B981) : Colors.red.shade400,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isCorrect ? Colors.green : Colors.red).withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                isCorrect ? '🎉' : '🌱',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isCorrect ? 'Ajoyib! ⭐' : 'Sal qoldi! 🌱',
                      style: TextStyle(
                        color: isCorrect
                            ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46))
                            : (isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B)),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      isCorrect
                          ? 'Barakalla, Malikam! +20 XP qo‘shildi ✨'
                          : 'Xavotir olmang, azizam. Qaytadan urinib ko‘ring 💖',
                      style: TextStyle(
                        color: isCorrect
                            ? (isDark ? const Color(0xFFA7F3D0) : const Color(0xFF047857))
                            : (isDark ? const Color(0xFFFECACA) : const Color(0xFFB91C1C)),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(key: ValueKey<bool?>(isCorrect))
        .fadeIn(duration: 250.ms)
        .slideY(begin: -0.1, end: 0, curve: Curves.easeOutBack);
  }

  Widget _buildQuestionWidget(Question question) {
    switch (question.type) {
      case QuestionType.mcq:
        return McqQuestion(question: question, onAnswer: _handleAnswer);
      case QuestionType.flashcard:
        return FlashcardQuestion(question: question, onAnswer: _handleAnswer);
      case QuestionType.typeAnswer:
        return _TypeAnswerQuestion(question: question, onAnswer: _handleAnswer);
    }
  }
}

// TypeAnswer widget — ichki (kichik bo'lishi mumkin)
class _TypeAnswerQuestion extends StatefulWidget {
  const _TypeAnswerQuestion({required this.question, required this.onAnswer});

  final Question question;
  final void Function(bool isCorrect) onAnswer;

  @override
  State<_TypeAnswerQuestion> createState() => _TypeAnswerQuestionState();
}

class _TypeAnswerQuestionState extends State<_TypeAnswerQuestion> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _submitted = false;
  bool? _isCorrect;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (_submitted) return;
    final input = _controller.text.trim().toLowerCase();
    final correct = widget.question.correctAnswer.trim().toLowerCase();
    final isCorrect = input == correct;
    setState(() {
      _submitted = true;
      _isCorrect = isCorrect;
    });
    widget.onAnswer(isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Arab so'zi
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE7F6),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Text(
                widget.question.arabic,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 56,
                  color: Color(0xFF4527A0),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => AudioService.instance.speak(widget.question.arabic),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD1C4E9),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.volume_up_rounded,
                        size: 18,
                        color: Color(0xFF7E57C2),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '[ ${widget.question.transliteration} ]',
                          style: TextStyle(
                            color: Colors.deepPurple.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0),

        const SizedBox(height: 16),

        Text(
          'O\'zbekcha ma\'nosini yozing:',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isCorrect == null
                    ? theme.colorScheme.outline
                    : _isCorrect!
                    ? Colors.green
                    : Colors.red,
                width: 2,
              ),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: !_submitted,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Javobingiz...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: FilledButton(
            onPressed: _submitted ? null : _submit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Tekshirish',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        if (_submitted && _isCorrect != null) ...[
          const SizedBox(height: 12),
          if (!_isCorrect!)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Text(
                      'To\'g\'ri: ${widget.question.correctAnswer}',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}
